unit fGestionAuteursDUnLivre;

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
  TfrmGestionAuteursDUnLivre = class(TForm)
    lvListeComplete: TListView;
    lvListeDuLivre: TListView;
    Layout1: TLayout;
    Layout2: TLayout;
    Layout3: TLayout;
    btnAjouter: TButton;
    btnSupprimer: TButton;
    GridPanelLayout1: TGridPanelLayout;
    btnOk: TButton;
    btnCancel: TButton;
    FDQuery1: TFDQuery;
    btnGestionAuteurs: TButton;
    procedure btnGestionAuteursClick(Sender: TObject);
    procedure btnAjouterClick(Sender: TObject);
    procedure btnSupprimerClick(Sender: TObject);
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
  frmGestionAuteursDUnLivre: TfrmGestionAuteursDUnLivre;

implementation

{$R *.fmx}

uses fGestionAuteurs;

{ TfrmGestionAuteursDUnLivre }

procedure TfrmGestionAuteursDUnLivre.btnAjouterClick(Sender: TObject);
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

procedure TfrmGestionAuteursDUnLivre.btnCancelClick(Sender: TObject);
begin
  close;
end;

procedure TfrmGestionAuteursDUnLivre.btnGestionAuteursClick(Sender: TObject);
var
  frm: TfrmGestionAuteurs;
begin
  frm := TfrmGestionAuteurs.Create(Self);
  try
    frm.ShowModal;
    ChargeListe;
  finally
    frm.Free;
  end;
end;

procedure TfrmGestionAuteursDUnLivre.btnOkClick(Sender: TObject);
var
  item: tlistviewitem;
begin
  dmBaseDeDonnees.DB.ExecSQL
    ('update livres_auteurs_lien set livre_code=-1,auteur_code=-1 where livre_code=:lc',
    [FLivre_Code]);
  // TODO : remplacer par une suppression logique des enregistrements
  // TODO : prévoir un module de ménage sur les tables concernées
  for item in lvListeDuLivre.Items do
  begin
    dmBaseDeDonnees.tabLivresAuteursLien.Insert;
    dmBaseDeDonnees.tabLivresAuteursLien.fieldbyname('livre_code').AsInteger :=
      FLivre_Code;
    dmBaseDeDonnees.tabLivresAuteursLien.fieldbyname('auteur_code').AsInteger
      := item.Tag;
    dmBaseDeDonnees.tabLivresAuteursLien.post;
  end;
  close;
end;

procedure TfrmGestionAuteursDUnLivre.btnSupprimerClick(Sender: TObject);
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

procedure TfrmGestionAuteursDUnLivre.ChargeListe;
var
  item: tlistviewitem;
begin
  lvListeComplete.Items.Clear;
  lvListeDuLivre.Items.Clear;
  FDQuery1.Open('select * from auteurs order by nom,prenom, pseudo');
  try
    FDQuery1.First;
    while not FDQuery1.Eof do
    begin
      if 0 < dmBaseDeDonnees.DB.ExecSQLScalar
        ('select count(*) from livres_auteurs_lien where livre_code=:lc and auteur_code=:ac',
        [FLivre_Code, FDQuery1.fieldbyname('code').AsInteger]) then
        item := lvListeDuLivre.Items.Add
      else
        item := lvListeComplete.Items.Add;
      item.Text := FDQuery1.fieldbyname('prenom').AsString + ' ' +
        FDQuery1.fieldbyname('nom').AsString + ' ' + FDQuery1.fieldbyname
        ('pseudo').AsString;
      item.Tag := FDQuery1.fieldbyname('code').AsInteger;
      FDQuery1.Next;
    end;
  finally
    FDQuery1.close;
  end;
end;

class procedure TfrmGestionAuteursDUnLivre.execute(ALivre_Code: integer;
  ATitre: string);
var
  frm: TfrmGestionAuteursDUnLivre;
begin
  frm := TfrmGestionAuteursDUnLivre.Create(application.mainform);
  try
    frm.FLivre_Code := ALivre_Code;
    frm.caption := 'Auteurs du livre ' + ATitre;
    frm.ShowModal;
  finally
    frm.Free;
  end;
end;

procedure TfrmGestionAuteursDUnLivre.FormShow(Sender: TObject);
begin
  ChargeListe;
end;

procedure TfrmGestionAuteursDUnLivre.lvListeCompleteDblClick(Sender: TObject);
begin
  btnAjouterClick(Sender);
end;

procedure TfrmGestionAuteursDUnLivre.lvListeDuLivreDblClick(Sender: TObject);
begin
  btnSupprimerClick(Sender);
end;

end.
