DROP DATABASE IF EXISTS mtg;

CREATE DATABASE mtg;

/*
CREATE TABLE mtg.sets (
    `code` VARCHAR(6),
    `name` VARCHAR(50),

    PRIMARY KEY (`code`)
    `mtgoCode` VARCHAR(6),
    `size` SMALLINT,
    `block` VARCHAR(50),
    `onlineOnly` BOOLEAN,
    `releaseDate` DATE,
    `type` VARCHAR(25)
);
*/

CREATE TABLE mtg.names (
  `id` INT NOT NULL REFERENCES mtg.rules(`id`),
  `name` VARCHAR(150)
);

CREATE TABLE mtg.colors (
  `id` INT NOT NULL REFERENCES mtg.rules(`id`),
  `color` VARCHAR(1)
);

CREATE TABLE mtg.supertypes (
    `id` INT NOT NULL REFERENCES mtg.rules(`id`),
    `supertype` VARCHAR(50)
);

CREATE TABLE mtg.types (
    `id` INT NOT NULL REFERENCES mtg.rules(`id`),
    `type` VARCHAR(50)
);

CREATE TABLE mtg.subtypes (
    `id` INT NOT NULL REFERENCES mtg.rules(`id`),
    `subtype` VARCHAR(50)
);

CREATE TABLE mtg.rules (

    /* TODO use max to determine limits of these varchars */

    /* need primary key that isnt name for unstable mixed cards */
    /* `uuid` VARCHAR(36) NOT NULL, */

    `id` INT NOT NULL AUTO_INCREMENT,

    `convertedManaCost` FLOAT,
    `manaCost` VARCHAR(46), /* B.F.M (may want to trim {} symbols} */
    `text` VARCHAR(800),

    `power` VARCHAR(4),
    `toughness` VARCHAR(4),
    `loyalty` VARCHAR(5),

    /*

    `set` VARCHAR(6) NOT NULL REFERENCES mtg.sets(`code`),
    `number` VARCHAR(20),

    
    `name` VARCHAR(150) NOT NULL,
    `names` VARCHAR(167), /* Knight of the Kitchen Sink *

    `colors` VARCHAR(5),
    `colorIdentity` VARCHAR(5),
    `type` VARCHAR(50),

    `rarity` VARCHAR(10),
    `hasFoil` BOOLEAN,
    `isReserved` BOOLEAN,
    */

    /* legality? */

    PRIMARY KEY (`id`)
);
/*
CREATE TABLE mtg.versions (
    nameset VARCHAR(100),
    name VARCHAR(100) NOT NULL,
    code VARCHAR(3),
    rarity VARCHAR(10),
    flavor VARCHAR(100),
    artist VARCHAR(100),
    number VARCHAR(100),
    multiverseid VARCHAR(100),
    /* link to image???
    FOREIGN KEY (name) REFERENCES mtg.cards(name),
    /* FOREIGN KEY (code) REFERENCES mtg.sets(code)
    PRIMARY KEY (nameset)
);
*/

/*
CREATE TABLE mtg.sets (

);
*/
