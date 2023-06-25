unit uOutilsCommuns;

interface

uses System.JSON;

/// <summary>Ressort la date du jour en AAAAMMJJ
/// </summary>
function DateToString8: string; overload;
/// <summary>Ressort la date passée en AAAAMMJJ
/// </summary>
function DateToString8(Const ADate: TDateTime): string; overload;
/// <summary>Transforme une date AAAAMMJJ dans son format d'affichage JJ/MM/AAAA
/// </summary>
function Date8ToString(Const Date8AAfficher: string): string;
/// <summary>Transforme une date AAAAMMJJ dans son format d'affichage AAAA-MM-JJ
/// </summary>
function Date8ToStringISO(Const Date8AAfficher: string): string;
/// <summary>Transforme une date AAAAMMJJ dans son format d'affichage RFC822
/// </summary>
function Date8ToStringRFC822(Const Date8AAfficher: string): string;
/// <summary>Ressort l'heure en cours en HHMMSS
/// </summary>
function TimeToString6: string; overload;
/// <summary>Ressort l'heure passée en HHMMSS
/// </summary>
function TimeToString6(Const ATime: TDateTime): string; overload;
/// <summary>Transforme une heure HHMMSS dans son format d'affichage HH:MM:SS
/// </summary>
function Time6ToString(Const Time6AAfficher: string): string;
/// <summary>Transforme la date et heure du moment en AAAAMMJJHHMMSS
/// Ce format est utilisé dans le stockage d'infos de création et de modification dans la base de données et permettre des tris chronologiques sur l'ordre alphabétique.
/// </summary>
function DateTimeToString14: string; overload;
/// <summary>Transforme la date et heure passée en AAAAMMJJHHMMSS
/// Ce format est utilisé dans le stockage d'infos de création et de modification dans la base de données et permettre des tris chronologiques sur l'ordre alphabétique.
/// </summary>
function DateTimeToString14(Const ADateTime: TDateTime): string; overload;
/// <summary>Transforme un tableau en son équivalent JSON.
/// </summary>
function OpenArrayToJSONArray(a: array of const): TJSONArray;
/// <summary>Retourne la représentation binaire (sous forme de chaîne) du nombre transmis
/// </summary>
function IntToBinary(const Value: Int64; const ALength: Integer = 16): String;
/// <summary>Converti une valeur en secondes vers son équivalent en HMS
/// </summary>
function SecToHMS(Const Valeur_En_secondes: Integer): String; overload;
procedure SecToHMS(Const Valeur_En_secondes: Integer;
  var HH, MM, SS: Integer); overload;
/// <summary>Converti une valeur HMS (xxH xxM xxS) en son équivalent en secondes
/// </summary>
function HMSToSec(Const Valeur_En_HMS: String): Integer; overload;
function HMSToSec(Const HH, MM, SS: Integer): Integer; overload;

function ToDelphiConst(Texte: string): string;

function ToURL(Texte: string): string;

function getNewID: string;

implementation

uses System.SysUtils, System.StrUtils, System.Character;

function DateToString8: string;
begin
  Result := DateToString8(Now);
end;

function DateToString8(Const ADate: TDateTime): string;
begin
  Result := FormatDateTime('yyyymmdd', ADate);
end;

function Date8ToString(Const Date8AAfficher: string): string;
var
  MM, jj: string;
begin
  // TODO : gérer les formats de date non européens de l'ouest
  MM := Date8AAfficher.Substring(4, 2);
  jj := Date8AAfficher.Substring(6, 2);
  if MM = '00' then
    Result := Date8AAfficher.Substring(0, 4)
  else if jj = '00' then
    Result := MM + FormatSettings.DateSeparator + Date8AAfficher.Substring(0, 4)
  else
    Result := jj + FormatSettings.DateSeparator + MM +
      FormatSettings.DateSeparator + Date8AAfficher.Substring(0, 4);
end;

function Date8ToStringISO(Const Date8AAfficher: string): string;
var
  MM, jj: string;
begin
  // TODO : gérer les formats de date non européens de l'ouest
  MM := Date8AAfficher.Substring(4, 2);
  jj := Date8AAfficher.Substring(6, 2);
  if MM = '00' then
    Result := Date8AAfficher.Substring(0, 4) + '-00-00'
  else if jj = '00' then
    Result := Date8AAfficher.Substring(0, 4) + '-' + MM + '-00'
  else
    Result := Date8AAfficher.Substring(0, 4) + '-' + MM + '-' + jj;
end;

function Date8ToStringRFC822(Const Date8AAfficher: string): string;
var
  x: Integer;
begin
  if Date8AAfficher.IsEmpty then
    raise Exception.Create
      ('Date non renseignée. Impossible à convertir dans Date8ToStringRFC822.');
  x := Date8AAfficher.Substring(6, 2).ToInteger;
  if x < 1 then
    x := 1;
  Result := x.ToString + ' ';
  case Date8AAfficher.Substring(4, 2).ToInteger of
    0, 1:
      Result := Result + 'Jan';
    2:
      Result := Result + 'Feb';
    3:
      Result := Result + 'Mar';
    4:
      Result := Result + 'Apr';
    5:
      Result := Result + 'May';
    6:
      Result := Result + 'Jun';
    7:
      Result := Result + 'Jul';
    8:
      Result := Result + 'Aug';
    9:
      Result := Result + 'Sep';
    10:
      Result := Result + 'Oct';
    11:
      Result := Result + 'Nov';
    12:
      Result := Result + 'Dec';
  end;
  Result := Result + ' ' + Date8AAfficher.Substring(0, 4) + ' 00:00:00 GMT';
end;

function TimeToString6: string;
begin
  Result := TimeToString6(Now);
end;

function TimeToString6(Const ATime: TDateTime): string;
begin
  Result := FormatDateTime('hhnnss', ATime);
end;

function Time6ToString(Const Time6AAfficher: string): string;
begin
  Result := Time6AAfficher.Substring(0, 2) + FormatSettings.TimeSeparator +
    Time6AAfficher.Substring(2, 2) + FormatSettings.TimeSeparator +
    Time6AAfficher.Substring(4, 2);
end;

function DateTimeToString14: string;
begin
  Result := DateTimeToString14(Now);
end;

function DateTimeToString14(Const ADateTime: TDateTime): string;
begin
  Result := DateToString8(ADateTime) + TimeToString6(ADateTime);
end;

function OpenArrayToJSONArray(a: array of const): TJSONArray;
var
  i: Integer;
  v: TVarRec;
begin
  Result := TJSONArray.Create;
  for i := low(a) to high(a) do
  begin
    v := a[i];
    case v.VType of
      vtInteger:
        Result.AddElement(TJSONNumber.Create(v.VInteger));
      vtBoolean:
        Result.AddElement(TJSONBool.Create(v.VBoolean));
      vtChar:
        Result.AddElement(TJSONString.Create(v.VChar));
      vtExtended:
        Result.AddElement(TJSONNumber.Create(Extended(v.VExtended^)));
{$IFNDEF NEXTGEN}
      vtString:
        Result.AddElement(TJSONString.Create(ShortString(v.VString^)));
{$ENDIF !NEXTGEN}
      vtWideChar:
        Result.AddElement(TJSONString.Create(v.VWideChar));
      vtAnsiString:
        Result.AddElement(TJSONString.Create(AnsiString(v.VAnsiString^)));
      vtCurrency:
        Result.AddElement(TJSONNumber.Create(Currency(v.VCurrency^)));
      vtWideString:
        Result.AddElement(TJSONString.Create(WideString(v.VWideString^)));
      vtInt64:
        Result.AddElement(TJSONNumber.Create(Int64(v.vint64^)));
      vtUnicodeString:
        Result.AddElement(TJSONString.Create(string(v.VUnicodeString)));
    else
      raise Exception.Create
        ('Type de donnée non géré. OpenArrayToJSONArray impossible.');
    end;
  end;
end;

function IntToBinary(const Value: Int64; const ALength: Integer): String;
var
  iWork: Int64;
begin
  Result := '';
  iWork := Value;
  while (iWork > 0) do
  begin
    Result := IntToStr(iWork mod 2) + Result;
    iWork := iWork div 2;
  end;
  while (Length(Result) < ALength) do
    Result := '0' + Result;
end;

function SecToHMS(Const Valeur_En_secondes: Integer): String;
var
  h, m, s: Integer;
begin
  SecToHMS(Valeur_En_secondes, h, m, s);
  Result := '';
  if (h > 0) then
    Result := Result + h.ToString + 'H ';
  if (m > 0) then
    Result := Result + m.ToString + 'M ';
  if (s > 0) or (Valeur_En_secondes = 0) then
    Result := Result + s.ToString + 'S ';
end;

procedure SecToHMS(Const Valeur_En_secondes: Integer; var HH, MM, SS: Integer);
begin
  SS := Valeur_En_secondes;
  HH := SS div SecsPerHour;
  SS := SS - HH * SecsPerHour;
  MM := SS div SecsPerMin;
  SS := SS - MM * SecsPerMin;
end;

function HMSToSec(Const Valeur_En_HMS: String): Integer;
var
  ch: string;
  i: Integer;
begin
  Result := 0;
  ch := Valeur_En_HMS.Trim.Replace(' ', '').ToUpper;
  i := ch.IndexOf('H');
  if (i > 0) then
  begin
    Result := Result + ch.Substring(0, i).ToInteger * SecsPerHour;
    ch := ch.Substring(i + 1);
  end;
  i := ch.IndexOf('M');
  if (i > 0) then
  begin
    Result := Result + ch.Substring(0, i).ToInteger * SecsPerMin;
    ch := ch.Substring(i + 1);
  end;
  i := ch.IndexOf('S');
  if (i > 0) then
    Result := Result + ch.Substring(0, i).ToInteger;
end;

function HMSToSec(Const HH, MM, SS: Integer): Integer;
begin
  Result := HH * SecsPerHour + MM * SecsPerMin + SS;
end;

function ToDelphiConst(Texte: string): string;
var
  c: char;
  i: Integer;
  PremierCaractere: boolean;
begin
  Result := '';
  Texte := Texte.Trim;
  PremierCaractere := true;
  for i := 0 to Length(Texte) - 1 do
  begin
    c := Texte.Chars[i];
    if c.IsInArray(['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']) then
    begin
      if PremierCaractere then
        Result := Result + '_' + c
      else
        Result := Result + c;
    end
    else if c.tolower.IsInArray(['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i',
      'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x',
      'y', 'z']) then
      Result := Result + c
    else if c.IsInArray(['@']) then
      Result := Result + '_'
    else if c.IsInArray(['#']) then
      Result := Result + '_'
    else if c.IsInArray(['£']) then
      Result := Result + '_'
    else if c.IsInArray(['€']) then
      Result := Result + 'EUR'
    else if c.IsInArray(['$']) then
      Result := Result + 'USD'
    else if c.IsInArray(['_', '-', ' ']) then
      Result := Result + '_'
    else if c.IsInArray(['à', 'â', 'ä', 'å']) then
      Result := Result + 'a'
    else if c.IsInArray(['é', 'è', 'ë', 'ê']) then
      Result := Result + 'e'
    else if c.IsInArray(['ï', 'î']) then
      Result := Result + 'i'
    else if c.IsInArray(['ô', 'ö', 'ø']) then
      Result := Result + 'o'
    else if c.IsInArray(['ü', 'û', 'ù']) then
      Result := Result + 'u'
    else if c.IsInArray(['Š']) then
      Result := Result + 'S'
    else if c.IsInArray(['ž']) then
      Result := Result + 'z'
    else if c.IsInArray(['æ']) then
      Result := Result + 'ae'
    else if c.IsInArray(['ç', 'č']) then
      Result := Result + 'c';
    PremierCaractere := false;
  end;
  while Result.IndexOf('__') > -1 do
    Result := ReplaceText(Result, '__', '_');
end;

function ToURL(Texte: string): string;
begin
  Result := ToDelphiConst(Texte).Replace('_', '-');
  if Result.Length > 0 then
    Result := Result + '.html';
end;

function getNewID: string;
var
  i: Integer;
begin
  Result := '';
  for i := 1 to 10 do
    Result := Result + random(10).ToString;
end;

initialization

randomize;

end.
