(* C2PP
  ***************************************************************************

  Delphi Books Database Admin
  Copyright (c) 2020-2026 Patrick PREMARTIN

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU Affero General Public License as
  published by the Free Software Foundation, either version 3 of the
  License, or (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU Affero General Public License for more details.

  You should have received a copy of the GNU Affero General Public License
  along with this program.  If not, see <https://www.gnu.org/licenses/>.

  ***************************************************************************

  Author(s) :
  Patrick PREMARTIN

  Site :
  https://delphi-books.com/opendata.html

  Project site :
  https://codeberg.org/Delphi-Books/DelphiBooks-DBAdmin

  ***************************************************************************
  File last update : 2026-06-15T19:35:44.141+02:00
  Signature : 31e123298312a7d614a56ee673baeef263fbd37c
  ***************************************************************************
*)

unit fBooksAuthors;

// TODO : add onResize event on form to resize the tlistviews
// TODO : add a button to create a new author (or access to authors CRUD screen)
interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, FMX.ListView.Types,
  FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.ListView,
  DelphiBooks.Classes, DelphiBooks.DB.Repository;

type
  TfrmBooksAuthors = class(TForm)
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
    FAuthors: TDelphiBooksAuthorShortsObjectList;
    FDB: TDelphiBooksDatabase;
    procedure MoveItem(ASelectedItem: TListItem;
      AFromListView, AToListView: TListView);
    procedure CopyItem(ASelectedItem: TListItem; AToListView: TListView);
    procedure RefreshLists;
  public
    { Déclarations publiques }
    constructor CreateWithAuthors(AOwner: TComponent;
      AAuthors: TDelphiBooksAuthorShortsObjectList; ADB: TDelphiBooksDatabase);
  end;

implementation

{$R *.fmx}

procedure TfrmBooksAuthors.btnAddClick(Sender: TObject);
begin
  if assigned(LvSource.Selected) and (LvSource.Selected is TListViewItem) then
    MoveItem(LvSource.Selected, LvSource, lvDestination);
end;

procedure TfrmBooksAuthors.btnCloseClick(Sender: TObject);
var
  i: integer;
  a: tdelphibooksauthor;
  ashort: TDelphiBooksAuthorShort;
begin
  FAuthors.Clear;
  for i := 0 to lvDestination.ItemCount - 1 do
  begin
    a := FDB.Authors.GetItemByGUID(lvDestination.Items[i].tagstring);
    if not assigned(a) then
      raise exception.Create('Author ' + lvDestination.Items[i].text +
        ' not found in the database !');
    ashort := TDelphiBooksAuthorShort.CreateFromJSON
      (a.ToJSONObject(true), true, true);
    if not assigned(ashort) then
      raise exception.Create('JSON format error for author ' +
        lvDestination.Items[i].text + ' !');
    FAuthors.Add(ashort);
  end;
  if assigned(FAuthors.Parent) then
    FAuthors.Parent.sethaschanged(true);
  close;
end;

procedure TfrmBooksAuthors.btnReloadClick(Sender: TObject);
begin
  RefreshLists;
end;

procedure TfrmBooksAuthors.btnRemoveClick(Sender: TObject);
begin
  if assigned(lvDestination.Selected) and
    (lvDestination.Selected is TListViewItem) then
    MoveItem(lvDestination.Selected, lvDestination, LvSource);
end;

constructor TfrmBooksAuthors.CreateWithAuthors(AOwner: TComponent;
  AAuthors: TDelphiBooksAuthorShortsObjectList; ADB: TDelphiBooksDatabase);
begin
  if not assigned(ADB) then
    raise exception.Create('The database is invalid !');

  if not assigned(AAuthors) then
    raise exception.Create('Authors list is invalid !');

  Create(AOwner);
  FAuthors := AAuthors;
  FDB := ADB;
end;

procedure TfrmBooksAuthors.CopyItem(ASelectedItem: TListItem;
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

procedure TfrmBooksAuthors.FormCreate(Sender: TObject);
begin
  RefreshLists;
end;

procedure TfrmBooksAuthors.MoveItem(ASelectedItem: TListItem;
  AFromListView, AToListView: TListView);
begin
  if not assigned(ASelectedItem) then
    raise exception.Create('No item to move !');
  if not assigned(AToListView) then
    raise exception.Create('No list view for destination !');

  CopyItem(ASelectedItem, AToListView);

  AFromListView.Items.delete(ASelectedItem.index);
end;

procedure TfrmBooksAuthors.RefreshLists;
var
  a: tdelphibooksauthor;
  item: TListViewItem;
begin
  LvSource.Items.Clear;
  lvDestination.Items.Clear;
  FDB.Authors.SortByName;
  if assigned(FDB.Authors) and (FDB.Authors.Count > 0) then
    for a in FDB.Authors do
    begin
      item := LvSource.Items.Add;
      item.text := a.PublicName;
      item.Detail := a.PageName;
      item.tagstring := a.Guid;

      if assigned(FAuthors.GetItemByGUID(a.Guid)) then
      begin
        LvSource.Selected := item;
        MoveItem(LvSource.Selected, LvSource, lvDestination);
      end;
    end;
end;

end.
