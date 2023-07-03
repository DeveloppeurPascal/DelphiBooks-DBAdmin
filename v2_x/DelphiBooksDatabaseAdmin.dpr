program DelphiBooksDatabaseAdmin;

uses
  System.StartUpCopy,
  FMX.Forms,
  fMain in 'fMain.pas' {frmMain},
  Olf.FMX.AboutDialog in '..\lib-externes\AboutDialog-Delphi-Component\sources\Olf.FMX.AboutDialog.pas',
  Olf.FMX.AboutDialogForm in '..\lib-externes\AboutDialog-Delphi-Component\sources\Olf.FMX.AboutDialogForm.pas' {OlfAboutDialogForm},
  DelphiBooks.Classes in '..\lib-externes\DelphiBooks-Common\src\DelphiBooks.Classes.pas',
  DelphiBooks.DB.Repository in '..\lib-externes\DelphiBooks-Common\src\DelphiBooks.DB.Repository.pas',
  u_urlOpen in '..\lib-externes\librairies\u_urlOpen.pas',
  uDMAboutBoxImage in 'uDMAboutBoxImage.pas' {DMAboutBoxImage: TDataModule},
  fLanguages in 'fLanguages.pas' {frmLanguages},
  DelphiBooks.Tools in '..\lib-externes\DelphiBooks-Common\src\DelphiBooks.Tools.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TDMAboutBoxImage, DMAboutBoxImage);
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.