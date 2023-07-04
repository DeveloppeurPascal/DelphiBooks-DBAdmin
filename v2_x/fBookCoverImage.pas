unit fBookCoverImage;

// TODO : permettre de supprimer une photo
// TODO : vérifier la taille de l'image générée (ou d'origine) afin de limiter sa taille et pouvoir faire correctement les synchronisations entre serveurs

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
  FMX.Layouts,
  FMX.Controls.Presentation,
  FMX.StdCtrls,
  FMX.ExtCtrls,
  DelphiBooks.Classes;

type
  TfrmBookCoverImage = class(TForm)
    ImageViewer1: TImageViewer;
    btnChange: TButton;
    GridPanelLayout1: TGridPanelLayout;
    btnSaveAndExit: TButton;
    btnCancel: TButton;
    OpenDialog1: TOpenDialog;
    procedure btnSaveAndExitClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnChangeClick(Sender: TObject);
  private
    FCoverFileName: string;
    FDelphiBooksItem: Tdelphibooksitem;
  public
    constructor CreateFromPhoto(AOwner: TComponent; AFileName: string;
      AItem: Tdelphibooksitem);
  end;

implementation

{$R *.fmx}

uses
  System.IOUtils;

procedure TfrmBookCoverImage.btnCancelClick(Sender: TObject);
begin
  close;
end;

procedure TfrmBookCoverImage.btnChangeClick(Sender: TObject);
begin
  if OpenDialog1.execute then
  begin
    if tfile.Exists(OpenDialog1.FileName) then
      ImageViewer1.Bitmap.LoadFromFile(OpenDialog1.FileName)
    else
      ImageViewer1.Bitmap.setsize(0, 0);
    btnSaveAndExit.Enabled := true;
  end;
end;

procedure TfrmBookCoverImage.btnSaveAndExitClick(Sender: TObject);
begin
  // TODO : save something in the book object to tell to WSBuilder that the picture has changed
  if tfile.Exists(FCoverFileName) then
    tfile.Delete(FCoverFileName);
  if (ImageViewer1.Bitmap.Width > 0) then
    ImageViewer1.Bitmap.SaveToFile(FCoverFileName);
  close;
end;

constructor TfrmBookCoverImage.CreateFromPhoto(AOwner: TComponent;
  AFileName: string; AItem: Tdelphibooksitem);
begin
  if not assigned(AItem) then
    raise exception.create('Need an item to choose a picture !');

  create(AOwner);

  FDelphiBooksItem := AItem;

  FCoverFileName := AFileName;
  if tfile.Exists(FCoverFileName) then
    ImageViewer1.Bitmap.LoadFromFile(FCoverFileName);
  btnSaveAndExit.Enabled := false;
end;

end.
