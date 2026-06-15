(* C2PP
  ***************************************************************************

  Delphi Books Database Admin
  Copyright (c) 2020-2026 Patrick PREMARTIN

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU Affero General Public License as
  published by the Free Software Foundation, either version 3 of the
  License, or (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU Affero General Public License for more details.

  You should have received a copy of the GNU Affero General Public License
  along with this program.  If not, see <https://www.gnu.org/licenses/>.

  ***************************************************************************

  Author(s) :
  Patrick PREMARTIN

  Site :
  https://delphi-books.com/opendata.html

  Project site :
  https://github.com/DeveloppeurPascal/DelphiBooks-DBAdmin

  ***************************************************************************
  File last update : 2026-06-15T18:30:10.763+02:00
  Signature : 71f604f72dadf523ea1fc889eb03cc7e4f292853
  ***************************************************************************
*)

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
