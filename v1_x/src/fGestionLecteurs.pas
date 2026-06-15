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
  File last update : 2026-06-15T18:30:10.688+02:00
  Signature : b7b136e93fad12489647060a002f88c0bab38ad8
  ***************************************************************************
*)

unit fGestionLecteurs;

// TODO : s'assurer que le pseudo est rempli à l'enregistrement
// TODO : gérer les photos des lecteurs
interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, uDM,
  System.Rtti, FMX.Grid.Style, Data.Bind.Controls, FMX.StdCtrls, FMX.Layouts,
  FMX.Bind.Navigator, FMX.Controls.Presentation, FMX.ScrollBox, FMX.Grid,
  Data.Bind.EngExt, FMX.Bind.DBEngExt, FMX.Bind.Grid, System.Bindings.Outputs,
  FMX.Bind.Editors, Data.Bind.Components, Data.Bind.Grid, Data.Bind.DBScope,
  FMX.Menus;

type
  TfrmGestionLecteurs = class(TForm)
    StringGrid1: TStringGrid;
    BindNavigator1: TBindNavigator;
    btnFermer: TButton;
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    LinkGridToDataSourceBindSourceDB1: TLinkGridToDataSource;
    PopupMenu1: TPopupMenu;
    mnuCommentaires: TMenuItem;
    procedure btnFermerClick(Sender: TObject);
    procedure mnuCommentairesClick(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  frmGestionLecteurs: TfrmGestionLecteurs;

implementation

{$R *.fmx}

uses fGestionTextesComplementaires, Data.db;

procedure TfrmGestionLecteurs.btnFermerClick(Sender: TObject);
begin
  close;
end;

procedure TfrmGestionLecteurs.mnuCommentairesClick(Sender: TObject);
begin
  // TODO : gestion des commentaires d'un lecteur
end;

procedure TfrmGestionLecteurs.PopupMenu1Popup(Sender: TObject);
var
  ok: Boolean;
begin
  ok := not(dmBaseDeDonnees.tabLecteurs.Eof or dmBaseDeDonnees.tabLecteurs.bof)
    and not(dmBaseDeDonnees.tabLecteurs.state in [dsinsert, dsedit]);
  mnuCommentaires.Enabled := false; // ok;
end;

end.
