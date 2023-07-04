unit fTablesOfContent;

// TODO : add a DELETE feature
// TODO : add a CANCEL list changes feature
// TODO : add a translation feature
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
  DelphiBooks.DB.Repository,
  DelphiBooks.Classes,
  FMX.ListView.Types,
  FMX.ListView.Appearances,
  FMX.ListView.Adapters.Base,
  FMX.Controls.Presentation,
  FMX.StdCtrls,
  FMX.Layouts,
  FMX.ListView,
  FMX.TabControl,
  FMX.Edit, FMX.Memo.Types, FMX.ScrollBox, FMX.Memo;

type
  TfrmTablesOfContent = class(TForm)
    TabControl1: TTabControl;
    tiList: TTabItem;
    tiEdit: TTabItem;
    ListView1: TListView;
    GridPanelLayout1: TGridPanelLayout;
    btnSaveAndExit: TButton;
    btnCancel: TButton;
    ToolBar1: TToolBar;
    btnAdd: TButton;
    VertScrollBox1: TVertScrollBox;
    GridPanelLayout2: TGridPanelLayout;
    btnItemSave: TButton;
    btnItemCancel: TButton;
    lblText: TLabel;
    lblISOCode: TLabel;
    edtISOCode: TEdit;
    mmoText: TMemo;
    procedure btnSaveAndExitClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure ListView1ButtonClick(const Sender: TObject;
      const AItem: TListItem; const AObject: TListItemSimpleControl);
    procedure btnAddClick(Sender: TObject);
    procedure btnItemCancelClick(Sender: TObject);
    procedure btnItemSaveClick(Sender: TObject);
  private
    { Déclarations privées }
    fTableOfContents: TDelphiBooksTableOfContentsObjectList;
  public
    { Déclarations publiques }
    constructor CreateWithTableOfContentsList(AOwner: TComponent;
      ATableOfContents: TDelphiBooksTableOfContentsObjectList);
    procedure RefreshListView(AGuid: string = '');
    procedure InitEdit;
  end;

implementation

{$R *.fmx}

uses
  FMX.DialogService,
  DelphiBooks.Tools;

{ TfrmTablesOfContent }

procedure TfrmTablesOfContent.btnAddClick(Sender: TObject);
begin
  if TabControl1.ActiveTab <> tiList then
    exit;

  ListView1.Selected := nil;
  InitEdit;
  TabControl1.Next;
end;

procedure TfrmTablesOfContent.btnCancelClick(Sender: TObject);
begin
  // TODO : manage the CANCEL operation when something has been modified

  // if TabControl1.ActiveTab <> tiList then
  // exit;
  //
  // Close;
end;

procedure TfrmTablesOfContent.btnItemCancelClick(Sender: TObject);
begin
  if TabControl1.ActiveTab <> tiEdit then
    exit;

  TabControl1.Previous;
end;

procedure TfrmTablesOfContent.btnItemSaveClick(Sender: TObject);
var
  d: TDelphiBooksTableOfContent;
  s: string;
begin
  if TabControl1.ActiveTab <> tiEdit then
    exit;

  mmoText.Text := mmoText.Text.Trim;
  if mmoText.Text.IsEmpty then
  begin
    mmoText.SetFocus;
    raise exception.Create('Text is needed !');
  end;

  edtISOCode.Text := edtISOCode.Text.Trim.ToLower;
  if edtISOCode.Text.IsEmpty then
  begin
    edtISOCode.SetFocus;
    raise exception.Create('ISO code is needed !');
  end
  else if (edtISOCode.Text.Length <> 2) then
  begin
    edtISOCode.SetFocus;
    raise exception.Create('Use the ISO 2 letters code for a TableOfContent !');
  end
  else
    for d in fTableOfContents do
      if (d.LanguageISOCode = edtISOCode.Text) and
        ((not assigned(ListView1.Selected)) or
        (ListView1.Selected.TagObject <> d)) then
      begin
        edtISOCode.SetFocus;
        raise exception.Create('This TableOfContent exists already !');
      end;

  if assigned(ListView1.Selected) and assigned(ListView1.Selected.TagObject) and
    (ListView1.Selected.TagObject is TDelphiBooksTableOfContent) then
    d := ListView1.Selected.TagObject as TDelphiBooksTableOfContent
  else
    d := nil;

  if not assigned(d) then
  begin
    d := TDelphiBooksTableOfContent.Create;
    fTableOfContents.Add(d);
  end;
  d.Text := mmoText.Text;
  d.LanguageISOCode := edtISOCode.Text;
  RefreshListView(d.Guid);
  TabControl1.Previous;
end;

procedure TfrmTablesOfContent.btnSaveAndExitClick(Sender: TObject);
begin
  if TabControl1.ActiveTab <> tiList then
    exit;

  Close;
end;

constructor TfrmTablesOfContent.CreateWithTableOfContentsList
  (AOwner: TComponent; ATableOfContents: TDelphiBooksTableOfContentsObjectList);
begin
  if not assigned(ATableOfContents) then
    raise exception.Create('TableOfContents list is invalid !');
  Create(AOwner);
  fTableOfContents := ATableOfContents;
end;

procedure TfrmTablesOfContent.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
// var
// d: TDelphiBooksTableOfContent;
// LCanClose: Boolean;
begin
  // TODO : manage the CANCEL operation when something has been modified
  // for d in FTableOfContents do
  // CanClose := CanClose and (not d.hasChanged);
  // if not CanClose then
  // begin
  // tdialogservice.MessageDialog
  // ('Changes has been done. Are you sure you want to lost them ?',
  // tmsgdlgtype.mtWarning, [tmsgdlgbtn.mbYes, tmsgdlgbtn.mbNo],
  // tmsgdlgbtn.mbNo, 0,
  // procedure(Const AResult: tmodalresult)
  // begin
  // LCanClose := AResult = mryes;
  // end);
  // CanClose := LCanClose;
  // if CanClose then
  // FLoadTableOfContentsFromRepository;
  // end;
end;

procedure TfrmTablesOfContent.FormCreate(Sender: TObject);
begin
  TabControl1.ActiveTab := tiList;
  RefreshListView;
end;

procedure TfrmTablesOfContent.InitEdit;
begin
  mmoText.Text := '';
  edtISOCode.Text := '';
end;

procedure TfrmTablesOfContent.ListView1ButtonClick(const Sender: TObject;
  const AItem: TListItem; const AObject: TListItemSimpleControl);
var
  d: TDelphiBooksTableOfContent;
begin
  if not assigned(AItem) then
    raise exception.Create('No item for this button !');

  if not assigned(AItem.TagObject) then
    raise exception.Create('No object for this item !');

  if not(AItem.TagObject is TDelphiBooksTableOfContent) then
    raise exception.Create('This item is not a TableOfContent !');

  if (ListView1.Selected <> AItem) then
    raise exception.Create('Selected item is not this one !');

  d := AItem.TagObject as TDelphiBooksTableOfContent;

  InitEdit;
  mmoText.Text := d.Text;
  edtISOCode.Text := d.LanguageISOCode;
  TabControl1.Next;
end;

procedure TfrmTablesOfContent.RefreshListView(AGuid: string);
var
  d: TDelphiBooksTableOfContent;
  item: tlistviewitem;
begin
  ListView1.BeginUpdate;
  try
    ListView1.Items.Clear;
    fTableOfContents.SortByISOCode;
    for d in fTableOfContents do
    begin
      item := ListView1.Items.Add;
      item.Text := d.Text;
      item.Detail := d.LanguageISOCode;
      item.ButtonText := 'Edit';
      item.TagObject := d;
      if (d.Guid = AGuid) then
        ListView1.Selected := item;
    end;
  finally
    ListView1.EndUpdate;
  end;
end;

initialization

tdialogservice.PreferredMode := tdialogservice.TPreferredMode.Sync;

end.
