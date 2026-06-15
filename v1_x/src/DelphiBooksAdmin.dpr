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
  File last update : 2026-06-15T18:30:10.649+02:00
  Signature : a027ce970480be7d5c6cc3d70f7e54de7589c9f5
  ***************************************************************************
*)

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
