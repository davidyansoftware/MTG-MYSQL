# MTG MySQL DB

Converts a database of Magic: the Gathering cards from JSON to a normalized MySQL database for easy searching and processing. The Schema is designed to handle variable number of some values, and reduce redundancy (see below).

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

### Get data file

The json data can be downloaded from https://mtgjson.com

```
wget https://mtgjson.com/json/AllSets.json
```

Download a local copy to pass to your scripts

### Prerequisites

The json file is pulled from https://mtgjson.com

MySQL - the database to store the data on cards

Perl 5 - for parsing JSON and writing to the MySQL table

A few perl libraries are also needed. These can be installed with CPAN

JSON - for json parsing

DBI - for interacting with the mysql database

```
cpan install JSON
cpan install DBI
```

### Running

Set up the MySQL schema by running the sql script in your MySQL environment.

```
mysql -u <username> -p < mtg.sql
```

Populate the mysql database with perl script. This can be run on a different system from where the MySQL, or the same.

```
perl parsecards.pl AllSets.json
```

This will prompt you for:

host_name (default: localhost)

username (default: root)

password

MTG has a long list of cards, and processing this data can time intensive depending on hardware.

### Usage

The schema gives as much flexibility as possible to searches. Here are some examples of how to use it.

Find the colors of "Psychatog":

```
mysql> select color from colors join names on colors.rulesId = names.rulesId where name = "Psychatog";
+-------+
| color |
+-------+
| B     |
| U     |
+-------+
```

Find the power/toughness of "Serra Angel":

```
mysql> select power, toughness from rules join names on rules.id = names.rulesId where name = "Serra Angel";
+-------+-----------+
| power | toughness |
+-------+-----------+
| 4     | 4         |
+-------+-----------+
```

Find 10 cards with CMC 3:

```
mysql> select name from names join rules on names.rulesId = rules.id where convertedManaCost = 3 limit 10;
+--------------------+
| name               |
+--------------------+
| Haazda Snare Squad |
| Riot Control       |
| Uncovered Clues    |
| Wind Drake         |
| Crypt Incursion    |
| Hired Torturer     |
| Rakdos Drake       |
| Awe for the Guilds |
| Pyrewild Shaman    |
| Battering Krasis   |
+--------------------+
```

Number of times Llanowar Elves has been reprinted:

```
mysql> select count(*) from cards join names on cards.rulesId = names.rulesId where name = "Llanowar Elves";
+----------+
| count(*) |
+----------+
|       41 |
+----------+
```

## Schema

This schema was designed to handle cards that have a variable number of entries per field. For example, some cards have a single color, some have many. By storing these in a separate table and referencing the card via id, I can denote any number of colors for a card, without depending on empty columns. This applies to name, color, type, subtype, and supertype. The name table is a special case where some cards have multiple names (split, double-faced). This allows you to query the database with any of the valid names to find the results.

### Tables

Check mtg.sql to see up-to-date fields for the following tables.

Cards - a sort of intersect table between sets and rules. This describes the physical printing of a card, including artist and rarity.

Sets - describes the set a card can be released in, along with some release information

Rules - describes rules information for a given card. Addtional, variable length information is stored in associated tables:

Names - names of the cards. Maybe have multiples in case of split/doublefaced

Colors - each color of the card, described by a char

Types/Supertypes/Subtypes - a listing of each type associated with the card

### Normalization

The schema is normalized to remove redundancy and improve data integrety. This assures that each piece of information has a single authoritative source, and isn't being duplicated at different points in the table. For example, cards are often printed multiple times through different sets. By keeping track of a set of rules via an id, we can reference the same set of rules (and associated names) even across different sets.

First Normal Form (1NF) - requires the values in each column of a table are atomic. This is achieved by creating additional tables to store variable length sets of information (ex: a card can have any number of subtypes, so subtypes is pulled into its own table with a many-to-one relationship with rules entries).

Second Normal Form (2NF) - requires all non-key attributes be dependent on the whole key. This is seen in the seperation of rules and card printings. All rules information are dependant on the rulesId, and printed cards simply reference the rulesId.

Third Normal Form (3NF) - requires that there are no transitive dependencies. This is different from 2NF in that each non-key attribute can ONLY depend on the candidate key.
