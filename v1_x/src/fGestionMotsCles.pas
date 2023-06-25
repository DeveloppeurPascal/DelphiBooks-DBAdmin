unit fGestionMotsCles;

// TODO : s'assurer que le libelle est renseigné avant enregistrement
// TODO : permettre de consulter et modifier la liste des livres associés à un mot clé
interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, System.Rtti,
  FMX.Grid.Style, Data.Bind.Controls, FMX.StdCtrls, FMX.Layouts,
  FMX.Bind.Navigator, FMX.Controls.Presentation, FMX.ScrollBox, FMX.Grid, uDM,
  Data.Bind.EngExt, Fmx.Bind.DBEngExt, Fmx.Bind.Grid, System.Bindings.Outputs,
  Fmx.Bind.Editors, Data.Bind.Components, Data.Bind.Grid, Data.Bind.DBScope;

type
  TfrmGestionMotsCles = class(TForm)
    StringGrid1: TStringGrid;
    BindNavigator1: TBindNavigator;
    btnFermer: TButton;
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    BindSourceDB2: TBindSourceDB;
    LinkGridToDataSourceBindSourceDB2: TLinkGridToDataSource;
    procedure btnFermerClick(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  frmGestionMotsCles: TfrmGestionMotsCles;

implementation

{$R *.fmx}

procedure TfrmGestionMotsCles.btnFermerClick(Sender: TObject);
begin
  close;
end;

end.
