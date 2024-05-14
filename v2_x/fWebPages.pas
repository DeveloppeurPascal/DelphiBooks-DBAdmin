unit fWebPages;

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
  FMX.Edit,
  FMX.Memo.Types,
  FMX.ScrollBox,
  FMX.Memo,
  FMX.fhtmlcomp,
  FMX.fhtmledit,
  FMX.fhteditactions,
  System.Actions,
  FMX.ActnList,
  FMX.Menus;

type
  TfrmWebPages = class(TForm)
    TabControl1: TTabControl;
    tiList: TTabItem;
    tiEditContent: TTabItem;
    lvPages: TListView;
    GridPanelLayout1: TGridPanelLayout;
    btnClose: TButton;
    ToolBar1: TToolBar;
    btnAddPage: TButton;
    VertScrollBox1: TVertScrollBox;
    GridPanelLayout2: TGridPanelLayout;
    btnContentClose: TButton;
    btnContentCancel: TButton;
    lblText: TLabel;
    lblISOCode: TLabel;
    edtISOCode: TEdit;
    lblTitle: TLabel;
    edtTitle: TEdit;
    tiEditPage: TTabItem;
    lvContents: TListView;
    ToolBar2: TToolBar;
    btnAddContent: TButton;
    edtPageName: TEdit;
    btnPageNameURLOpen: TButton;
    lblPageName: TLabel;
    GridPanelLayout3: TGridPanelLayout;
    btnPageSave: TButton;
    btnPageCancel: TButton;
    lblContents: TLabel;
    tcText: TTabControl;
    tiWYSIWYG: TTabItem;
    edtWYSIWYG: THtmlEditor;
    tiHTMLSource: TTabItem;
    edtSource: TMemo;
    ActionList1: TActionList;
    HtActionCopy1: THtActionCopy;
    HtActionCut1: THtActionCut;
    HtActionPaste1: THtActionPaste;
    MainMenu1: TMainMenu;
    mnuMacOS: TMenuItem;
    mnuEdition: TMenuItem;
    mnuCouper: TMenuItem;
    mnuCopier: TMenuItem;
    mnuColler: TMenuItem;
    mnuToutSelectionner: TMenuItem;
    procedure btnCloseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure lvPagesButtonClick(const Sender: TObject; const AItem: TListItem;
      const AObject: TListItemSimpleControl);
    procedure btnAddPageClick(Sender: TObject);
    procedure btnContentCancelClick(Sender: TObject);
    procedure btnContentCloseClick(Sender: TObject);
    procedure lvContentsButtonClick(const Sender: TObject;
      const AItem: TListItem; const AObject: TListItemSimpleControl);
    procedure btnAddContentClick(Sender: TObject);
    procedure btnPageNameURLOpenClick(Sender: TObject);
    procedure btnPageCancelClick(Sender: TObject);
    procedure btnPageSaveClick(Sender: TObject);
    procedure tcTextChange(Sender: TObject);
    procedure mnuCollerClick(Sender: TObject);
    procedure mnuCopierClick(Sender: TObject);
    procedure mnuCouperClick(Sender: TObject);
    procedure mnuToutSelectionnerClick(Sender: TObject);
  private
    fDB: TDelphiBooksDatabase;
    fItem: TDelphiBooksWebPage;
    function GetContentText: string;
    procedure SetContentText(const Value: string);
  public
    property ContentText: string read GetContentText write SetContentText;
    constructor CreateWithDB(AOwner: TComponent; ADB: TDelphiBooksDatabase);
    procedure RefreshContentsListView(AGuid: string = '');
    procedure RefreshPagesListView(AGuid: string = '');
    procedure InitPageEdit;
    procedure InitContentEdit;
  end;

implementation

{$R *.fmx}

uses
  FMX.DialogService,
  DelphiBooks.Tools,
  u_urlOpen;

procedure TfrmWebPages.btnAddContentClick(Sender: TObject);
begin
  if TabControl1.ActiveTab <> tiEditPage then
    exit;

  lvContents.Selected := nil;
  InitContentEdit;
  TabControl1.Next;
end;

procedure TfrmWebPages.btnAddPageClick(Sender: TObject);
begin
  if TabControl1.ActiveTab <> tiList then
    exit;

  lvPages.Selected := nil;
  fItem := nil;
  InitPageEdit;
  TabControl1.Next;
end;

procedure TfrmWebPages.btnContentCancelClick(Sender: TObject);
begin
  if TabControl1.ActiveTab <> tiEditContent then
    exit;

  TabControl1.Previous;
end;

procedure TfrmWebPages.btnContentCloseClick(Sender: TObject);
var
  wpc: TDelphiBooksWebPageContent;
begin
  if TabControl1.ActiveTab <> tiEditContent then
    exit;

  edtISOCode.Text := edtISOCode.Text.Trim.ToLower;
  if edtISOCode.Text.IsEmpty then
  begin
    edtISOCode.SetFocus;
    raise exception.Create('Language ISO code is needed !');
  end
  else if (edtISOCode.Text.Length <> 2) then
  begin
    edtISOCode.SetFocus;
    raise exception.Create
      ('Use the ISO 2 letters language code for a Description !');
  end
  else
  begin
    if fItem.Contents.Count > 0 then
      for wpc in fItem.Contents do
        if (wpc.LanguageISOCode = edtISOCode.Text) and
          ((not assigned(lvContents.Selected)) or
          (lvContents.Selected.TagObject <> wpc)) then
        begin
          edtISOCode.SetFocus;
          raise exception.Create
            ('This language is already used for a description !');
        end;
    if not assigned(fDB.Languages.GetItemByLanguage(edtISOCode.Text)) then
    begin
      edtISOCode.SetFocus;
      raise exception.Create
        ('This language is unknonw ! Add it to the database from the main menu.');
    end;
  end;

  edtTitle.Text := edtTitle.Text.Trim;
  if edtTitle.Text.IsEmpty then
  begin
    edtTitle.SetFocus;
    raise exception.Create('Title needed !');
  end;

  ContentText := ContentText.Trim;
  if ContentText.IsEmpty then
    raise exception.Create('Text is needed !');

  if assigned(lvContents.Selected) and assigned(lvContents.Selected.TagObject)
    and (lvContents.Selected.TagObject is TDelphiBooksWebPageContent) then
    wpc := lvContents.Selected.TagObject as TDelphiBooksWebPageContent
  else
    wpc := nil;

  if not assigned(wpc) then
  begin
    wpc := TDelphiBooksWebPageContent.Create;
    fItem.Contents.Add(wpc);
  end;
  wpc.Title := edtTitle.Text;
  wpc.Text := ContentText;
  wpc.LanguageISOCode := edtISOCode.Text;
  fItem.sethaschanged(true);
  RefreshContentsListView(wpc.Guid);
  TabControl1.Previous;
end;

procedure TfrmWebPages.btnPageCancelClick(Sender: TObject);
begin
  if TabControl1.ActiveTab <> tiEditPage then
    exit;

  TabControl1.Previous;
end;

procedure TfrmWebPages.btnPageNameURLOpenClick(Sender: TObject);
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

procedure TfrmWebPages.btnPageSaveClick(Sender: TObject);
var
  s: string;
begin
  if TabControl1.ActiveTab <> tiEditPage then
    exit;

  edtPageName.Text := edtPageName.Text.Trim;

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

  if edtPageName.Text.IsEmpty or (edtPageName.Text.Length <= Length('.html'))
  then
    raise exception.Create('Page name is needed !');

  if not fDB.isPageNameUniq(edtPageName.Text, TDelphiBooksTable.WebPages, fItem)
  then
  begin
    edtPageName.SetFocus;
    raise exception.Create('This page name already exist !');
  end;

  if not assigned(fItem) then
  begin
    fItem := TDelphiBooksWebPage.Create;
    fDB.WebPages.Add(fItem);
  end;
  fItem.PageName := edtPageName.Text;
  fDB.SaveItemToRepository(fItem, TDelphiBooksTable.WebPages);
  RefreshPagesListView(fItem.Guid);
  TabControl1.Previous;
end;

constructor TfrmWebPages.CreateWithDB(AOwner: TComponent;
  ADB: TDelphiBooksDatabase);
begin
  if not assigned(ADB) then
    raise exception.Create('No database available !');
  if not assigned(ADB.WebPages) then
    raise exception.Create('Web pages list is invalid !');
  Create(AOwner);
  fDB := ADB;
end;

procedure TfrmWebPages.btnCloseClick(Sender: TObject);
begin
  if TabControl1.ActiveTab <> tiList then
    exit;

  Close;
end;

procedure TfrmWebPages.FormCreate(Sender: TObject);
begin
  TabControl1.ActiveTab := tiList;
  RefreshPagesListView;

  // Adaptation du menu pour macOS
{$IFDEF MACOS}
  mnuMacOS.Visible := true;
{$ELSE}
  mnuMacOS.Visible := false;
{$ENDIF}
end;

function TfrmWebPages.GetContentText: string;
begin
  if tcText.ActiveTab = tiWYSIWYG then
    result := edtWYSIWYG.Doc.InnerHTML
  else
    result := edtSource.Text;
end;

procedure TfrmWebPages.InitContentEdit;
begin
  edtTitle.Text := '';
  ContentText := '';
  edtISOCode.Text := '';
  tcText.ActiveTab := tiWYSIWYG;
end;

procedure TfrmWebPages.InitPageEdit;
begin
  edtPageName.Text := '';
  btnAddContent.Visible := false;
  lvContents.Items.Clear;
end;

procedure TfrmWebPages.lvContentsButtonClick(const Sender: TObject;
  const AItem: TListItem; const AObject: TListItemSimpleControl);
var
  wpc: TDelphiBooksWebPageContent;
begin
  if not assigned(AItem) then
    raise exception.Create('No item for this button !');

  if not assigned(AItem.TagObject) then
    raise exception.Create('No object for this item !');

  if not(AItem.TagObject is TDelphiBooksWebPageContent) then
    raise exception.Create('This item is not a web page content !');

  if (lvContents.Selected <> AItem) then
    raise exception.Create('Selected item is not this one !');

  wpc := AItem.TagObject as TDelphiBooksWebPageContent;

  InitContentEdit;
  edtTitle.Text := wpc.Title;
  ContentText := wpc.Text;
  edtISOCode.Text := wpc.LanguageISOCode;
  TabControl1.Next;
end;

procedure TfrmWebPages.lvPagesButtonClick(const Sender: TObject;
  const AItem: TListItem; const AObject: TListItemSimpleControl);
begin
  if not assigned(AItem) then
    raise exception.Create('No item for this button !');

  if not assigned(AItem.TagObject) then
    raise exception.Create('No object for this item !');

  if not(AItem.TagObject is TDelphiBooksWebPage) then
    raise exception.Create('This item is not a web page !');

  if (lvPages.Selected <> AItem) then
    raise exception.Create('Selected item is not this one !');

  fItem := AItem.TagObject as TDelphiBooksWebPage;

  InitPageEdit;
  edtPageName.Text := fItem.PageName;
  RefreshContentsListView;
  btnAddContent.Visible := true;
  TabControl1.Next;
end;

procedure TfrmWebPages.mnuCollerClick(Sender: TObject);
begin
  if TabControl1.ActiveTab = tiEditContent then
    if tcText.ActiveTab = tiWYSIWYG then
      HtActionPaste1.Execute
    else
      edtSource.PasteFromClipboard;
end;

procedure TfrmWebPages.mnuCopierClick(Sender: TObject);
begin
  if TabControl1.ActiveTab = tiEditContent then
    if tcText.ActiveTab = tiWYSIWYG then
      HtActionCopy1.Execute
    else
      edtSource.CopyToClipboard;
end;

procedure TfrmWebPages.mnuCouperClick(Sender: TObject);
begin
  if TabControl1.ActiveTab = tiEditContent then
    if tcText.ActiveTab = tiWYSIWYG then
      HtActionCut1.Execute
    else
      edtSource.CutToClipboard;
end;

procedure TfrmWebPages.mnuToutSelectionnerClick(Sender: TObject);
begin
  if TabControl1.ActiveTab = tiEditContent then
    if tcText.ActiveTab = tiWYSIWYG then
      edtWYSIWYG.SelectAll
    else
      edtSource.SelectAll;
end;

procedure TfrmWebPages.RefreshContentsListView(AGuid: string);
var
  wpc: TDelphiBooksWebPageContent;
  item: tlistviewitem;
begin
  lvContents.BeginUpdate;
  try
    lvContents.Items.Clear;
    fItem.Contents.SortByISOCode;
    for wpc in fItem.Contents do
    begin
      item := lvContents.Items.Add;
      item.Text := wpc.Text;
      item.Detail := wpc.LanguageISOCode;
      item.ButtonText := 'Edit';
      item.TagObject := wpc;
      if (wpc.Guid = AGuid) then
        lvContents.Selected := item;
    end;
  finally
    lvContents.EndUpdate;
  end;
end;

procedure TfrmWebPages.RefreshPagesListView(AGuid: string);
var
  wp: TDelphiBooksWebPage;
  item: tlistviewitem;
begin
  lvPages.BeginUpdate;
  try
    lvPages.Items.Clear;
    fDB.WebPages.SortByPageName;
    for wp in fDB.WebPages do
    begin
      item := lvPages.Items.Add;
      item.Text := wp.PageName;
      item.ButtonText := 'Edit';
      item.TagObject := wp;
      if (wp.Guid = AGuid) then
        lvPages.Selected := item;
    end;
  finally
    lvPages.EndUpdate;
  end;
end;

procedure TfrmWebPages.SetContentText(const Value: string);
begin
  edtWYSIWYG.HTML.Text := Value;
  edtSource.Text := Value;
end;

procedure TfrmWebPages.tcTextChange(Sender: TObject);
begin
  if tcText.ActiveTab = tiWYSIWYG then
  begin
    edtWYSIWYG.HTML.Text := edtSource.Text;
    tthread.ForceQueue(nil,
      procedure
      begin
        edtWYSIWYG.SetFocus;
      end);
  end;
  if tcText.ActiveTab = tiHTMLSource then
  begin
    edtSource.Text := edtWYSIWYG.Doc.InnerHTML;
    tthread.ForceQueue(nil,
      procedure
      begin
        edtSource.SetFocus;
      end);
  end;
end;

initialization

tdialogservice.PreferredMode := tdialogservice.TPreferredMode.Sync;

end.
