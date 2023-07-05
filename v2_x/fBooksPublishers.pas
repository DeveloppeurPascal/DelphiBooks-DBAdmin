unit fBooksPublishers;

// TODO : add onResize event on form to resize the tlistviews
// TODO : add a button to create a new Publisher (or access to Publishers CRUD screen)
interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, FMX.ListView.Types,
  FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.ListView,
  DelphiBooks.Classes, DelphiBooks.DB.Repository;

type
  TfrmBooksPublishers = class(TForm)
    GridPanelLayout1: TGridPanelLayout;
    btnClose: TButton;
    LvSource: TListView;
    Layout1: TLayout;
    lvDestination: TListView;
    Layout2: TLayout;
    btnAdd: TButton;
    btnRemove: TButton;
    btnReload: TButton;
    procedure btnCloseClick(Sender: TObject);
    procedure btnReloadClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure btnRemoveClick(Sender: TObject);
  private
    { Déclarations privées }
    FPublishers: TDelphiBooksPublisherShortsObjectList;
    FDB: TDelphiBooksDatabase;
    procedure MoveItem(ASelectedItem: TListItem;
      AFromListView, AToListView: TListView);
    procedure CopyItem(ASelectedItem: TListItem; AToListView: TListView);
    procedure RefreshLists;
  public
    { Déclarations publiques }
    constructor CreateWithPublishers(AOwner: TComponent;
      APublishers: TDelphiBooksPublisherShortsObjectList;
      ADB: TDelphiBooksDatabase);
  end;

implementation

{$R *.fmx}

procedure TfrmBooksPublishers.btnAddClick(Sender: TObject);
begin
  if assigned(LvSource.Selected) and (LvSource.Selected is TListViewItem) then
    MoveItem(LvSource.Selected, LvSource, lvDestination);
end;

procedure TfrmBooksPublishers.btnCloseClick(Sender: TObject);
var
  i: integer;
  p: tdelphibooksPublisher;
  pshort: TDelphiBooksPublisherShort;
begin
  FPublishers.Clear;
  for i := 0 to lvDestination.ItemCount - 1 do
  begin
    p := FDB.Publishers.GetItemByGUID(lvDestination.Items[i].tagstring);
    if not assigned(p) then
      raise exception.Create('Publisher ' + lvDestination.Items[i].text +
        ' not foud in the database !');
    pshort := TDelphiBooksPublisherShort.CreateFromJSON
      (p.ToJSONObject(true), true);
    if not assigned(pshort) then
      raise exception.Create('JSON format error for Publisher ' +
        lvDestination.Items[i].text + ' !');
    FPublishers.Add(pshort);
  end;
  if assigned(FPublishers.Parent) then
    FPublishers.Parent.sethaschanged(true);
  close;
end;

procedure TfrmBooksPublishers.btnReloadClick(Sender: TObject);
begin
  RefreshLists;
end;

procedure TfrmBooksPublishers.btnRemoveClick(Sender: TObject);
begin
  if assigned(lvDestination.Selected) and
    (lvDestination.Selected is TListViewItem) then
    MoveItem(lvDestination.Selected, lvDestination, LvSource);
end;

constructor TfrmBooksPublishers.CreateWithPublishers(AOwner: TComponent;
  APublishers: TDelphiBooksPublisherShortsObjectList;
  ADB: TDelphiBooksDatabase);
begin
  if not assigned(ADB) then
    raise exception.Create('The database is invalid !');

  if not assigned(APublishers) then
    raise exception.Create('Publishers list is invalid !');

  Create(AOwner);
  FPublishers := APublishers;
  FDB := ADB;
end;

procedure TfrmBooksPublishers.CopyItem(ASelectedItem: TListItem;
  AToListView: TListView);
var
  NewItem, OldItem: TListViewItem;
begin
  if not assigned(ASelectedItem) then
    raise exception.Create('No item to move !');
  if not assigned(AToListView) then
    raise exception.Create('No list view for destination !');

  OldItem := ASelectedItem as TListViewItem;

  NewItem := AToListView.Items.Add;
  NewItem.text := OldItem.text;
  NewItem.Detail := OldItem.Detail;
  NewItem.tagstring := OldItem.tagstring;
end;

procedure TfrmBooksPublishers.FormCreate(Sender: TObject);
begin
  RefreshLists;
end;

procedure TfrmBooksPublishers.MoveItem(ASelectedItem: TListItem;
  AFromListView, AToListView: TListView);
begin
  if not assigned(ASelectedItem) then
    raise exception.Create('No item to move !');
  if not assigned(AToListView) then
    raise exception.Create('No list view for destination !');

  CopyItem(ASelectedItem, AToListView);

  AFromListView.Items.delete(ASelectedItem.index);
end;

procedure TfrmBooksPublishers.RefreshLists;
var
  p: tdelphibooksPublisher;
  item: TListViewItem;
begin
  LvSource.Items.Clear;
  lvDestination.Items.Clear;
  FDB.Publishers.SortByCompanyName;
  if assigned(FDB.Publishers) and (FDB.Publishers.Count > 0) then
    for p in FDB.Publishers do
    begin
      item := LvSource.Items.Add;
      item.text := p.companyname;
      item.Detail := p.PageName;
      item.tagstring := p.Guid;

      if assigned(FPublishers.GetItemByGUID(p.Guid)) then
      begin
        LvSource.Selected := item;
        MoveItem(LvSource.Selected, LvSource, lvDestination);
      end;
    end;
end;

end.
