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
  File last update : 2026-06-15T18:30:10.672+02:00
  Signature : 6bac9826907c48b49b43d82cc83aa4ca9127c666
  ***************************************************************************
*)

unit fGestionAuteurs;

// TODO : lors de l'enregistrement des modifications, s'assurer que le nom/prénom ou pseudo sont bien saisis
// TODO : ajouter la gestion des livres de l'auteur (consultation et modification)
// TODO : gérer les photos des auteurs
interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, uDM,
  System.Rtti, FMX.Grid.Style, FMX.ScrollBox, FMX.Grid,
  FMX.Controls.Presentation, FMX.StdCtrls, Data.Bind.EngExt, FMX.Bind.DBEngExt,
  FMX.Bind.Grid, System.Bindings.Outputs, FMX.Bind.Editors, Data.Bind.Controls,
  FMX.Layouts, FMX.Bind.Navigator, Data.Bind.Components, Data.Bind.Grid,
  Data.Bind.DBScope, FMX.Menus;

type
  TfrmGestionAuteurs = class(TForm)
    btnFermer: TButton;
    StringGrid1: TStringGrid;
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    LinkGridToDataSourceBindSourceDB1: TLinkGridToDataSource;
    BindNavigator1: TBindNavigator;
    PopupMenu1: TPopupMenu;
    mnuDescriptions: TMenuItem;
    procedure btnFermerClick(Sender: TObject);
    procedure mnuDescriptionsClick(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  frmGestionAuteurs: TfrmGestionAuteurs;

implementation

{$R *.fmx}

uses fGestionTextesComplementaires, Data.db;

procedure TfrmGestionAuteurs.btnFermerClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmGestionAuteurs.FormShow(Sender: TObject);
begin
  dmBaseDeDonnees.tabAuteurs.First;
end;

procedure TfrmGestionAuteurs.mnuDescriptionsClick(Sender: TObject);
begin
  if not(dmBaseDeDonnees.tabAuteurs.Eof or dmBaseDeDonnees.tabAuteurs.bof) and
    not(dmBaseDeDonnees.tabAuteurs.state in [dsinsert, dsedit]) then
    tfrmGestionTextesComplementaires.execute('Description de ' +
      dmBaseDeDonnees.tabAuteurs.fieldbyname('prenom').asstring + ' ' +
      dmBaseDeDonnees.tabAuteurs.fieldbyname('nom').asstring + ' ' +
      dmBaseDeDonnees.tabAuteurs.fieldbyname('pseudo').asstring, 'auteurs',
      dmBaseDeDonnees.tabAuteurs.fieldbyname('code').AsInteger,
      dmBaseDeDonnees.tabAuteursDescription, 'auteurs_description',
      'auteur_code', 'description');
end;

procedure TfrmGestionAuteurs.PopupMenu1Popup(Sender: TObject);
var
  ok: boolean;
begin
  ok := not(dmBaseDeDonnees.tabAuteurs.Eof or dmBaseDeDonnees.tabAuteurs.bof)
    and not(dmBaseDeDonnees.tabAuteurs.state in [dsinsert, dsedit]);
  mnuDescriptions.Enabled := ok;
end;

end.
