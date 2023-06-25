unit fGestionLivres;

// TODO : s'assurer que le titre est renseigné
// TODO : gérer le format de saisie de date à partir d'un calendrier plutôt que la saisie AAAAMMJJ de stockage
interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, uDM,
  System.Rtti, FMX.Grid.Style, Data.Bind.Controls, Data.Bind.EngExt,
  FMX.Bind.DBEngExt, FMX.Bind.Grid, System.Bindings.Outputs, FMX.Bind.Editors,
  Data.Bind.Components, Data.Bind.Grid, Data.Bind.DBScope, FMX.StdCtrls,
  FMX.Layouts, FMX.Bind.Navigator, FMX.Controls.Presentation, FMX.ScrollBox,
  FMX.Grid, FMX.Menus;

type
  TfrmGestionLivres = class(TForm)
    StringGrid1: TStringGrid;
    BindNavigator1: TBindNavigator;
    btnFermer: TButton;
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    LinkGridToDataSourceBindSourceDB1: TLinkGridToDataSource;
    PopupMenu1: TPopupMenu;
    mnuAuteurs: TMenuItem;
    mnuEditeurs: TMenuItem;
    mnuDescriptions: TMenuItem;
    mnuTableDesMatières: TMenuItem;
    mnuCommentaires: TMenuItem;
    mnuLangueDuLivre: TMenuItem;
    mnuMotsCles: TMenuItem;
    mnuPhotoDeCouverture: TMenuItem;
    procedure btnFermerClick(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure mnuAuteursClick(Sender: TObject);
    procedure mnuCommentairesClick(Sender: TObject);
    procedure mnuDescriptionsClick(Sender: TObject);
    procedure mnuEditeursClick(Sender: TObject);
    procedure mnuTableDesMatièresClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure mnuLangueDuLivreClick(Sender: TObject);
    procedure mnuMotsClesClick(Sender: TObject);
    procedure mnuPhotoDeCouvertureClick(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  frmGestionLivres: TfrmGestionLivres;

implementation

{$R *.fmx}

uses fGestionTextesComplementaires, Data.db, fChoixLangue,
  fGestionAuteursDUnLivre, fGestionEditeursDUnLivre, fGestionMotsClesDUnLivre,
  fChoixPhotos;

procedure TfrmGestionLivres.btnFermerClick(Sender: TObject);
begin
  close;
end;

procedure TfrmGestionLivres.FormShow(Sender: TObject);
begin
  dmBaseDeDonnees.tabLivres.First;
end;

procedure TfrmGestionLivres.mnuAuteursClick(Sender: TObject);
begin
  if not(dmBaseDeDonnees.tabLivres.Eof or dmBaseDeDonnees.tabLivres.bof) and
    not(dmBaseDeDonnees.tabLivres.state in [dsinsert, dsedit]) then
    TfrmGestionAuteursDUnLivre.execute(dmBaseDeDonnees.tabLivres.fieldbyname
      ('code').AsInteger, dmBaseDeDonnees.tabLivres.fieldbyname('titre')
      .AsString);
end;

procedure TfrmGestionLivres.mnuCommentairesClick(Sender: TObject);
begin
  // TODO : gestion des commentaires d'un livre
  raise exception.Create('Non géré');
end;

procedure TfrmGestionLivres.mnuDescriptionsClick(Sender: TObject);
begin
  if not(dmBaseDeDonnees.tabLivres.Eof or dmBaseDeDonnees.tabLivres.bof) and
    not(dmBaseDeDonnees.tabLivres.state in [dsinsert, dsedit]) then
    tfrmGestionTextesComplementaires.execute('Description de ' +
      dmBaseDeDonnees.tabLivres.fieldbyname('titre').AsString, 'livres',
      dmBaseDeDonnees.tabLivres.fieldbyname('code').AsInteger,
      dmBaseDeDonnees.tabLivresDescription, 'livres_description', 'livre_code',
      'description');
end;

procedure TfrmGestionLivres.mnuEditeursClick(Sender: TObject);
begin
  if not(dmBaseDeDonnees.tabLivres.Eof or dmBaseDeDonnees.tabLivres.bof) and
    not(dmBaseDeDonnees.tabLivres.state in [dsinsert, dsedit]) then
    TfrmGestionEditeursDUnLivre.execute
      (dmBaseDeDonnees.tabLivres.fieldbyname('code').AsInteger,
      dmBaseDeDonnees.tabLivres.fieldbyname('titre').AsString);
end;

procedure TfrmGestionLivres.mnuLangueDuLivreClick(Sender: TObject);
var
  langue_code: integer;
begin
  if not(dmBaseDeDonnees.tabLivres.Eof or dmBaseDeDonnees.tabLivres.bof) and
    not(dmBaseDeDonnees.tabLivres.state in [dsinsert, dsedit]) then
  begin
    langue_code := TfrmChoixLangue.execute
      (dmBaseDeDonnees.tabLivres.fieldbyname('langue_code').AsInteger);
    if langue_code <> dmBaseDeDonnees.tabLivres.fieldbyname('langue_code').AsInteger
    then
    begin
      dmBaseDeDonnees.tabLivres.edit;
      dmBaseDeDonnees.tabLivres.fieldbyname('langue_code').AsInteger :=
        langue_code;
      dmBaseDeDonnees.tabLivres.post;
      // TODO : modifier le statut "a_generer" de la langue actuelle
      // TODO : modifier le statut "a_generer" de la nouvelle langue du livre
    end;
  end;
end;

procedure TfrmGestionLivres.mnuMotsClesClick(Sender: TObject);
begin
  if not(dmBaseDeDonnees.tabLivres.Eof or dmBaseDeDonnees.tabLivres.bof) and
    not(dmBaseDeDonnees.tabLivres.state in [dsinsert, dsedit]) then
    TfrmGestionMotsClesDUnLivre.execute
      (dmBaseDeDonnees.tabLivres.fieldbyname('code').AsInteger,
      dmBaseDeDonnees.tabLivres.fieldbyname('titre').AsString);
end;

procedure TfrmGestionLivres.mnuPhotoDeCouvertureClick(Sender: TObject);
begin
  if not(dmBaseDeDonnees.tabLivres.Eof or dmBaseDeDonnees.tabLivres.bof) and
    not(dmBaseDeDonnees.tabLivres.state in [dsinsert, dsedit]) then
    TfrmChoixPhotos.execute('livres', dmBaseDeDonnees.tabLivres.fieldbyname
      ('code').AsInteger, dmBaseDeDonnees.tabLivres.fieldbyname('titre')
      .AsString);
end;

procedure TfrmGestionLivres.mnuTableDesMatièresClick(Sender: TObject);
begin
  if not(dmBaseDeDonnees.tabLivres.Eof or dmBaseDeDonnees.tabLivres.bof) and
    not(dmBaseDeDonnees.tabLivres.state in [dsinsert, dsedit]) then
    tfrmGestionTextesComplementaires.execute('Table des matières de ' +
      dmBaseDeDonnees.tabLivres.fieldbyname('titre').AsString, 'livres',
      dmBaseDeDonnees.tabLivres.fieldbyname('code').AsInteger,
      dmBaseDeDonnees.tabLivresTableDesMatieres, 'livres_tabledesmatieres',
      'livre_code', 'tabledesmatieres');
end;

procedure TfrmGestionLivres.PopupMenu1Popup(Sender: TObject);
var
  ok: Boolean;
begin
  ok := not(dmBaseDeDonnees.tabLivres.Eof or dmBaseDeDonnees.tabLivres.bof) and
    not(dmBaseDeDonnees.tabLivres.state in [dsinsert, dsedit]);
  mnuLangueDuLivre.Enabled := ok;
  mnuPhotoDeCouverture.Enabled := ok;
  mnuAuteurs.Enabled := ok;
  mnuEditeurs.Enabled := ok;
  mnuDescriptions.Enabled := ok;
  mnuTableDesMatières.Enabled := ok;
  mnuMotsCles.Enabled := ok;
  mnuCommentaires.Enabled := false;
  // TODO : à activer une fois les commentaires gérés
end;

end.
