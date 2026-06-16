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
  File last update : 2026-06-15T19:35:44.023+02:00
  Signature : 09c91a83440ab85a1f13155a62ee6ecddad177ff
  ***************************************************************************
*)

unit fChoixPhotos;

// TODO : permettre de supprimer une photo
// TODO : vérifier la taille de l'image générée (ou d'origine) afin de limiter sa taille et pouvoir faire correctement les synchronisations entre serveurs
interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.ExtCtrls;

type
  TfrmChoixPhotos = class(TForm)
    ImageViewer1: TImageViewer;
    btnChoisir: TButton;
    GridPanelLayout1: TGridPanelLayout;
    btnOk: TButton;
    btnCancel: TButton;
    OpenDialog1: TOpenDialog;
    procedure FormShow(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnChoisirClick(Sender: TObject);
  private
    { Déclarations privées }
    FTableName: string;
    FCode: integer;
  public
    { Déclarations publiques }
    class procedure execute(ATableName: string; ACode: integer; ATitre: string);
  end;

var
  frmChoixPhotos: TfrmChoixPhotos;

implementation

{$R *.fmx}

uses System.IOUtils, uCheminDeStockage, uDM;

procedure TfrmChoixPhotos.btnCancelClick(Sender: TObject);
begin
  close;
end;

procedure TfrmChoixPhotos.btnChoisirClick(Sender: TObject);
begin
  if OpenDialog1.execute then
  begin
    ImageViewer1.Bitmap.LoadFromFile(OpenDialog1.FileName);
    btnOk.Enabled := true;
  end;
end;

procedure TfrmChoixPhotos.btnOkClick(Sender: TObject);
var
  nom_image: string;
begin
  nom_image := getCheminDeLaPhoto(FTableName, FCode);
  if tfile.Exists(nom_image) then
    tfile.Delete(nom_image);
  ImageViewer1.Bitmap.SaveToFile(nom_image);
  dmBaseDeDonnees.DB.ExecSQL('update ' + FTableName +
    ' set a_generer=1 where code=:c', [FCode]);
  // TODO : gérer les champs de synchronisation pour forcer la copie de la photo
  close;
end;

class procedure TfrmChoixPhotos.execute(ATableName: string; ACode: integer;
  ATitre: string);
var
  frm: TfrmChoixPhotos;
begin
  frm := TfrmChoixPhotos.Create(application.mainform);
  try
    frm.FTableName := ATableName;
    frm.FCode := ACode;
    frm.caption := 'Photo de ' + ATitre;
    frm.showmodal;
  finally
    frm.free;
  end;
end;

procedure TfrmChoixPhotos.FormShow(Sender: TObject);
var
  nom_image: string;
begin
  nom_image := getCheminDeLaPhoto(FTableName, FCode);
  if tfile.Exists(nom_image) then
    ImageViewer1.Bitmap.LoadFromFile(nom_image);
  btnOk.Enabled := false;
end;

end.
