unit fMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls;

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
    procedure btnFermerClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnGenerationSiteWebClick(Sender: TObject);
    procedure btnSynchroDBClick(Sender: TObject);
    procedure btnAuteursClick(Sender: TObject);
    procedure btnEditeursClick(Sender: TObject);
    procedure btnLanguesClick(Sender: TObject);
    procedure btnLecteursClick(Sender: TObject);
    procedure btnLivresClick(Sender: TObject);
    procedure btnMotsClesClick(Sender: TObject);
    procedure btnSauvegardeDeLaBaseDeDonneesClick(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.fmx}

uses fGestionAuteurs, fGestionEditeurs, fGestionLangues, fGestionLecteurs,
  fGestionLivres, fGestionMotsCles, uDM, FMX.Platform, fGenerationSite;

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

procedure TfrmMain.btnFermerClick(Sender: TObject);
begin
  close;
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

procedure TfrmMain.btnSynchroDBClick(Sender: TObject);
begin
  // TODO : gérer la synchro de la base de données
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
