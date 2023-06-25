unit fChoixLangue;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.ListBox, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, uDM;

type
  TfrmChoixLangue = class(TForm)
    cbListeLangues: TComboBox;
    btnOk: TButton;
    btnCancel: TButton;
    btnGestionLangues: TButton;
    FDQuery1: TFDQuery;
    procedure FormShow(Sender: TObject);
    procedure btnGestionLanguesClick(Sender: TObject);
  private
    { Déclarations privées }
    FLangue_Code: integer;
    procedure ChargeListeLangues;
  public
    { Déclarations publiques }
    class function Execute(ALangue_Code: integer): integer;
  end;

var
  frmChoixLangue: TfrmChoixLangue;

implementation

{$R *.fmx}

uses fGestionLangues;

procedure TfrmChoixLangue.btnGestionLanguesClick(Sender: TObject);
var
  frm: TfrmGestionLangues;
begin
  frm := TfrmGestionLangues.Create(self);
  try
    frm.ShowModal;
    ChargeListeLangues;
  finally
    frm.Free;
  end;
end;

procedure TfrmChoixLangue.ChargeListeLangues;
var
  item: tlistboxitem;
begin
  cbListeLangues.Items.Clear;
  FDQuery1.Open('select libelle,code_iso,code from langues order by libelle');
  try
    FDQuery1.First;
    while not FDQuery1.Eof do
    begin
      item := tlistboxitem.Create(self);
      item.Text := FDQuery1.fieldbyname('libelle').Asstring + ' (' +
        FDQuery1.fieldbyname('code_iso').Asstring + ')';
      item.Tag := FDQuery1.fieldbyname('code').AsInteger;
      cbListeLangues.AddObject(item);
      if FDQuery1.fieldbyname('code').AsInteger = FLangue_Code then
        cbListeLangues.ItemIndex := cbListeLangues.Count - 1;
      FDQuery1.Next;
    end;
  finally
    FDQuery1.close;
  end;
end;

class function TfrmChoixLangue.Execute(ALangue_Code: integer): integer;
var
  frm: TfrmChoixLangue;
begin
  result := ALangue_Code;
  frm := TfrmChoixLangue.Create(application.mainform);
  try
    frm.FLangue_Code := ALangue_Code;
    if (frm.ShowModal = mrOk) and (frm.cbListeLangues.ItemIndex > -1) then
      result := frm.cbListeLangues.listitems[frm.cbListeLangues.ItemIndex].Tag;
  finally
    frm.Free;
  end;
end;

procedure TfrmChoixLangue.FormShow(Sender: TObject);
begin
  ChargeListeLangues;
end;

end.
