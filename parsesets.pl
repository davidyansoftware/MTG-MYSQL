use strict;

use DBI;
use JSON;
use Data::Dumper;

sub prompt {
    my ($prompt, $default) = @_;

    $prompt .= "($default)" if ($default);
    $prompt .= ": ";
    print $prompt;

    my $value = <STDIN>;
    $value = chomp $value;
    $value = $value || $default;

    return $value;
}

sub promptPassword {
    my ($prompt) = @_;
    $prompt .= ": ";
    print $prompt;

    `stty -echo`;
    my $password = <STDIN>;
    `stty echo`;
    print "\n";

    chomp $password;
    return $password;
}

sub dbConnect {
    my $host = &prompt("host","localhost");
    my $username = &prompt("username","root");
    my $password = &promptPassword("password");
    my $dbh = DBI->connect("DBI:mysql:mtg:$host", $username, $password) or die ("Could not connect to database");

    return $dbh;
}

my $dbh = &dbConnect();

my $filename = $ARGV[0];

print "READING FROM FILE\n";
my $json;
{
    local $/;

    open FILE, $filename;
    $json = <FILE>;
    close FILE;
}

print "DECODING FILE\n";
my $sethash = decode_json($json);

print "ADDING CARDS TO DATABASE\n";

my $rulesExist = $dbh->prepare("select id from names join rules on names.rulesId = rules.id where name = ? and text = ?");

#TODO ignore tokens
my $insertSet = $dbh->prepare("insert into sets (name, code, mtgoCode, block, releaseDate, type, baseSetSize, totalSetSize, isFoilOnly, isOnlineOnly) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");

# extra tables are used when there are a variable number of those fields per card
my $insertRules = $dbh->prepare("insert into rules (convertedManaCost, manaCost, text, power, toughness, loyalty) values (?, ?, ?, ?, ?, ?)");
my $insertNames = $dbh->prepare("insert into names values (?, ?)");
my $insertColors = $dbh->prepare("insert into colors values (?, ?)");
my $insertSupertype = $dbh->prepare("insert into supertypes values (?, ?)");
my $insertType = $dbh->prepare("insert into types values (?, ?)");
my $insertSubtype = $dbh->prepare("insert into subtypes values (?, ?)");

my $insertCard = $dbh->prepare("insert into cards(setId, number, rulesId, flavorText, artist) values (?, ?, ?, ?, ?)");

foreach my $set (keys %{$sethash}) {
    my %set = %{$sethash->{$set}};

    print "$set{name}\n";

    $insertSet->execute(
        $set{name},
        $set{code},
        $set{mtgoCode},
        $set{block},
        $set{releaseDate},
        $set{type},
        $set{baseSetSize},
        $set{totalSetSize},
        $set{isFoilOnly},
        $set{isOnlineOnly},
    ) or print "Cant's execute $set{name}\n";
    my $setId = $insertSet->{'mysql_insertid'};

    my $cardhash = $set{cards};
    foreach my $card (@{$cardhash}) {

        my $rulesId = &insertRules($card);

        $insertCard->execute(
            $setId,
            $card->{number},
            $rulesId,
            $card->{flavorText},
            $card->{artist}
        );
    }
}
$rulesExist->finish();
$insertSet->finish();
$insertRules->finish();
$insertNames->finish();
$insertColors->finish();
$insertSupertype->finish();
$insertType->finish();
$insertSubtype->finish();
$insertCard->finish();

$dbh->disconnect();

sub insertRules {
    my ($card) = @_;

    my %card = %{$card};    

    $rulesExist->execute($card{name}, $card{text});
    my ($rulesId) = $rulesExist->fetchrow_array();
    return $rulesId if $rulesId;

    $insertRules->execute(
        $card{convertedManaCost},
        $card{manaCost},
        $card{text},
        $card{power},
        $card{toughness},
        $card{loyalty},
    ) or print "Can't execute $card{name}\n";
    my $id = $insertRules->{'mysql_insertid'};        

    my %names = ( $card{name} => 1 );
    foreach my $name (@{$card{names}}) {
        $names{$name} = 1;
    }
    foreach my $name (keys %names) {
        $insertNames->execute($id, $name) or print "Can't execute $card{name} $name";
    }

    foreach my $color (@{$card{colors}}) {
        $insertColors->execute($id, $color) or print "Can't execute $card{color} $color";
    }

    foreach my $supertype (@{$card{supertypes}}) {
        $insertSupertype->execute($id, $supertype) or print "Can't execute $card{name} $supertype\n";
    }

    foreach my $type (@{$card{types}}) {
        $insertType->execute($id, $type) or print "Can't execute $card{name} $type\n";
    }

    foreach my $subtype (@{$card{subtypes}}) {
        $insertSubtype->execute($id, $subtype) or print "Can't execute $card{name} $subtype\n";
    }

    return $id;
}
