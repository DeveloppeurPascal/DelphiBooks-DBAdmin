program DelphiBooksAdmin;

uses
  System.StartUpCopy,
  FMX.Forms,
  fMain in 'fMain.pas' {frmMain},
  uDM in 'uDM.pas' {dmBaseDeDonnees: TDataModule},
  uOutilsCommuns in 'uOutilsCommuns.pas',
  uParam in 'uParam.pas',
  fGestionLangues in 'fGestionLangues.pas' {frmGestionLangues},
  fGestionAuteurs in 'fGestionAuteurs.pas' {frmGestionAuteurs},
  fGestionEditeurs in 'fGestionEditeurs.pas' {frmGestionEditeurs},
  fGestionLivres in 'fGestionLivres.pas' {frmGestionLivres},
  fGestionMotsCles in 'fGestionMotsCles.pas' {frmGestionMotsCles},
  fGestionLecteurs in 'fGestionLecteurs.pas' {frmGestionLecteurs},
  fGestionTextesComplementaires in 'fGestionTextesComplementaires.pas' {frmGestionTextesComplementaires},
  fChoixLangue in 'fChoixLangue.pas' {frmChoixLangue},
  fGestionAuteursDUnLivre in 'fGestionAuteursDUnLivre.pas' {frmGestionAuteursDUnLivre},
  fGestionEditeursDUnLivre in 'fGestionEditeursDUnLivre.pas' {frmGestionEditeursDUnLivre},
  fGestionMotsClesDUnLivre in 'fGestionMotsClesDUnLivre.pas' {frmGestionMotsClesDUnLivre},
  uCheminDeStockage in 'uCheminDeStockage.pas',
  fChoixPhotos in 'fChoixPhotos.pas' {frmChoixPhotos},
  fGenerationSite in 'fGenerationSite.pas' {frmGenerationSite},
  OlfSoftware.DeepL.ClientLib in '..\..\lib-externes\DeepL4Delphi\src\OlfSoftware.DeepL.ClientLib.pas',
  DelphiBooks.Classes in '..\..\lib-externes\DelphiBooks-Common\src\DelphiBooks.Classes.pas',
  DelphiBooks.DB.Repository in '..\..\lib-externes\DelphiBooks-Common\src\DelphiBooks.DB.Repository.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TdmBaseDeDonnees, dmBaseDeDonnees);
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
