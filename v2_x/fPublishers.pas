unit fPublishers;

// TODO : add a DELETE feature
// TODO : add the CRUD for publishers DESCRIPTIONS
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
  FMX.TabControl, FMX.Edit;

type
  TfrmPublishers = class(TForm)
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
    lblCompanyName: TLabel;
    edtCompanyName: TEdit;
    lblWebSite: TLabel;
    edtWebSite: TEdit;
    lblPageName: TLabel;
    edtPageName: TEdit;
    procedure btnSaveAndExitClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure ListView1ButtonClick(const Sender: TObject;
      const AItem: TListItem; const AObject: TListItemSimpleControl);
    procedure btnAddClick(Sender: TObject);
    procedure btnItemCancelClick(Sender: TObject);
    procedure btnItemSaveClick(Sender: TObject);
    procedure edtCompanyNameChange(Sender: TObject);
  private
    { Déclarations privées }
    FDB: tdelphibooksdatabase;
  public
    { Déclarations publiques }
    constructor CreateWithDB(AOwner: TComponent; ADB: tdelphibooksdatabase);
    procedure RefreshListView(AGuid: string = '');
    procedure InitEdit;
    procedure SetPageNameFromText;
  end;

implementation

{$R *.fmx}

uses
  FMX.DialogService,
  DelphiBooks.Tools;

{ TfrmPublishers }

procedure TfrmPublishers.btnAddClick(Sender: TObject);
begin
  if TabControl1.ActiveTab <> tiList then
    exit;

  ListView1.Selected := nil;
  InitEdit;
  TabControl1.Next;
end;

procedure TfrmPublishers.btnCancelClick(Sender: TObject);
begin
  if TabControl1.ActiveTab <> tiList then
    exit;

  Close;
end;

procedure TfrmPublishers.btnItemCancelClick(Sender: TObject);
begin
  if TabControl1.ActiveTab <> tiEdit then
    exit;

  TabControl1.Previous;
end;

procedure TfrmPublishers.btnItemSaveClick(Sender: TObject);
var
  p: TDelphiBooksPublisher;
  s: string;
begin
  if TabControl1.ActiveTab <> tiEdit then
    exit;

  edtCompanyName.Text := edtCompanyName.Text.Trim;
  if edtCompanyName.Text.IsEmpty then
  begin
    edtCompanyName.SetFocus;
    raise exception.Create('The company name is needed !');
  end;

  edtWebSite.Text := edtWebSite.Text.Trim.ToLower;

  SetPageNameFromText;
  if edtPageName.Text.EndsWith('.html') then
    s := tourl(edtPageName.Text.Substring(0, edtPageName.Text.Length -
      Length('.html')))
  else
    s := tourl(edtPageName.Text);
  if edtPageName.Text <> s then
  begin
    edtPageName.Text := s;
    edtPageName.SetFocus;
    raise exception.Create('Invalid page name. It has been fixed.');
  end;

  if assigned(ListView1.Selected) and assigned(ListView1.Selected.TagObject) and
    (ListView1.Selected.TagObject is TDelphiBooksPublisher) then
    p := ListView1.Selected.TagObject as TDelphiBooksPublisher
  else
    p := nil;

  if not FDB.isPageNameUniq(edtPageName.Text, TDelphiBooksTable.Publishers, p)
  then
  begin
    edtPageName.SetFocus;
    raise exception.Create('This page name already exist !');
  end;

  if not assigned(p) then
  begin
    p := TDelphiBooksPublisher.Create;
    FDB.Publishers.Add(p);
  end;
  p.CompanyName := edtCompanyName.Text;
  p.WebSiteURL := edtWebSite.Text;
  p.PageName := edtPageName.Text;
  RefreshListView(p.Guid);
  TabControl1.Previous;
end;

procedure TfrmPublishers.btnSaveAndExitClick(Sender: TObject);
begin
  if TabControl1.ActiveTab <> tiList then
    exit;

  FDB.SavePublishersToRepository;
  Close;
end;

constructor TfrmPublishers.CreateWithDB(AOwner: TComponent;
  ADB: tdelphibooksdatabase);
begin
  if not assigned(ADB) then
    raise exception.Create('No database available !');
  if not assigned(ADB.Publishers) then
    raise exception.Create('Publishers list is invalid !');
  Create(AOwner);
  FDB := ADB;
end;

procedure TfrmPublishers.edtCompanyNameChange(Sender: TObject);
begin
  SetPageNameFromText;
end;

procedure TfrmPublishers.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  p: TDelphiBooksPublisher;
  LCanClose: Boolean;
begin
  for p in FDB.Publishers do
    CanClose := CanClose and (not p.hasChanged);
  if not CanClose then
  begin
    tdialogservice.MessageDialog
      ('Changes has been done. Are you sure you want to lost them ?',
      tmsgdlgtype.mtWarning, [tmsgdlgbtn.mbYes, tmsgdlgbtn.mbNo],
      tmsgdlgbtn.mbNo, 0,
      procedure(Const AResult: tmodalresult)
      begin
        LCanClose := AResult = mryes;
      end);
    CanClose := LCanClose;
    if CanClose then
      FDB.LoadPublishersFromRepository;
  end;
end;

procedure TfrmPublishers.FormCreate(Sender: TObject);
begin
  TabControl1.ActiveTab := tiList;
  RefreshListView;
end;

procedure TfrmPublishers.InitEdit;
begin
  edtCompanyName.Text := '';
  edtWebSite.Text := '';
  edtPageName.Text := '';
end;

procedure TfrmPublishers.ListView1ButtonClick(const Sender: TObject;
const AItem: TListItem; const AObject: TListItemSimpleControl);
var
  p: TDelphiBooksPublisher;
begin
  if not assigned(AItem) then
    raise exception.Create('No item for this button !');

  if not assigned(AItem.TagObject) then
    raise exception.Create('No object for this item !');

  if not(AItem.TagObject is TDelphiBooksPublisher) then
    raise exception.Create('This item is not a publisher !');

  if (ListView1.Selected <> AItem) then
    raise exception.Create('Selected item is not this one !');

  p := AItem.TagObject as TDelphiBooksPublisher;

  InitEdit;
  edtCompanyName.Text := p.CompanyName;
  edtWebSite.Text := p.WebSiteURL;
  edtPageName.Text := p.PageName;
  TabControl1.Next;
end;

procedure TfrmPublishers.RefreshListView(AGuid: string);
var
  p: TDelphiBooksPublisher;
  item: tlistviewitem;
begin
  ListView1.BeginUpdate;
  try
    ListView1.Items.Clear;
    FDB.Publishers.SortByCompanyName;
    for p in FDB.Publishers do
    begin
      item := ListView1.Items.Add;
      item.Text := p.CompanyName;
      item.Detail := p.PageName;
      item.ButtonText := 'Edit';
      item.TagObject := p;
      if (p.Guid = AGuid) then
        ListView1.Selected := item;
    end;
  finally
    ListView1.EndUpdate;
  end;
end;

procedure TfrmPublishers.SetPageNameFromText;
begin
  edtPageName.Text := edtPageName.Text.Trim;
  if edtPageName.Text.IsEmpty then
    edtPageName.Text := tourl(edtCompanyName.Text);
end;

initialization

tdialogservice.PreferredMode := tdialogservice.TPreferredMode.Sync;

end.
