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
