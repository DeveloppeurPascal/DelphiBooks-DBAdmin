unit fBooks;

// TODO : add a DELETE feature
// TODO : add the CRUD for books KEYWORDS

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
  TfrmBooks = class(TForm)
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
    lblPubDate: TLabel;
    edtPubDate: TEdit;
    lblWebSite: TLabel;
    edtWebSite: TEdit;
    lblPageName: TLabel;
    edtPageName: TEdit;
    lblISBN10: TLabel;
    edtISBN10: TEdit;
    lblTitle: TLabel;
    edtTitle: TEdit;
    lblISBN13: TLabel;
    edtISBN13: TEdit;
    gplContextualMenu: TGridPanelLayout;
    btnDescriptions: TButton;
    btnTableOfContent: TButton;
    btnBookAuthors: TButton;
    brnBookPublishers: TButton;
    btnCoverImage: TButton;
    procedure btnCloseClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure ListView1ButtonClick(const Sender: TObject;
      const AItem: TListItem; const AObject: TListItemSimpleControl);
    procedure btnAddClick(Sender: TObject);
    procedure btnItemCancelClick(Sender: TObject);
    procedure btnItemSaveClick(Sender: TObject);
    procedure edtTitleChange(Sender: TObject);
    procedure btnDescriptionsClick(Sender: TObject);
    procedure btnTableOfContentClick(Sender: TObject);
    procedure btnBookAuthorsClick(Sender: TObject);
    procedure brnBookPublishersClick(Sender: TObject);
    procedure btnCoverImageClick(Sender: TObject);
  private
    { Déclarations privées }
    FDB: tdelphibooksdatabase;
    function getCurrentBook: TDelphiBooksBook;
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
  System.IOUtils,
  FMX.DialogService,
  DelphiBooks.Tools,
  fDescriptions,
  fTablesOfContent,
  fBooksAuthors,
  fBooksPublishers,
  fBookCoverImage;

{ Tfrmbooks }

procedure TfrmBooks.brnBookPublishersClick(Sender: TObject);
var
  f: TfrmBooksPublishers;
  b: TDelphiBooksBook;
begin
  b := getCurrentBook;
  if assigned(b) then
  begin
    f := TfrmBooksPublishers.CreateWithPublishers(self, b.Publishers, FDB);
    try
      f.ShowModal;
    finally
      f.Free;
    end;
  end;
end;

procedure TfrmBooks.btnAddClick(Sender: TObject);
begin
  if TabControl1.ActiveTab <> tiList then
    exit;

  ListView1.Selected := nil;
  InitEdit;
  TabControl1.Next;
end;

procedure TfrmBooks.btnBookAuthorsClick(Sender: TObject);
var
  f: TfrmBooksAuthors;
  b: TDelphiBooksBook;
begin
  b := getCurrentBook;
  if assigned(b) then
  begin
    f := TfrmBooksAuthors.CreateWithAuthors(self, b.Authors, FDB);
    try
      f.ShowModal;
    finally
      f.Free;
    end;
  end;
end;

procedure TfrmBooks.btnCloseClick(Sender: TObject);
begin
  if TabControl1.ActiveTab <> tiList then
    exit;

  Close;
end;

procedure TfrmBooks.btnCoverImageClick(Sender: TObject);
var
  f: TfrmBookCoverImage;
  b: TDelphiBooksBook;
begin
  b := getCurrentBook;
  f := TfrmBookCoverImage.CreateFromPhoto(self,
    tpath.combine(FDB.DatabaseFolder, b.GetImageFileName), b);
  try
    f.ShowModal;
  finally
    f.Free;
  end;
end;

procedure TfrmBooks.btnDescriptionsClick(Sender: TObject);
var
  f: TfrmDescriptions;
  b: TDelphiBooksBook;
begin
  b := getCurrentBook;
  if assigned(b) then
  begin
    f := TfrmDescriptions.CreateWithDescriptionsList(self, b.Descriptions, FDB);
    try
      f.ShowModal;
    finally
      f.Free;
    end;
  end;
end;

procedure TfrmBooks.btnItemCancelClick(Sender: TObject);
begin
  if TabControl1.ActiveTab <> tiEdit then
    exit;

  TabControl1.Previous;
end;

procedure TfrmBooks.btnItemSaveClick(Sender: TObject);
var
  b: TDelphiBooksBook;
  s: string;
begin
  if TabControl1.ActiveTab <> tiEdit then
    exit;

  edtTitle.Text := edtTitle.Text.Trim;
  if edtTitle.Text.IsEmpty then
  begin
    edtTitle.SetFocus;
    raise exception.Create('A book needs a title !');
  end;

  edtISBN10.Text := edtISBN10.Text.Trim;

  edtISBN13.Text := edtISBN13.Text.Trim;

  edtPubDate.Text := edtPubDate.Text.Trim;
  if edtPubDate.Text.IsEmpty then
  begin
    edtPubDate.SetFocus;
    raise exception.Create
      ('Publication date is needed (YYYY0000, or YYYYMM00 or YYYYMMDD) !');
  end;
  // TODO : add PubDate format test (8 numbers)

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

  b := getCurrentBook;

  if not FDB.isPageNameUniq(edtPageName.Text, TDelphiBooksTable.books, b) then
  begin
    edtPageName.SetFocus;
    raise exception.Create('This page name already exist !');
  end;

  if not assigned(b) then
  begin
    b := TDelphiBooksBook.Create;
    FDB.books.Add(b);
  end;
  b.Title := edtTitle.Text;
  b.ISBN10 := edtISBN10.Text;
  b.ISBN13 := edtISBN13.Text;
  b.PublishedDateYYYYMMDD := edtPubDate.Text;
  b.WebSiteURL := edtWebSite.Text;
  b.PageName := edtPageName.Text;
  FDB.SaveItemToRepository(b, TDelphiBooksTable.books);
  RefreshListView(b.Guid);
  TabControl1.Previous;
end;

procedure TfrmBooks.btnTableOfContentClick(Sender: TObject);
var
  f: TfrmTablesOfContent;
  b: TDelphiBooksBook;
begin
  b := getCurrentBook;
  if assigned(b) then
  begin
    f := TfrmTablesOfContent.CreateWithTableOfContentsList(self, b.TOCs, FDB);
    try
      f.ShowModal;
    finally
      f.Free;
    end;
  end;
end;

constructor TfrmBooks.CreateWithDB(AOwner: TComponent;
  ADB: tdelphibooksdatabase);
begin
  if not assigned(ADB) then
    raise exception.Create('No database available !');
  if not assigned(ADB.books) then
    raise exception.Create('books list is invalid !');
  Create(AOwner);
  FDB := ADB;
end;

procedure TfrmBooks.edtTitleChange(Sender: TObject);
begin
  SetPageNameFromText;
end;

procedure TfrmBooks.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  b: TDelphiBooksBook;
  LCanClose: Boolean;
begin
  for b in FDB.books do
    CanClose := CanClose and (not b.hasChanged);
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
      FDB.LoadbooksFromRepository;
  end;
end;

procedure TfrmBooks.FormCreate(Sender: TObject);
begin
  TabControl1.ActiveTab := tiList;
  RefreshListView;
end;

function TfrmBooks.getCurrentBook: TDelphiBooksBook;
begin
  if assigned(ListView1.Selected) and assigned(ListView1.Selected.TagObject) and
    (ListView1.Selected.TagObject is TDelphiBooksBook) then
    result := ListView1.Selected.TagObject as TDelphiBooksBook
  else
    result := nil;
end;

procedure TfrmBooks.InitEdit;
begin
  edtTitle.Text := '';
  edtISBN10.Text := '';
  edtISBN13.Text := '';
  edtPubDate.Text := '';
  edtWebSite.Text := '';
  edtPageName.Text := '';
end;

procedure TfrmBooks.ListView1ButtonClick(const Sender: TObject;
const AItem: TListItem; const AObject: TListItemSimpleControl);
var
  b: TDelphiBooksBook;
begin
  if not assigned(AItem) then
    raise exception.Create('No item for this button !');

  if not assigned(AItem.TagObject) then
    raise exception.Create('No object for this item !');

  if not(AItem.TagObject is TDelphiBooksBook) then
    raise exception.Create('This item is not a book !');

  if (ListView1.Selected <> AItem) then
    raise exception.Create('Selected item is not this one !');

  b := AItem.TagObject as TDelphiBooksBook;

  InitEdit;
  edtTitle.Text := b.Title;
  edtISBN10.Text := b.ISBN10;
  edtISBN13.Text := b.ISBN13;
  edtPubDate.Text := b.PublishedDateYYYYMMDD;
  edtWebSite.Text := b.WebSiteURL;
  edtPageName.Text := b.PageName;
  TabControl1.Next;
end;

procedure TfrmBooks.RefreshListView(AGuid: string);
var
  b: TDelphiBooksBook;
  item: tlistviewitem;
begin
  ListView1.BeginUpdate;
  try
    ListView1.Items.Clear;
    FDB.books.SortByTitle;
    for b in FDB.books do
    begin
      item := ListView1.Items.Add;
      item.Text := b.Title;
      item.Detail := b.PublishedDateYYYYMM + ' - ' + b.ISBN13 + ' - ' +
        b.PageName;
      item.ButtonText := 'Edit';
      item.TagObject := b;
      if (b.Guid = AGuid) then
        ListView1.Selected := item;
    end;
  finally
    ListView1.EndUpdate;
  end;
end;

procedure TfrmBooks.SetPageNameFromText;
begin
  edtPageName.Text := edtPageName.Text.Trim;
  if edtPageName.Text.IsEmpty then
    if not edtTitle.Text.IsEmpty then
      edtPageName.Text := tourl(edtTitle.Text);
end;

initialization

tdialogservice.PreferredMode := tdialogservice.TPreferredMode.Sync;

end.
