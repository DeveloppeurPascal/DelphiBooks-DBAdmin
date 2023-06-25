unit fGestionTextesComplementaires;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants, FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics,
  FMX.Dialogs, FMX.ListBox, FMX.StdCtrls, FMX.Controls.Presentation,
  FMX.Layouts, uDM, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, FMX.Objects;

type
  TfrmGestionTextesComplementaires = class(TForm)
    Layout1: TLayout;
    btnFermer: TButton;
    lblLangue: TLabel;
    cbLangues: TComboBox;
    FDQuery1: TFDQuery;
    ScrollBox1: TScrollBox;
    btnTraduireLesAutres: TButton;
    btnModifier: TButton;
    Texte: TText;
    procedure btnFermerClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure cbLanguesChange(Sender: TObject);
    procedure btnModifierClick(Sender: TObject);
    procedure btnTraduireLesAutresClick(Sender: TObject);
  private
    { Déclarations privées }
    FMasterTableName: string;
    FMasterCode: integer;
    FTableName: string;
    FTable: TFDTable;
    FKeyFieldName: string;
    FTxtFieldName: string;
    FLangue_Code: integer;
    fcode: integer;
  protected
  public
    { Déclarations publiques }
    class procedure execute(ATitre, AMasterTableName: string;
      AMasterCode: integer; ATable: TFDTable; ATableName, AKeyFieldName,
      ATxtFieldName: string);
  end;

var
  frmGestionTextesComplementaires: TfrmGestionTextesComplementaires;

implementation

{$R *.fmx}

uses
  OlfSoftware.DeepL.ClientLib, System.IOUtils, FMX.DialogService;

procedure TfrmGestionTextesComplementaires.btnFermerClick(Sender: TObject);
begin
  close;
end;

procedure TfrmGestionTextesComplementaires.btnModifierClick(Sender: TObject);
//var
//  EditeurHTML: TTMSFNCHTMLEditor;
begin
//  if cbLangues.ItemIndex > -1 then
//  begin
//    EditeurHTML := TTMSFNCHTMLEditor.Create(self);
//    try
//      EditeurHTML.Text := texte.Text;
//      if EditeurHTML.execute = mrok then
//      begin
//        texte.Text := EditeurHTML.Text;
//        if FTable.FindKey([fcode]) then
//          FTable.edit
//        else
//        begin
//          FTable.insert;
//          FTable.fieldbyname(FKeyFieldName).AsInteger := FMasterCode;
//          FTable.fieldbyname('langue_code').AsInteger := FLangue_Code;
//        end;
//        FTable.fieldbyname(FTxtFieldName).Asstring := texte.Text;
//        FTable.post;
//      end;
//    finally
//      EditeurHTML.free;
//    end;
//  end;
raise exception.Create('Fonctionnalité indisponible. (remplacer composant TTMSFNCHTMLEditor)');
end;

procedure TfrmGestionTextesComplementaires.btnTraduireLesAutresClick
  (Sender: TObject);
var
  TexteSource: string;
  LangueSource: string;
  TexteTraduit: string;
  LangueDestination: string;
begin
  // On prend le texte de la langue actuelle et on écrase les autres langues avec lui
  if cbLangues.ItemIndex > -1 then
  begin
    TexteSource := texte.Text;
    LangueSource := dmBaseDeDonnees.DB.ExecSQLScalar
      ('select code_iso from langues where code=:c', [FLangue_Code]);
    FDQuery1.open('select * from langues where code<>:c', [FLangue_Code]);
    try
      while not FDQuery1.eof do
      begin
        LangueDestination := FDQuery1.fieldbyname('code_iso').Asstring;
        TexteTraduit := DeepLTranslateTextSync
          (tfile.readalltext(tpath.combine(tpath.GetDocumentsPath,
          'cle-deepl.txt')), LangueSource, LangueDestination, TexteSource);
        TDialogService.MessageDialog('La traduction ' + LangueSource + '->' +
          LangueDestination + ' donne "' + TexteTraduit +
          '". Ecraser le texte existant ?', TMsgDlgType.mtconfirmation, mbYesNo,
          tmsgdlgbtn.mbNo, 0,
          procedure(const ModalRestul: TModalResult)
          var
            MsgCode: integer;
          begin
            if (ModalRestul = mrYes) then
            begin
              MsgCode := dmBaseDeDonnees.DB.ExecSQLScalar('select code from ' +
                FTableName + ' where langue_code=:lc and ' + FKeyFieldName +
                '=:kfnc', [FDQuery1.fieldbyname('code').AsInteger,
                FMasterCode]);
              if (MsgCode < 1) then
                dmBaseDeDonnees.DB.ExecSQL('insert into ' + FTableName + ' (' +
                  FKeyFieldName + ',langue_code,' + FTxtFieldName +
                  ') values (:kfnc,:lc,:txt)',
                  [FMasterCode, FDQuery1.fieldbyname('code').AsInteger,
                  TexteTraduit])
              else
                dmBaseDeDonnees.DB.ExecSQL('update ' + FTableName + ' set ' +
                  FTxtFieldName + '=:txt where (code=:c)',
                  [TexteTraduit, MsgCode]);
            end;
          end);
        FDQuery1.next;
      end;
    finally
      FDQuery1.close;
    end;
  end;
end;

procedure TfrmGestionTextesComplementaires.cbLanguesChange(Sender: TObject);

begin
  if (cbLangues.ListItems[cbLangues.ItemIndex].Tag > -1) then
  begin
    texte.Text := '';
    fcode := -1;
    FLangue_Code := cbLangues.ListItems[cbLangues.ItemIndex].Tag;
    FDQuery1.open('select code,' + FTxtFieldName + ' from ' + FTableName +
      ' where langue_code=:lc and ' + FKeyFieldName + '=:c',
      [FLangue_Code, FMasterCode]);
    try
      FDQuery1.First;
      if not FDQuery1.eof then
      begin
        texte.Text := FDQuery1.fieldbyname(FTxtFieldName).Asstring;
        fcode := FDQuery1.fieldbyname('code').AsInteger;
      end;
    finally
      FDQuery1.close;
    end;
  end
  else
    FLangue_Code := -1;
end;

class procedure TfrmGestionTextesComplementaires.execute(ATitre,
  AMasterTableName: string; AMasterCode: integer; ATable: TFDTable;
ATableName, AKeyFieldName, ATxtFieldName: string);
var
  frm: TfrmGestionTextesComplementaires;
begin
  frm := TfrmGestionTextesComplementaires.Create(application.mainform);
  try
    frm.caption := ATitre;
    frm.FMasterTableName := AMasterTableName;
    frm.FMasterCode := AMasterCode;
    frm.FTable := ATable;
    frm.FTableName := ATableName;
    frm.FKeyFieldName := AKeyFieldName;
    frm.FTxtFieldName := ATxtFieldName;
    frm.showmodal;
  finally
    frm.free;
  end;
end;

procedure TfrmGestionTextesComplementaires.FormShow(Sender: TObject);
var
  item: tlistboxitem;
begin
  texte.Text := '';
  fcode := -1;
  // Alimentation de la liste des langues disponibles
  cbLangues.Items.Clear;
  FDQuery1.open('select libelle,code_iso,code from langues order by libelle');
  try
    FDQuery1.First;
    while not FDQuery1.eof do
    begin
      item := tlistboxitem.Create(self);
      item.Text := FDQuery1.fieldbyname('libelle').Asstring + ' (' +
        FDQuery1.fieldbyname('code_iso').Asstring + ')';
      item.Tag := FDQuery1.fieldbyname('code').AsInteger;
      cbLangues.AddObject(item);
      FDQuery1.next;
    end;
  finally
    FDQuery1.close;
  end;
  FLangue_Code := -1;
end;

initialization

TDialogService.PreferredMode := TDialogService.TPreferredMode.Sync;

end.
