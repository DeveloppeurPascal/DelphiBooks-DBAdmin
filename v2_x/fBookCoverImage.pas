unit fBookCoverImage;

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
    GridPanelLayout1: TGridPanelLayout;
    btnSaveAndExit: TButton;
    btnCancel: TButton;
    OpenDialog1: TOpenDialog;
    GridPanelLayout2: TGridPanelLayout;
    btnChange: TButton;
    btnRemovePicture: TButton;
    procedure btnSaveAndExitClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnChangeClick(Sender: TObject);
    procedure btnRemovePictureClick(Sender: TObject);
  private
    FCoverFileName: string;
    FDelphiBooksItem: Tdelphibooksitem;
    FImageChanged: boolean;
    procedure SetImageChanged(const Value: boolean);
  public
    property ImageChanged: boolean read FImageChanged write SetImageChanged;
    constructor CreateFromPhoto(AOwner: TComponent; AFileName: string;
      AItem: Tdelphibooksitem);
    constructor Create(AOwner: TComponent); override;
  end;

implementation

{$R *.fmx}

uses
  System.IOUtils, DelphiBooks.DB.Repository;

procedure TfrmBookCoverImage.btnCancelClick(Sender: TObject);
begin
  close;
end;

procedure TfrmBookCoverImage.btnChangeClick(Sender: TObject);
begin
  if OpenDialog1.execute then
  begin
    if tfile.Exists(OpenDialog1.FileName) then
    begin
      ImageViewer1.Bitmap.LoadFromFile(OpenDialog1.FileName);
      ImageViewer1.BestFit;
    end
    else
      ImageViewer1.Bitmap.setsize(0, 0);
    ImageChanged := true;
  end;
end;

procedure TfrmBookCoverImage.btnRemovePictureClick(Sender: TObject);
begin
  ImageViewer1.Bitmap.setsize(0, 0);
  ImageChanged := true;
end;

procedure TfrmBookCoverImage.btnSaveAndExitClick(Sender: TObject);
begin
  if ImageChanged then
  begin
    if tfile.Exists(FCoverFileName) then
      tfile.Delete(FCoverFileName);
    if (ImageViewer1.Bitmap.Width > 0) then
      ImageViewer1.Bitmap.SaveToFile(FCoverFileName);
    FDelphiBooksItem.SetHasNewImage(true);
  end;
  close;
end;

constructor TfrmBookCoverImage.Create(AOwner: TComponent);
begin
  inherited;
  ImageChanged := false;
end;

constructor TfrmBookCoverImage.CreateFromPhoto(AOwner: TComponent;
  AFileName: string; AItem: Tdelphibooksitem);
begin
  if not assigned(AItem) then
    raise exception.Create('Need an item to choose a picture !');

  Create(AOwner);

  FDelphiBooksItem := AItem;

  FCoverFileName := AFileName;
  if tfile.Exists(FCoverFileName) then
  begin
    ImageViewer1.Bitmap.LoadFromFile(FCoverFileName);
    ImageViewer1.BestFit;
  end;
  btnSaveAndExit.Enabled := false;
end;

procedure TfrmBookCoverImage.SetImageChanged(const Value: boolean);
begin
  FImageChanged := Value;
  btnSaveAndExit.Enabled := FImageChanged;
end;

end.
