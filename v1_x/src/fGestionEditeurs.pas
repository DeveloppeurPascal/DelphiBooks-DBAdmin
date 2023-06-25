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
