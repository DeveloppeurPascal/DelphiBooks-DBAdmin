unit uDM;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteWrapper.Stat, FireDAC.Phys.SQLiteDef, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.FMXUI.Wait, FireDAC.Comp.ScriptCommands, FireDAC.Stan.Util,
  FireDAC.Stan.StorageJSON, FireDAC.Comp.Script, Data.DB, FireDAC.Comp.Client,
  FireDAC.Phys.SQLite, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf,
  FireDAC.DApt, FireDAC.Comp.DataSet;

type
  TdmBaseDeDonnees = class(TDataModule)
    FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink;
    DB: TFDConnection;
    dbScriptMajDatabase: TFDScript;
    FDStanStorageJSONLink1: TFDStanStorageJSONLink;
    tabEditeursDescription: TFDTable;
    tabLivresDescription: TFDTable;
    tabEditeurs: TFDTable;
    tabAuteurs: TFDTable;
    tabAuteursDescription: TFDTable;
    tabLecteurs: TFDTable;
    tabLivresAuteursLien: TFDTable;
    tabLivres: TFDTable;
    tabLivresEditeursLien: TFDTable;
    tabLivresCommentaires: TFDTable;
    tabLivresMotsClesLien: TFDTable;
    tabLangues: TFDTable;
    tabMotsCles: TFDTable;
    tabLivresTableDesMatieres: TFDTable;
    procedure DataModuleCreate(Sender: TObject);
    procedure dbBeforeConnect(Sender: TObject);
    procedure dbAfterConnect(Sender: TObject);
    procedure tabBeforePost(DataSet: TDataSet);
    procedure tabBeforeDelete(DataSet: TDataSet);
  private
    { Déclarations privées }
    NomFichierDB, NomFichierDBVersion: string;
    LaBaseExisteDeja: boolean;
    function getDBName: string;
    procedure MiseANiveauBaseDeDonnees;
  public
    { Déclarations publiques }
    function SauvegardeBaseDeDonnees: string;
    function getConnectionAlias: string;
  end;

var
  dmBaseDeDonnees: TdmBaseDeDonnees;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}
{$R *.dfm}

uses
  System.IOUtils, uOutilsCommuns, uCheminDeStockage;

procedure TdmBaseDeDonnees.DataModuleCreate(Sender: TObject);
begin
  if not DB.Connected then
    DB.Open;
end;

procedure TdmBaseDeDonnees.dbAfterConnect(Sender: TObject);
var
  i: integer;
begin
  // mise à niveau de la base au cas où ce serait nécessaire
  MiseANiveauBaseDeDonnees;
  // On démarre les tables présentes dans le module de données hérité.
  for i := 0 to ComponentCount - 1 do
    if (components[i] is TFDTable) then
    begin
      // ouverture de la table
      (components[i] as TFDTable).Open;
      // si la table a un champ 'id', on le prend comme clé ce qui permet de s'assurer que les FindKey[] ultérieurs fonctionneront correctement
      if (components[i] as TFDTable).FieldList.IndexOf('code') >= 0 then
        (components[i] as TFDTable).IndexFieldNames := 'code';
    end;
  // dbConnexion.ExecSQL('PRAGMA locking_mode=NORMAL;');
end;

procedure TdmBaseDeDonnees.dbBeforeConnect(Sender: TObject);
var
  DBParams: tstringlist;
begin
  if not fdmanager.active then
    fdmanager.Open;
  // on bascule sur la vraie base de donnée (en débug ou celle de production)
  NomFichierDB := getDBName + '.db';
  NomFichierDBVersion := getDBName + '.dbv';
  LaBaseExisteDeja := tfile.Exists(NomFichierDB);
  if not(fdmanager.IsConnectionDef(getConnectionAlias)) then
  begin
    DBParams := tstringlist.Create;
    try
      DBParams.Clear;
      DBParams.Values['DriverID'] := 'SQLite';
      DBParams.Values['Database'] := NomFichierDB;
      DBParams.Values['OpenMode'] := 'CreateUTF8';
      DBParams.Values['StringFormat'] := 'Unicode';
      DBParams.Values['SharedCache'] := 'False';
{$IFDEF DEBUG}
      DBParams.Values['Password'] := '';
      DBParams.Values['LockingMode'] := 'Normal';
{$ELSE}
      (*
        Ne laissez jamais de mot de passe en dure dans un projet sur un dépôt
        de code. Je le fais ici car ça n'a aucun impact sur un projet archivé
        dont la base de données n'était que sur une seul ordinateur et ne
        contenant que des données publiques disponibles sur Delphi-Books.com et
        son API.

        Never leave a hard password in a project on a code repository. I do it
        here because it has no impact on an archived project whose database was
        only on one computer and contained only public data available on
        Delphi-Books.com and its API.

        PS :
          for a good (or at least "better") practice look at what is done for
          DeepL API key in fGestionTextesComplementaires.pas
      *)
      DBParams.Values['Password'] :=
        '[{54E&A278A-0BD5-42éBF-95DF-2D5FC417èC9C2}]';
      DBParams.Values['Encrypt'] := 'aes-256';
      // DBParams.Values['LockingMode'] := 'Exclusive';
      DBParams.Values['LockingMode'] := 'Normal';
{$ENDIF}
      fdmanager.AddConnectionDef(getConnectionAlias, 'SQLite', DBParams);
      fdmanager.FetchOptions.Mode := TFDFetchMode.fmAll;
    finally
      FreeAndNil(DBParams);
    end;
  end;
  DB.Params.Clear;
  DB.ConnectionDefName := getConnectionAlias;
  DB.LoginPrompt := false;
  DB.FetchOptions.Mode := TFDFetchMode.fmAll;
end;

function TdmBaseDeDonnees.getConnectionAlias: string;
begin
  result := tpath.GetFileNameWithoutExtension(paramstr(0));
end;

function TdmBaseDeDonnees.getDBName: string;
begin
{$IFDEF DEBUG}
  result := tpath.Combine(getCheminDeStockage, 'DelphiBooksDB-DEBUG');
{$ELSE}
  result := tpath.Combine(getCheminDeStockage, 'DelphiBooksDB');
{$ENDIF}
end;

var
  MiseANiveauBaseDeDonneesEffectuee: boolean = false;

procedure TdmBaseDeDonnees.MiseANiveauBaseDeDonnees;
var
  i: integer;
  VersionBase: integer;
  premier: integer;
  ModifFaite: boolean;
begin
  if not MiseANiveauBaseDeDonneesEffectuee then
    MiseANiveauBaseDeDonneesEffectuee := true
  else
    exit;
  if (NomFichierDBVersion.Length > 0) then
  begin
    if tfile.Exists(NomFichierDBVersion) then
      VersionBase := tfile.ReadAllText(NomFichierDBVersion, tencoding.UTF8)
        .ToInteger
    else
      VersionBase := -1;
    if (VersionBase + 1 < dbScriptMajDatabase.SQLScripts.Count) then
    begin
      SauvegardeBaseDeDonnees;
      premier := VersionBase + 1;
      ModifFaite := false;
      for i := premier to dbScriptMajDatabase.SQLScripts.Count - 1 do
      begin
        dbScriptMajDatabase.ExecuteScript
          (dbScriptMajDatabase.SQLScripts[i].SQL);
        VersionBase := i;
        ModifFaite := true;
      end;
      if (ModifFaite) then
        tfile.WriteAllText(NomFichierDBVersion, VersionBase.ToString,
          tencoding.UTF8);
    end;
  end;
end;

function TdmBaseDeDonnees.SauvegardeBaseDeDonnees: string;
var
  NomFichierBackup: string;
begin
  NomFichierBackup := getDBName + '-' + DateTimeToString14 + '.bkp.db';
  DB.ExecSQL('VACUUM INTO ' + NomFichierBackup.QuotedString);
  result := NomFichierBackup;
end;

procedure TdmBaseDeDonnees.tabBeforePost(DataSet: TDataSet);
var
  fld: tfield;
  tab: TFDTable;
  i: integer;
begin
  for i := 0 to DataSet.FieldCount - 1 do
    if DataSet.Fields[i].IsNull then
    begin
      if DataSet.Fields[i].FieldName.EndsWith('code') or
        (DataSet.Fields[i].DataType in [ftinteger, ftword, ftfloat, ftcurrency,
        ftbytes, ftlargeint, ftLongWord, ftShortint, ftByte, ftExtended,
        ftsingle]) then
        DataSet.Fields[i].AsInteger := 0
      else
        DataSet.Fields[i].asstring := '';
    end
    else if (DataSet.Fields[i].DataType in [ftstring, ftwidestring]) then
      DataSet.Fields[i].asstring := DataSet.Fields[i].asstring.Trim;
  fld := DataSet.FindField('id');
  if assigned(fld) and ((fld.asstring = '') or (fld.asstring = '0000000000'))
  then
    fld.asstring := getnewid;
  fld := DataSet.FindField('a_generer');
  if assigned(fld) then
    fld.asboolean := true;
  fld := DataSet.FindField('isbn10');
  if assigned(fld) then
    fld.asstring := fld.asstring.Replace('-', '');
  fld := DataSet.FindField('gencod');
  if assigned(fld) then
    fld.asstring := fld.asstring.Replace('-', '');
  // fld := DataSet.FindField('pseudo');
  // if assigned(fld) and fld.IsNull then
  // fld.AsString := '';
  fld := DataSet.FindField('nom_page');
  if assigned(fld) and fld.asstring.Trim.IsEmpty then
    if (DataSet is TFDTable) then
    begin
      tab := DataSet as TFDTable;
      if tab.TableName = 'auteurs' then
      begin
        if DataSet.FieldByName('pseudo').asstring.Trim.IsEmpty then
          fld.asstring := ToURL(DataSet.FieldByName('prenom').asstring + ' ' +
            DataSet.FieldByName('nom').asstring)
        else
          fld.asstring := ToURL(DataSet.FieldByName('pseudo').asstring);
      end
      else if tab.TableName = 'editeurs' then
        fld.asstring := ToURL(DataSet.FieldByName('raison_sociale').asstring)
      else if tab.TableName = 'langues' then
        fld.asstring := ToURL(DataSet.FieldByName('libelle').asstring)
      else if tab.TableName = 'lecteurs' then
        fld.asstring := ToURL(DataSet.FieldByName('pseudo').asstring)
      else if tab.TableName = 'livres' then
        fld.asstring := ToURL(DataSet.FieldByName('titre').asstring)
      else if tab.TableName = 'motscles' then
        fld.asstring := ToURL(DataSet.FieldByName('libelle').asstring)
      else
        raise exception.Create('Unknown table ' + tab.TableName +
          ' with nom_page field in uDM.TdmBaseDeDonnees.tabBeforePost.');
    end;
  // TODO : faire un contrôle d'existence des noms de pages pour éviter les dublons
end;

procedure TdmBaseDeDonnees.tabBeforeDelete(DataSet: TDataSet);
begin
  abort;
end;

end.
