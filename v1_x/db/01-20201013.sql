CREATE TABLE livres_motscles_lien (
  code INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  livre_code INTEGER NOT NULL,
  motcle_code INTEGER NOT NULL
);

CREATE TABLE auteurs_description (
  code INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  id CHAR(10) NOT NULL DEFAULT 0000000000,
  auteur_code INTEGER NOT NULL,
  langue_code INTEGER NOT NULL,
  description TEXT NOT NULL
);

CREATE TABLE livres_editeurs_lien (
  code INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  livre_code INTEGER NOT NULL,
  editeur_code INTEGER NOT NULL
);

CREATE TABLE motscles (
  code INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  id CHAR(10) NOT NULL DEFAULT 0000000000,
  libelle VARCHAR(255) NOT NULL,
  nom_page VARCHAR(255) NOT NULL,
  a_generer BIT NOT NULL DEFAULT 1
);

CREATE TABLE livres_auteurs_lien (
  code INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  livre_code INTEGER NOT NULL,
  auteur_code INTEGER NOT NULL
);

CREATE TABLE lecteurs (
  code INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  id CHAR(10) NOT NULL DEFAULT 0000000000,
  pseudo VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL,
  url_site VARCHAR(255) NOT NULL,
  verifie BIT NOT NULL DEFAULT 0,
  actif BIT NOT NULL DEFAULT 0,
  bloque BIT NOT NULL DEFAULT 0,
  nom_page VARCHAR(255) NOT NULL,
  a_generer BIT NOT NULL DEFAULT 1
);

CREATE TABLE livres_commentaires (
  code INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  id CHAR(10) NOT NULL DEFAULT 0000000000,
  livre_code INTEGER NOT NULL,
  lecteur_code INTEGER NOT NULL,
  langue_code INTEGER NOT NULL,
  dateducommentaire CHAR(8) NOT NULL DEFAULT 00000000,
  a_moderer BIT NOT NULL DEFAULT 1,
  valide BIT NOT NULL DEFAULT 0,
  commentaire TEXT NOT NULL
);

CREATE TABLE livres_tabledesmatieres (
  code INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  id CHAR(10) NOT NULL DEFAULT 0000000000,
  livre_code INTEGER NOT NULL,
  langue_code INTEGER NOT NULL,
  tabledesmatieres TEXT NOT NULL
);

CREATE TABLE livres_description (
  code INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  id CHAR(10) NOT NULL DEFAULT 0000000000,
  livre_code INTEGER NOT NULL,
  langue_code INTEGER NOT NULL,
  description TEXT NOT NULL
);

CREATE TABLE editeurs_description (
  code INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  id CHAR(10) NOT NULL DEFAULT 0000000000,
  editeur_code INTEGER NOT NULL,
  langue_code INTEGER NOT NULL,
  description TEXT NOT NULL
);

CREATE TABLE langues (
  code INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  id CHAR(10) NOT NULL DEFAULT 0000000000,
  libelle VARCHAR(255) NOT NULL,
  code_iso VARCHAR(5) NOT NULL,
  nom_page VARCHAR(255) NOT NULL,
  a_generer BIT NOT NULL DEFAULT 1
);

CREATE TABLE editeurs (
  code INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  id CHAR(10) NOT NULL DEFAULT 0000000000,
  raison_sociale VARCHAR(255) NOT NULL,
  url_site VARCHAR(255) NOT NULL,
  nom_page VARCHAR(255) NOT NULL,
  a_generer BIT NOT NULL DEFAULT 1
);

CREATE TABLE auteurs (
  code INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  id CHAR(10) NOT NULL DEFAULT 0000000000,
  nom VARCHAR(255) NOT NULL,
  prenom VARCHAR(255) NOT NULL,
  pseudo VARCHAR(255) NOT NULL,
  url_site VARCHAR(255) NOT NULL,
  nom_page VARCHAR(255) NOT NULL,
  a_generer BIT NOT NULL DEFAULT 1
);

CREATE TABLE livres (
  code INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  id CHAR(10) NOT NULL DEFAULT 0000000000,
  titre VARCHAR(255) NOT NULL,
  isbn10 CHAR(10) NOT NULL DEFAULT 0000000000,
  gencod CHAR(13) NOT NULL DEFAULT 0000000000000,
  langue_code INTEGER NOT NULL DEFAULT 0,
  datedesortie CHAR(8) NOT NULL DEFAULT 00000000,
  url_site VARCHAR(255) NOT NULL,
  nom_page VARCHAR(255) NOT NULL,
  a_generer BIT NOT NULL DEFAULT 1
);

CREATE INDEX tabledesmatieres_par_livre_langue ON livres_tabledesmatieres
  (livre_code,langue_code,code);

CREATE INDEX livres_par_datedesortie ON livres
  (datedesortie,titre,code);

CREATE INDEX livres_par_titres ON livres
  (titre,code);

CREATE INDEX tabledesmatieres_par_langue_livre ON livres_tabledesmatieres
  (langue_code,livre_code,code);

CREATE INDEX livres_a_generer ON livres
  (a_generer,code);

CREATE INDEX description_par_livre_langue ON livres_description
  (livre_code,langue_code,code);

CREATE INDEX description_par_langue_editeur ON editeurs_description
  (langue_code,editeur_code,code);

CREATE INDEX description_par_editeur_langue ON editeurs_description
  (editeur_code,langue_code,code);

CREATE INDEX commentaires_a_moderer_par_livre ON livres_commentaires
  (a_moderer,livre_code,lecteur_code,langue_code,code);

CREATE INDEX commentaires_a_moderer_par_lecteur ON livres_commentaires
  (a_moderer,lecteur_code,livre_code,langue_code,code);

CREATE INDEX commentaires_par_lecteur ON livres_commentaires
  (valide,lecteur_code,dateducommentaire,livre_code,langue_code,code);

CREATE INDEX commentaires_par_livre ON livres_commentaires
  (valide,livre_code,langue_code,dateducommentaire,lecteur_code,code);

CREATE INDEX lecteurs_actifs ON lecteurs
  (actif,bloque,pseudo,code);

CREATE INDEX lecteurs_par_pseudo ON lecteurs
  (pseudo,code);

CREATE INDEX langues_par_libelle ON langues
  (libelle,code);

CREATE INDEX lecteurs_a_generer ON lecteurs
  (a_generer,actif,bloque,code);

CREATE INDEX editeurs_a_generer ON editeurs
  (a_generer,code);

CREATE INDEX lien_auteur_livre ON livres_auteurs_lien
  (auteur_code,livre_code);

CREATE INDEX lien_editeur_livre ON livres_editeurs_lien
  (editeur_code,livre_code);

CREATE INDEX lien_livre_editeur ON livres_editeurs_lien
  (livre_code,editeur_code);

CREATE INDEX motscles_a_generer ON motscles
  (a_generer,code);

CREATE INDEX motscles_par_libelle ON motscles
  (libelle,code);

CREATE INDEX lien_livre_auteur ON livres_auteurs_lien
  (livre_code,auteur_code);

CREATE INDEX editeurs_par_raisonsociale ON editeurs
  (raison_sociale,code);

CREATE INDEX description_par_langue_auteur ON auteurs_description
  (langue_code,auteur_code,code);

CREATE INDEX description_par_auteur_langue ON auteurs_description
  (auteur_code,langue_code,code);

CREATE INDEX description_par_langue_livre ON livres_description
  (langue_code,livre_code,code);

CREATE INDEX langues_a_generer ON langues
  (a_generer,code);

CREATE INDEX lien_livre_motcle ON livres_motscles_lien
  (livre_code,motcle_code);

CREATE INDEX auteurs_a_generer ON auteurs
  (a_generer,code);

CREATE INDEX auteurs_par_nom ON auteurs
  (nom,prenom,pseudo,code);

CREATE INDEX lien_motcle_livre ON livres_motscles_lien
  (motcle_code,livre_code);
