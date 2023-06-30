# 20230630 - [DeveloppeurPascal](https://github.com/DeveloppeurPascal)

* added languages export to new repository DB

## SQLite fields in each table concerned by the export (for documentation and archives)

* export table langues (pour les traductions du site + pour les choix de langue dans les livres)

CREATE TABLE langues (
  libelle VARCHAR(255) NOT NULL,
  code_iso VARCHAR(5) NOT NULL,
  nom_page VARCHAR(255) NOT NULL,
);
