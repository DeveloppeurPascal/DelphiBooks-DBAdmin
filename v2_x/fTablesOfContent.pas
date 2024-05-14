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
  TfrmTablesOfContent = class(TForm)
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
    btnItemClose: TButton;
    btnItemCancel: TButton;
    lblText: TLabel;
    lblISOCode: TLabel;
    edtISOCode: TEdit;
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
    procedure ListView1ButtonClick(const Sender: TObject;
      const AItem: TListItem; const AObject: TListItemSimpleControl);
    procedure btnAddClick(Sender: TObject);
    procedure btnItemCancelClick(Sender: TObject);
    procedure btnItemCloseClick(Sender: TObject);
    procedure tcTextChange(Sender: TObject);
    procedure mnuCollerClick(Sender: TObject);
    procedure mnuCopierClick(Sender: TObject);
    procedure mnuCouperClick(Sender: TObject);
    procedure mnuToutSelectionnerClick(Sender: TObject);
  private
    fTableOfContents: TDelphiBooksTableOfContentsObjectList;
    fDB: TDelphiBooksDatabase;
    function GetContentText: string;
    procedure SetContentText(const Value: string);
  public
    property ContentText: string read GetContentText write SetContentText;
    constructor CreateWithTableOfContentsList(AOwner: TComponent;
      ATableOfContents: TDelphiBooksTableOfContentsObjectList;
      ADB: TDelphiBooksDatabase);
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

procedure TfrmTablesOfContent.btnItemCancelClick(Sender: TObject);
begin
  if TabControl1.ActiveTab <> tiEdit then
    exit;

  TabControl1.Previous;
end;

procedure TfrmTablesOfContent.btnItemCloseClick(Sender: TObject);
var
  d: TDelphiBooksTableOfContent;
begin
  if TabControl1.ActiveTab <> tiEdit then
    exit;

  ContentText := ContentText.Trim;
  if ContentText.IsEmpty then
    raise exception.Create('Text is needed !');

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
      ('Use the ISO 2 letters language code for a table of content !');
  end
  else
  begin
    for d in fTableOfContents do
      if (d.LanguageISOCode = edtISOCode.Text) and
        ((not assigned(ListView1.Selected)) or
        (ListView1.Selected.TagObject <> d)) then
      begin
        edtISOCode.SetFocus;
        raise exception.Create
          ('This language is already used for a table of content !');
      end;
    if not assigned(fDB.Languages.GetItemByLanguage(edtISOCode.Text)) then
    begin
      edtISOCode.SetFocus;
      raise exception.Create
        ('This language is unknonw ! Add it to the database from the main menu.');
    end;
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
  d.Text := ContentText;
  d.LanguageISOCode := edtISOCode.Text;
  if assigned(fTableOfContents.Parent) then
    fTableOfContents.Parent.sethaschanged(true);
  RefreshListView(d.Guid);
  TabControl1.Previous;
end;

procedure TfrmTablesOfContent.btnCloseClick(Sender: TObject);
begin
  if TabControl1.ActiveTab <> tiList then
    exit;

  Close;
end;

constructor TfrmTablesOfContent.CreateWithTableOfContentsList
  (AOwner: TComponent; ATableOfContents: TDelphiBooksTableOfContentsObjectList;
  ADB: TDelphiBooksDatabase);
begin
  if not assigned(ADB) then
    raise exception.Create('The database is invalid !');
  if not assigned(ATableOfContents) then
    raise exception.Create('Table of content list is invalid !');
  Create(AOwner);
  fTableOfContents := ATableOfContents;
  fDB := ADB;
end;

procedure TfrmTablesOfContent.FormCreate(Sender: TObject);
begin
  TabControl1.ActiveTab := tiList;
  RefreshListView;

  // Adaptation du menu pour macOS
{$IFDEF MACOS}
  mnuMacOS.Visible := true;
{$ELSE}
  mnuMacOS.Visible := false;
{$ENDIF}
end;

function TfrmTablesOfContent.GetContentText: string;
begin
  if tcText.ActiveTab = tiWYSIWYG then
    result := edtWYSIWYG.Doc.InnerHTML
  else
    result := edtSource.Text;
end;

procedure TfrmTablesOfContent.InitEdit;
begin
  ContentText := '';
  edtISOCode.Text := '';
  tcText.ActiveTab := tiWYSIWYG;
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
  ContentText := d.Text;
  edtISOCode.Text := d.LanguageISOCode;
  TabControl1.Next;
end;

procedure TfrmTablesOfContent.mnuCollerClick(Sender: TObject);
begin
  if TabControl1.ActiveTab = tiEdit then
    if tcText.ActiveTab = tiWYSIWYG then
      HtActionPaste1.Execute
    else
      edtSource.PasteFromClipboard;
end;

procedure TfrmTablesOfContent.mnuCopierClick(Sender: TObject);
begin
  if TabControl1.ActiveTab = tiEdit then
    if tcText.ActiveTab = tiWYSIWYG then
      HtActionCopy1.Execute
    else
      edtSource.CopyToClipboard;
end;

procedure TfrmTablesOfContent.mnuCouperClick(Sender: TObject);
begin
  if TabControl1.ActiveTab = tiEdit then
    if tcText.ActiveTab = tiWYSIWYG then
      HtActionCut1.Execute
    else
      edtSource.CutToClipboard;
end;

procedure TfrmTablesOfContent.mnuToutSelectionnerClick(Sender: TObject);
begin
  if TabControl1.ActiveTab = tiEdit then
    if tcText.ActiveTab = tiWYSIWYG then
      edtWYSIWYG.SelectAll
    else
      edtSource.SelectAll;
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

procedure TfrmTablesOfContent.SetContentText(const Value: string);
begin
  edtWYSIWYG.HTML.Text := Value;
  edtSource.Text := Value;
end;

procedure TfrmTablesOfContent.tcTextChange(Sender: TObject);
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
