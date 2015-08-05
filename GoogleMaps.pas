unit GoogleMaps;

interface

uses Classes,Windows,IdURI,IdHTTP,Contnrs,
     Vcl.Dialogs, System.SysUtils,
     ActiveX, MSXML;

type
  TGMObject = class(TObject)
    doc : IXMLDOMDocument;
  public
    function XMLSelectSingleNode(xmltag,XML_Part:string):IXMLDomNode;
    function LangBoolToStr(value:Boolean; lang:string):string;
  end;

  TGMAdressComponent = class (TGMObject)
  private
    FLongName:string;
    FShortName:string;
    FComponentTypes:TStringList;
  public
    constructor Create(XML_Part:IXMLDomNode);virtual;
    destructor Destroy;
  published
    property LongName:string read FLongName;
    property ShortName:string read FShortName;
    property ComponentTypes:TStringList read FComponentTypes;
  end;

  TGMLocation = class(TGMObject)
  private
    FLat,
    FLng:Extended;
  public
    constructor Create(XML_Part:IXMLDomNode);
  published
    property Lat:Extended read FLat; // широта
    property Lng:Extended read FLng; // долгота
  end;

  TGMViewPort = class(TGMObject)
  private
    FSouthwest:TGMLocation;
    FNortheast:TGMLocation;
  public
    constructor Create(XML_Part:IXMLDomNode);virtual;
  published
    property Southwest:TGMLocation read FSouthwest;
    property Northeast:TGMLocation read FNortheast;
  end;

  TGMGeometry = class(TGMObject)
  private
    FLocation: TGMLocation;
    FLocationType: string;
    FViewPort: TGMViewPort;
  public
    constructor Create(XML_Part:IXMLDomNode);virtual;
  published
    property Location:TGMLocation read FLocation;
    property LocationType:string read FLocationType;
    property ViewPort:TGMViewPort read FViewPort;
  end;

{Типы компонентов адресов

Массив ResultTypes[] в возвращенных результатах указывает тип адреса. Эти типы могут возвращаться также в массивах address_components[] для указания типа определенного компонента адреса. У адресов в геокодере может быть несколько типов; эти типы можно считать "тегами". Например, многие города помечаются тегами типов political и locality.

Геокодер HTTP поддерживает и возвращает следующие типы:

street_address, обозначающий подробные адреса.
route, обозначающий трассы, имеющие код (например, "US 101").
intersection, обозначающий крупные перекрестки, обычно двух главных дорог.
political, обозначающий политические образования. Последний тип обычно обозначает многоугольник, включающий местную административно-территориальную единицу.
country, обозначающий страны и обычно являющийся типом высшего порядка, возвращаемым геокодером.
administrative_area_level_1, обозначающий административно-территориальную единицу первого уровня в пределах страны. В США это – штаты. Административные единицы такого уровня существуют не во всех странах.
administrative_area_level_2, обозначающий административно-территориальную единицу второго уровня в пределах страны. В США это – округа. Административные единицы такого уровня существуют не во всех странах.
administrative_area_level_3, обозначающий административно-территориальную единицу третьего уровня в пределах страны. Этот тип указывает мелкие административные единицы. Административные единицы такого уровня существуют не во всех странах.
colloquial_area, обозначающий распространенное альтернативное название для политической или административной единицы.
locality, обозначающий города, являющиеся политическими или административными единицами.
sublocality, обозначающий районы города.
neighborhood, обозначающий микрорайоны и кварталы с собственными названиями.
premise, обозначающий поименованные местоположения, обычно строения или группы строений с общим именем.
subpremise, обозначающий единицы, на которые делится предыдущая категория, обычно отдельные строения внутри групп строений с общим названием.
postal_code, обозначающий почтовый индекс, используемый для почтовых адресов внутри страны.
natural_feature, обозначающий главные природные достопримечательности.
airport, обозначающий аэропорты.
park, обозначающий парки, имеющие названия.
point_of_interest, обозначающий достопримечательности, имеющие названия. Обычно главные местные достопримечательности (POI) представляют собой местные объекты, отмеченные на карте, такие как Эмпайр-стейт-билдинг или статуя Свободы, которые не могут быть однозначно отнесены к другой категории.
post_box, обозначающий конкретные почтовые ящики.
street_number, обозначающий точные номера домов.
floor, обозначающий этажи в адресах зданий.
room, обозначающий номера квартир в адресах зданий.}
  TGMResult = class(TGMObject)
  private
    FResultType:TStringList;
    FFormattedAddress:string;
    FAddressComponents:TObjectList;
    FGeometry:TGMGeometry;
    function GetAddressComponents(index: integer): TGMAdressComponent;
    function GetAdressComponentCount: Integer;
  public
    property AddressComponents[index:integer]:TGMAdressComponent read GetAddressComponents;
    constructor Create(XML_Part:IXMLDomNode);virtual;
    destructor Destroy;
  published
    property ResultTypes:TStringList read FResultType;
    property FormattedAddress:string read FFormattedAddress;
    property AddressComponentsCount:Integer read GetAdressComponentCount;
    property Geometry:TGMGeometry read FGeometry;
  end;

//Коды статуса
//Поле "status", входящее в объект ответа службы геокодирования, содержит статус запроса и может включать в себя отладочную информацию для отслеживания сбоев службы. Поле "status" может содержать следующие значения:
//"OK", указывающее на отсутствие ошибок. Синтаксический анализ адреса выполнен успешно. Был возвращен по крайней мере один геокод.
//"ZERO_RESULTS", указывающее, что геокодирование выполнено успешно, но не возвратило никаких результатов. Это может произойти, если геокодеру был передан несуществующий элемент address или координаты latlng в удаленной точке.
//"OVER_QUERY_LIMIT", указывающее на превышение квоты.
//"REQUEST_DENIED", означающее, что запрос отклонен, обычно из-за отсутствия параметра sensor.
//"INVALID_REQUEST", обычно указывающее, что запрос (address или latlng) отсутствует.
  TGMStatus = (gmNetEror,gmOK,gmZERO_RESULTS,gmOVER_QUERY_LIMIT,gmREQUEST_DENIED,gmINVALID_REQUEST);

  TGMGeocodeResponse = class(TGMObject)
  private
    FStatus:TGMStatus;
    FRequestString:string;
    FResponseContent:string;
    FResults:TObjectList;
    fCashed:Boolean;
    function GetResults(index: Integer): TGMResult;
    function GetResultsCount: Integer;
  public
    property Results[index:Integer]:TGMResult read GetResults;
    constructor Create(Adress:string);virtual;
    destructor Destroy;
  published
    property Cashed:Boolean read fCashed;
    property Status:TGMStatus read FStatus;
    property ResultsCount:Integer read GetResultsCount;
    property RequestString:string read FRequestString;
    property ResponseContent:string read FResponseContent;
    function AllFormattedAdresses:string;
  end;


var
  GM_Cashe:TStringList;

implementation

{ TGMResult }

  constructor TGMResult.Create(XML_Part:IXMLDomNode);
  var nlAdressComponents,nlResTypes:IXMLDOMNodeList;
      niGeometry:IXMLDOMNode;
      i:Integer;
  begin
    FGeometry := nil;
    FResultType:= TStringList.Create;
    FAddressComponents:=TObjectList.Create;
    FFormattedAddress:=XML_Part.selectSingleNode('formatted_address').text;
    niGeometry := XML_Part.SelectSingleNode('geometry');
    FGeometry:=TGMGeometry.Create(niGeometry);
    nlAdressComponents := XML_Part.selectNodes('address_component');
    for I := 0 to nlAdressComponents.length-1 do
    try
      FAddressComponents.Add(TGMAdressComponent.Create(nlAdressComponents[i]));
    except

    end;
    nlResTypes := XML_Part.selectNodes('type');
    for I := 0 to nlResTypes.length-1 do
    try
      FResultType.Add(nlResTypes[i].text);
    except

    end;
  end;

  destructor TGMResult.Destroy;
  begin
    FResultType.Free;
    FAddressComponents.Free;
    if FGeometry <> nil then
      FGeometry.Free;
  end;

  function TGMResult.GetAddressComponents(index: integer): TGMAdressComponent;
  begin
    Result := TGMAdressComponent(FAddressComponents[index]);
  end;

  function TGMResult.GetAdressComponentCount: Integer;
  begin
    Result := FAddressComponents.Count;
  end;

  { TGMGeocodeResponse }

  constructor TGMGeocodeResponse.Create(Adress: string);
  var HTTP:TIdHTTP;
      Stream:TStringStream;
      XML,s:string;
      GeocodeResponse,StatusNode:IXMLDOMNode;
      nlResults:IXMLDOMNodeList;
      res:TGMResult;
      i:integer;
  begin
    FResults:=TObjectList.Create;
    FResults.OwnsObjects:=true;
    while not Pos('  ',Adress)=0 do
      Adress := StringReplace(Adress,'  ','+',[rfReplaceAll]);
    Adress := Trim(AnsiLowerCase(StringReplace(Adress,' ','+',[rfReplaceAll])));
    i:= GM_Cashe.IndexOf(Adress);
    if i>=0 then
    begin
      FResponseContent:=TStringList(GM_Cashe.Objects[i]).Text;
      fCashed:=true;
    end
    else
    begin
      FRequestString := TIdURI.URLEncode('http://maps.googleapis.com/maps/api/geocode/xml?address='+ Adress +'&language=RU&sensor=false');
      HTTP := TIdHttp.Create(nil);
      Stream:=TStringStream.Create('',CP_UTF8);
      try
        HTTP.Get(FRequestString,Stream);
        FResponseContent := Stream.DataString;
      except
        FStatus:=gmNetEror;
        Exit;
      end;
    end;

      GeocodeResponse:=XMLSelectSingleNode('GeocodeResponse',FResponseContent);
      StatusNode := GeocodeResponse.selectSingleNode('status');
      s:=UpperCase(StatusNode.text);
      //Коды статуса
      //Поле "status", входящее в объект ответа службы геокодирования, содержит статус запроса и может включать в себя отладочную информацию для отслеживания сбоев службы. Поле "status" может содержать следующие значения:
      //"OK", указывающее на отсутствие ошибок. Синтаксический анализ адреса выполнен успешно. Был возвращен по крайней мере один геокод.
      //"ZERO_RESULTS", указывающее, что геокодирование выполнено успешно, но не возвратило никаких результатов. Это может произойти, если геокодеру был передан несуществующий элемент address или координаты latlng в удаленной точке.
      //"OVER_QUERY_LIMIT", указывающее на превышение квоты.
      //"REQUEST_DENIED", означающее, что запрос отклонен, обычно из-за отсутствия параметра sensor.
      //"INVALID_REQUEST", обычно указывающее, что запрос (address или latlng) отсутствует.
      if s='OK' then
      begin
        FStatus := gmOK;
        GM_Cashe.AddObject(Adress,TStringList.Create);
        TStringList(GM_Cashe.Objects[GM_Cashe.Count-1]).Text:=FResponseContent;
      end
      else
      if s='ZERO_RESULTS' then FStatus := gmZERO_RESULTS
      else
      if s='OVER_QUERY_LIMIT' then FStatus := gmOVER_QUERY_LIMIT
      else
      if s='REQUEST_DENIED' then FStatus := gmREQUEST_DENIED
      else
      if s='INVALID_REQUEST' then FStatus := gmINVALID_REQUEST
      else

    HTTP.Free;
    Stream.Free;
    if FStatus<>gmOK then exit;
    if GeocodeResponse = nil then exit;
    nlResults := GeocodeResponse.selectNodes('result');
    for I := 0 to nlResults.length-1 do
    begin
      try
        FResults.Add(TGMResult.Create(nlResults.item[i]));
      except

      end;
    end;


  end;

  destructor TGMGeocodeResponse.Destroy;
  begin
    FResults.Free;
  end;

  function TGMGeocodeResponse.AllFormattedAdresses: string;
  var i:Integer;
  begin
    for i := 0 to ResultsCount-1 do
    begin
      Result:=Result + Results[i].FFormattedAddress+#13;
    end;
    Result := Trim(Result);
  end;

function TGMGeocodeResponse.GetResults(index: Integer): TGMResult;
  begin
    Result := TGMResult(FResults[index]);
  end;

  function TGMGeocodeResponse.GetResultsCount: Integer;
  begin
    Result := FResults.Count;
  end;

  { TGMAdressComponent }

  constructor TGMAdressComponent.Create(XML_Part: IXMLDomNode);
  var i:integer;
      nlResTypes:IXMLDOMNodeList;
  begin
    FComponentTypes:=TStringList.Create;
    nlResTypes := XML_Part.selectNodes('type');
    for I := 0 to nlResTypes.length-1 do
    try
      FComponentTypes.Add(nlResTypes[i].text);
    except

    end;
    FLongName := XML_Part.selectSingleNode('long_name').text;
    FShortName := XML_Part.selectSingleNode('short_name').text;

  end;

  destructor TGMAdressComponent.Destroy;
  begin
    FComponentTypes.Free;
  end;

{ TGMViewPort }

  constructor TGMViewPort.Create(XML_Part: IXMLDomNode);
  begin
    try
    FSouthwest:= TGMLocation.Create(XML_Part.selectSingleNode('southwest'));
    except
    end;
    try
    FNortheast:= TGMLocation.Create(XML_Part.selectSingleNode('northeast'));
    except
    end;
  end;

  { TGMLocation }

  constructor TGMLocation.Create(XML_Part: IXMLDomNode);
  var ds:Char;
  begin
    ds:=FormatSettings.DecimalSeparator;
    FormatSettings.DecimalSeparator := '.';
    FLat := StrToFloat(XML_Part.selectSingleNode('lat').text);
    FLng := StrToFloat(XML_Part.selectSingleNode('lng').text);
    FormatSettings.DecimalSeparator := ds;

  end;

  { TGMGeometry }

  constructor TGMGeometry.Create(XML_Part: IXMLDomNode);
  var niViewport:IXMLDOMNode;
  begin
    FLocation := TGMLocation.Create(XML_Part.selectSingleNode('location'));
    FLocationType := XML_Part.selectSingleNode('location_type').text;
    niViewport := XML_Part.selectSingleNode('viewport');
    FViewPort := TGMViewPort.Create(niViewport);
  end;

{ TGMObject }

function TGMObject.XMLSelectSingleNode(xmltag,XML_Part:string):IXMLDomNode;
var
  node : IXMLDomNode;
begin
  CoInitialize(nil); // Needs to be called once before using CoDOMDocument.Create;
  doc := CoDOMDocument.Create;
  doc.loadXML(XML_Part);
  if (doc.documentElement = nil) then
    Exit;
  node := doc.selectSingleNode(xmltag);
  Result := node;
end;

function TGMObject.langbooltostr(value:Boolean; lang:string):string;
begin
  if lang = 'ru' then
    case value of
      False: result:='Нет';
      True : result:='Да';
    end
  else
    case value of
      False: result:='False';
      True : result:='True';
    end
end;

initialization
  GM_Cashe := TStringList.Create;

finalization
  while GM_Cashe.Count>0 do
  begin
    if GM_Cashe.Objects[0]<>nil then
    begin
      TStringList(GM_Cashe.Objects[0]).Free;
      GM_Cashe.Delete(0);
    end;
  end;
  GM_Cashe.Free

end.
