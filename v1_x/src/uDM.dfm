object dmBaseDeDonnees: TdmBaseDeDonnees
  OnCreate = DataModuleCreate
  Height = 595
  Width = 982
  object FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink
    Left = 520
    Top = 96
  end
  object db: TFDConnection
    Params.Strings = (
      
        'Database=C:\Users\olfso\Documents\Embarcadero\Studio\Projets\Del' +
        'phiBooksAdmin\src-DelphiBooksAdmin\db_dev.db'
      'LockingMode=Normal'
      'DriverID=SQLite')
    LoginPrompt = False
    AfterConnect = dbAfterConnect
    BeforeConnect = dbBeforeConnect
    Left = 40
    Top = 24
  end
  object dbScriptMajDatabase: TFDScript
    SQLScripts = <
      item
        Name = '01'
        SQL.Strings = (
          'CREATE TABLE livres_motscles_lien ('
          '  code INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,'
          '  livre_code INTEGER NOT NULL,'
          '  motcle_code INTEGER NOT NULL'
          ');'
          ''
          'CREATE TABLE auteurs_description ('
          '  code INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,'
          '  id CHAR(10) NOT NULL DEFAULT 0000000000,'
          '  auteur_code INTEGER NOT NULL,'
          '  langue_code INTEGER NOT NULL,'
          '  description TEXT NOT NULL'
          ');'
          ''
          'CREATE TABLE livres_editeurs_lien ('
          '  code INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,'
          '  livre_code INTEGER NOT NULL,'
          '  editeur_code INTEGER NOT NULL'
          ');'
          ''
          'CREATE TABLE motscles ('
          '  code INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,'
          '  id CHAR(10) NOT NULL DEFAULT 0000000000,'
          '  libelle VARCHAR(255) NOT NULL,'
          '  nom_page VARCHAR(255) NOT NULL,'
          '  a_generer BIT NOT NULL DEFAULT 1'
          ');'
          ''
          'CREATE TABLE livres_auteurs_lien ('
          '  code INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,'
          '  livre_code INTEGER NOT NULL,'
          '  auteur_code INTEGER NOT NULL'
          ');'
          ''
          'CREATE TABLE lecteurs ('
          '  code INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,'
          '  id CHAR(10) NOT NULL DEFAULT 0000000000,'
          '  pseudo VARCHAR(255) NOT NULL,'
          '  email VARCHAR(255) NOT NULL,'
          '  url_site VARCHAR(255) NOT NULL,'
          '  verifie BIT NOT NULL DEFAULT 0,'
          '  actif BIT NOT NULL DEFAULT 0,'
          '  bloque BIT NOT NULL DEFAULT 0,'
          '  nom_page VARCHAR(255) NOT NULL,'
          '  a_generer BIT NOT NULL DEFAULT 1'
          ');'
          ''
          'CREATE TABLE livres_commentaires ('
          '  code INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,'
          '  id CHAR(10) NOT NULL DEFAULT 0000000000,'
          '  livre_code INTEGER NOT NULL,'
          '  lecteur_code INTEGER NOT NULL,'
          '  langue_code INTEGER NOT NULL,'
          '  dateducommentaire CHAR(8) NOT NULL DEFAULT 00000000,'
          '  a_moderer BIT NOT NULL DEFAULT 1,'
          '  valide BIT NOT NULL DEFAULT 0,'
          '  commentaire TEXT NOT NULL'
          ');'
          ''
          'CREATE TABLE livres_tabledesmatieres ('
          '  code INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,'
          '  id CHAR(10) NOT NULL DEFAULT 0000000000,'
          '  livre_code INTEGER NOT NULL,'
          '  langue_code INTEGER NOT NULL,'
          '  tabledesmatieres TEXT NOT NULL'
          ');'
          ''
          'CREATE TABLE livres_description ('
          '  code INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,'
          '  id CHAR(10) NOT NULL DEFAULT 0000000000,'
          '  livre_code INTEGER NOT NULL,'
          '  langue_code INTEGER NOT NULL,'
          '  description TEXT NOT NULL'
          ');'
          ''
          'CREATE TABLE editeurs_description ('
          '  code INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,'
          '  id CHAR(10) NOT NULL DEFAULT 0000000000,'
          '  editeur_code INTEGER NOT NULL,'
          '  langue_code INTEGER NOT NULL,'
          '  description TEXT NOT NULL'
          ');'
          ''
          'CREATE TABLE langues ('
          '  code INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,'
          '  id CHAR(10) NOT NULL DEFAULT 0000000000,'
          '  libelle VARCHAR(255) NOT NULL,'
          '  code_iso VARCHAR(5) NOT NULL,'
          '  nom_page VARCHAR(255) NOT NULL,'
          '  a_generer BIT NOT NULL DEFAULT 1'
          ');'
          ''
          'CREATE TABLE editeurs ('
          '  code INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,'
          '  id CHAR(10) NOT NULL DEFAULT 0000000000,'
          '  raison_sociale VARCHAR(255) NOT NULL,'
          '  url_site VARCHAR(255) NOT NULL,'
          '  nom_page VARCHAR(255) NOT NULL,'
          '  a_generer BIT NOT NULL DEFAULT 1'
          ');'
          ''
          'CREATE TABLE auteurs ('
          '  code INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,'
          '  id CHAR(10) NOT NULL DEFAULT 0000000000,'
          '  nom VARCHAR(255) NOT NULL,'
          '  prenom VARCHAR(255) NOT NULL,'
          '  pseudo VARCHAR(255) NOT NULL,'
          '  url_site VARCHAR(255) NOT NULL,'
          '  nom_page VARCHAR(255) NOT NULL,'
          '  a_generer BIT NOT NULL DEFAULT 1'
          ');'
          ''
          'CREATE TABLE livres ('
          '  code INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,'
          '  id CHAR(10) NOT NULL DEFAULT 0000000000,'
          '  titre VARCHAR(255) NOT NULL,'
          '  isbn10 CHAR(10) NOT NULL DEFAULT 0000000000,'
          '  gencod CHAR(13) NOT NULL DEFAULT 0000000000000,'
          '  langue_code INTEGER NOT NULL DEFAULT 0,'
          '  datedesortie CHAR(8) NOT NULL DEFAULT 00000000,'
          '  url_site VARCHAR(255) NOT NULL,'
          '  nom_page VARCHAR(255) NOT NULL,'
          '  a_generer BIT NOT NULL DEFAULT 1'
          ');'
          ''
          
            'CREATE INDEX tabledesmatieres_par_livre_langue ON livres_tablede' +
            'smatieres'
          '  (livre_code,langue_code,code);'
          ''
          'CREATE INDEX livres_par_datedesortie ON livres'
          '  (datedesortie,titre,code);'
          ''
          'CREATE INDEX livres_par_titres ON livres'
          '  (titre,code);'
          ''
          
            'CREATE INDEX tabledesmatieres_par_langue_livre ON livres_tablede' +
            'smatieres'
          '  (langue_code,livre_code,code);'
          ''
          'CREATE INDEX livres_a_generer ON livres'
          '  (a_generer,code);'
          ''
          'CREATE INDEX description_par_livre_langue ON livres_description'
          '  (livre_code,langue_code,code);'
          ''
          
            'CREATE INDEX description_par_langue_editeur ON editeurs_descript' +
            'ion'
          '  (langue_code,editeur_code,code);'
          ''
          
            'CREATE INDEX description_par_editeur_langue ON editeurs_descript' +
            'ion'
          '  (editeur_code,langue_code,code);'
          ''
          
            'CREATE INDEX commentaires_a_moderer_par_livre ON livres_commenta' +
            'ires'
          '  (a_moderer,livre_code,lecteur_code,langue_code,code);'
          ''
          
            'CREATE INDEX commentaires_a_moderer_par_lecteur ON livres_commen' +
            'taires'
          '  (a_moderer,lecteur_code,livre_code,langue_code,code);'
          ''
          'CREATE INDEX commentaires_par_lecteur ON livres_commentaires'
          
            '  (valide,lecteur_code,dateducommentaire,livre_code,langue_code,' +
            'code);'
          ''
          'CREATE INDEX commentaires_par_livre ON livres_commentaires'
          
            '  (valide,livre_code,langue_code,dateducommentaire,lecteur_code,' +
            'code);'
          ''
          'CREATE INDEX lecteurs_actifs ON lecteurs'
          '  (actif,bloque,pseudo,code);'
          ''
          'CREATE INDEX lecteurs_par_pseudo ON lecteurs'
          '  (pseudo,code);'
          ''
          'CREATE INDEX langues_par_libelle ON langues'
          '  (libelle,code);'
          ''
          'CREATE INDEX lecteurs_a_generer ON lecteurs'
          '  (a_generer,actif,bloque,code);'
          ''
          'CREATE INDEX editeurs_a_generer ON editeurs'
          '  (a_generer,code);'
          ''
          'CREATE INDEX lien_auteur_livre ON livres_auteurs_lien'
          '  (auteur_code,livre_code);'
          ''
          'CREATE INDEX lien_editeur_livre ON livres_editeurs_lien'
          '  (editeur_code,livre_code);'
          ''
          'CREATE INDEX lien_livre_editeur ON livres_editeurs_lien'
          '  (livre_code,editeur_code);'
          ''
          'CREATE INDEX motscles_a_generer ON motscles'
          '  (a_generer,code);'
          ''
          'CREATE INDEX motscles_par_libelle ON motscles'
          '  (libelle,code);'
          ''
          'CREATE INDEX lien_livre_auteur ON livres_auteurs_lien'
          '  (livre_code,auteur_code);'
          ''
          'CREATE INDEX editeurs_par_raisonsociale ON editeurs'
          '  (raison_sociale,code);'
          ''
          
            'CREATE INDEX description_par_langue_auteur ON auteurs_descriptio' +
            'n'
          '  (langue_code,auteur_code,code);'
          ''
          
            'CREATE INDEX description_par_auteur_langue ON auteurs_descriptio' +
            'n'
          '  (auteur_code,langue_code,code);'
          ''
          'CREATE INDEX description_par_langue_livre ON livres_description'
          '  (langue_code,livre_code,code);'
          ''
          'CREATE INDEX langues_a_generer ON langues'
          '  (a_generer,code);'
          ''
          'CREATE INDEX lien_livre_motcle ON livres_motscles_lien'
          '  (livre_code,motcle_code);'
          ''
          'CREATE INDEX auteurs_a_generer ON auteurs'
          '  (a_generer,code);'
          ''
          'CREATE INDEX auteurs_par_nom ON auteurs'
          '  (nom,prenom,pseudo,code);'
          ''
          'CREATE INDEX lien_motcle_livre ON livres_motscles_lien'
          '  (motcle_code,livre_code);')
      end>
    Connection = db
    Params = <>
    Macros = <>
    Left = 120
    Top = 24
  end
  object FDStanStorageJSONLink1: TFDStanStorageJSONLink
    Left = 520
    Top = 24
  end
  object tabEditeursDescription: TFDTable
    BeforePost = tabBeforePost
    BeforeDelete = tabBeforeDelete
    IndexFieldNames = 'code'
    Connection = db
    UpdateOptions.UpdateTableName = 'editeurs_description'
    TableName = 'editeurs_description'
    Left = 160
    Top = 192
  end
  object tabLivresDescription: TFDTable
    BeforePost = tabBeforePost
    BeforeDelete = tabBeforeDelete
    IndexFieldNames = 'code'
    Connection = db
    UpdateOptions.UpdateTableName = 'livres_description'
    TableName = 'livres_description'
    Left = 264
    Top = 400
  end
  object tabEditeurs: TFDTable
    BeforePost = tabBeforePost
    BeforeDelete = tabBeforeDelete
    IndexFieldNames = 'code'
    Connection = db
    UpdateOptions.UpdateTableName = 'editeurs'
    TableName = 'editeurs'
    Left = 48
    Top = 192
  end
  object tabAuteurs: TFDTable
    BeforePost = tabBeforePost
    BeforeDelete = tabBeforeDelete
    IndexFieldNames = 'code'
    Connection = db
    UpdateOptions.UpdateTableName = 'auteurs'
    TableName = 'auteurs'
    Left = 48
    Top = 128
  end
  object tabAuteursDescription: TFDTable
    BeforePost = tabBeforePost
    BeforeDelete = tabBeforeDelete
    IndexFieldNames = 'code'
    Connection = db
    UpdateOptions.UpdateTableName = 'auteurs_description'
    TableName = 'auteurs_description'
    Left = 160
    Top = 128
  end
  object tabLecteurs: TFDTable
    BeforePost = tabBeforePost
    BeforeDelete = tabBeforeDelete
    IndexFieldNames = 'code'
    Connection = db
    UpdateOptions.UpdateTableName = 'lecteurs'
    TableName = 'lecteurs'
    Left = 48
    Top = 336
  end
  object tabLivresAuteursLien: TFDTable
    BeforePost = tabBeforePost
    BeforeDelete = tabBeforeDelete
    IndexFieldNames = 'code'
    Connection = db
    UpdateOptions.UpdateTableName = 'livres_auteurs_lien'
    TableName = 'livres_auteurs_lien'
    Left = 144
    Top = 400
  end
  object tabLivres: TFDTable
    BeforePost = tabBeforePost
    BeforeDelete = tabBeforeDelete
    IndexFieldNames = 'code'
    Connection = db
    UpdateOptions.UpdateTableName = 'livres'
    TableName = 'livres'
    Left = 48
    Top = 400
  end
  object tabLivresEditeursLien: TFDTable
    BeforePost = tabBeforePost
    BeforeDelete = tabBeforeDelete
    IndexFieldNames = 'code'
    Connection = db
    UpdateOptions.UpdateTableName = 'livres_editeurs_lien'
    TableName = 'livres_editeurs_lien'
    Left = 800
    Top = 384
  end
  object tabLivresCommentaires: TFDTable
    BeforePost = tabBeforePost
    BeforeDelete = tabBeforeDelete
    IndexFieldNames = 'code'
    Connection = db
    UpdateOptions.UpdateTableName = 'livres_commentaires'
    TableName = 'livres_commentaires'
    Left = 664
    Top = 384
  end
  object tabLivresMotsClesLien: TFDTable
    BeforePost = tabBeforePost
    BeforeDelete = tabBeforeDelete
    IndexFieldNames = 'code'
    Connection = db
    UpdateOptions.UpdateTableName = 'livres_motscles_lien'
    TableName = 'livres_motscles_lien'
    Left = 392
    Top = 384
  end
  object tabLangues: TFDTable
    BeforePost = tabBeforePost
    BeforeDelete = tabBeforeDelete
    IndexFieldNames = 'code'
    Connection = db
    UpdateOptions.UpdateTableName = 'langues'
    TableName = 'langues'
    Left = 48
    Top = 264
  end
  object tabMotsCles: TFDTable
    BeforePost = tabBeforePost
    BeforeDelete = tabBeforeDelete
    IndexFieldNames = 'code'
    Connection = db
    UpdateOptions.UpdateTableName = 'motscles'
    TableName = 'motscles'
    Left = 40
    Top = 472
  end
  object tabLivresTableDesMatieres: TFDTable
    BeforePost = tabBeforePost
    BeforeDelete = tabBeforeDelete
    IndexFieldNames = 'code'
    Connection = db
    UpdateOptions.UpdateTableName = 'livres_tabledesmatieres'
    TableName = 'livres_tabledesmatieres'
    Left = 520
    Top = 384
  end
end
