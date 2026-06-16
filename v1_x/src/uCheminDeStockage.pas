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
  https://codeberg.org/Delphi-Books/DelphiBooks-DBAdmin

  ***************************************************************************
  File last update : 2026-06-15T19:35:44.098+02:00
  Signature : 16f7196c050ce12417d6851fec9095428fe468d6
  ***************************************************************************
*)

unit uCheminDeStockage;

interface

function getCheminDeStockage: string;
function getCheminDeStockagePhotos: string;
function getCheminDeLaPhoto(TableName: string; Code: integer): string;

implementation

uses
  system.ioutils, system.SysUtils;

function getCheminDeStockage: string;
var
  arborescence: string;
begin
{$IFDEF DEBUG}
  arborescence := tpath.Combine(tpath.GetDocumentsPath, '_DonneesDeTest-DEBUG');
{$ELSE}
  arborescence := tpath.Combine(tpath.GetHomePath, '_DonneesDeProduction');
{$ENDIF}
  arborescence := tpath.Combine(arborescence, 'Delphi-Books_com');
  if not TDirectory.Exists(arborescence) then
    TDirectory.CreateDirectory(arborescence);
  result := arborescence;
end;

function getCheminDeStockagePhotos: string;
var
  arborescence: string;
begin
  arborescence := tpath.Combine(getCheminDeStockage, 'Photos');
  if not TDirectory.Exists(arborescence) then
    TDirectory.CreateDirectory(arborescence);
  result := arborescence;
end;

function getCheminDeLaPhoto(TableName: string; Code: integer): string;
begin
  result := tpath.Combine(getCheminDeStockagePhotos,
    TableName + '-' + Code.ToString + '.png')
end;

end.
