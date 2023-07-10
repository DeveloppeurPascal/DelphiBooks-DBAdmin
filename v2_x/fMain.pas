unit fMain;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  Olf.FMX.AboutDialog,
  uDMAboutBoxImage,
  FMX.Controls.Presentation,
  FMX.StdCtrls,
  DelphiBooks.DB.Repository;

type
  TfrmMain = class(TForm)
    OlfAboutDialog1: TOlfAboutDialog;
    btnAbout: TButton;
    btnClose: TButton;
    btnBooks: TButton;
    btnPublishers: TButton;
    btnAuthors: TButton;
    btnLanguages: TButton;
    procedure FormCreate(Sender: TObject);
    procedure OlfAboutDialog1URLClick(const AURL: string);
    procedure btnCloseClick(Sender: TObject);
    procedure btnAboutClick(Sender: TObject);
    procedure btnLanguagesClick(Sender: TObject);
    procedure btnAuthorsClick(Sender: TObject);
    procedure btnPublishersClick(Sender: TObject);
    procedure btnBooksClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FDB: TDelphiBooksDatabase;
    procedure SetDB(const Value: TDelphiBooksDatabase);
    { Déclarations privées }
  protected
    procedure getFolders(var RootFolder, DBFolder: string);
    procedure LoadDatabase;
  public
    { Déclarations publiques }
    property DB: TDelphiBooksDatabase read FDB write SetDB;
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.fmx}

uses
  System.IOUtils,
  u_urlOpen,
  fLanguages,
  fPublishers,
  fAuthors,
  fBooks;

procedure TfrmMain.btnAboutClick(Sender: TObject);
begin
  OlfAboutDialog1.Execute;
end;

procedure TfrmMain.btnAuthorsClick(Sender: TObject);
var
  f: TfrmAuthors;
begin
  f := TfrmAuthors.CreateWithDB(self, DB);
  try
    f.ShowModal;
  finally
    f.Free;
  end;
end;

procedure TfrmMain.btnBooksClick(Sender: TObject);
var
  f: Tfrmbooks;
begin
  f := Tfrmbooks.CreateWithDB(self, DB);
  try
    f.ShowModal;
  finally
    f.Free;
  end;
end;

procedure TfrmMain.btnCloseClick(Sender: TObject);
begin
  close;
end;

procedure TfrmMain.btnLanguagesClick(Sender: TObject);
var
  f: TfrmLanguages;
begin
  f := TfrmLanguages.CreateWithDB(self, DB);
  try
    f.ShowModal;
  finally
    f.Free;
  end;
end;

procedure TfrmMain.btnPublishersClick(Sender: TObject);
var
  f: TfrmPublishers;
begin
  f := TfrmPublishers.CreateWithDB(self, DB);
  try
    f.ShowModal;
  finally
    f.Free;
  end;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  OlfAboutDialog1.Titre := caption;
  caption := caption + ' v' + OlfAboutDialog1.VersionNumero + ' - ' +
    OlfAboutDialog1.VersionDate;
  btnLanguages.Enabled := false;
  btnAuthors.Enabled := false;
  btnPublishers.Enabled := false;
  btnBooks.Enabled := false;
  tthread.ForceQueue(nil,
    procedure
    begin
      LoadDatabase;
      btnLanguages.Enabled := true;
      btnAuthors.Enabled := true;
      btnPublishers.Enabled := true;
      btnBooks.Enabled := true;
    end);
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  DB.Free;
end;

procedure TfrmMain.getFolders(var RootFolder, DBFolder: string);
var
  ProgFolder: string;
begin
  // get exe file folder
  ProgFolder := tpath.GetDirectoryName(paramstr(0));
  if ProgFolder.isempty then
    raise exception.Create('Can''t extract program directory path.');
  if not tdirectory.Exists(ProgFolder) then
    raise exception.Create('Can''t find folder "' + ProgFolder + '".');

  // get DelphiBooks-WebSite folder depending on DEBUG/RELEASE version
{$IFDEF RELEASE}
  // the exe file is in "/database" folder of the repository
  RootFolder := tpath.Combine(ProgFolder, '..');
{$ELSE}
  // the compiled exe is in /v2_X/Win32/debug (or else)
  // the web site repository is in /lib-externes/DelphiBooks-WebSite
  RootFolder := tpath.Combine(ProgFolder, '..');
  RootFolder := tpath.Combine(RootFolder, '..');
  RootFolder := tpath.Combine(RootFolder, '..');
  RootFolder := tpath.Combine(RootFolder, 'lib-externes');
  RootFolder := tpath.Combine(RootFolder, 'DelphiBooks-WebSite');
{$ENDIF}
  if RootFolder.isempty then
    raise exception.Create('Can''t define root repository path.');
  if not tdirectory.Exists(RootFolder) then
    raise exception.Create('Can''t find folder "' + RootFolder + '".');

  // Database is in /database/datas folder in the WebSite repository
  DBFolder := tpath.Combine(RootFolder, 'database');
  DBFolder := tpath.Combine(DBFolder, 'datas');
  if DBFolder.isempty then
    raise exception.Create('Can''t define database path.');
  if not tdirectory.Exists(DBFolder) then
    raise exception.Create('Can''t find folder "' + DBFolder + '".');
end;

procedure TfrmMain.LoadDatabase;
var
  FRootFolder, FDBFolder: string;
begin
  getFolders(FRootFolder, FDBFolder);
  DB := TDelphiBooksDatabase.CreateFromRepository(FRootFolder);
end;

procedure TfrmMain.OlfAboutDialog1URLClick(const AURL: string);
begin
  url_Open_In_Browser(AURL);
end;

procedure TfrmMain.SetDB(const Value: TDelphiBooksDatabase);
begin
  FDB := Value;
end;

initialization

{$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := true;
{$ENDIF}

end.
