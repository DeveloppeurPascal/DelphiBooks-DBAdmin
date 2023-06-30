unit fMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type
  TfrmMain = class(TForm)
    btnAuteurs: TButton;
    btnEditeurs: TButton;
    btnLangues: TButton;
    btnLecteurs: TButton;
    btnLivres: TButton;
    btnMotsCles: TButton;
    btnGenerationSiteWeb: TButton;
    btnSynchroDB: TButton;
    btnFermer: TButton;
    btnSauvegardeDeLaBaseDeDonnees: TButton;
    btnExportToRepository: TButton;
    procedure btnFermerClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnGenerationSiteWebClick(Sender: TObject);
    procedure btnAuteursClick(Sender: TObject);
    procedure btnEditeursClick(Sender: TObject);
    procedure btnLanguesClick(Sender: TObject);
    procedure btnLecteursClick(Sender: TObject);
    procedure btnLivresClick(Sender: TObject);
    procedure btnMotsClesClick(Sender: TObject);
    procedure btnSauvegardeDeLaBaseDeDonneesClick(Sender: TObject);
    procedure btnExportToRepositoryClick(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.fmx}

uses
  System.IOUtils,
  fGestionAuteurs,
  fGestionEditeurs,
  fGestionLangues,
  fGestionLecteurs,
  fGestionLivres,
  fGestionMotsCles,
  uDM,
  FMX.Platform,
  fGenerationSite,
  DelphiBooks.Classes,
  DelphiBooks.DB.Repository,
  uCheminDeStockage;

procedure TfrmMain.btnAuteursClick(Sender: TObject);
var
  frm: TfrmGestionAuteurs;
begin
  frm := TfrmGestionAuteurs.Create(Self);
  try
    frm.ShowModal;
  finally
    frm.Free;
  end;
end;

procedure TfrmMain.btnEditeursClick(Sender: TObject);
var
  frm: TfrmGestionEditeurs;
begin
  frm := TfrmGestionEditeurs.Create(Self);
  try
    frm.ShowModal;
  finally
    frm.Free;
  end;
end;

procedure TfrmMain.btnExportToRepositoryClick(Sender: TObject);
var
  DBRepository: TDelphiBooksDatabase;
  qrytab, qrysec: tfdquery;
  sql: string;
  a: TDelphiBooksAuthor;
  shorta: TDelphiBooksAuthorShort;
  p: TDelphiBooksPublisher;
  shortp: TDelphiBooksPublisherShort;
  b: TDelphiBooksBook;
  shortb: TDelphiBooksBookShort;
  d: TDelphiBooksDescription;
  toc: TDelphiBooksTableOfContent;
  l: TDelphiBooksLanguage;
begin
{$IFDEF MACOS}
  DBRepository := TDelphiBooksDatabase.Create;
  try

    // ******************************
    // Authors
    qrytab := tfdquery.Create(Self);
    try
      qrytab.Connection := dmBaseDeDonnees.DB;
      sql := 'select * from auteurs';
      qrytab.Open(sql);
      qrytab.First;
      while not qrytab.eof do
      begin
        a := TDelphiBooksAuthor.Create;
        a.setid(qrytab.FieldByName('code').AsInteger);
        a.LastName := qrytab.FieldByName('nom').AsString;
        a.FirstName := qrytab.FieldByName('prenom').AsString;
        a.Pseudo := qrytab.FieldByName('pseudo').AsString;
        a.WebSiteURL := qrytab.FieldByName('url_site').AsString;
        a.PageName := qrytab.FieldByName('nom_page').AsString;

        qrysec := tfdquery.Create(Self);
        try
          qrysec.Connection := dmBaseDeDonnees.DB;
          sql := 'select auteurs_description.*, langues.code_iso from auteurs_description, langues where (auteurs_description.langue_code=langues.code) and (auteurs_description.auteur_code='
            + a.Id.Tostring + ')';
          qrysec.Open(sql);
          qrysec.First;
          while not qrysec.eof do
          begin
            d := TDelphiBooksDescription.Create;
            d.LanguageISOCode := qrysec.FieldByName('code_iso').AsString;
            d.Text := qrysec.FieldByName('description').AsString;
            a.Descriptions.Add(d);
            qrysec.Next;
          end;
        finally
          qrysec.Close;
        end;

        DBRepository.Authors.Add(a);
        qrytab.Next;
      end;
    finally
      qrytab.Close;
    end;

    // ******************************
    // Publishers

    qrytab := tfdquery.Create(Self);
    try
      qrytab.Connection := dmBaseDeDonnees.DB;
      sql := 'select * from editeurs';
      qrytab.Open(sql);
      qrytab.First;
      while not qrytab.eof do
      begin
        p := TDelphiBooksPublisher.Create;
        p.setid(qrytab.FieldByName('code').AsInteger);
        p.CompanyName := qrytab.FieldByName('raison_sociale').AsString;
        p.WebSiteURL := qrytab.FieldByName('url_site').AsString;
        p.PageName := qrytab.FieldByName('nom_page').AsString;

        qrysec := tfdquery.Create(Self);
        try
          qrysec.Connection := dmBaseDeDonnees.DB;
          sql := 'select editeurs_description.*, langues.code_iso from editeurs_description, langues where (editeurs_description.langue_code=langues.code) and (editeurs_description.editeur_code='
            + p.Id.Tostring + ')';
          qrysec.Open(sql);
          qrysec.First;
          while not qrysec.eof do
          begin
            d := TDelphiBooksDescription.Create;
            d.LanguageISOCode := qrysec.FieldByName('code_iso').AsString;
            d.Text := qrysec.FieldByName('description').AsString;
            p.Descriptions.Add(d);
            qrysec.Next;
          end;
        finally
          qrysec.Close;
        end;

        DBRepository.Publishers.Add(p);
        qrytab.Next;
      end;
    finally
      qrytab.Close;
    end;

    // ******************************
    // Books

    qrytab := tfdquery.Create(Self);
    try
      qrytab.Connection := dmBaseDeDonnees.DB;
      sql := 'select livres.*, langues.code_iso from livres, langues where (livres.langue_code=langues.code)';
      qrytab.Open(sql);
      qrytab.First;
      while not qrytab.eof do
      begin
        b := TDelphiBooksBook.Create;
        b.setid(qrytab.FieldByName('code').AsInteger);
        b.Title := qrytab.FieldByName('titre').AsString;
        b.ISBN10 := qrytab.FieldByName('isbn10').AsString;
        b.ISBN13 := qrytab.FieldByName('gencod').AsString;
        b.PublishedDateYYYYMMDD := qrytab.FieldByName('datedesortie').AsString;
        b.LanguageISOCode := qrytab.FieldByName('code_iso').AsString;
        b.WebSiteURL := qrytab.FieldByName('url_site').AsString;
        b.PageName := qrytab.FieldByName('nom_page').AsString;

        qrysec := tfdquery.Create(Self);
        try
          qrysec.Connection := dmBaseDeDonnees.DB;
          sql := 'select livres_description.*, langues.code_iso from livres_description, langues where (livres_description.langue_code=langues.code) and (livres_description.livre_code='
            + b.Id.Tostring + ')';
          qrysec.Open(sql);
          qrysec.First;
          while not qrysec.eof do
          begin
            d := TDelphiBooksDescription.Create;
            d.LanguageISOCode := qrysec.FieldByName('code_iso').AsString;
            d.Text := qrysec.FieldByName('description').AsString;
            b.Descriptions.Add(d);
            qrysec.Next;
          end;
        finally
          qrysec.Close;
        end;

        qrysec := tfdquery.Create(Self);
        try
          qrysec.Connection := dmBaseDeDonnees.DB;
          sql := 'select livres_tabledesmatieres.*, langues.code_iso from livres_tabledesmatieres, langues where (livres_tabledesmatieres.langue_code=langues.code) and (livres_tabledesmatieres.livre_code='
            + b.Id.Tostring + ')';
          qrysec.Open(sql);
          qrysec.First;
          while not qrysec.eof do
          begin
            toc := TDelphiBooksTableOfContent.Create;
            toc.LanguageISOCode := qrysec.FieldByName('code_iso').AsString;
            toc.Text := qrysec.FieldByName('tabledesmatieres').AsString;
            b.TOCs.Add(toc);
            qrysec.Next;
          end;
        finally
          qrysec.Close;
        end;

        DBRepository.Books.Add(b);
        qrytab.Next;
      end;
    finally
      qrytab.Close;
    end;

    // ******************************
    // Authors books

    qrytab := tfdquery.Create(Self);
    try
      qrytab.Connection := dmBaseDeDonnees.DB;
      sql := 'select * from livres_auteurs_lien where (auteur_code>0) and (livre_code>0)';
      qrytab.Open(sql);
      qrytab.First;
      while not qrytab.eof do
      begin
        a := DBRepository.Authors.GetItemByID(qrytab.FieldByName('auteur_code')
          .AsInteger);
        // if not assigned(a) then
        // raise exception.Create('Unknow author ' +
        // qrytab.FieldByName('auteur_code').AsString + ' for book ' +
        // qrytab.FieldByName('livre_code').AsString);
        if assigned(a) then
        begin
          b := DBRepository.Books.GetItemByID(qrytab.FieldByName('livre_code')
            .AsInteger);
          // if not assigned(b) then
          // raise exception.Create('Unknow book ' +
          // qrytab.FieldByName('livre_code').AsString + ' for author ' +
          // qrytab.FieldByName('auteur_code').AsString);
          if assigned(b) then
          begin
            // authors in books
            shorta := TDelphiBooksAuthorShort.CreateFromJSON
              (a.ToJSONObject(true), true);
            b.Authors.Add(shorta);
            // books in authors
            shortb := TDelphiBooksBookShort.CreateFromJSON
              (b.ToJSONObject(true), true);
            a.Books.Add(shortb);
          end;
        end;
        qrytab.Next;
      end;
    finally
      qrytab.Close;
    end;

    // ******************************
    // Publishers books

    qrytab := tfdquery.Create(Self);
    try
      qrytab.Connection := dmBaseDeDonnees.DB;
      sql := 'select * from livres_editeurs_lien where (editeur_code>0) and (livre_code>0)';
      qrytab.Open(sql);
      qrytab.First;
      while not qrytab.eof do
      begin
        p := DBRepository.Publishers.GetItemByID
          (qrytab.FieldByName('editeur_code').AsInteger);
        // if not assigned(p) then
        // raise exception.Create('Unknow publisher ' +
        // qrytab.FieldByName('editeur_code').AsString + ' for book ' +
        // qrytab.FieldByName('livre_code').AsString);
        if assigned(p) then
        begin
          b := DBRepository.Books.GetItemByID(qrytab.FieldByName('livre_code')
            .AsInteger);
          // if not assigned(b) then
          // raise exception.Create('Unknow book ' +
          // qrytab.FieldByName('livre_code').AsString + ' for publisher ' +
          // qrytab.FieldByName('editeur_code').AsString);
          if assigned(b) then
          begin
            // publishers in books
            shortp := TDelphiBooksPublisherShort.CreateFromJSON
              (p.ToJSONObject(true), true);
            b.Publishers.Add(shortp);
            // books in publishers
            shortb := TDelphiBooksBookShort.CreateFromJSON
              (b.ToJSONObject(true), true);
            p.Books.Add(shortb);
          end;
        end;
        qrytab.Next;
      end;
    finally
      qrytab.Close;
    end;

    // ******************************
    // Languages

    qrytab := tfdquery.Create(Self);
    try
      qrytab.Connection := dmBaseDeDonnees.DB;
      sql := 'select * from langues';
      qrytab.Open(sql);
      qrytab.First;
      while not qrytab.eof do
      begin
        l := TDelphiBooksLanguage.Create;
        l.setid(qrytab.FieldByName('code').AsInteger);
        l.Text := qrytab.FieldByName('libelle').AsString;
        l.LanguageISOCode := qrytab.FieldByName('code_iso').AsString;
        l.PageName := qrytab.FieldByName('nom_page').AsString;

        DBRepository.Languages.Add(l);
        qrytab.Next;
      end;
    finally
      qrytab.Close;
    end;

    // ******************************
    // Books covers

    if DBRepository.Books.Count > 0 then
      for b in DBRepository.Books do
        tfile.Copy(getCheminDeLaPhoto('livres', b.Id),
          '/Users/patrickpremartin/Sites/Delphi-Books_com/database/datas/' +
          DBRepository.guidtofilename(b.Guid, tdelphibookstable.Books, '.png'));

    DBRepository.SaveToRepository
      ('/Users/patrickpremartin/Sites/Delphi-Books_com');
  finally
    DBRepository.Free;
  end;
{$ELSE}
  raise exception.Create
    ('A n''exécuter que sur le Mac historique de gestion des données.');
{$ENDIF}
end;

procedure TfrmMain.btnFermerClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmMain.btnGenerationSiteWebClick(Sender: TObject);
var
  frm: TfrmGenerationSite;
begin
  frm := TfrmGenerationSite.Create(Self);
  try
    frm.ShowModal;
  finally
    frm.Free;
  end;
end;

procedure TfrmMain.btnLanguesClick(Sender: TObject);
var
  frm: TfrmGestionLangues;
begin
  frm := TfrmGestionLangues.Create(Self);
  try
    frm.ShowModal;
  finally
    frm.Free;
  end;
end;

procedure TfrmMain.btnLecteursClick(Sender: TObject);
var
  frm: TfrmGestionLecteurs;
begin
  frm := TfrmGestionLecteurs.Create(Self);
  try
    frm.ShowModal;
  finally
    frm.Free;
  end;
end;

procedure TfrmMain.btnLivresClick(Sender: TObject);
var
  frm: TfrmGestionLivres;
begin
  frm := TfrmGestionLivres.Create(Self);
  try
    frm.ShowModal;
  finally
    frm.Free;
  end;
end;

procedure TfrmMain.btnMotsClesClick(Sender: TObject);
var
  frm: TfrmGestionMotsCles;
begin
  frm := TfrmGestionMotsCles.Create(Self);
  try
    frm.ShowModal;
  finally
    frm.Free;
  end;
end;

procedure TfrmMain.btnSauvegardeDeLaBaseDeDonneesClick(Sender: TObject);
var
  NomFichier: string;
  clipboard: ifmxclipboardservice;
begin
  NomFichier := dmBaseDeDonnees.SauvegardeBaseDeDonnees;
  if TPlatformServices.Current.SupportsPlatformService(ifmxclipboardservice,
    clipboard) then
    clipboard.SetClipboard(NomFichier);
  showmessage('Sauvegarde effectuée dans ' + NomFichier);
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
{$IFDEF DEBUG}
  caption := 'DEBUG ' + caption;
{$ENDIF}
end;

initialization

{$IFDEF DEBUG}
  reportmemoryleaksonshutdown := true;
{$ENDIF}

end.
