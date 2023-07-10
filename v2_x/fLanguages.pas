unit fLanguages;

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
  TfrmLanguages = class(TForm)
    TabControl1: TTabControl;
    tiList: TTabItem;
    tiEdit: TTabItem;
    ListView1: TListView;
    GridPanelLayout1: TGridPanelLayout;
    btnClose: TButton;
    ToolBar1: TToolBar;
    btnAdd: TButton;
    VertScrollBox1: TVertScrollBox;
    GridPanelLayout2: TGridPanelLayout;
    btnItemSave: TButton;
    btnItemCancel: TButton;
    lblText: TLabel;
    edtText: TEdit;
    lblISOCode: TLabel;
    edtISOCode: TEdit;
    lblPageName: TLabel;
    edtPageName: TEdit;
    btnPageNameURLOpen: TButton;
    procedure btnCloseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ListView1ButtonClick(const Sender: TObject;
      const AItem: TListItem; const AObject: TListItemSimpleControl);
    procedure btnAddClick(Sender: TObject);
    procedure btnItemCancelClick(Sender: TObject);
    procedure btnItemSaveClick(Sender: TObject);
    procedure edtTextChange(Sender: TObject);
    procedure btnPageNameURLOpenClick(Sender: TObject);
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
  DelphiBooks.Tools,
  u_urlOpen;

{ TfrmLanguages }

procedure TfrmLanguages.btnAddClick(Sender: TObject);
begin
  if TabControl1.ActiveTab <> tiList then
    exit;

  ListView1.Selected := nil;
  InitEdit;
  TabControl1.Next;
end;

procedure TfrmLanguages.btnCloseClick(Sender: TObject);
begin
  if TabControl1.ActiveTab <> tiList then
    exit;

  Close;
end;

procedure TfrmLanguages.btnItemCancelClick(Sender: TObject);
begin
  if TabControl1.ActiveTab <> tiEdit then
    exit;

  TabControl1.Previous;
end;

procedure TfrmLanguages.btnItemSaveClick(Sender: TObject);
var
  l: TDelphiBooksLanguage;
  s: string;
begin
  if TabControl1.ActiveTab <> tiEdit then
    exit;

  edtText.Text := edtText.Text.Trim;
  if edtText.Text.IsEmpty then
  begin
    edtText.SetFocus;
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
    raise exception.Create('Use the ISO 2 letters code for a language !');
  end
  else
    for l in FDB.Languages do
      if (l.LanguageISOCode = edtISOCode.Text) and
        ((not assigned(ListView1.Selected)) or
        (ListView1.Selected.TagObject <> l)) then
      begin
        edtISOCode.SetFocus;
        raise exception.Create('This language exists already !');
      end;

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
    (ListView1.Selected.TagObject is TDelphiBooksLanguage) then
    l := ListView1.Selected.TagObject as TDelphiBooksLanguage
  else
    l := nil;

  if not FDB.isPageNameUniq(edtPageName.Text, TDelphiBooksTable.Languages, l)
  then
  begin
    edtPageName.SetFocus;
    raise exception.Create('This page name already exist !');
  end;

  if not assigned(l) then
  begin
    l := TDelphiBooksLanguage.Create;
    FDB.Languages.Add(l);
  end;
  l.Text := edtText.Text;
  l.LanguageISOCode := edtISOCode.Text;
  l.PageName := edtPageName.Text;
  FDB.SaveItemToRepository(l, TDelphiBooksTable.Languages);
  RefreshListView(l.Guid);
  TabControl1.Previous;
end;

procedure TfrmLanguages.btnPageNameURLOpenClick(Sender: TObject);
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

constructor TfrmLanguages.CreateWithDB(AOwner: TComponent;
  ADB: tdelphibooksdatabase);
begin
  if not assigned(ADB) then
    raise exception.Create('No database available !');
  if not assigned(ADB.Languages) then
    raise exception.Create('Languages list is invalid !');
  Create(AOwner);
  FDB := ADB;
end;

procedure TfrmLanguages.edtTextChange(Sender: TObject);
begin
  SetPageNameFromText;
end;

procedure TfrmLanguages.FormCreate(Sender: TObject);
begin
  TabControl1.ActiveTab := tiList;
  RefreshListView;
end;

procedure TfrmLanguages.InitEdit;
begin
  edtText.Text := '';
  edtISOCode.Text := '';
  edtPageName.Text := '';
end;

procedure TfrmLanguages.ListView1ButtonClick(const Sender: TObject;
  const AItem: TListItem; const AObject: TListItemSimpleControl);
var
  l: TDelphiBooksLanguage;
begin
  if not assigned(AItem) then
    raise exception.Create('No item for this button !');

  if not assigned(AItem.TagObject) then
    raise exception.Create('No object for this item !');

  if not(AItem.TagObject is TDelphiBooksLanguage) then
    raise exception.Create('This item is not a language !');

  if (ListView1.Selected <> AItem) then
    raise exception.Create('Selected item is not this one !');

  l := AItem.TagObject as TDelphiBooksLanguage;

  InitEdit;
  edtText.Text := l.Text;
  edtISOCode.Text := l.LanguageISOCode;
  edtPageName.Text := l.PageName;
  TabControl1.Next;
end;

procedure TfrmLanguages.RefreshListView(AGuid: string);
var
  l: TDelphiBooksLanguage;
  item: tlistviewitem;
begin
  ListView1.BeginUpdate;
  try
    ListView1.Items.Clear;
    FDB.Languages.SortByISOCode;
    for l in FDB.Languages do
    begin
      item := ListView1.Items.Add;
      item.Text := l.LanguageISOCode + ' - ' + l.Text;
      item.Detail := l.PageName;
      item.ButtonText := 'Edit';
      item.TagObject := l;
      if (l.Guid = AGuid) then
        ListView1.Selected := item;
    end;
  finally
    ListView1.EndUpdate;
  end;
end;

procedure TfrmLanguages.SetPageNameFromText;
begin
  edtPageName.Text := edtPageName.Text.Trim;
  if edtPageName.Text.IsEmpty then
    edtPageName.Text := tourl(edtText.Text);
end;

initialization

tdialogservice.PreferredMode := tdialogservice.TPreferredMode.Sync;

end.
