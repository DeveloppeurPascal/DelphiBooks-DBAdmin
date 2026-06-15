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
  https://github.com/DeveloppeurPascal/DelphiBooks-DBAdmin

  ***************************************************************************
  File last update : 2026-06-15T18:30:10.666+02:00
  Signature : 7116ff16159e8ffa18677d54a55b4b4b046a9df5
  ***************************************************************************
*)

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
