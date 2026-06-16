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
  File last update : 2026-06-15T19:35:44.056+02:00
  Signature : 6185638c979469812853f47ab207270a38f8e7f9
  ***************************************************************************
*)

unit fGestionEditeurs;

// TODO : s'assurer que la raison sociale est bien renseignée lors de l'enregistrement
// TODO : ajouter la gestion des livres de l'éditeur (consultation et modification)
// TODO : gérer les photos des éditerus (ou leur logo)
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
  TfrmGestionEditeurs = class(TForm)
    StringGrid1: TStringGrid;
    BindNavigator1: TBindNavigator;
    btnFermer: TButton;
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    LinkGridToDataSourceBindSourceDB1: TLinkGridToDataSource;
    PopupMenu1: TPopupMenu;
    mnuDescriptions: TMenuItem;
    procedure btnFermerClick(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure mnuDescriptionsClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  frmGestionEditeurs: TfrmGestionEditeurs;

implementation

{$R *.fmx}

uses fGestionTextesComplementaires, Data.db;

procedure TfrmGestionEditeurs.btnFermerClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmGestionEditeurs.FormShow(Sender: TObject);
begin
  dmBaseDeDonnees.tabEditeurs.First;
end;

procedure TfrmGestionEditeurs.mnuDescriptionsClick(Sender: TObject);
begin
  if not(dmBaseDeDonnees.tabEditeurs.Eof or dmBaseDeDonnees.tabEditeurs.bof) and
    not(dmBaseDeDonnees.tabEditeurs.state in [dsinsert, dsedit]) then
    tfrmGestionTextesComplementaires.execute('Description de ' +
      dmBaseDeDonnees.tabEditeurs.fieldbyname('raison_sociale').asstring,
      'editeurs', dmBaseDeDonnees.tabEditeurs.fieldbyname('code').AsInteger,
      dmBaseDeDonnees.tabEditeursDescription, 'editeurs_description',
      'editeur_code', 'description');
end;

procedure TfrmGestionEditeurs.PopupMenu1Popup(Sender: TObject);
var
  ok: boolean;
begin
  ok := not(dmBaseDeDonnees.tabEditeurs.Eof or dmBaseDeDonnees.tabEditeurs.bof)
    and not(dmBaseDeDonnees.tabEditeurs.state in [dsinsert, dsedit]);
  mnuDescriptions.Enabled := ok;
end;

end.
