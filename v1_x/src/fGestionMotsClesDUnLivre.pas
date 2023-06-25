unit fGestionMotsClesDUnLivre;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, uDM,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, FMX.Layouts, FMX.Controls.Presentation, FMX.StdCtrls,
  FMX.ListView;

type
  TfrmGestionMotsClesDUnLivre = class(TForm)
    lvListeComplete: TListView;
    btnGestionMotsCles: TButton;
    lvListeDuLivre: TListView;
    Layout2: TLayout;
    Layout3: TLayout;
    btnAjouter: TButton;
    btnSupprimer: TButton;
    GridPanelLayout1: TGridPanelLayout;
    btnOk: TButton;
    btnCancel: TButton;
    FDQuery1: TFDQuery;
    Layout1: TLayout;
    procedure FormShow(Sender: TObject);
    procedure btnAjouterClick(Sender: TObject);
    procedure btnSupprimerClick(Sender: TObject);
    procedure btnGestionMotsClesClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure lvListeCompleteDblClick(Sender: TObject);
    procedure lvListeDuLivreDblClick(Sender: TObject);
  private
    { Déclarations privées }
    fLivre_code: integer;
    procedure ChargeListe;
  public
    { Déclarations publiques }
    class procedure execute(ALivre_Code: integer; ATitre: string);
  end;

var
  frmGestionMotsClesDUnLivre: TfrmGestionMotsClesDUnLivre;

implementation

{$R *.fmx}

uses fGestionMotsCles;

procedure TfrmGestionMotsClesDUnLivre.btnAjouterClick(Sender: TObject);
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

procedure TfrmGestionMotsClesDUnLivre.btnCancelClick(Sender: TObject);
begin
  close;
end;

procedure TfrmGestionMotsClesDUnLivre.btnGestionMotsClesClick(Sender: TObject);
var
  frm: TfrmGestionMotsCles;
begin
  frm := TfrmGestionMotsCles.Create(Self);
  try
    frm.ShowModal;
    ChargeListe;
  finally
    frm.Free;
  end;
end;

procedure TfrmGestionMotsClesDUnLivre.btnOkClick(Sender: TObject);
var
  item: tlistviewitem;
begin
  dmBaseDeDonnees.DB.ExecSQL
    ('update livres_motscles_lien set livre_code=-1,motcle_code=-1 where livre_code=:lc',
    [fLivre_code]);
  // TODO : remplacer par une suppression logique des enregistrements
  // TODO : prévoir un module de ménage sur les tables concernées
  for item in lvListeDuLivre.Items do
  begin
    dmBaseDeDonnees.tabLivresmotsclesLien.Insert;
    dmBaseDeDonnees.tabLivresmotsclesLien.fieldbyname('livre_code').AsInteger :=
      fLivre_code;
    dmBaseDeDonnees.tabLivresmotsclesLien.fieldbyname('motcle_code').AsInteger
      := item.Tag;
    dmBaseDeDonnees.tabLivresmotsclesLien.post;
  end;
  close;
end;

procedure TfrmGestionMotsClesDUnLivre.btnSupprimerClick(Sender: TObject);
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

procedure TfrmGestionMotsClesDUnLivre.ChargeListe;
var
  item: tlistviewitem;
begin
  lvListeComplete.Items.Clear;
  lvListeDuLivre.Items.Clear;
  FDQuery1.Open('select * from motscles order by libelle');
  try
    FDQuery1.First;
    while not FDQuery1.Eof do
    begin
      if 0 < dmBaseDeDonnees.DB.ExecSQLScalar
        ('select count(*) from livres_motscles_lien where livre_code=:lc and motcle_code=:ac',
        [fLivre_code, FDQuery1.fieldbyname('code').AsInteger]) then
        item := lvListeDuLivre.Items.Add
      else
        item := lvListeComplete.Items.Add;
      item.Text := FDQuery1.fieldbyname('libelle').AsString;
      item.Tag := FDQuery1.fieldbyname('code').AsInteger;
      FDQuery1.Next;
    end;
  finally
    FDQuery1.close;
  end;
end;

class procedure TfrmGestionMotsClesDUnLivre.execute(ALivre_Code: integer;
  ATitre: string);
var
  frm: TfrmGestionMotsClesDUnLivre;
begin
  frm := TfrmGestionMotsClesDUnLivre.Create(application.mainform);
  try
    frm.fLivre_code := ALivre_Code;
    frm.caption := 'Mots clés du livre ' + ATitre;
    frm.ShowModal;
  finally
    frm.Free;
  end;
end;

procedure TfrmGestionMotsClesDUnLivre.FormShow(Sender: TObject);
begin
  ChargeListe;
end;

procedure TfrmGestionMotsClesDUnLivre.lvListeCompleteDblClick(Sender: TObject);
begin
  btnAjouterClick(Sender);
end;

procedure TfrmGestionMotsClesDUnLivre.lvListeDuLivreDblClick(Sender: TObject);
begin
  btnSupprimerClick(Sender);
end;

end.
