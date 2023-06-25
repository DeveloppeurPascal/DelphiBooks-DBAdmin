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
