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
