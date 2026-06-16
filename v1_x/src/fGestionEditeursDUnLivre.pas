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
  File last update : 2026-06-15T19:35:44.061+02:00
  Signature : a9134c99d2268eba9cc909b0daa07a0400c2f9d7
  ***************************************************************************
*)

unit fGestionEditeursDUnLivre;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  FMX.Layouts, FMX.Controls.Presentation, FMX.StdCtrls, FMX.ListView, uDM,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client;

type
  TfrmGestionEditeursDUnLivre = class(TForm)
    lvListeComplete: TListView;
    btnGestionEditeurs: TButton;
    lvListeDuLivre: TListView;
    Layout2: TLayout;
    Layout3: TLayout;
    btnAjouter: TButton;
    btnSupprimer: TButton;
    GridPanelLayout1: TGridPanelLayout;
    btnOk: TButton;
    btnCancel: TButton;
    FDQuery1: TFDQuery;
    Layout1: TLayout;
    procedure btnAjouterClick(Sender: TObject);
    procedure btnSupprimerClick(Sender: TObject);
    procedure btnGestionEditeursClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure lvListeCompleteDblClick(Sender: TObject);
    procedure lvListeDuLivreDblClick(Sender: TObject);
  private
    { Déclarations privées }
    FLivre_Code: integer;
    procedure ChargeListe;
  public
    { Déclarations publiques }
    class procedure execute(ALivre_Code: integer; ATitre: string);
  end;

var
  frmGestionEditeursDUnLivre: TfrmGestionEditeursDUnLivre;

implementation

{$R *.fmx}

uses fGestionEditeurs;

procedure TfrmGestionEditeursDUnLivre.btnAjouterClick(Sender: TObject);
var
  item, select: tlistviewitem;
begin
  if assigned(lvListeComplete.Selected) then
  begin
    select := (lvListeComplete.Selected as tlistviewitem);
    item := lvListeDuLivre.Items.Add;
    item.Text := select.Text;
    item.Tag := select.Tag;
    lvListeComplete.Items.Delete(select.Index);
  end;
end;

procedure TfrmGestionEditeursDUnLivre.btnCancelClick(Sender: TObject);
begin
  close;
end;

procedure TfrmGestionEditeursDUnLivre.btnGestionEditeursClick(Sender: TObject);
var
  frm: TfrmGestionEditeurs;
begin
  frm := TfrmGestionEditeurs.Create(Self);
  try
    frm.ShowModal;
    ChargeListe;
  finally
    frm.Free;
  end;
end;

procedure TfrmGestionEditeursDUnLivre.btnOkClick(Sender: TObject);
var
  item: tlistviewitem;
begin
  dmBaseDeDonnees.DB.ExecSQL
    ('update livres_editeurs_lien set livre_code=-1,editeur_code=-1 where livre_code=:lc',
    [FLivre_Code]);
  // TODO : remplacer par une suppression logique des enregistrements
  // TODO : prévoir un module de ménage sur les tables concernées
  for item in lvListeDuLivre.Items do
  begin
    dmBaseDeDonnees.tabLivresEditeursLien.Insert;
    dmBaseDeDonnees.tabLivresEditeursLien.fieldbyname('livre_code').AsInteger :=
      FLivre_Code;
    dmBaseDeDonnees.tabLivresEditeursLien.fieldbyname('editeur_code').AsInteger
      := item.Tag;
    dmBaseDeDonnees.tabLivresEditeursLien.post;
  end;
  close;
end;

procedure TfrmGestionEditeursDUnLivre.btnSupprimerClick(Sender: TObject);
var
  item, select: tlistviewitem;
begin
  if assigned(lvListeDuLivre.Selected) then
  begin
    select := (lvListeDuLivre.Selected as tlistviewitem);
    item := lvListeComplete.Items.Add;
    item.Text := select.Text;
    item.Tag := select.Tag;
    lvListeDuLivre.Items.Delete(select.Index);
  end;
end;

procedure TfrmGestionEditeursDUnLivre.ChargeListe;
var
  item: tlistviewitem;
begin
  lvListeComplete.Items.Clear;
  lvListeDuLivre.Items.Clear;
  FDQuery1.Open('select * from editeurs order by raison_sociale');
  try
    FDQuery1.First;
    while not FDQuery1.Eof do
    begin
      if 0 < dmBaseDeDonnees.DB.ExecSQLScalar
        ('select count(*) from livres_editeurs_lien where livre_code=:lc and editeur_code=:ac',
        [FLivre_Code, FDQuery1.fieldbyname('code').AsInteger]) then
        item := lvListeDuLivre.Items.Add
      else
        item := lvListeComplete.Items.Add;
      item.Text := FDQuery1.fieldbyname('raison_sociale').AsString;
      item.Tag := FDQuery1.fieldbyname('code').AsInteger;
      FDQuery1.Next;
    end;
  finally
    FDQuery1.close;
  end;
end;

class procedure TfrmGestionEditeursDUnLivre.execute(ALivre_Code: integer;
  ATitre: string);
var
  frm: TfrmGestionEditeursDUnLivre;
begin
  frm := TfrmGestionEditeursDUnLivre.Create(application.mainform);
  try
    frm.FLivre_Code := ALivre_Code;
    frm.caption := 'Editeurs du livre ' + ATitre;
    frm.ShowModal;
  finally
    frm.Free;
  end;
end;

procedure TfrmGestionEditeursDUnLivre.FormShow(Sender: TObject);
begin
  ChargeListe;
end;

procedure TfrmGestionEditeursDUnLivre.lvListeCompleteDblClick(Sender: TObject);
begin
  btnAjouterClick(Sender);
end;

procedure TfrmGestionEditeursDUnLivre.lvListeDuLivreDblClick(Sender: TObject);
begin
  btnSupprimerClick(Sender);
end;

end.
