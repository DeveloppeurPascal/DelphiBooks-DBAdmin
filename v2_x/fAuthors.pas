unit fAuthors;

// TODO : add a DELETE feature
// TODO : add the CRUD for authors DESCRIPTIONS
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
  TfrmAuthors = class(TForm)
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
    lblPseudo: TLabel;
    edtPseudo: TEdit;
    lblWebSite: TLabel;
    edtWebSite: TEdit;
    lblPageName: TLabel;
    edtPageName: TEdit;
    lblLastname: TLabel;
    edtLastname: TEdit;
    lblFirstname: TLabel;
    edtFirstname: TEdit;
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
    { D�clarations priv�es }
    FDB: tdelphibooksdatabase;
  public
    { D�clarations publiques }
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

{ TfrmAuthors }

procedure TfrmAuthors.btnAddClick(Sender: TObject);
begin
  if TabControl1.ActiveTab <> tiList then
    exit;

  ListView1.Selected := nil;
  InitEdit;
  TabControl1.Next;
end;

procedure TfrmAuthors.btnCancelClick(Sender: TObject);
begin
  if TabControl1.ActiveTab <> tiList then
    exit;

  Close;
end;

procedure TfrmAuthors.btnItemCancelClick(Sender: TObject);
begin
  if TabControl1.ActiveTab <> tiEdit then
    exit;

  TabControl1.Previous;
end;

procedure TfrmAuthors.btnItemSaveClick(Sender: TObject);
var
  a: TDelphiBooksauthor;
  s: string;
begin
  if TabControl1.ActiveTab <> tiEdit then
    exit;

  edtFirstname.Text := edtFirstname.Text.Trim;
  edtLastname.Text := edtLastname.Text.Trim;
  edtPseudo.Text := edtPseudo.Text.Trim;

  if edtFirstname.Text.IsEmpty and edtLastname.Text.IsEmpty and edtPseudo.Text.IsEmpty
  then
  begin
    edtFirstname.SetFocus;
    raise exception.Create
      ('Please fill at least one field in firstname, lastname or pseudo !');
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
    (ListView1.Selected.TagObject is TDelphiBooksauthor) then
    a := ListView1.Selected.TagObject as TDelphiBooksauthor
  else
    a := nil;

  if not FDB.isPageNameUniq(edtPageName.Text, TDelphiBooksTable.authors, a) then
  begin
    edtPageName.SetFocus;
    raise exception.Create('This page name already exist !');
  end;

  if not assigned(a) then
  begin
    a := TDelphiBooksauthor.Create;
    FDB.authors.Add(a);
  end;
  a.Firstname := edtFirstname.Text;
  a.LastName := edtLastname.Text;
  a.Pseudo := edtPseudo.Text;
  a.WebSiteURL := edtWebSite.Text;
  a.PageName := edtPageName.Text;
  RefreshListView(a.Guid);
  TabControl1.Previous;
end;

procedure TfrmAuthors.btnSaveAndExitClick(Sender: TObject);
begin
  if TabControl1.ActiveTab <> tiList then
    exit;

  FDB.SaveauthorsToRepository;
  Close;
end;

constructor TfrmAuthors.CreateWithDB(AOwner: TComponent;
  ADB: tdelphibooksdatabase);
begin
  if not assigned(ADB) then
    raise exception.Create('No database available !');
  if not assigned(ADB.authors) then
    raise exception.Create('authors list is invalid !');
  Create(AOwner);
  FDB := ADB;
end;

procedure TfrmAuthors.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  a: TDelphiBooksauthor;
  LCanClose: Boolean;
begin
  for a in FDB.authors do
    CanClose := CanClose and (not a.hasChanged);
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
      FDB.LoadauthorsFromRepository;
  end;
end;

procedure TfrmAuthors.FormCreate(Sender: TObject);
begin
  TabControl1.ActiveTab := tiList;
  RefreshListView;
end;

procedure TfrmAuthors.InitEdit;
begin
  edtFirstname.Text := '';
  edtLastname.Text := '';
  edtPseudo.Text := '';
  edtWebSite.Text := '';
  edtPageName.Text := '';
end;

procedure TfrmAuthors.ListView1ButtonClick(const Sender: TObject;
const AItem: TListItem; const AObject: TListItemSimpleControl);
var
  a: TDelphiBooksauthor;
begin
  if not assigned(AItem) then
    raise exception.Create('No item for this button !');

  if not assigned(AItem.TagObject) then
    raise exception.Create('No object for this item !');

  if not(AItem.TagObject is TDelphiBooksauthor) then
    raise exception.Create('This item is not a author !');

  if (ListView1.Selected <> AItem) then
    raise exception.Create('Selected item is not this one !');

  a := AItem.TagObject as TDelphiBooksauthor;

  InitEdit;
  edtFirstname.Text := a.Firstname;
  edtLastname.Text := a.LastName;
  edtPseudo.Text := a.Pseudo;
  edtWebSite.Text := a.WebSiteURL;
  edtPageName.Text := a.PageName;
  TabControl1.Next;
end;

procedure TfrmAuthors.RefreshListView(AGuid: string);
var
  a: TDelphiBooksauthor;
  item: tlistviewitem;
begin
  ListView1.BeginUpdate;
  try
    ListView1.Items.Clear;
    FDB.authors.SortByName;
    for a in FDB.authors do
    begin
      item := ListView1.Items.Add;
      item.Text := a.PublicName;
      item.Detail := a.PageName;
      item.ButtonText := 'Edit';
      item.TagObject := a;
      if (a.Guid = AGuid) then
        ListView1.Selected := item;
    end;
  finally
    ListView1.EndUpdate;
  end;
end;

procedure TfrmAuthors.SetPageNameFromText;
begin
  edtPageName.Text := edtPageName.Text.Trim;
  if edtPageName.Text.IsEmpty then
    if not edtPseudo.Text.IsEmpty then
      edtPageName.Text := tourl(edtPseudo.Text)
    else
      edtPageName.Text :=
        tourl(Trim(edtFirstname.Text + ' ' + edtLastname.Text));
end;

initialization

tdialogservice.PreferredMode := tdialogservice.TPreferredMode.Sync;

end.
