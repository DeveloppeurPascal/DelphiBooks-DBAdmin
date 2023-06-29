# 20230629 - [DeveloppeurPascal](https://github.com/DeveloppeurPascal)

* removed the empty "btnSynchroDBClick" onClick event from Admin v1.x program (will not be coded)
* added a button in the menu to export from old SQLite DB to new repository DB
* added authors export to new repository DB
* added publishers export to new repository DB
* added books export to new repository DB
* added books-authors export to new repository DB
* added books-publishers export to new repository DB
* added export for books covers

## SQLite fields in each table concerned by the export (for documentation and archives)

* export table langues (pour les traductions du site + pour les choix de langue dans les livres)

CREATE TABLE langues (
  libelle VARCHAR(255) NOT NULL,
  code_iso VARCHAR(5) NOT NULL,
  nom_page VARCHAR(255) NOT NULL,
);

* export auteurs + leur description

CREATE TABLE auteurs (
  code INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  nom VARCHAR(255) NOT NULL,
  prenom VARCHAR(255) NOT NULL,
  pseudo VARCHAR(255) NOT NULL,
  url_site VARCHAR(255) NOT NULL,
  nom_page VARCHAR(255) NOT NULL,
);
CREATE TABLE auteurs_description (
  auteur_code INTEGER NOT NULL,
  langue_code INTEGER NOT NULL,
  description TEXT NOT NULL
);

* export éditeurs + leur description

CREATE TABLE editeurs (
  code INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  raison_sociale VARCHAR(255) NOT NULL,
  url_site VARCHAR(255) NOT NULL,
  nom_page VARCHAR(255) NOT NULL,
);
CREATE TABLE editeurs_description (
  editeur_code INTEGER NOT NULL,
  langue_code INTEGER NOT NULL,
  description TEXT NOT NULL
);

* export livres + tables externes sous forme de liste

CREATE TABLE livres (
  code INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  titre VARCHAR(255) NOT NULL,
  isbn10 CHAR(10) NOT NULL DEFAULT 0000000000,
  gencod CHAR(13) NOT NULL DEFAULT 0000000000000,
  langue_code INTEGER NOT NULL DEFAULT 0,
  datedesortie CHAR(8) NOT NULL DEFAULT 00000000,
  url_site VARCHAR(255) NOT NULL,
  nom_page VARCHAR(255) NOT NULL,
);
CREATE TABLE livres_description (
  livre_code INTEGER NOT NULL,
  langue_code INTEGER NOT NULL,
  description TEXT NOT NULL
);
CREATE TABLE livres_tabledesmatieres (
  livre_code INTEGER NOT NULL,
  langue_code INTEGER NOT NULL,
  tabledesmatieres TEXT NOT NULL
);

* export books of authors and authors of books

CREATE TABLE livres_auteurs_lien (
  livre_code INTEGER NOT NULL,
  auteur_code INTEGER NOT NULL
);

* export books of publishers and publishers of books

CREATE TABLE livres_editeurs_lien (
  livre_code INTEGER NOT NULL,
  editeur_code INTEGER NOT NULL
);
