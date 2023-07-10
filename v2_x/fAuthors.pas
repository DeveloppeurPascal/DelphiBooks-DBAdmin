unit fAuthors;

// TODO : add a DELETE feature
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
  FMX.Edit;

type
  TfrmAuthors = class(TForm)
    TabControl1: TTabControl;
    tiList: TTabItem;
    tiEdit: TTabItem;
    ListView1: TListView;
    GridPanelLayout1: TGridPanelLayout;
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
    gplContextualMenu: TGridPanelLayout;
    btnDescriptions: TButton;
    btnURLOpen: TButton;
    btnPageNameURLOpen: TButton;
    procedure btnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ListView1ButtonClick(const Sender: TObject;
      const AItem: TListItem; const AObject: TListItemSimpleControl);
    procedure btnAddClick(Sender: TObject);
    procedure btnItemCancelClick(Sender: TObject);
    procedure btnItemSaveClick(Sender: TObject);
    procedure btnDescriptionsClick(Sender: TObject);
    procedure btnURLOpenClick(Sender: TObject);
    procedure btnPageNameURLOpenClick(Sender: TObject);
  private
    { Déclarations privées }
    FDB: tdelphibooksdatabase;
    function getCurrentAuthor: TDelphiBooksAuthor;
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
  DelphiBooks.Tools,
  fDescriptions,
  u_urlOpen;

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

procedure TfrmAuthors.btnDescriptionsClick(Sender: TObject);
var
  f: TfrmDescriptions;
  a: TDelphiBooksAuthor;
begin
  a := getCurrentAuthor;
  if assigned(a) then
  begin
    f := TfrmDescriptions.CreateWithDescriptionsList(self, a.Descriptions, FDB);
    try
      f.ShowModal;
    finally
      f.Free;
    end;
  end;
end;

procedure TfrmAuthors.btnItemCancelClick(Sender: TObject);
begin
  if TabControl1.ActiveTab <> tiEdit then
    exit;

  TabControl1.Previous;
end;

procedure TfrmAuthors.btnItemSaveClick(Sender: TObject);
var
  a: TDelphiBooksAuthor;
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

  a := getCurrentAuthor;

  if not FDB.isPageNameUniq(edtPageName.Text, TDelphiBooksTable.authors, a) then
  begin
    edtPageName.SetFocus;
    raise exception.Create('This page name already exist !');
  end;

  if not assigned(a) then
  begin
    a := TDelphiBooksAuthor.Create;
    FDB.authors.Add(a);
  end;
  a.Firstname := edtFirstname.Text;
  a.LastName := edtLastname.Text;
  a.Pseudo := edtPseudo.Text;
  a.WebSiteURL := edtWebSite.Text;
  a.PageName := edtPageName.Text;
  FDB.SaveItemToRepository(a, TDelphiBooksTable.authors);
  RefreshListView(a.Guid);
  TabControl1.Previous;
end;

procedure TfrmAuthors.btnPageNameURLOpenClick(Sender: TObject);
var
  page_name, url: string;
begin
  page_name := edtPageName.Text.Trim;
  if not page_name.IsEmpty then
  begin
    url := 'https://delphi-books.com/en/' + page_name;
    url_Open_In_Browser(url);
  end;
end;

procedure TfrmAuthors.btnURLOpenClick(Sender: TObject);
var
  url: string;
begin
  url := edtWebSite.Text.Trim;
  if not url.IsEmpty then
    url_Open_In_Browser(url);
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
  gplContextualMenu.Visible := false;
end;

procedure TfrmAuthors.ListView1ButtonClick(const Sender: TObject;
  const AItem: TListItem; const AObject: TListItemSimpleControl);
var
  a: TDelphiBooksAuthor;
begin
  if not assigned(AItem) then
    raise exception.Create('No item for this button !');

  if not assigned(AItem.TagObject) then
    raise exception.Create('No object for this item !');

  if not(AItem.TagObject is TDelphiBooksAuthor) then
    raise exception.Create('This item is not a author !');

  if (ListView1.Selected <> AItem) then
    raise exception.Create('Selected item is not this one !');

  a := AItem.TagObject as TDelphiBooksAuthor;

  InitEdit;
  edtFirstname.Text := a.Firstname;
  edtLastname.Text := a.LastName;
  edtPseudo.Text := a.Pseudo;
  edtWebSite.Text := a.WebSiteURL;
  edtPageName.Text := a.PageName;
  gplContextualMenu.Visible := true;
  TabControl1.Next;
end;

procedure TfrmAuthors.RefreshListView(AGuid: string);
var
  a: TDelphiBooksAuthor;
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

function TfrmAuthors.getCurrentAuthor: TDelphiBooksAuthor;
begin
  if assigned(ListView1.Selected) and assigned(ListView1.Selected.TagObject) and
    (ListView1.Selected.TagObject is TDelphiBooksAuthor) then
    result := ListView1.Selected.TagObject as TDelphiBooksAuthor
  else
    result := nil;
end;

initialization

tdialogservice.PreferredMode := tdialogservice.TPreferredMode.Sync;

end.
