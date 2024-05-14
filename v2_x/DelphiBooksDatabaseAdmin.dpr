program DelphiBooksDatabaseAdmin;

uses
  System.StartUpCopy,
  FMX.Forms,
  fMain in 'fMain.pas' {frmMain},
  DelphiBooks.Classes in '..\lib-externes\DelphiBooks-Common\src\DelphiBooks.Classes.pas',
  DelphiBooks.DB.Repository in '..\lib-externes\DelphiBooks-Common\src\DelphiBooks.DB.Repository.pas',
  uDMAboutBoxImage in 'uDMAboutBoxImage.pas' {DMAboutBoxImage: TDataModule},
  fBooks in 'fBooks.pas' {frmBooks},
  DelphiBooks.Tools in '..\lib-externes\DelphiBooks-Common\src\DelphiBooks.Tools.pas',
  fTablesOfContent in 'fTablesOfContent.pas' {frmTablesOfContent},
  fPublishers in 'fPublishers.pas' {frmPublishers},
  fAuthors in 'fAuthors.pas' {frmAuthors},
  fLanguages in 'fLanguages.pas' {frmLanguages},
  fWebPages in 'fWebPages.pas' {frmWebPages},
  fBooksPublishers in 'fBooksPublishers.pas' {frmBooksPublishers},
  fBooksAuthors in 'fBooksAuthors.pas' {frmBooksAuthors},
  fBookCoverImage in 'fBookCoverImage.pas' {frmBookCoverImage},
  fDescriptions in 'fDescriptions.pas' {frmDescriptions},
  u_urlOpen in '..\lib-externes\librairies\src\u_urlOpen.pas',
  Olf.FMX.AboutDialog in '..\lib-externes\AboutDialog-Delphi-Component\src\Olf.FMX.AboutDialog.pas',
  Olf.FMX.AboutDialogForm in '..\lib-externes\AboutDialog-Delphi-Component\src\Olf.FMX.AboutDialogForm.pas' {OlfAboutDialogForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TDMAboutBoxImage, DMAboutBoxImage);
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
