//*************************************************************
//                        ONVIF_WDSL                          *
//				                                        	  *
//                     Freeware Library                       *
//                       For Delphi 10.4                      *
//                            by                              *
//                     Alessandro Mancini                     *
//				                                        	  *
//*************************************************************
{LICENSE:
THIS SOFTWARE IS PROVIDED TO YOU "AS IS" WITHOUT WARRANTY OF ANY KIND,
EITHER EXPRESSED OR IMPLIED INCLUDING BUT NOT LIMITED TO THE APPLIED
WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
YOU ASSUME THE ENTIRE RISK AS TO THE ACCURACY AND THE USE OF THE SOFTWARE
AND ALL OTHER RISK ARISING OUT OF THE USE OR PERFORMANCE OF THIS SOFTWARE
AND DOCUMENTATION. PRODUCTIONS DOES NOT WARRANT THAT THE SOFTWARE IS ERROR-FREE
OR WILL OPERATE WITHOUT INTERRUPTION. THE SOFTWARE IS NOT DESIGNED, INTENDED
OR LICENSED FOR USE IN HAZARDOUS ENVIRONMENTS REQUIRING FAIL-SAFE CONTROLS,
INCLUDING WITHOUT LIMITATION, THE DESIGN, CONSTRUCTION, MAINTENANCE OR
OPERATION OF NUCLEAR FACILITIES, AIRCRAFT NAVIGATION OR COMMUNICATION SYSTEMS,
AIR TRAFFIC CONTROL, AND LIFE SUPPORT OR WEAPONS SYSTEMS. PRODUCTIONS SPECIFICALLY
DISCLAIMS ANY EXPRESS OR IMPLIED WARRANTY OF FITNESS FOR SUCH PURPOSE.

You may use/change/modify the component under 1 conditions:
1. In your application, add credits to "ONVIF WDSL"
{*******************************************************************************}

unit ONVIF;

interface
uses
  System.Classes, System.SysUtils, System.SyncObjs, System.Messaging,
  IdUDPServer, IdGlobal, Soap.XSBuiltIns, IdSocketHandle, IdAuthenticationDigest,
  Winsock;

Type

  {   https://www.onvif.org/specs/srv/ptz/ONVIF-PTZ-Service-Spec-v221.pdf
      https://www.onvif.org/specs/srv/img/ONVIF-Imaging-Service-Spec.pdf?441d4a&441d4a

    TODO 
      Preset  
      Imaging like IR CuT, IRIS Focus
      Home
      Move AbsoluteMove,RelativeMove
    
      PRofile and TDeviceInformation parser in record

  TDeviceInformation = record
    Manufacturer   : string;
    Model          : string;
    FirmwareVersion: String;
    SerialNumber   : String;
    HardwareId     : String;
    XAddr          : String;
  end;

  TSimpleItem = record
    Name : String;
    Value: String;
  end;
  
  TRealPoint = record
    x: Real;
    y: Real;
  end;

  TElementItemXY = TRealPoint;
  
  TElementItemLayout = record
    Columns  : Integer;
    Rows     : Integer;
    Translate: TElementItemXY;
    Scale    : TElementItemXY;
  end;
  
  TElementItemTransform = record
    Translate : TElementItemXY;
    Scale     : TElementItemXY;
  end;
  
  TPolygon          = TRealPoint;  
  TElementItemField = TArray<TPolygon>;
  TElementItem = record
    Name     : String;
    Layout   : TElementItemLayout;
    Field    : TElementItemField;
    Transform: TElementItemTransform;
  end;
  
  TAnalyticsModule = record
    Type_      : String;
    Name       : String;
    SimpleItem : TArray<TSimpleItem>;
    ElementItem: TArray<TElementItem>;
  end;
  
  TRule = TAnalyticsModule;

  TBoundsOnvif  = record
    x     : Integer;
    y     : Integer;
    width : Integer;
    height: Integer;
  end;

  TVideoSourceConfiguration = record
    token      : string;
    Name       : String;
    UseCount   : Integer;
    SourceToken: string;
    Bounds     : TBoundsOnvif;
  end;

  TAddressONVIF = record
    Type_      : string;
    IPv4Address: string;
  end;  

  TMulticastONVIF = record
    Address  : TAddressONVIF;
    Port     : Word;
    TTL      : Integer;
    AutoStart: Boolean;
  end;  
    
  TVideoEncoderConfiguration = record
    token          : String;
    Name           : String;
    UseCount       : Integer;
    Encoding       : string;
    Quality        : Double;
    SessionTimeout : String;
    Resolution     : record
      width : Integer;
      height: Integer;
    end;      
    RateControl    : record
      FrameRateLimit  : Integer;
      EncodingInterval: Integer;
      BitrateLimit    : Integer;
    end;
    H264           : record
      GovLength  : Integer;
      H264Profile: String;
    end;
    Multicast      : TMulticastONVIF;   
  end;  

  TAudioEncoderConfiguration = record
    token         : string;
    Name          : string;
    UseCount      : Integer;
    Encoding      : string;
    Bitrate       : Integer;
    SampleRate    : Integer;
    MultiCast     : TMulticastONVIF;
    SessionTimeout: String;
  end;  

  TVideoAnalyticsConfiguration = record
    token                       : String;
    Name                        : string;
    UseCount                    : Integer;
    AnalyticsEngineConfiguration: TArray<TAnalyticsModule>;
    RuleEngineConfiguration     : TArray<TRule>;
  end;  

  TPTZConfiguration = record
    token                                : String;
    Name                                 : string;
    UseCount                             : Integer;
    NodeToken                            : String;
    DefaultContinuousPanTiltVelocitySpace: string;
    DefaultContinuousZoomVelocitySpace   : string;
    DefaultPTZTimeout                    : String;
  end;  

 TAudioDecoderConfiguration = record
    token   : string;
    Name    : String;
    UseCount: Integer;
  end;    

  TAudioOutputConfiguration = record
    token      : String;
    Name       : String;
    UseCount   : Integer;
    OutputToken: String;
    SendPrimacy: string;
    OutputLevel: Integer;
  end;   
  
  TExtension = record
    AudioOutputConfiguration   : TAudioOutputConfiguration;
    TAudioDecoderConfiguration : TAudioDecoderConfiguration;
  end;
     
  TProfile = record
    fixed                      : Boolean;
    token                      : string;
    Name                       : String;
    VideoSourceConfiguration   : TVideoSourceConfiguration;
    VideoEncoderConfiguration  : TVideoEncoderConfiguration;
    AudioEncoderConfiguration  : TAudioEncoderConfiguration;
    VideoAnalyticsConfiguration: TVideoAnalyticsConfiguration;
    PTZConfiguration           : TPTZConfiguration;
    Extension                  : TExtension;
  end;   
  
  TProfiles = TArray<TProfile>;    }

  TONVIFAddrType         = (atDeviceService, atMedia,atPtz);
  TONVIF_PTZ_CommandType = (opcLeft,opcTop,opcRight,opcBotton,opcTopRight,opcTopLeft,opcBottonLeft,opcBottonRight);
  
  TONVIFManager = class
  private
    const
      URL_DEVICE_SERVICE = 'device_service';
      URL_PTZ_SERVICE    = 'ptz_service';  
      URL_MEDIA          = 'media';
    procedure SetUrl(const Value: String);
    var
    FUrl      : String;
    FLogin    : String;
    FPassword : String;
    FToken    : String;
    FSpeed    : Byte;
    /// <summary>
    ///   Calculates the password digest based on the provided parameters.
    /// </summary>
    /// <param name="aPasswordDigest">
    ///   Variable to store the calculated password digest.
    /// </param>
    /// <param name="aNonce">
    ///   String containing the nonce value.
    /// </param>
    /// <param name="aCreated">
    ///   String containing the created timestamp.
    /// </param>
    /// <remarks>
    ///   Ensure that the input parameters are valid and properly formatted.
    ///   The calculated password digest will be stored in the provided variable.
    /// </remarks>
    procedure GetPasswordDigest( Var aPasswordDigest, aNonce, aCreated: String);

    /// <summary>
    ///   Generates a URL based on the specified ONVIF address type.
    /// </summary>
    /// <param name="aUrlType">
    ///   The type of ONVIF address for which the URL needs to be generated.
    /// </param>
    /// <returns>
    ///   The generated URL as a string.
    /// </returns>
    /// <remarks>
    ///   The function takes an ONVIF address type as input and returns
    ///   the corresponding URL. Make sure to handle unexpected address types
    ///   appropriately.
    /// </remarks>    
    function GetUrlByType(const aUrlType: TONVIFAddrType): string;
    
    /// <summary>
    ///   Calculates the SHA-1 hash of the provided byte array.
    /// </summary>
    /// <param name="aData">
    ///   The input data for which the SHA-1 hash will be calculated.
    /// </param>
    /// <returns>
    ///   The calculated SHA-1 hash as a byte array.
    /// </returns>
    /// <remarks>
    ///   This function uses the SHA-1 hashing algorithm to generate a hash
    ///   for the provided input data. Ensure that the input data is valid
    ///   and properly formatted.
    /// </remarks>    
    function SHA1(const aData: TBytes): TBytes;
    
    function GetSoapXMLConnection:String;     

    /// <summary>
    ///   Prepares an XML string representing a request to retrieve profiles.
    /// </summary>
    /// <returns>
    ///   The XML string representing the GetProfiles request.
    /// </returns>
    /// <remarks>
    ///   This function generates an XML string that can be used as a request
    ///   to retrieve profiles. The format and structure of the XML may depend
    ///   on the specific requirements of the system or API you are working with.
    /// </remarks>    
    function PrepareGetProfilesRequest: String;
        
    {Device information}
    function PrepareGetDeviceInformationRequest: String;
    {PTZ}
    function PreparePTZ_StartMoveRequest(const aCommand: String): String;
    function PreparePTZ_StopMoveRequest: String;
    function PreparePTZ_StartZoomRequest(const aCommand: String): String;
    {Request}
    function ExecuteRequest(const Addr: String; const InStream, OutStream: TStringStream;var aStatusCode: Integer): Boolean; overload;
    function ExecuteRequest(const Addr, Request: String; Var Answer: String;var aStatusCode: Integer): Boolean; overload;    
    procedure CheckAuxiliaryCommand;
    
  public
    constructor Create(const aUrl,aLogin,aPassword,aToken:String);     
    function PTZ_StartZoom(aInZoom: Boolean;var aResultStr :String ;var aStatusCode:Integer): Boolean;
    function PTZ_StartMove(const acommand:TONVIF_PTZ_CommandType;var aResultStr :String ;var aStatusCode:Integer): Boolean;     
    function PTZ_StopMove(var aResultStr :String ;var aStatusCode:Integer): Boolean;    
    function GetDeviceInformation(var aResultStr :String ;var aStatusCode:Integer): Boolean;
    function GetProfiles(var aResultStr :String ;var aStatusCode:Integer): Boolean;    
    property Speed : Byte read FSpeed write FSpeed;   
    property Url   : String read Furl write SetUrl; 
  end;

implementation

Uses System.NetEncoding, IdHashSHA, IdHTTP, IdURI;


procedure TONVIFManager.CheckAuxiliaryCommand;
begin
  
end;

constructor TONVIFManager.Create(const aUrl,aLogin,aPassword,aToken:String);
begin
  Url       := aUrl;    // execute setUrl;
  FLogin    := aLogin;
  FPassword := aPassword;
  FToken    := aToken;
  FSpeed    := 6;
end;

procedure TONVIFManager.GetPasswordDigest(Var aPasswordDigest, aNonce, aCreated: String);
Var i          : Integer;
    LRaw_nonce : TBytes;
    LBnonce    : TBytes; 
    LDigest    : TBytes;
    Lraw_digest: TBytes;
begin
  SetLength(LRaw_nonce, 20);
  for i := 0 to High(LRaw_nonce) do
    LRaw_nonce[i]:= Random(256);
    
  LBnonce         := TNetEncoding.Base64.Encode(LRaw_nonce);
  aNonce          := TEncoding.ANSI.GetString(LBnonce);
  aCreated        := DateTimeToXMLTime(Now,False);
  Lraw_digest     := SHA1(LRaw_nonce + TEncoding.ANSI.GetBytes(aCreated) + TEncoding.ANSI.GetBytes(FPassword));
  LDigest         := TNetEncoding.Base64.Encode(Lraw_digest);
  aPasswordDigest := TEncoding.ANSI.GetString(LDigest);
end;

procedure TONVIFManager.SetUrl(const Value: String);
begin
  if Furl <> Value then
  begin
    Furl := Value;
    CheckAuxiliaryCommand;
  end;
end;

function TONVIFManager.SHA1(const aData: TBytes): TBytes;
Var LIdHashSHA1: TIdHashSHA1;
    i, j: TIdBytes;
begin
  LIdHashSHA1 := TIdHashSHA1.Create;
  try
    SetLength(i, Length(aData));
    Move(aData[0], i[0], Length(aData));
    j := LIdHashSHA1.HashBytes(i);
    SetLength(Result, Length(j));
    Move(j[0], Result[0], Length(j));
  finally
    LIdHashSHA1.Free;
  end;
end;

function TONVIFManager.GetUrlByType(const aUrlType: TONVIFAddrType): string;
Var LUri: TIdURI;
begin
  LUri := TIdURI.Create(FUrl);
  try
    case aUrlType of
      atDeviceService: LUri.Document := URL_DEVICE_SERVICE;
      atMedia        : LUri.Document := URL_MEDIA;
      atPtz          : LUri.Document := URL_PTZ_SERVICE;
    end;
    Result := LUri.Uri;
  finally
    FreeAndNil(LUri);
  end;
end;

function TONVIFManager.GetSoapXMLConnection:String;
CONST  XML_SOAP_CONNECTION: String =
    '<?xml version="1.0"?> ' + 
    '<soap:Envelope ' +        
    'xmlns:soap="http://www.w3.org/2003/05/soap-envelope" ' + 
    'xmlns:wsdl="http://www.onvif.org/ver10/media/wsdl">' + 
    '<soap:Header>' + 
    '<Security xmlns="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" s:mustUnderstand="1"> ' + 
    '<UsernameToken> ' + 
    '<Username>%s</Username> ' + 
    '<Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordDigest">%s</Password> ' +
    '<Nonce EncodingType="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-soap-message-security-1.0#Base64Binary">%s</Nonce> ' +
    '<Created xmlns="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">%s</Created> ' +
    '</UsernameToken> ' + 
    '</Security> ' +   
    '</soap:Header>' + 
    '<soap:Body xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"> ';
var LPasswordDigest : String; 
    LNonce          : String;
    LCreated        : String;
begin
  GetPasswordDigest(LPasswordDigest, LNonce, LCreated);
  Result := Format(XML_SOAP_CONNECTION, [FLogin, LPasswordDigest, LNonce, LCreated]);    
end;

function TONVIFManager.PrepareGetProfilesRequest: String;
const GET_PROFILES = '<GetProfiles xmlns="http://www.onvif.org/ver10/media/wsdl" /> ' + 
                      '</soap:Body> ' +
                      '</soap:Envelope>';
begin
  Result := GetSoapXMLConnection + GET_PROFILES
end;

function TONVIFManager.PrepareGetDeviceInformationRequest: String;
const GET_CAPABILITIES = '<GetCapabilities'+
                         ' xmlns="http://www.onvif.org/ver10/device/wsdl">'+
                         '<Category>All</Category>'+
                         '</GetCapabilities>'+
                         '</soap:Body>'+
                         '</soap:Envelope>';
begin
  Result := GetSoapXMLConnection+ GET_CAPABILITIES;
end;

function TONVIFManager.GetProfiles(var aResultStr :String ;var aStatusCode:Integer): Boolean;
begin
  Result := ExecuteRequest(GetUrlByType(atDeviceService), PrepareGetProfilesRequest, aResultStr,aStatusCode);
end;

function TONVIFManager.ExecuteRequest(const Addr, Request: String; Var Answer: String;var aStatusCode: Integer): Boolean;
Var LInStream : TStringStream; 
    LOutStream: TStringStream;
begin
  LInStream  := TStringStream.Create(Request);
  Try
    LOutStream := TStringStream.Create;
    try
      Result := ExecuteRequest(Addr, LInStream, LOutStream,aStatusCode);
      Answer := LOutStream.DataString;      
    finally
      FreeAndNil(LOutStream);
    end;
  Finally
    FreeAndNil(LInStream);
  End;
end;

function TONVIFManager.ExecuteRequest(const Addr: String; const InStream, OutStream: TStringStream;var aStatusCode: Integer): Boolean;
Var LIdhtp1: TIdHTTP;
    LUri: TIdURI;
begin
  LIdhtp1 := TIdHTTP.Create;
  LUri    := TIdURI.Create(Addr);
  try
    With LIdhtp1 do
    begin
      AllowCookies        := True;

      HandleRedirects     := True;
      Request.Accept      := 'gzip, deflate';
      Request.Host        := LUri.Host;
      Request.CharSet     := 'utf-8';
      Request.ContentType := 'application/soap+xml; charset=utf-8;';
      Request.CustomHeaders.Clear;
      ProtocolVersion     := pv1_1;
      HTTPOptions         := [hoNoProtocolErrorException, hoWantProtocolErrorContent,hoNoParseXmlCharset];
      Post(Addr, InStream, OutStream);
      aStatusCode := ResponseCode;
      Result      := (aStatusCode div 100) = 2
    end;
  finally
    LUri.Free;
    LIdhtp1.Free;
  end;
end;

function TONVIFManager.GetDeviceInformation(var aResultStr :String ;var aStatusCode:Integer): Boolean;
begin
  Result := ExecuteRequest(FUrl, PrepareGetDeviceInformationRequest, aResultStr,aStatusCode);
end;

function TONVIFManager.PreparePTZ_StartMoveRequest(const aCommand: String): String;

const CALL_PTZ_COMMAND = 	'<ContinuousMove'+
                          ' xmlns="http://www.onvif.org/ver20/ptz/wsdl"> '+
                          '<ProfileToken>%s</ProfileToken> '+
                          '<Velocity>'+
                          '<PanTilt %s '+
                          'xmlns="http://www.onvif.org/ver10/schema"/> '+
                          '</Velocity>'+
                          '</ContinuousMove>'+
                          '</soap:Body> '+
                          '</soap:Envelope>'; 
begin

  Result := GetSoapXMLConnection+ Format(CALL_PTZ_COMMAND,[FToken,aCommand]);
end;


function TONVIFManager.PreparePTZ_StartZoomRequest(const aCommand: String): String;

const CALL_PTZ_COMMAND = 	'<ContinuousMove'+
                          ' xmlns="http://www.onvif.org/ver20/ptz/wsdl"> '+
                          '<ProfileToken>%s</ProfileToken> '+
                          '<Velocity>'+
                          '<Zoom %s '+
                          'xmlns="http://www.onvif.org/ver10/schema"/> '+
                          '</Velocity>'+
                          '</ContinuousMove>'+
                          '</soap:Body> '+
                          '</soap:Envelope>';                          
begin
  Result := GetSoapXMLConnection+ Format(CALL_PTZ_COMMAND,[FToken,aCommand]);
end;

function TONVIFManager.PTZ_StartMove(const aCommand: TONVIF_PTZ_CommandType;var aResultStr :String ;var aStatusCode:Integer): Boolean;
var LCommandStr: String;                                                   
begin
  case aCommand of
    opcTop          : LCommandStr := Format('x="0" y="0.%d"',[FSpeed]);
    opcBotton       : LCommandStr := Format('x="0" y="-0.%d"',[FSpeed]);
    opcRight        : LCommandStr := Format('x="0.%d" y="0"',[FSpeed]);  
    opcLeft         : LCommandStr := Format('x="-0.%d" y="0"',[FSpeed]);                                 
    opcTopRight     : LCommandStr := Format('x="0.%d" y="0.%d"',[FSpeed,FSpeed]);                                  
    opcTopLeft      : LCommandStr := Format('x="-0.%d" y="0.%d"',[FSpeed,FSpeed]);                                  
    opcBottonLeft   : LCommandStr := Format('x="-0.%d" y="-0.%d"',[FSpeed,FSpeed]);
    opcBottonRight : LCommandStr := Format('x="0.%d" y="-0.%d"',[FSpeed,FSpeed]);                                  
  end;
  Result := ExecuteRequest(GetUrlByType(atPtz), PreparePTZ_StartMoveRequest(LCommandStr), aResultStr,aStatusCode);
end;

function TONVIFManager.PTZ_StartZoom(aInZoom: Boolean;var aResultStr :String ;var aStatusCode:Integer): Boolean;
var LCommand: String;
begin
  if aInZoom then
     LCommand := Format('x="-0.%d"',[FSpeed])
  else
     LCommand := Format('x="0.%d"',[FSpeed]);
        
  Result := ExecuteRequest(GetUrlByType(atPtz), PreparePTZ_StartZoomRequest(LCommand), aResultStr,aStatusCode);
end;

function TONVIFManager.PreparePTZ_StopMoveRequest: String;
const STOP_PTZ_COMMAND =  '<Stop xmlns="http://www.onvif.org/ver20/ptz/wsdl">'+
                          '<ProfileToken>%s</ProfileToken> '+
                          '<PanTilt>true</PanTilt><Zoom>false</Zoom></Stop>'+
                          '</soap:Body>'+
                          '</soap:Envelope>';
begin
  Result := GetSoapXMLConnection+ Format(STOP_PTZ_COMMAND,[FToken]);
end;

function TONVIFManager.PTZ_StopMove(var aResultStr :String ;var aStatusCode:Integer): Boolean;
begin
  Result := ExecuteRequest(GetUrlByType(atPtz), PreparePTZ_StopMoveRequest, aResultStr,aStatusCode);
end;





end.
