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

my $cardExists = $dbh->prepare("select exists(select * from names where name = ?)");

#TODO ignore tokens
#my $insertSet = $dbh->prepare("insert into sets values (?, ?)"); #, ?, ?, ?, ?, ?, ?)");
my $insertRules = $dbh->prepare("insert into rules (convertedManaCost, manaCost, text, power, toughness, loyalty) values (?, ?, ?, ?, ?, ?)");
my $insertNames = $dbh->prepare("insert into names values (?, ?)");
my $insertColors = $dbh->prepare("insert into colors values (?, ?)");
my $insertSupertype = $dbh->prepare("insert into supertypes values (?, ?)");
my $insertType = $dbh->prepare("insert into types values (?, ?)");
my $insertSubtype = $dbh->prepare("insert into subtypes values (?, ?)");

foreach my $set (keys %{$sethash}) {
    my %set = %{$sethash->{$set}};

    print "$set{name}\n";

    my $cardhash = $set{cards};

    foreach my $card (@{$cardhash}) {
        my %card = %{$card};

        $cardExists->execute($card{name});
        my ($exists) = $cardExists->fetchrow_array();
        next if $exists;

        $insertRules->execute(
            $card{convertedManaCost},
            $card{manaCost},
            $card{text},
            $card{power},
            $card{toughness},
            $card{loyalty},
        ) or print "Can't execute $card{name} $card{names}\n";

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
    }
}
$cardExists->finish();
#$insertSet->finish();
$insertRules->finish();
$insertNames->finish();
$insertColors->finish();
$insertSupertype->finish();
$insertType->finish();
$insertSubtype->finish();

$dbh->disconnect;
