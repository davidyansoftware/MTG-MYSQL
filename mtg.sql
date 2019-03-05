DROP DATABASE IF EXISTS mtg;

CREATE DATABASE mtg;

CREATE TABLE mtg.sets (
    `id` INT NOT NULL AUTO_INCREMENT,

    `name` VARCHAR(50),
    `code` VARCHAR(6),
    `mtgoCode` VARCHAR(6),

    `block` VARCHAR(50),
    `releaseDate` DATE,
    `type` VARCHAR(25),

    `baseSetSize` SMALLINT,
    `totalSetSize` SMALLINT,

    `isFoilOnly` BOOLEAN,
    `isOnlineOnly` BOOLEAN,

    PRIMARY KEY (`id`)
);

CREATE TABLE mtg.cards (
    `setId` INT NOT NULL REFERENCES mtg.sets(`id`),
    `number` VARCHAR(10),
    `rulesId` INT NOT NULL REFERENCES mtg.rules(`id`),

    `flavorText` VARCHAR(100),
    `artist` VARCHAR(100)
);

CREATE TABLE mtg.rules (

    /* TODO use max to determine limits of these varchars */

    /* need primary key that isnt name for unstable mixed cards */
    `id` INT NOT NULL AUTO_INCREMENT,

    `convertedManaCost` FLOAT,
    `manaCost` VARCHAR(46), /* B.F.M (may want to trim {} symbols} */
    `text` VARCHAR(800),

    `power` VARCHAR(4),
    `toughness` VARCHAR(4),
    `loyalty` VARCHAR(5),

    PRIMARY KEY (`id`)
);
/* tables below to handle variable length fields */
CREATE TABLE mtg.names (
    `rulesId` INT NOT NULL REFERENCES mtg.rules(`id`),
    `name` VARCHAR(150)
);
CREATE TABLE mtg.colors (
    `rulesId` INT NOT NULL REFERENCES mtg.rules(`id`),
    `color` VARCHAR(1)
);
CREATE TABLE mtg.supertypes (
    `rulesId` INT NOT NULL REFERENCES mtg.rules(`id`),
    `supertype` VARCHAR(50)
);
CREATE TABLE mtg.types (
    `rulesId` INT NOT NULL REFERENCES mtg.rules(`id`),
    `type` VARCHAR(50)
);
CREATE TABLE mtg.subtypes (
    `rulesId` INT NOT NULL REFERENCES mtg.rules(`id`),
    `subtype` VARCHAR(50)
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

