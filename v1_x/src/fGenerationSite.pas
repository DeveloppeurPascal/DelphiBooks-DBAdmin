unit fGenerationSite;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, uDM, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, FMX.Memo.Types, FMX.ScrollBox,
  FMX.Memo;

type
  TfrmGenerationSite = class(TForm)
    sdDossierDuSite: TSaveDialog;
    odDossierDesTemplates: TOpenDialog;
    lblDossierDesTemplates: TLabel;
    lblDossierDuSite: TLabel;
    btnChoixDossierDesTemplates: TButton;
    btnChoixDossierDuSite: TButton;
    btnFermer: TButton;
    pbEtapes: TProgressBar;
    pbSousEtapes: TProgressBar;
    btnLancerGeneration: TButton;
    qryLanguesDuSite: TFDQuery;
    procedure FormShow(Sender: TObject);
    procedure btnChoixDossierDesTemplatesClick(Sender: TObject);
    procedure btnChoixDossierDuSiteClick(Sender: TObject);
    procedure btnFermerClick(Sender: TObject);
    procedure btnLancerGenerationClick(Sender: TObject);
  private
    FFolderTemplate: string;
    FFolderWebSite: string;
    FGenerationenCours: boolean;
    procedure SetFolderTemplate(const Value: string);
    procedure SetFolderWebSite(const Value: string);
    procedure SetGenerationenCours(const Value: boolean);
    { Déclarations privées }
    property FolderTemplate: string read FFolderTemplate
      write SetFolderTemplate;
    property FolderWebSite: string read FFolderWebSite write SetFolderWebSite;
    property GenerationenCours: boolean read FGenerationenCours
      write SetGenerationenCours;
    procedure Etape1_Index(DossierDesPages: string; LangueEnCours: TFDQuery);
    procedure Etape2_ListeAuteurs(DossierDesPages: string;
      LangueEnCours: TFDQuery);
    procedure Etape3_ListeEditeurs(DossierDesPages: string;
      LangueEnCours: TFDQuery);
    procedure Etape4_ListeLangues(DossierDesPages: string;
      LangueEnCours: TFDQuery);
    procedure Etape5_ListeLecteurs(DossierDesPages: string;
      LangueEnCours: TFDQuery);
    procedure Etape6_ListeLivres(DossierDesPages: string;
      LangueEnCours: TFDQuery);
    procedure Etape7_ListeMotsCles(DossierDesPages: string;
      LangueEnCours: TFDQuery);
    procedure Etape8_PagesDesAuteurs(DossierDesPages: string;
      LangueEnCours: TFDQuery);
    procedure Etape9_PagesDesEditeurs(DossierDesPages: string;
      LangueEnCours: TFDQuery);
    procedure Etape10_PagesDesLangues(DossierDesPages: string;
      LangueEnCours: TFDQuery);
    procedure Etape11_PagesDesLecteurs(DossierDesPages: string;
      LangueEnCours: TFDQuery);
    procedure Etape12_PageDesLivres(DossierDesPages: string;
      LangueEnCours: TFDQuery);
    procedure Etape13_PagesDesMotsCles(DossierDesPages: string;
      LangueEnCours: TFDQuery);
    procedure Etape14_ImagesDeCouverturesDesLivres;
    procedure Etape15_FluxRSS(DossierDesPages: string; LangueEnCours: TFDQuery);
    procedure Etape16_SiteMap(DossierDesPages: string; LangueEnCours: TFDQuery);
    procedure Etape17_APIOpenData;
    procedure DefinirNbSousEtape(nb: integer);
    procedure FinEtape;
    procedure FinSousEtape;
    procedure erreur(msg: string);
    procedure GenererPage(FichierTemplate, FichierDestination: string;
      LangueEnCours: TFDQuery; ANomTable: string = ''; AQry: TFDQuery = nil);
    procedure RedimensionneEtEnregistre(PhotoARedimensionner: string;
      PhotoFinale: string; largeur, hauteur: integer);
  public
    { Déclarations publiques }
  end;

var
  frmGenerationSite: TfrmGenerationSite;

implementation

{$R *.fmx}

uses
  System.Generics.Collections, System.ioutils, uParam, System.Threading,
  System.DateUtils, uOutilsCommuns, System.StrUtils, uCheminDeStockage;

const
  CImageExtension = '.jpg';

procedure TfrmGenerationSite.btnChoixDossierDesTemplatesClick(Sender: TObject);
var
  chemin: string;
begin
  if tdirectory.Exists(FolderTemplate) then
    odDossierDesTemplates.InitialDir := FolderTemplate
  else
    odDossierDesTemplates.InitialDir := tpath.GetDocumentsPath;
  if odDossierDesTemplates.Execute then
  begin
    chemin := tpath.GetDirectoryName(odDossierDesTemplates.FileName);
    if tdirectory.Exists(chemin) and
      tfile.Exists(tpath.Combine(chemin, 'DephiBooks.tpl')) then
    begin
      FolderTemplate := chemin;
      tParams.setValue('TemplateFolder', FolderTemplate);
      tParams.save;
    end;
  end;
end;

procedure TfrmGenerationSite.btnChoixDossierDuSiteClick(Sender: TObject);
var
  chemin: string;
begin
  if tdirectory.Exists(FolderWebSite) then
    sdDossierDuSite.InitialDir := FolderWebSite
  else
    sdDossierDuSite.InitialDir := '';
  if sdDossierDuSite.Execute then
  begin
    if tdirectory.Exists(sdDossierDuSite.FileName) then
      chemin := sdDossierDuSite.FileName
    else
      chemin := tpath.GetDirectoryName(sdDossierDuSite.FileName);
    if tdirectory.Exists(chemin) then
    begin
      FolderWebSite := chemin;
      tParams.setValue('WSFolder', FolderWebSite);
      tParams.save;
    end;
  end;
end;

procedure TfrmGenerationSite.btnFermerClick(Sender: TObject);
begin
  close;
end;

procedure TfrmGenerationSite.btnLancerGenerationClick(Sender: TObject);
begin
  if FolderTemplate.IsEmpty then
  begin
    ShowMessage('Veuillez renseigner le chemin des templates du site.');
    btnChoixDossierDesTemplates.SetFocus;
    exit;
  end;
  if FolderWebSite.IsEmpty then
  begin
    ShowMessage
      ('Veuillez renseigner le chemin de destination des pages générées.');
    btnChoixDossierDuSite.SetFocus;
    exit;
  end;
  GenerationenCours := true;
  if qryLanguesDuSite.Active then
    qryLanguesDuSite.close;
  qryLanguesDuSite.open('select * from langues');
  pbEtapes.Min := 0;
  pbEtapes.Max := 15 * qryLanguesDuSite.RecordCount + 1 + 7;
  // Nb templates * Nb langues du site + Generation des images + Open Data
  pbEtapes.Value := 0;
  pbSousEtapes.Min := 0;
  pbSousEtapes.Max := 100; // à adapter par étape
  pbSousEtapes.Value := 0;
  qryLanguesDuSite.First;
  ttask.run(
    procedure
    var
      DossierDeDestination: string;
    begin
      try
        while not qryLanguesDuSite.Eof do
        begin
          if not qryLanguesDuSite.FieldByName('code_iso').asstring.IsEmpty then
          begin
            DossierDeDestination := tpath.Combine(FolderWebSite,
              qryLanguesDuSite.FieldByName('code_iso').asstring);
            if not tdirectory.Exists(DossierDeDestination) then
              tdirectory.CreateDirectory(DossierDeDestination);
            Etape1_Index(DossierDeDestination, qryLanguesDuSite);
            Etape2_ListeAuteurs(DossierDeDestination, qryLanguesDuSite);
            Etape3_ListeEditeurs(DossierDeDestination, qryLanguesDuSite);
            Etape4_ListeLangues(DossierDeDestination, qryLanguesDuSite);
            Etape5_ListeLecteurs(DossierDeDestination, qryLanguesDuSite);
            Etape6_ListeLivres(DossierDeDestination, qryLanguesDuSite);
            Etape7_ListeMotsCles(DossierDeDestination, qryLanguesDuSite);
            Etape8_PagesDesAuteurs(DossierDeDestination, qryLanguesDuSite);
            Etape9_PagesDesEditeurs(DossierDeDestination, qryLanguesDuSite);
            Etape10_PagesDesLangues(DossierDeDestination, qryLanguesDuSite);
            Etape11_PagesDesLecteurs(DossierDeDestination, qryLanguesDuSite);
            Etape12_PageDesLivres(DossierDeDestination, qryLanguesDuSite);
            Etape13_PagesDesMotsCles(DossierDeDestination, qryLanguesDuSite);
            Etape15_FluxRSS(DossierDeDestination, qryLanguesDuSite);
            Etape16_SiteMap(DossierDeDestination, qryLanguesDuSite);
          end;
          qryLanguesDuSite.Next;
        end;
        Etape14_ImagesDeCouverturesDesLivres;
        Etape17_APIOpenData;
      finally
        tthread.Queue(nil,
          procedure
          begin
            GenerationenCours := false;
            ShowMessage('Génération terminée.');
          end);
      end;
    end);
end;

procedure TfrmGenerationSite.DefinirNbSousEtape(nb: integer);
begin
  tthread.Queue(nil,
    procedure
    begin
      pbSousEtapes.Min := 0;
      pbSousEtapes.Max := nb;
      pbSousEtapes.Value := 0;
    end);
end;

procedure TfrmGenerationSite.erreur(msg: string);
begin
  tthread.Queue(nil,
    procedure
    begin
      ShowMessage(msg);
    end);
end;

procedure TfrmGenerationSite.Etape10_PagesDesLangues(DossierDesPages: string;
LangueEnCours: TFDQuery);
var
  qry: TFDQuery;
begin
  qry := TFDQuery.Create(Self);
  try
    qry.ConnectionName := dmBaseDeDonnees.getConnectionAlias;
    qry.open('select * from langues');
    // TODO : ajouter la sélection par rapport aux éléments à regénérer
    try
      DefinirNbSousEtape(qry.RecordCount);
      qry.First;
      while not qry.Eof do
      begin
        GenererPage(tpath.Combine(FolderTemplate, 'langue_tpl.html'),
          tpath.Combine(DossierDesPages, qry.FieldByName('nom_page').asstring),
          LangueEnCours, 'langues', qry);
        qry.Next;
        FinSousEtape;
      end;
    finally
      qry.close;
    end;
  finally
    qry.free;
  end;
  FinEtape;
end;

procedure TfrmGenerationSite.Etape11_PagesDesLecteurs(DossierDesPages: string;
LangueEnCours: TFDQuery);
var
  qry: TFDQuery;
begin
  qry := TFDQuery.Create(Self);
  try
    qry.ConnectionName := dmBaseDeDonnees.getConnectionAlias;
    qry.open('select * from lecteurs');
    // TODO : ajouter la sélection par rapport aux éléments à regénérer
    try
      DefinirNbSousEtape(qry.RecordCount);
      qry.First;
      while not qry.Eof do
      begin
        GenererPage(tpath.Combine(FolderTemplate, 'lecteur_tpl.html'),
          tpath.Combine(DossierDesPages, qry.FieldByName('nom_page').asstring),
          LangueEnCours, 'lecteurs', qry);
        qry.Next;
        FinSousEtape;
      end;
    finally
      qry.close;
    end;
  finally
    qry.free;
  end;
  FinEtape;
end;

procedure TfrmGenerationSite.Etape12_PageDesLivres(DossierDesPages: string;
LangueEnCours: TFDQuery);
var
  qry: TFDQuery;
begin
  qry := TFDQuery.Create(Self);
  try
    qry.ConnectionName := dmBaseDeDonnees.getConnectionAlias;
    qry.open('select livres.*, langues.libelle as langue_libelle, langues.nom_page as langue_nom_page, langues.code_iso as langue_code_iso from livres,langues where livres.langue_code=langues.code');
    // TODO : ajouter la sélection par rapport aux éléments à regénérer
    try
      DefinirNbSousEtape(qry.RecordCount);
      qry.First;
      while not qry.Eof do
      begin
        GenererPage(tpath.Combine(FolderTemplate, 'livre_tpl.html'),
          tpath.Combine(DossierDesPages, qry.FieldByName('nom_page').asstring),
          LangueEnCours, 'livres', qry);
        qry.Next;
        FinSousEtape;
      end;
    finally
      qry.close;
    end;
  finally
    qry.free;
  end;
  FinEtape;
end;

procedure TfrmGenerationSite.Etape13_PagesDesMotsCles(DossierDesPages: string;
LangueEnCours: TFDQuery);
var
  qry: TFDQuery;
begin
  qry := TFDQuery.Create(Self);
  try
    qry.ConnectionName := dmBaseDeDonnees.getConnectionAlias;
    qry.open('select * from motscles');
    // TODO : ajouter la sélection par rapport aux éléments à regénérer
    try
      DefinirNbSousEtape(qry.RecordCount);
      qry.First;
      while not qry.Eof do
      begin
        GenererPage(tpath.Combine(FolderTemplate, 'motcle_tpl.html'),
          tpath.Combine(DossierDesPages, qry.FieldByName('nom_page').asstring),
          LangueEnCours, 'motscles', qry);
        qry.Next;
        FinSousEtape;
      end;
    finally
      qry.close;
    end;
  finally
    qry.free;
  end;
  FinEtape;
end;

procedure TfrmGenerationSite.Etape14_ImagesDeCouverturesDesLivres;
var
  qry: TFDQuery;
  FichierPhoto: string;
  NomPhoto: string;
begin
  qry := TFDQuery.Create(Self);
  try
    qry.ConnectionName := dmBaseDeDonnees.getConnectionAlias;
    qry.open('select * from livres');
    // TODO : ajouter la sélection par rapport aux éléments/photos à regénérer
    try
      DefinirNbSousEtape(qry.RecordCount * 17);
      // 100w, 150w, 200w, 300w, 400w, 500w, 100h, 200h, 300h, 400h, 500h, 100x100, 200x200, 300x300, 400x400, 500x500, 130x110
      qry.First;
      while not qry.Eof do
      begin
        FichierPhoto := getCheminDeLaPhoto('livres', qry.FieldByName('code')
          .AsInteger);
        if tfile.Exists(FichierPhoto) then
        begin
          NomPhoto := qry.FieldByName('nom_page').asstring.Replace('.html',
            CImageExtension);
          RedimensionneEtEnregistre(FichierPhoto, NomPhoto, 100, 0);
          FinSousEtape;
          RedimensionneEtEnregistre(FichierPhoto, NomPhoto, 150, 0);
          FinSousEtape;
          RedimensionneEtEnregistre(FichierPhoto, NomPhoto, 200, 0);
          FinSousEtape;
          RedimensionneEtEnregistre(FichierPhoto, NomPhoto, 300, 0);
          FinSousEtape;
          RedimensionneEtEnregistre(FichierPhoto, NomPhoto, 400, 0);
          FinSousEtape;
          RedimensionneEtEnregistre(FichierPhoto, NomPhoto, 500, 0);
          FinSousEtape;
          RedimensionneEtEnregistre(FichierPhoto, NomPhoto, 0, 100);
          FinSousEtape;
          RedimensionneEtEnregistre(FichierPhoto, NomPhoto, 0, 200);
          FinSousEtape;
          RedimensionneEtEnregistre(FichierPhoto, NomPhoto, 0, 300);
          FinSousEtape;
          RedimensionneEtEnregistre(FichierPhoto, NomPhoto, 0, 400);
          FinSousEtape;
          RedimensionneEtEnregistre(FichierPhoto, NomPhoto, 0, 500);
          FinSousEtape;
          RedimensionneEtEnregistre(FichierPhoto, NomPhoto, 100, 100);
          FinSousEtape;
          RedimensionneEtEnregistre(FichierPhoto, NomPhoto, 200, 200);
          FinSousEtape;
          RedimensionneEtEnregistre(FichierPhoto, NomPhoto, 300, 300);
          FinSousEtape;
          RedimensionneEtEnregistre(FichierPhoto, NomPhoto, 400, 400);
          FinSousEtape;
          RedimensionneEtEnregistre(FichierPhoto, NomPhoto, 500, 500);
          FinSousEtape;
          RedimensionneEtEnregistre(FichierPhoto, NomPhoto, 130, 110);
          FinSousEtape;
        end;
        qry.Next;
      end;
    finally
      qry.close;
    end;
  finally
    qry.free;
  end;
  FinEtape;
end;

procedure TfrmGenerationSite.Etape15_FluxRSS(DossierDesPages: string;
LangueEnCours: TFDQuery);
begin
  DefinirNbSousEtape(1);
  GenererPage(tpath.Combine(FolderTemplate, 'rss_tpl.xml'),
    tpath.Combine(DossierDesPages, 'rss.xml'), LangueEnCours);
  FinSousEtape;
  FinEtape;
end;

procedure TfrmGenerationSite.Etape16_SiteMap(DossierDesPages: string;
LangueEnCours: TFDQuery);
begin
  DefinirNbSousEtape(1);
  GenererPage(tpath.Combine(FolderTemplate, 'sitemap_tpl.xml'),
    tpath.Combine(DossierDesPages, 'sitemap.xml'), LangueEnCours);
  FinSousEtape;
  FinEtape;
end;

procedure TfrmGenerationSite.Etape17_APIOpenData;
var
  qry: TFDQuery;
  DossierAPI: string;
  DossierDeGeneration: string;
begin
  if qryLanguesDuSite.Active then
    qryLanguesDuSite.close;
  qryLanguesDuSite.open('select * from langues where code_iso="en"');
  try
    DossierAPI := tpath.Combine(FolderWebSite, 'api');
    if not tdirectory.Exists(DossierAPI) then
      tdirectory.CreateDirectory(DossierAPI);

    // travail sur les auteurs
    DossierDeGeneration := tpath.Combine(DossierAPI, 'a');
    if not tdirectory.Exists(DossierDeGeneration) then
      tdirectory.CreateDirectory(DossierDeGeneration);

    // liste des auteurs
    DefinirNbSousEtape(1);
    try
      GenererPage(tpath.Combine(FolderTemplate, 'api-auteurs_tpl.txt'),
        tpath.Combine(DossierDeGeneration, 'all.json'), qryLanguesDuSite);
    finally
      FinSousEtape;
      FinEtape;
    end;

    // détail de chaque auteur
    qry := TFDQuery.Create(Self);
    try
      qry.ConnectionName := dmBaseDeDonnees.getConnectionAlias;
      qry.open('select * from auteurs');
      // TODO : ajouter la sélection par rapport aux éléments à regénérer
      try
        DefinirNbSousEtape(qry.RecordCount);
        qry.First;
        while not qry.Eof do
        begin
          GenererPage(tpath.Combine(FolderTemplate, 'api-auteur-dtl_tpl.txt'),
            tpath.Combine(DossierDeGeneration, qry.FieldByName('code').asstring
            + '.json'), qryLanguesDuSite, 'auteurs', qry);
          qry.Next;
          FinSousEtape;
        end;
      finally
        qry.close;
      end;
    finally
      qry.free;
    end;
    FinEtape;

    // travail sur les editeurs
    DossierDeGeneration := tpath.Combine(DossierAPI, 'p');
    if not tdirectory.Exists(DossierDeGeneration) then
      tdirectory.CreateDirectory(DossierDeGeneration);

    // liste des editeurs
    DefinirNbSousEtape(1);
    try
      GenererPage(tpath.Combine(FolderTemplate, 'api-editeurs_tpl.txt'),
        tpath.Combine(DossierDeGeneration, 'all.json'), qryLanguesDuSite);
    finally
      FinSousEtape;
      FinEtape;
    end;

    // détail de chaque editeur
    qry := TFDQuery.Create(Self);
    try
      qry.ConnectionName := dmBaseDeDonnees.getConnectionAlias;
      qry.open('select * from editeurs');
      // TODO : ajouter la sélection par rapport aux éléments à regénérer
      try
        DefinirNbSousEtape(qry.RecordCount);
        qry.First;
        while not qry.Eof do
        begin
          GenererPage(tpath.Combine(FolderTemplate, 'api-editeur-dtl_tpl.txt'),
            tpath.Combine(DossierDeGeneration, qry.FieldByName('code').asstring
            + '.json'), qryLanguesDuSite, 'editeurs', qry);
          qry.Next;
          FinSousEtape;
        end;
      finally
        qry.close;
      end;
    finally
      qry.free;
    end;
    FinEtape;

    // travail sur les livres
    DossierDeGeneration := tpath.Combine(DossierAPI, 'b');
    if not tdirectory.Exists(DossierDeGeneration) then
      tdirectory.CreateDirectory(DossierDeGeneration);

    // liste des livres
    DefinirNbSousEtape(1);
    try
      GenererPage(tpath.Combine(FolderTemplate, 'api-livres_tpl.txt'),
        tpath.Combine(DossierDeGeneration, 'all.json'), qryLanguesDuSite);
    finally
      FinSousEtape;
      FinEtape;
    end;

    // liste des livres récents
    DefinirNbSousEtape(1);
    try
      GenererPage(tpath.Combine(FolderTemplate, 'api-livres-recents_tpl.txt'),
        tpath.Combine(DossierDeGeneration, 'lastyear.json'), qryLanguesDuSite);
    finally
      FinSousEtape;
      FinEtape;
    end;

    // détail de chaque livre
    qry := TFDQuery.Create(Self);
    try
      qry.ConnectionName := dmBaseDeDonnees.getConnectionAlias;
      qry.open('select livres.*, langues.libelle as langue_libelle, langues.nom_page as langue_nom_page, langues.code_iso as langue_code_iso from livres,langues where livres.langue_code=langues.code');
      // TODO : ajouter la sélection par rapport aux éléments à regénérer
      try
        DefinirNbSousEtape(qry.RecordCount);
        qry.First;
        while not qry.Eof do
        begin
          GenererPage(tpath.Combine(FolderTemplate, 'api-livre-dtl_tpl.txt'),
            tpath.Combine(DossierDeGeneration, qry.FieldByName('code').asstring
            + '.json'), qryLanguesDuSite, 'livres', qry);
          qry.Next;
          FinSousEtape;
        end;
      finally
        qry.close;
      end;
    finally
      qry.free;
    end;
    FinEtape;

  finally
    qryLanguesDuSite.close;
  end;
end;

procedure TfrmGenerationSite.Etape1_Index(DossierDesPages: string;
LangueEnCours: TFDQuery);
begin
  DefinirNbSousEtape(1);
  GenererPage(tpath.Combine(FolderTemplate, 'index_tpl.html'),
    tpath.Combine(DossierDesPages, 'index.html'), LangueEnCours);
  FinSousEtape;
  FinEtape;
end;

procedure TfrmGenerationSite.Etape2_ListeAuteurs(DossierDesPages: string;
LangueEnCours: TFDQuery);
begin
  DefinirNbSousEtape(1);
  // TODO : rebaptiser le nom des pages génériques selon la langue en cours
  GenererPage(tpath.Combine(FolderTemplate, 'auteurs_tpl.html'),
    tpath.Combine(DossierDesPages, 'auteurs.html'), LangueEnCours);
  FinSousEtape;
  FinEtape;
end;

procedure TfrmGenerationSite.Etape3_ListeEditeurs(DossierDesPages: string;
LangueEnCours: TFDQuery);
begin
  DefinirNbSousEtape(1);
  // TODO : rebaptiser le nom des pages génériques selon la langue en cours
  GenererPage(tpath.Combine(FolderTemplate, 'editeurs_tpl.html'),
    tpath.Combine(DossierDesPages, 'editeurs.html'), LangueEnCours);
  FinSousEtape;
  FinEtape;
end;

procedure TfrmGenerationSite.Etape4_ListeLangues(DossierDesPages: string;
LangueEnCours: TFDQuery);
begin
  DefinirNbSousEtape(1);
  // TODO : rebaptiser le nom des pages génériques selon la langue en cours
  GenererPage(tpath.Combine(FolderTemplate, 'langues_tpl.html'),
    tpath.Combine(DossierDesPages, 'langues.html'), LangueEnCours);
  FinSousEtape;
  FinEtape;
end;

procedure TfrmGenerationSite.Etape5_ListeLecteurs(DossierDesPages: string;
LangueEnCours: TFDQuery);
begin
  DefinirNbSousEtape(1);
  // TODO : rebaptiser le nom des pages génériques selon la langue en cours
  GenererPage(tpath.Combine(FolderTemplate, 'lecteurs_tpl.html'),
    tpath.Combine(DossierDesPages, 'lecteurs.html'), LangueEnCours);
  FinSousEtape;
  FinEtape;
end;

procedure TfrmGenerationSite.Etape6_ListeLivres(DossierDesPages: string;
LangueEnCours: TFDQuery);
begin
  DefinirNbSousEtape(2);
  // TODO : rebaptiser le nom des pages génériques selon la langue en cours
  GenererPage(tpath.Combine(FolderTemplate, 'livres_tpl.html'),
    tpath.Combine(DossierDesPages, 'livres.html'), LangueEnCours);
  FinSousEtape;
  GenererPage(tpath.Combine(FolderTemplate, 'livres-par-date_tpl.html'),
    tpath.Combine(DossierDesPages, 'livres-par-date.html'), LangueEnCours);
  FinSousEtape;
  FinEtape;
end;

procedure TfrmGenerationSite.Etape7_ListeMotsCles(DossierDesPages: string;
LangueEnCours: TFDQuery);
begin
  DefinirNbSousEtape(1);
  // TODO : rebaptiser le nom des pages génériques selon la langue en cours
  GenererPage(tpath.Combine(FolderTemplate, 'motscles_tpl.html'),
    tpath.Combine(DossierDesPages, 'motscles.html'), LangueEnCours);
  FinSousEtape;
  FinEtape;
end;

procedure TfrmGenerationSite.Etape8_PagesDesAuteurs(DossierDesPages: string;
LangueEnCours: TFDQuery);
var
  qry: TFDQuery;
begin
  qry := TFDQuery.Create(Self);
  try
    qry.ConnectionName := dmBaseDeDonnees.getConnectionAlias;
    qry.open('select * from auteurs');
    // TODO : ajouter la sélection par rapport aux éléments à regénérer
    try
      DefinirNbSousEtape(qry.RecordCount);
      qry.First;
      while not qry.Eof do
      begin
        GenererPage(tpath.Combine(FolderTemplate, 'auteur_tpl.html'),
          tpath.Combine(DossierDesPages, qry.FieldByName('nom_page').asstring),
          LangueEnCours, 'auteurs', qry);
        qry.Next;
        FinSousEtape;
      end;
    finally
      qry.close;
    end;
  finally
    qry.free;
  end;
  FinEtape;
end;

procedure TfrmGenerationSite.Etape9_PagesDesEditeurs(DossierDesPages: string;
LangueEnCours: TFDQuery);
var
  qry: TFDQuery;
begin
  qry := TFDQuery.Create(Self);
  try
    qry.ConnectionName := dmBaseDeDonnees.getConnectionAlias;
    qry.open('select * from editeurs');
    // TODO : ajouter la sélection par rapport aux éléments à regénérer
    try
      DefinirNbSousEtape(qry.RecordCount);
      qry.First;
      while not qry.Eof do
      begin
        GenererPage(tpath.Combine(FolderTemplate, 'editeur_tpl.html'),
          tpath.Combine(DossierDesPages, qry.FieldByName('nom_page').asstring),
          LangueEnCours, 'editeurs', qry);
        qry.Next;
        FinSousEtape;
      end;
    finally
      qry.close;
    end;
  finally
    qry.free;
  end;
  FinEtape;
end;

procedure TfrmGenerationSite.FinEtape;
begin
  tthread.Queue(nil,
    procedure
    begin
      pbEtapes.Value := pbEtapes.Value + 1;
    end);
end;

procedure TfrmGenerationSite.FinSousEtape;
begin
  tthread.Queue(nil,
    procedure
    begin
      pbSousEtapes.Value := pbSousEtapes.Value + 1;
    end);
end;

procedure TfrmGenerationSite.FormShow(Sender: TObject);
begin
  FolderTemplate := tParams.getValue('TemplateFolder', '');
  FolderWebSite := tParams.getValue('WSFolder', '');
  pbEtapes.Visible := false;
  pbSousEtapes.Visible := false;
end;

procedure TfrmGenerationSite.GenererPage(FichierTemplate, FichierDestination
  : string; LangueEnCours: TFDQuery; ANomTable: string = '';
AQry: TFDQuery = nil);
var
  Source, Destination, PrecedentFichier: string;
  Donnees: TDictionary<string, TFDQuery>;
  qry: TFDQuery;
  PosCurseur, PosMarqueur: integer;
  Marqueur: string;
  Listes: TDictionary<string, string>;
  ListePrecedentePosListe: tstack<integer>;
  PosListe: integer;
  PremierElementListesPrecedentes: tstack<boolean>;
  PremierElementListeEnCours: boolean;
  ListePrecedenteAvaitElem: tstack<boolean>;
  ListeAvaitElem: boolean;
  AfficheBlocsPrecedents: tstack<boolean>;
  AfficheBlocEnCours: boolean;
  ListeNomTable: string;
  sql: string;

  function GetQry(NomTable: string): TFDQuery;
  begin
    if not Donnees.TryGetValue(NomTable, result) then
    begin
      result := TFDQuery.Create(Self);
      result.ConnectionName := dmBaseDeDonnees.getConnectionAlias;
      Donnees.Add(NomTable, result);
    end;
  end;

  function RemplaceMarqueur(Marqueur: string): string;
  var
    qry: TFDQuery;
  begin
    result := '';
    if Marqueur = 'livre_code' then
    begin
      qry := GetQry('livres');
      if (not qry.Eof) then
        result := qry.FieldByName('code').asstring;
    end
    else if Marqueur = 'livre_titre' then
    begin
      qry := GetQry('livres');
      if (not qry.Eof) then
        result := qry.FieldByName('titre').asstring;
    end
    else if Marqueur = 'livre_titre-xml' then
    begin
      qry := GetQry('livres');
      if (not qry.Eof) then
        result := qry.FieldByName('titre').asstring.Replace('&', 'and');
    end
    else if Marqueur = 'livre_isbn10' then
    begin
      qry := GetQry('livres');
      if (not qry.Eof) then
        result := qry.FieldByName('isbn10').asstring;
    end
    else if Marqueur = 'livre_gencod' then
    begin
      qry := GetQry('livres');
      if (not qry.Eof) then
        result := qry.FieldByName('gencod').asstring;
    end
    else if Marqueur = 'livre_anneedesortie' then
    begin
      qry := GetQry('livres');
      if (not qry.Eof) then
        result := qry.FieldByName('datedesortie').asstring.Substring(0, 4);
    end
    else if Marqueur = 'livre_datedesortie' then
    begin
      qry := GetQry('livres');
      if (not qry.Eof) then
        result := Date8ToString(qry.FieldByName('datedesortie').asstring);
    end
    else if Marqueur = 'livre_datedesortie-iso' then
    begin
      qry := GetQry('livres');
      if (not qry.Eof) then
        result := Date8ToStringISO(qry.FieldByName('datedesortie').asstring);
    end
    else if Marqueur = 'livre_datedesortie-rfc822' then
    begin
      qry := GetQry('livres');
      if (not qry.Eof) then
        result := Date8ToStringRFC822(qry.FieldByName('datedesortie').asstring);
    end
    else if Marqueur = 'livre_url_site' then
    begin
      qry := GetQry('livres');
      if (not qry.Eof) then
        result := qry.FieldByName('url_site').asstring;
    end
    else if Marqueur = 'livre_nom_page' then
    begin
      qry := GetQry('livres');
      if (not qry.Eof) then
        result := qry.FieldByName('nom_page').asstring;
    end
    else if Marqueur = 'livre_langue_libelle' then
    begin
      qry := GetQry('livres');
      if (not qry.Eof) then
        result := qry.FieldByName('langue_libelle').asstring;
    end
    else if Marqueur = 'livre_langue_nom_page' then
    begin
      qry := GetQry('livres');
      if (not qry.Eof) then
        result := qry.FieldByName('langue_nom_page').asstring;
    end
    else if Marqueur = 'livre_langue_code_iso' then
    begin
      qry := GetQry('livres');
      if (not qry.Eof) then
        result := qry.FieldByName('langue_code_iso').asstring;
    end
    else if Marqueur = 'livre_photo' then
    begin
      qry := GetQry('livres');
      if (not qry.Eof) then
        result := qry.FieldByName('nom_page').asstring.Replace('.html',
          CImageExtension);
    end
    else if Marqueur = 'livre_commentaire' then
    begin
      qry := GetQry('livre_commentaires');
      if (not qry.Eof) then
        result := qry.FieldByName('commentaire').asstring;
    end
    else if Marqueur = 'livre_commentaire_langue_libelle' then
    begin
      qry := GetQry('livre_commentaires');
      if (not qry.Eof) then
        result := qry.FieldByName('langue_libelle').asstring;
    end
    else if Marqueur = 'livre_commentaire_langue_code_iso' then
    begin
      qry := GetQry('livre_commentaires');
      if (not qry.Eof) then
        result := qry.FieldByName('langue_code_iso').asstring;
    end
    else if Marqueur = 'livre_commentaire_langue_nom_page' then
    begin
      qry := GetQry('livre_commentaires');
      if (not qry.Eof) then
        result := qry.FieldByName('langue_nom_page').asstring;
    end
    else if Marqueur = 'livre_commentaire_date' then
    begin
      qry := GetQry('livre_commentaires');
      if (not qry.Eof) then
        result := Date8ToString(qry.FieldByName('dateducommentaire').asstring);
    end
    else if Marqueur = 'livre_commentaire_pseudo' then
    begin
      qry := GetQry('livre_commentaires');
      if (not qry.Eof) then
        result := qry.FieldByName('pseudo').asstring;
    end
    else if Marqueur = 'livre_commentaire_nom_page' then
    begin
      qry := GetQry('livre_commentaires');
      if (not qry.Eof) then
        result := qry.FieldByName('nom_page').asstring;
    end
    else if Marqueur = 'livre_tabledesmatieres' then
    begin
      qry := GetQry('livre_tablesdesmatieres');
      if (not qry.Eof) then
        result := qry.FieldByName('tabledesmatieres').asstring;
    end
    else if Marqueur = 'livre_tabledesmatieres_langue_libelle' then
    begin
      qry := GetQry('livre_tablesdesmatieres');
      if (not qry.Eof) then
        result := qry.FieldByName('langue_libelle').asstring;
    end
    else if Marqueur = 'livre_tabledesmatieres_langue_code_iso' then
    begin
      qry := GetQry('livre_tablesdesmatieres');
      if (not qry.Eof) then
        result := qry.FieldByName('langue_code_iso').asstring;
    end
    else if Marqueur = 'livre_tabledesmatieres_langue_nom_page' then
    begin
      qry := GetQry('livre_tablesdesmatieres');
      if (not qry.Eof) then
        result := qry.FieldByName('langue_nom_page').asstring;
    end
    else if Marqueur = 'livre_description' then
    begin
      qry := GetQry('livre_descriptions');
      if (not qry.Eof) then
        result := qry.FieldByName('description').asstring;
    end
    else if Marqueur = 'livre_description_langue_libelle' then
    begin
      qry := GetQry('livre_descriptions');
      if (not qry.Eof) then
        result := qry.FieldByName('langue_libelle').asstring;
    end
    else if Marqueur = 'livre_description_langue_code_iso' then
    begin
      qry := GetQry('livre_descriptions');
      if (not qry.Eof) then
        result := qry.FieldByName('langue_code_iso').asstring;
    end
    else if Marqueur = 'livre_description_langue_nom_page' then
    begin
      qry := GetQry('livre_descriptions');
      if (not qry.Eof) then
        result := qry.FieldByName('langue_nom_page').asstring;
    end
    else if Marqueur = 'motcle_libelle' then
    begin
      qry := GetQry('motscles');
      if (not qry.Eof) then
        result := qry.FieldByName('libelle').asstring;
    end
    else if Marqueur = 'motcle_nom_page' then
    begin
      qry := GetQry('motscles');
      if (not qry.Eof) then
        result := qry.FieldByName('nom_page').asstring;
    end
    else if Marqueur = 'lecteur_pseudo' then
    begin
      qry := GetQry('lecteurs');
      if (not qry.Eof) then
        result := qry.FieldByName('pseudo').asstring;
    end
    else if Marqueur = 'lecteur_url_site' then
    begin
      qry := GetQry('lecteurs');
      if (not qry.Eof) then
        result := qry.FieldByName('url_site').asstring;
    end
    else if Marqueur = 'lecteur_nom_page' then
    begin
      qry := GetQry('lecteurs');
      if (not qry.Eof) then
        result := qry.FieldByName('nom_page').asstring;
    end
    else if Marqueur = 'lecteur_photo' then
    begin
      qry := GetQry('lecteurs');
      if (not qry.Eof) then
        result := qry.FieldByName('nom_page').asstring.Replace('.html',
          CImageExtension);
    end
    else if Marqueur = 'langue_libelle' then
    begin
      qry := GetQry('langues');
      if (not qry.Eof) then
        result := qry.FieldByName('libelle').asstring;
    end
    else if Marqueur = 'langue_code_iso' then
    begin
      qry := GetQry('langues');
      if (not qry.Eof) then
        result := qry.FieldByName('code_iso').asstring;
    end
    else if Marqueur = 'langue_nom_page' then
    begin
      qry := GetQry('langues');
      if (not qry.Eof) then
        result := qry.FieldByName('nom_page').asstring;
    end
    else if Marqueur = 'langue_photo' then
    begin
      qry := GetQry('langues');
      if (not qry.Eof) then
        result := qry.FieldByName('nom_page').asstring.Replace('.html',
          CImageExtension);
    end
    else if Marqueur = 'page_langue_libelle' then
    begin
      result := LangueEnCours.FieldByName('libelle').asstring;
    end
    else if Marqueur = 'page_langue_code_iso' then
    begin
      result := LangueEnCours.FieldByName('code_iso').asstring;
    end
    else if Marqueur = 'page_langue_nom_page' then
    begin
      result := LangueEnCours.FieldByName('nom_page').asstring;
    end
    else if Marqueur = 'page_langue_photo' then
    begin
      result := LangueEnCours.FieldByName('nom_page').asstring.Replace('.html',
        CImageExtension);
    end
    else if Marqueur = 'page_copyright_annees' then
    begin
      if yearof(now) > 2020 then
        result := '2020-' + yearof(now).ToString
      else
        result := '2020';
    end
    else if Marqueur = 'page_filename' then
    begin
      result := tpath.GetFileName(FichierDestination);
    end
    else if Marqueur = 'page_url' then
    begin
      result := 'https://delphi-books.com/' + LangueEnCours.FieldByName
        ('code_iso').asstring + '/' + tpath.GetFileName(FichierDestination);
    end
    else if Marqueur = 'editeur_code' then
    begin
      qry := GetQry('editeurs');
      if (not qry.Eof) then
        result := qry.FieldByName('code').asstring;
    end
    else if Marqueur = 'editeur_raison_sociale' then
    begin
      qry := GetQry('editeurs');
      if (not qry.Eof) then
        result := qry.FieldByName('raison_sociale').asstring;
    end
    else if Marqueur = 'editeur_url_site' then
    begin
      qry := GetQry('editeurs');
      if (not qry.Eof) then
        result := qry.FieldByName('url_site').asstring;
    end
    else if Marqueur = 'editeur_nom_page' then
    begin
      qry := GetQry('editeurs');
      if (not qry.Eof) then
        result := qry.FieldByName('nom_page').asstring;
    end
    else if Marqueur = 'editeur_photo' then
    begin
      qry := GetQry('editeurs');
      if (not qry.Eof) then
        result := qry.FieldByName('nom_page').asstring.Replace('.html',
          CImageExtension);
    end
    else if Marqueur = 'editeur_description' then
    begin
      qry := GetQry('editeur_descriptions');
      if (not qry.Eof) then
        result := qry.FieldByName('description').asstring;
    end
    else if Marqueur = 'editeur_description_langue_libelle' then
    begin
      qry := GetQry('editeur_descriptions');
      if (not qry.Eof) then
        result := qry.FieldByName('langue_libelle').asstring;
    end
    else if Marqueur = 'editeur_description_langue_code_iso' then
    begin
      qry := GetQry('editeur_descriptions');
      if (not qry.Eof) then
        result := qry.FieldByName('langue_code_iso').asstring;
    end
    else if Marqueur = 'editeur_description_langue_nom_page' then
    begin
      qry := GetQry('editeur_descriptions');
      if (not qry.Eof) then
        result := qry.FieldByName('langue_nom_page').asstring;
    end
    else if Marqueur = 'auteur_code' then
    begin
      qry := GetQry('auteurs');
      if (not qry.Eof) then
        result := qry.FieldByName('code').asstring;
    end
    else if Marqueur = 'auteur_nom' then
    begin
      qry := GetQry('auteurs');
      if (not qry.Eof) then
        result := qry.FieldByName('nom').asstring;
    end
    else if Marqueur = 'auteur_prenom' then
    begin
      qry := GetQry('auteurs');
      if (not qry.Eof) then
        result := qry.FieldByName('prenom').asstring;
    end
    else if Marqueur = 'auteur_pseudo' then
    begin
      qry := GetQry('auteurs');
      if (not qry.Eof) then
        result := qry.FieldByName('pseudo').asstring;
    end
    else if Marqueur = 'auteur_libelle' then
    begin
      qry := GetQry('auteurs');
      if (not qry.Eof) then
        if qry.FieldByName('pseudo').asstring.IsEmpty then
          result := qry.FieldByName('prenom').asstring + ' ' +
            qry.FieldByName('nom').asstring
        else
          result := qry.FieldByName('pseudo').asstring;
    end
    else if Marqueur = 'auteur_url_site' then
    begin
      qry := GetQry('auteurs');
      if (not qry.Eof) then
        result := qry.FieldByName('url_site').asstring;
    end
    else if Marqueur = 'auteur_nom_page' then
    begin
      qry := GetQry('auteurs');
      if (not qry.Eof) then
        result := qry.FieldByName('nom_page').asstring;
    end
    else if Marqueur = 'auteur_photo' then
    begin
      qry := GetQry('auteurs');
      if (not qry.Eof) then
        result := qry.FieldByName('nom_page').asstring.Replace('.html',
          CImageExtension);
    end
    else if Marqueur = 'auteur_description' then
    begin
      qry := GetQry('auteur_descriptions');
      if (not qry.Eof) then
        result := qry.FieldByName('description').asstring;
    end
    else if Marqueur = 'auteur_description_langue_libelle' then
    begin
      qry := GetQry('auteur_descriptions');
      if (not qry.Eof) then
        result := qry.FieldByName('langue_libelle').asstring;
    end
    else if Marqueur = 'auteur_description_langue_code_iso' then
    begin
      qry := GetQry('auteur_descriptions');
      if (not qry.Eof) then
        result := qry.FieldByName('langue_code_iso').asstring;
    end
    else if Marqueur = 'auteur_description_langue_nom_page' then
    begin
      qry := GetQry('auteur_descriptions');
      if (not qry.Eof) then
        result := qry.FieldByName('langue_nom_page').asstring;
    end
    else if Marqueur = 'date' then
    begin
      result := Date8ToString(DateToString8(now));
    end
    else if Marqueur = 'date-iso' then
    begin
      result := Date8ToStringISO(DateToString8(now));
    end
    else if Marqueur = 'date-rfc822' then
    begin
      result := Date8ToStringRFC822(DateToString8(now));
    end
    else
    begin
      erreur('Marqueur ' + Marqueur + ' inconnu dans ' + FichierTemplate);
      raise exception.Create('Marqueur ' + Marqueur + ' inconnu dans ' +
        FichierTemplate);
    end;
  end;

begin
  try
    Source := tfile.ReadAllText(FichierTemplate, tencoding.UTF8);
  except
    erreur('Fichier ' + FichierTemplate + ' non trouvé.');
    raise;
  end;
  Donnees := TDictionary<string, TFDQuery>.Create;
  try
    if (not ANomTable.IsEmpty) and assigned(AQry) then
      Donnees.Add(ANomTable, AQry);
    Listes := TDictionary<string, string>.Create;
    try
      PremierElementListeEnCours := false;
      PremierElementListesPrecedentes := tstack<boolean>.Create;
      try
        ListeAvaitElem := false;
        ListePrecedenteAvaitElem := tstack<boolean>.Create;
        try
          AfficheBlocEnCours := true;
          AfficheBlocsPrecedents := tstack<boolean>.Create;
          try
            PosListe := length(Source);
            ListePrecedentePosListe := tstack<integer>.Create;
            try
              Destination := '';
              PosCurseur := 0;
              try
                while (PosCurseur < length(Source)) do
                begin
                  PosMarqueur := Source.IndexOf('!$', PosCurseur);
                  if (PosMarqueur >= 0) then
                  begin // tag trouvé, on le traite
                    if AfficheBlocEnCours then
                      Destination := Destination + Source.Substring(PosCurseur,
                        PosMarqueur - PosCurseur);
                    Marqueur := Source.Substring(PosMarqueur + 2,
                      Source.IndexOf('$!', PosMarqueur + 2) - PosMarqueur -
                      2).ToLower;
                    if Marqueur.StartsWith('liste_') then
                    begin // ne traite pas de listes imbriquées
{$REGION 'listes gérées par le logiciel'}
                      if Marqueur = 'liste_livres' then
                      begin
                        sql := 'select livres.*,langues.libelle as langue_libelle, langues.nom_page as langue_nom_page, langues.code_iso as langue_code_iso from livres, langues where livres.langue_code=langues.code order by titre';
                        ListeNomTable := 'livres';
                      end
                      else if Marqueur = 'liste_livres-par_date' then
                      begin
                        sql := 'select livres.*,langues.libelle as langue_libelle, langues.nom_page as langue_nom_page, langues.code_iso as langue_code_iso from livres, langues where livres.langue_code=langues.code order by datedesortie desc, titre';
                        ListeNomTable := 'livres';
                      end
                      else if Marqueur = 'liste_livres_recents' then
                      begin // que le slivres édités depuis 1 an (année glissante)
                        sql := 'select livres.*,langues.libelle as langue_libelle, langues.nom_page as langue_nom_page, langues.code_iso as langue_code_iso from livres, langues where livres.langue_code=langues.code and livres.datedesortie>"'
                          + DateToString8(incyear(now, -1)) +
                          '" order by datedesortie desc, titre';
                        ListeNomTable := 'livres';
                      end
                      else if Marqueur = 'liste_livres_derniers_ajouts' then
                      begin // que les 1' denriers (7 par ligne dans le design classique du site, donc 2 lignes)
                        sql := 'select livres.*,langues.libelle as langue_libelle, langues.nom_page as langue_nom_page, langues.code_iso as langue_code_iso from livres, langues where livres.langue_code=langues.code order by code desc limit 0,14';
                        ListeNomTable := 'livres';
                      end
                      else if Marqueur = 'liste_livres_par_editeur' then
                      begin
                        qry := GetQry('editeurs');
                        sql := 'select livres.*,langues.libelle as langue_libelle, langues.nom_page as langue_nom_page, langues.code_iso as langue_code_iso from livres, langues, livres_editeurs_lien where livres.langue_code=langues.code and '
                          + 'livres.code=livres_editeurs_lien.livre_code and livres_editeurs_lien.editeur_code='
                          + ifthen(qry.Active and (not qry.Eof),
                          qry.FieldByName('code').asstring, '-1') +
                          ' order by titre';
                        ListeNomTable := 'livres';
                      end
                      else if Marqueur = 'liste_livres_par_auteur' then
                      begin
                        qry := GetQry('auteurs');
                        sql := 'select livres.*,langues.libelle as langue_libelle, langues.nom_page as langue_nom_page, langues.code_iso as langue_code_iso from livres, langues, livres_auteurs_lien where livres.langue_code=langues.code and '
                          + 'livres.code=livres_auteurs_lien.livre_code and livres_auteurs_lien.auteur_code='
                          + ifthen(qry.Active and (not qry.Eof),
                          qry.FieldByName('code').asstring, '-1') +
                          ' order by titre';
                        ListeNomTable := 'livres';
                      end
                      else if Marqueur = 'liste_livres_par_motcle' then
                      begin
                        qry := GetQry('motscles');
                        sql := 'select livres.*,langues.libelle as langue_libelle, langues.nom_page as langue_nom_page, langues.code_iso as langue_code_iso from livres, langues, livres_motscles_lien where livres.langue_code=langues.code and '
                          + 'livres.code=livres_motscles_lien.livre_code and livres_motscles_lien.motcle_code='
                          + ifthen(qry.Active and (not qry.Eof),
                          qry.FieldByName('code').asstring, '-1') +
                          ' order by titre';
                        ListeNomTable := 'livres';
                      end
                      else if Marqueur = 'liste_livres_par_langue' then
                      begin
                        qry := GetQry('langues');
                        sql := 'select livres.*,langues.libelle as langue_libelle, langues.nom_page as langue_nom_page, langues.code_iso as langue_code_iso from livres, langues where livres.langue_code=langues.code and '
                          + 'langues.code=' +
                          ifthen(qry.Active and (not qry.Eof),
                          qry.FieldByName('code').asstring, '-1') +
                          ' order by titre';
                        ListeNomTable := 'livres';
                      end
                      else if Marqueur = 'liste_commentaires_par_livre' then
                      begin
                        qry := GetQry('livres');
                        sql := 'select livres_commentaires.*, langues.libelle as langue_libelle, langues.nom_page as langue_nom_page, langues.code_iso as langue_code_iso, lecteurs.pseudo as lecteur_pseudo '
                          + 'from livres_commentaires,langues,lecteurs ' +
                          'where livres_commentaires.langue_code=langues.code and livres_commentaires.lecteur_code=lecteurs.code and livres_commentaires.livre_code='
                          + ifthen(qry.Active and (not qry.Eof),
                          qry.FieldByName('code').asstring, '-1') +
                          ' order by dateducommentaire desc';
                        ListeNomTable := 'livre_commentaires';
                      end
                      else if Marqueur = 'liste_tabledesmatieres_par_livre' then
                      begin
                        qry := GetQry('livres');
                        sql := 'select livres_tabledesmatieres.*,langues.libelle as langue_libelle, langues.nom_page as langue_nom_page, langues.code_iso as langue_code_iso '
                          + 'from livres_tabledesmatieres, langues ' +
                          'where livres_tabledesmatieres.langue_code=langues.code and '
                          + 'livres_tabledesmatieres.livre_code=' +
                          ifthen(qry.Active and (not qry.Eof),
                          qry.FieldByName('code').asstring, '-1');
                        ListeNomTable := 'livre_tablesdesmatieres';
                      end
                      else if Marqueur = 'liste_descriptions_par_livre' then
                      begin
                        qry := GetQry('livres');
                        sql := 'select livres_description.*,langues.libelle as langue_libelle, langues.nom_page as langue_nom_page, langues.code_iso as langue_code_iso '
                          + 'from livres_description, langues ' +
                          'where livres_description.langue_code=langues.code and '
                          + 'livres_description.livre_code=' +
                          ifthen(qry.Active and (not qry.Eof),
                          qry.FieldByName('code').asstring, '-1');
                        ListeNomTable := 'livre_descriptions';
                      end
                      else if Marqueur = 'liste_motscles' then
                      begin
                        sql := 'select * from motscles';
                        ListeNomTable := 'motscles';
                      end
                      else if Marqueur = 'liste_motscles_par_livre' then
                      begin
                        qry := GetQry('livres');
                        sql := 'select motscles.* ' +
                          'from motscles, livres_motscles_lien ' +
                          'where motscles.code=livres_motscles_lien.motcle_code and '
                          + 'livres_motscles_lien.livre_code=' +
                          ifthen(qry.Active and (not qry.Eof),
                          qry.FieldByName('code').asstring, '-1');
                        ListeNomTable := 'motscles';
                      end
                      else if Marqueur = 'liste_lecteurs' then
                      begin
                        sql := 'select * from lecteurs order by pseudo';
                        ListeNomTable := 'lecteurs';
                      end
                      else if Marqueur = 'liste_langues' then
                      begin
                        sql := 'select * from langues order by libelle';
                        ListeNomTable := 'langues';
                      end
                      else if Marqueur = 'liste_editeurs' then
                      begin
                        sql := 'select * from editeurs order by raison_sociale';
                        ListeNomTable := 'editeurs';
                      end
                      else if Marqueur = 'liste_editeurs_par_livre' then
                      begin
                        qry := GetQry('livres');
                        sql := 'select editeurs.* ' +
                          'from editeurs, livres_editeurs_lien ' +
                          'where editeurs.code=livres_editeurs_lien.editeur_code and '
                          + 'livres_editeurs_lien.livre_code=' +
                          ifthen(qry.Active and (not qry.Eof),
                          qry.FieldByName('code').asstring, '-1');
                        ListeNomTable := 'editeurs';
                      end
                      else if Marqueur = 'liste_descriptions_par_editeur' then
                      begin
                        qry := GetQry('editeurs');
                        sql := 'select editeurs_description.*,langues.libelle as langue_libelle, langues.nom_page as langue_nom_page, langues.code_iso as langue_code_iso '
                          + 'from editeurs_description, langues ' +
                          'where editeurs_description.langue_code=langues.code and '
                          + 'editeurs_description.editeur_code=' +
                          ifthen(qry.Active and (not qry.Eof),
                          qry.FieldByName('code').asstring, '-1');
                        ListeNomTable := 'editeur_descriptions';
                      end
                      else if Marqueur = 'liste_auteurs' then
                      begin
                        sql := 'select * from auteurs order by nom,prenom,pseudo';
                        ListeNomTable := 'auteurs';
                      end
                      else if Marqueur = 'liste_auteurs_par_livre' then
                      begin
                        qry := GetQry('livres');
                        sql := 'select auteurs.* ' +
                          'from auteurs, livres_auteurs_lien ' +
                          'where auteurs.code=livres_auteurs_lien.auteur_code and '
                          + 'livres_auteurs_lien.livre_code=' +
                          ifthen(qry.Active and (not qry.Eof),
                          qry.FieldByName('code').asstring, '-1');
                        ListeNomTable := 'auteurs';
                      end
                      else if Marqueur = 'liste_descriptions_par_auteur' then
                      begin
                        qry := GetQry('auteurs');
                        sql := 'select auteurs_description.*,langues.libelle as langue_libelle, langues.nom_page as langue_nom_page, langues.code_iso as langue_code_iso '
                          + 'from auteurs_description, langues ' +
                          'where auteurs_description.langue_code=langues.code and '
                          + 'auteurs_description.auteur_code=' +
                          ifthen(qry.Active and (not qry.Eof),
                          qry.FieldByName('code').asstring, '-1');
                        ListeNomTable := 'auteur_descriptions';
                      end
                      else
                      begin
                        erreur('Marqueur ' + Marqueur + ' inconnu dans ' +
                          FichierTemplate);
                        raise exception.Create('Marqueur ' + Marqueur +
                          ' inconnu dans ' + FichierTemplate);
                      end;
{$ENDREGION}
                      if (not sql.IsEmpty) and (not ListeNomTable.IsEmpty) then
                      begin
                        Listes.tryAdd(Marqueur, ListeNomTable);
                        qry := GetQry(ListeNomTable);
                        if qry.Active then
                          qry.close;
                        qry.open(sql);
                        qry.First;
                        PremierElementListesPrecedentes.Push
                          (PremierElementListeEnCours);
                        PremierElementListeEnCours := true;
                        AfficheBlocsPrecedents.Push(AfficheBlocEnCours);
                        AfficheBlocEnCours := AfficheBlocEnCours and
                          (not qry.Eof);
                        ListePrecedenteAvaitElem.Push(not qry.Eof);
                        ListeAvaitElem := false;
                        // ListeAvaitElem ne s'alimente qu'en fin de liste
                        ListePrecedentePosListe.Push(PosListe);
                        PosListe := PosMarqueur + Marqueur.length + 4;
                        PosCurseur := PosListe;
                      end
                      else
                      begin // Liste non gérée ou problème
                        erreur('Marqueur ' + Marqueur + ' non gérée');
                        raise exception.Create('Marqueur ' + Marqueur +
                          ' non gérée');
                      end;
                    end
                    else if Marqueur.StartsWith('/liste_') then
                    begin // retourne en tête de liste ou continue si dernier enregistrement passé
                      PosCurseur := PosMarqueur + Marqueur.length + 4;
                      if Listes.TryGetValue(Marqueur.Substring(1), ListeNomTable)
                      then
                      begin
                        qry := GetQry(ListeNomTable);
                        if qry.Active and (not qry.Eof) then
                        begin
                          qry.Next;
                          if not qry.Eof then
                          begin // on boucle
                            PosCurseur := PosListe;
                            PremierElementListeEnCours := false;
                          end
                          else
                          begin // liste terminée
                            PosListe := ListePrecedentePosListe.Pop;
                            PremierElementListeEnCours :=
                              PremierElementListesPrecedentes.Pop;
                            AfficheBlocEnCours := AfficheBlocsPrecedents.Pop;
                            ListeAvaitElem := ListePrecedenteAvaitElem.Pop;
                          end;
                        end
                        else
                        begin // liste vide donc terminée
                          PosListe := ListePrecedentePosListe.Pop;
                          PremierElementListeEnCours :=
                            PremierElementListesPrecedentes.Pop;
                          AfficheBlocEnCours := AfficheBlocsPrecedents.Pop;
                          ListeAvaitElem := ListePrecedenteAvaitElem.Pop;
                        end;
                      end
                    end
                    else if Marqueur.StartsWith('if ') then
                    begin
                      AfficheBlocsPrecedents.Push(AfficheBlocEnCours);
{$REGION 'traitement des conditions'}
                      if (Marqueur = 'if liste_premier_element') then
                      begin
                        AfficheBlocEnCours := PremierElementListeEnCours;
                      end
                      else if (Marqueur = 'if liste_precedente_affichee') then
                      begin
                        AfficheBlocEnCours := ListeAvaitElem;
                      end
                      else if (Marqueur = 'if livre_a_isbn10') then
                      begin
                        qry := GetQry('livres');
                        AfficheBlocEnCours := (not qry.Eof) and
                          (not qry.FieldByName('isbn10').asstring.IsEmpty);
                      end
                      else if (Marqueur = 'if livre_a_gencod') then
                      begin
                        qry := GetQry('livres');
                        AfficheBlocEnCours := (not qry.Eof) and
                          (not qry.FieldByName('gencod').asstring.IsEmpty);
                      end
                      else if (Marqueur = 'if livre_a_url_site') then
                      begin
                        qry := GetQry('livres');
                        AfficheBlocEnCours := (not qry.Eof) and
                          (not qry.FieldByName('url_site').asstring.IsEmpty);
                      end
                      else if (Marqueur = 'if livre_a_photo') then
                      begin
                        qry := GetQry('livres');
                        AfficheBlocEnCours := (not qry.Eof) and
                          tfile.Exists(getCheminDeLaPhoto('livres',
                          qry.FieldByName('code').AsInteger));
                      end
                      else if (Marqueur = 'if lecteur_a_url_site') then
                      begin
                        qry := GetQry('lecteurs');
                        AfficheBlocEnCours := (not qry.Eof) and
                          (not qry.FieldByName('url_site').asstring.IsEmpty);
                      end
                      else if (Marqueur = 'if lecteur_a_photo') then
                      begin
                        qry := GetQry('lecteurs');
                        AfficheBlocEnCours := (not qry.Eof) and
                          tfile.Exists(getCheminDeLaPhoto('lecteurs',
                          qry.FieldByName('code').AsInteger));
                      end
                      else if (Marqueur = 'if editeur_a_url_site') then
                      begin
                        qry := GetQry('editeurs');
                        AfficheBlocEnCours := (not qry.Eof) and
                          (not qry.FieldByName('url_site').asstring.IsEmpty);
                      end
                      else if (Marqueur = 'if editeur_a_photo') then
                      begin
                        qry := GetQry('editeurs');
                        AfficheBlocEnCours := (not qry.Eof) and
                          tfile.Exists(getCheminDeLaPhoto('editeurs',
                          qry.FieldByName('code').AsInteger));
                      end
                      else if (Marqueur = 'if auteur_a_url_site') then
                      begin
                        qry := GetQry('auteurs');
                        AfficheBlocEnCours := (not qry.Eof) and
                          (not qry.FieldByName('url_site').asstring.IsEmpty);
                      end
                      else if (Marqueur = 'if auteur_a_photo') then
                      begin
                        qry := GetQry('auteurs');
                        AfficheBlocEnCours := (not qry.Eof) and
                          tfile.Exists(getCheminDeLaPhoto('auteurs',
                          qry.FieldByName('code').AsInteger));
                      end
                      else
                      begin
                        erreur('Marqueur ' + Marqueur + ' inconnu dans ' +
                          FichierTemplate);
                        raise exception.Create('Marqueur ' + Marqueur +
                          ' inconnu dans ' + FichierTemplate);
                      end;
{$ENDREGION}
                      // On n'accepte l'affichage que si le bloc précédent (donc celui dans lequel on se trouve) était déjà affichable
                      AfficheBlocEnCours := AfficheBlocsPrecedents.Peek and
                        AfficheBlocEnCours;
                      PosCurseur := PosMarqueur + Marqueur.length + 4;
                    end
                    else if Marqueur = 'else' then
                    begin
                      AfficheBlocEnCours := AfficheBlocsPrecedents.Peek and
                        (not AfficheBlocEnCours);
                      PosCurseur := PosMarqueur + Marqueur.length + 4;
                    end
                    else if Marqueur = '/if' then
                    begin
                      AfficheBlocEnCours := AfficheBlocsPrecedents.Pop;
                      PosCurseur := PosMarqueur + Marqueur.length + 4;
                    end
                    else
                    begin
                      if AfficheBlocEnCours then
                        Destination := Destination + RemplaceMarqueur(Marqueur);
                      PosCurseur := PosMarqueur + Marqueur.length + 4;
                    end;
                  end
                  else
                  begin
                    // pas de tag trouvé, on termine l'envoi du source
                    if AfficheBlocEnCours then
                      Destination := Destination + Source.Substring(PosCurseur);
                    PosCurseur := length(Source);
                  end;
                end;
              finally
//                log.d(FichierDestination);
//                log.d(tfile.Exists(FichierDestination).ToString);
                if tfile.Exists(FichierDestination) then
                  PrecedentFichier := tfile.ReadAllText(FichierDestination,
                    tencoding.UTF8)
                else
                  PrecedentFichier := '';
                if PrecedentFichier <> Destination then
                  tfile.WriteAllText(FichierDestination, Destination,
                    tencoding.UTF8);
              end;
            finally
              ListePrecedentePosListe.free;
            end;
          finally
            AfficheBlocsPrecedents.free;
          end;
        finally
          ListePrecedenteAvaitElem.free;
        end;
      finally
        PremierElementListesPrecedentes.free;
      end;
    finally
      Listes.free;
    end;
  finally
    for qry in Donnees.Values do
      if (qry <> AQry) then
      begin
        if qry.Active then
          qry.close;
        qry.free;
      end;
    Donnees.free;
  end;
end;

procedure TfrmGenerationSite.RedimensionneEtEnregistre(PhotoARedimensionner
  : string; PhotoFinale: string; largeur, hauteur: integer);
var
  DossierDestination, FichierDestination: string;
  bitmap: TBitmap;
begin
  // contrôle du dossier de stockage des images redimensionnées
  DossierDestination := tpath.Combine(tpath.Combine(FolderWebSite, 'covers'),
    largeur.ToString + 'x' + hauteur.ToString);
  if not tdirectory.Exists(DossierDestination) then
    tdirectory.CreateDirectory(DossierDestination);
  // contrôle du fichier destination s'il existe
  FichierDestination := tpath.Combine(DossierDestination, PhotoFinale);
  if (not tfile.Exists(FichierDestination)) or
    (tfile.GetLastWriteTime(PhotoARedimensionner) > tfile.GetLastWriteTime
    (FichierDestination)) then
  begin
    // Génération de l'image si la source a été modifiée ou si la destination n'existe pas encore
    bitmap := TBitmap.CreateFromFile(PhotoARedimensionner);
    try
      if (largeur > 0) then
      begin
        if (hauteur > 0) then
          // TODO : corriger le ratio largeur / hauteur pour gérer un stretch ou prendre un morceau de l'image
          bitmap.Resize(largeur, hauteur)
        else
          bitmap.Resize(largeur, (bitmap.Height * largeur) div bitmap.Width);
      end
      else if (hauteur > 0) then
        bitmap.Resize((bitmap.Width * hauteur) div bitmap.Height, hauteur)
      else
        raise exception.Create('Taille de photo finale non définie.');
      bitmap.SaveToFile(FichierDestination);
    finally
      bitmap.free;
    end;
  end;
  FinSousEtape;
end;

procedure TfrmGenerationSite.SetFolderTemplate(const Value: string);
begin
  FFolderTemplate := Value;
  lblDossierDesTemplates.text := 'Thèmes : ' + FFolderTemplate;
end;

procedure TfrmGenerationSite.SetFolderWebSite(const Value: string);
begin
  FFolderWebSite := Value;
  lblDossierDuSite.text := 'Site : ' + FFolderWebSite;
end;

procedure TfrmGenerationSite.SetGenerationenCours(const Value: boolean);
begin
  FGenerationenCours := Value;
  if Value then
  begin
    pbEtapes.Visible := true;
    pbSousEtapes.Visible := true;
    btnChoixDossierDesTemplates.Enabled := false;
    btnChoixDossierDuSite.Enabled := false;
    btnLancerGeneration.Enabled := false;
    btnFermer.Enabled := false;
  end
  else
  begin
    pbEtapes.Visible := false;
    pbSousEtapes.Visible := false;
    btnChoixDossierDesTemplates.Enabled := true;
    btnChoixDossierDuSite.Enabled := true;
    btnLancerGeneration.Enabled := true;
    btnFermer.Enabled := true;
  end;
end;

end.
