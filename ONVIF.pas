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
  System.IOUtils, IdUDPServer, IdGlobal, Soap.XSBuiltIns, IdSocketHandle,
  IdAuthenticationDigest, Winsock, XmlDoc, XmlIntf, XMLDom,
  ONVIF.Structure.Device, ONVIF.Structure.Profile,
  ONVIF.Structure.Capabilities;

CONST ONVIF_ERROR_URL_EMPTY                    = -1000;
      ONVIF_ERROR_SOAP_INVALID                 = -1001;
      ONVIF_ERROR_SOAP_NOBODY                  = -1002;
      ONVIF_ERROR_SOAP_FAULTCODE_NOT_FOUND     = -1003;      
      
Type


  {   https://www.onvif.org/specs/core/ONVIF-Core-Specification.pdf
      https://www.onvif.org/specs/srv/ptz/ONVIF-PTZ-Service-Spec-v221.pdf
      https://www.onvif.org/specs/srv/img/ONVIF-Imaging-Service-Spec.pdf?441d4a&441d4a

    TODO 
      Preset  
      Imaging like IR CuT, IRIS Focus
      Home
      Move AbsoluteMove,RelativeMove    
      PRofile parser in record

          AudioEncoderConfiguration  : TAudioEncoderConfiguration;
          VideoAnalyticsConfiguration: TVideoAnalyticsConfiguration;
          Extension                  : TExtension;
          
          Need example          
      SystemdateTime
   }


  /// <summary>
  ///   Specifies the type of ONVIF address, including device service, media, and PTZ.
  /// </summary>
  TONVIFAddrType = (atDeviceService, atMedia, atPtz,atDevice);

  /// <summary>
  ///   Specifies the type of ONVIF PTZ (Pan-Tilt-Zoom) command, including left, top, right,
  ///   bottom, top-right, top-left, bottom-left, and bottom-right.
  /// </summary>
  TONVIF_PTZ_CommandType = (opcNone,opcLeft, opcTop, opcRight, opcBotton, opcTopRight, opcTopLeft, opcBottonLeft, opcBottonRight);

  /// <summary>
  ///   Enumerates the types of PTZ movement supported by ONVIF.
  /// </summary>
  /// <remarks>
  ///   Possible values are: Continuous Move, Relative Move, and Absolute Move.
  /// </remarks>  
  TONVIF_PTZ_MoveType = (opmvContinuousMove,opmvtRelativeMove,opmvtAbsoluteMove);


  /// <summary>
  ///   Enumerates the logging levels for ONVIF events.
  /// </summary>
  /// <remarks>
  ///   Possible values are: Information, Error, Warning, and Exception.
  /// </remarks>
  TPONVIFLivLog = (tpLivInfo,tpLivError,tpLivWarning,tpLiveException);

  /// <summary>
  ///   Defines a procedure type for writing logs with specific parameters.
  /// </summary>
  /// <param name="Funzione">
  ///   Name of the function or operation.
  /// </param>
  /// <param name="Descrizione">
  ///   Description of the log entry.
  /// </param>
  /// <param name="Livello">
  ///   Logging level (Information, Error, Warning, or Exception).
  /// </param>
  /// <param name="IsVerboseLog">
  ///   Indicates whether the log entry is verbose. Default is False.
  /// </param>
  /// <remarks>
  ///   This procedure is used to write logs with detailed information based on the specified parameters.
  /// </remarks>  
  TEventWriteLog = procedure (Const Funzione,Descrizione:String;Livello : TPONVIFLivLog;IsVerboseLog:boolean=False) of object;  
    
  /// <summary>
  ///   Represents a manager class for handling ONVIF-related functionalities.
  /// </summary>  
  TONVIFManager = class
  private

    FUrl                 : String;
    FLogin               : String;
    FPassword            : String;
    FToken               : String;
    FLastResponse        : String;
    FLastStatusCode      : Integer;
    FSaveResponseOnDisk  : Boolean;
    FSpeed               : Byte;
    FDevice              : TDeviceInformation;
    FOnWriteLog          : TEventWriteLog; 
    FProfiles            : TProfiles;
    FCapabilities        : TCapabilitiesONVIF;
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
    
    /// <summary>
    ///   Returns an XML string representing a SOAP connection.
    /// </summary>
    /// <returns>
    ///   A string containing the details of the SOAP connection in XML format.
    /// </returns>    
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
        
    /// <summary>
    ///   Prepares and returns an XML string representing a request for device information.
    /// </summary>
    /// <returns>
    ///   A string containing the XML-formatted request for device information.
    /// </returns>
    function PrepareGetDeviceInformationRequest: String;
    /// <summary>
    ///   Retrieves device information and returns a Boolean indicating the success of the operation.
    /// </summary>
    /// <returns>
    ///   True if the device information is successfully retrieved; False otherwise, compile TDeviceInformation record.
    /// </returns>    
    function GetDeviceInformation: Boolean;
    /// <summary>
    ///   Resets the state or configuration of internal record like TDeviceInformation.
    /// </summary>    
    procedure Reset;
    {PTZ}
    /// <summary>
    ///   Prepares an ONVIF PTZ (Pan-Tilt) start move request based on the specified command.
    /// </summary>
    /// <param name="aCommand">
    ///   The command to be included in the PTZ start move request.
    /// </param>
    /// <returns>
    ///   An XML-formatted string representing the PTZ start move request.
    /// </returns>
    function PreparePTZ_StartMoveRequest(const aCommand: String): String;

    /// <summary>
    ///   Prepares an ONVIF PTZ stop move request.
    /// </summary>
    /// <returns>
    ///   An XML-formatted string representing the PTZ stop move request.
    /// </returns>
    function PreparePTZ_StopMoveRequest: String;

    /// <summary>
    ///   Prepares an ONVIF PTZ start zoom request based on the specified command.
    /// </summary>
    /// <param name="aCommand">
    ///   The command to be included in the PTZ start zoom request.
    /// </param>
    /// <returns>
    ///   An XML-formatted string representing the PTZ start zoom request.
    /// </returns>
    function PreparePTZ_StartZoomRequest(const aCommand: String): String;

    /// <summary>
    ///   Executes an ONVIF request using the provided address, input stream, and output stream.
    /// </summary>
    /// <param name="Addr">
    ///   The address for the ONVIF request.
    /// </param>
    /// <param name="InStream">
    ///   The input stream containing the ONVIF request data.
    /// </param>
    /// <param name="OutStream">
    ///   The output stream to store the ONVIF response data.
    /// </param>
    /// <returns>
    ///   True if the request is executed successfully; False otherwise.
    /// </returns>
    function ExecuteRequest(const Addr: String; const InStream, OutStream: TStringStream): Boolean; overload;

    /// <summary>
    ///   Executes an ONVIF request using the provided address and request string.
    /// </summary>
    /// <param name="Addr">
    ///   The address for the ONVIF request.
    /// </param>
    /// <param name="Request">
    ///   The ONVIF request string.
    /// </param>
    /// <param name="Answer">
    ///   Returns the ONVIF response string after executing the request.
    /// </param>
    /// <returns>
    ///   True if the request is executed successfully; False otherwise.
    /// </returns>
    function ExecuteRequest(const Addr, Request: String; var Answer: String): Boolean; overload;

    /// <summary>
    ///   Checks and handles an auxiliary command.
    /// </summary>
    procedure CheckAuxiliaryCommand;    

    /// <summary>
    ///   Sets the URL used for ONVIF communication.
    /// </summary>
    /// <param name="aValue">
    ///   The URL to be set.
    /// </param>
    procedure SetUrl(const aValue: String);

    /// <summary>
    ///   Prepares a GetCapabilities request for ONVIF communication.
    /// </summary>
    /// <returns>
    ///   The prepared GetCapabilities request string.
    /// </returns>
    function PrepareGetCapabilitiesRequest: String;

    /// <summary>
    ///   Retrieves and processes capabilities for the current ONVIF device.
    /// </summary>
    /// <returns>
    ///   Returns True if the capabilities are successfully retrieved and processed; otherwise, returns False.
    /// </returns>   
    function GetCapabilities: Boolean;    

    /// <summary>
    ///   Writes a log entry with specified parameters.
    /// </summary>
    /// <param name="aFunction">
    ///   Name of the function or operation.
    /// </param>
    /// <param name="aDescription">
    ///   Description of the log entry.
    /// </param>
    /// <param name="aLivel">
    ///   Logging level (Information, Error, Warning, or Exception).
    /// </param>
    /// <param name="aIsVerboseLog">
    ///   Indicates whether the log entry is verbose. Default is False.
    /// </param>
    procedure DoWriteLog(const aFunction, aDescription: String; aLivel: TPONVIFLivLog; aIsVerboseLog: boolean = False);

    /// <summary>
    ///   Checks if the set URL is valid for ONVIF communication.
    /// </summary>
    /// <returns>
    ///   True if the URL is valid; otherwise, False.
    /// </returns>
    function UrlIsValid: Boolean;

    /// <summary>
    ///   Converts an internal error code to a human-readable string.
    /// </summary>
    /// <param name="aError">
    ///   The internal error code to be converted.
    /// </param>
    /// <returns>
    ///   The human-readable string representation of the internal error.
    /// </returns>
    function InternalErrorToString(const aError: Integer): String;
    
    /// <summary>
    /// Checks whether the given XML node is a valid SOAP XML.
    /// </summary>
    /// <param name="aRootNode">The root node of the XML document.</param>
    /// <returns>True if the XML is a valid SOAP XML; otherwise, false.</returns>
    function IsValidSoapXML(const aRootNode: IXMLNode): Boolean;

    /// <summary>
    /// Retrieves the SOAP body node from the given SOAP XML document.
    /// </summary>
    /// <param name="aRootNode">The root node of the SOAP XML document.</param>
    /// <returns>The SOAP body node.</returns>
    function GetSoapBody(const aRootNode: IXMLNode): IXMLNode;

    /// <summary>
    /// Recursively searches for an XML node with the specified name within the given XML node.
    /// </summary>
    /// <param name="ANode">The XML node to start the search from.</param>
    /// <param name="aSearchNodeName">The name of the XML node to search for.</param>
    /// <returns>The found XML node or nil if not found.</returns>
    function RecursiveFindNode(ANode: IXMLNode; const aSearchNodeName: string;const aScanAllNode: Boolean=False): IXMLNode;
    /// <summary>
    ///   Resets the ONVIF capabilities of the device to default values.
    /// </summary>
    procedure ResetCapabilities;

    /// <summary>
    ///   Resets the ONVIF device information to default values.
    /// </summary>
    procedure ResetDevice;

    /// <summary>
    ///   Resets the ONVIF profiles information to default values.
    /// </summary>
    procedure ResetProfiles;
       
  public
    /// <summary>
    ///   Initializes a new instance of the TONVIFManager class with the specified ONVIF service details.
    /// </summary>
    /// <param name="aUrl">
    ///   The URL of the ONVIF service.
    /// </param>
    /// <param name="aLogin">
    ///   The login credentials for the ONVIF service.
    /// </param>
    /// <param name="aPassword">
    ///   The password credentials for the ONVIF service.
    /// </param>
    constructor Create(const aUrl, aLogin, aPassword:String);overload;
  
    /// <summary>
    ///   Initializes a new instance of the TONVIFManager class with the specified ONVIF service details.
    /// </summary>
    /// <param name="aUrl">
    ///   The URL of the ONVIF service.
    /// </param>
    /// <param name="aLogin">
    ///   The login credentials for the ONVIF service.
    /// </param>
    /// <param name="aPassword">
    ///   The password credentials for the ONVIF service.
    /// </param>
    /// <param name="aToken">
    ///   The security token for the ONVIF service.
    /// </param>
    constructor Create(const aUrl, aLogin, aPassword, aToken: String);overload;

    /// <summary>
    ///   ONVIF PTZ Zoom start operation.
    /// </summary>
    /// <param name="aInZoom">
    ///   Indicates whether it is an "in" zoom operation (True) or "out" zoom operation (False).
    /// </param>
    /// <param name="aResultStr">
    ///   Returns the result string after executing the PTZ start zoom operation.
    /// <returns>
    ///   True if the PTZ start zoom operation is executed successfully; False otherwise.
    /// </returns>
    function PTZ_StartZoom(aMoveType:TONVIF_PTZ_MoveType;aInZoom: Boolean): Boolean;

    /// <summary>
    ///   Initiates an ONVIF PTZ (Pan-Tilt) move operation based on the specified command.
    /// </summary>
    /// <param name="acommand">
    ///   The type of PTZ move command to be executed.
    /// </param>
    /// <param name="aResultStr">
    ///   Returns the result string after executing the PTZ move operation.
    /// </param>
    /// <returns>
    ///   True if the PTZ move operation is executed successfully; False otherwise.
    /// </returns>
    function PTZ_StartMove(aMoveType:TONVIF_PTZ_MoveType;const acommand: TONVIF_PTZ_CommandType): Boolean;

    /// <summary>
    ///   Stops an ongoing ONVIF PTZ (Pan-Tilt-Zoom) move operation.
    /// </summary>
    /// <param name="aResultStr">
    ///   Returns the result string after stopping the PTZ move operation.
    /// </param>
    /// <returns>
    ///   True if the PTZ move operation is successfully stopped; False otherwise.
    /// </returns>
    function PTZ_StopMove: Boolean;

    /// <summary>
    ///   Retrieves the profiles associated with the ONVIF device.
    /// </summary>
    /// <param name="aResultStr">
    ///   Returns the result string containing the profiles after executing the operation.
    /// </param>
    /// <returns>
    ///   True if the operation is executed successfully; False otherwise.
    /// </returns>
    function GetProfiles: Boolean;

    /// <summary>
    ///   Gets or sets the speed parameter for PTZ operations.
    /// </summary>
    property Speed                : Byte               read FSpeed              write FSpeed;

    /// <summary>
    ///   Gets or sets the URL of the ONVIF service.
    /// </summary>
    property Url                  : String             read Furl                write SetUrl;

    /// <summary>
    ///   Gets or sets the token of the ONVIF camera.
    /// </summary>    
    property Token                : String             read FToken              write FToken;
        
    
    /// <summary>
    ///   Event handler for writing logs with specific parameters.
    /// </summary>
    /// <remarks>
    ///   Use this event to handle log writing with detailed information based on the specified parameters.
    /// </remarks>
    property OnWriteLog           : TEventWriteLog     read FOnWriteLog         write FOnWriteLog;
    
    /// <summary>
    ///   Gets or sets whether to save the last HTTP response on disk.
    /// </summary>
    /// <remarks>
    ///   Set this property to True if you want to save the last HTTP response on disk.
    /// </remarks>
    property SaveResponseOnDisk   : Boolean            read FSaveResponseOnDisk write FSaveResponseOnDisk;  

    /// <summary>
    ///   Gets the last HTTP status code received.
    /// </summary>
    /// <remarks>
    ///   Use this property to retrieve the last HTTP status code received during communication.
    /// </remarks>    
    property LastStatusCode       : Integer            read FLastStatusCode;
    
    /// <summary>
    ///   Gets the last HTTP response received.
    /// </summary>
    /// <remarks>
    ///   Use this property to retrieve the last HTTP response received during communication.
    /// </remarks>    
    property LastResponse         : String             read FLastResponse;  

    /// <summary>
    ///   Gets information about the ONVIF device.
    /// </summary>
    property Device               : TDeviceInformation read FDevice;
    
    /// <summary>
    ///   Gets the profiles associated with the ONVIF communication.
    /// </summary>
    /// <remarks>
    ///   Use this property to retrieve the profiles associated with the ONVIF communication.
    /// </remarks>    
    property Profiles             : TProfiles          read FProfiles;  

    /// <summary>
    ///   Represents the ONVIF capabilities of the device.
    /// </summary>
    /// <remarks>
    ///   The ONVIF capabilities, including device, events, PTZ, and extension capabilities.
    /// </remarks>     
    property Capabilities         : TCapabilitiesONVIF read FCapabilities; 
  end;

implementation

Uses System.NetEncoding, IdHashSHA, IdHTTP, IdURI;



constructor TONVIFManager.Create(const aUrl, aLogin, aPassword:String);
begin
  Create(aUrl, aLogin, aPassword,String.Empty);
end;


constructor TONVIFManager.Create(const aUrl,aLogin,aPassword,aToken:String);
begin
  FLogin              := aLogin;
  FSaveResponseOnDisk := False;
  FPassword           := aPassword;
  FToken              := aToken;
  Url                 := aUrl;    // execute setUrl;  
  FSpeed              := 6;
end;

procedure TONVIFManager.DoWriteLog(const aFunction, aDescription: String;aLivel: TPONVIFLivLog; aIsVerboseLog: boolean=false);
begin
  if Assigned(FOnWriteLog) then
    FOnWriteLog(aFunction,aDescription,aLivel,aIsVerboseLog)
end;



procedure TONVIFManager.CheckAuxiliaryCommand;
begin
  
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

procedure TONVIFManager.SetUrl(const aValue: String);
begin
  if Furl <> aValue then
  begin
    if aValue.Trim.IsEmpty then
      Reset
    else
    begin
      Furl := aValue;
      {TODO get system date time to be use for password? }
      {TODO GetCapabilities}
      GetCapabilities;
      GetDeviceInformation;
      GetProfiles;
      

      if not Token.Trim.IsEmpty then
      begin
        {TODO Get preset}
        CheckAuxiliaryCommand;
      end;
    end;
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

function TONVIFManager.UrlIsValid: Boolean;
begin
  Result := not FUrl.Trim.IsEmpty;
  if not result then
  begin
    FLastStatusCode := ONVIF_ERROR_URL_EMPTY;
    FLastResponse   := InternalErrorToString(ONVIF_ERROR_URL_EMPTY);
  end;
    
end;

function TONVIFManager.InternalErrorToString(const aError :Integer):String;
begin
  case aError of
    ONVIF_ERROR_URL_EMPTY                : Result := 'Url is empty'; 
    ONVIF_ERROR_SOAP_INVALID             : result := 'Root node is not SOAP envelope';
    ONVIF_ERROR_SOAP_NOBODY              : result := 'Body SOAP node not found';
    ONVIF_ERROR_SOAP_FAULTCODE_NOT_FOUND : Result := 'SOAP Fault code not found';
  else
    result := 'Unknow error' 
  end;
end;

function TONVIFManager.GetUrlByType(const aUrlType: TONVIFAddrType): string;
CONST   
      URL_DEVICE_SERVICE = 'device_service';
      URL_PTZ_SERVICE    = 'ptz_service';  
      URL_MEDIA          = 'media';
      URL_DEVICE         = 'device';

Var LUri: TIdURI;
begin
  Result := String.Empty;
  if not UrlIsValid then Exit;
  
  LUri := TIdURI.Create(FUrl);
  try
    case aUrlType of
      atDeviceService: LUri.Document := URL_DEVICE_SERVICE;
      atMedia        : LUri.Document := URL_MEDIA;
      atPtz          : LUri.Document := URL_PTZ_SERVICE;
      atDevice       : LUri.Document := URL_DEVICE;
    end;
    Result := LUri.Uri;                                  
  finally
    FreeAndNil(LUri);
  end;
end;

function TONVIFManager.GetSoapXMLConnection:String;
CONST XML_SOAP_CONNECTION: String =
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

function TONVIFManager.PrepareGetCapabilitiesRequest: String;
const GET_CAPABILITIES = '<GetCapabilities'+
                         ' xmlns="http://www.onvif.org/ver10/device/wsdl">'+
                         '<Category>All</Category>'+
                         '</GetCapabilities>'+
                         '</soap:Body>'+
                         '</soap:Envelope>';
begin
  Result := GetSoapXMLConnection+ GET_CAPABILITIES;
end;

function TONVIFManager.GetCapabilities: Boolean;
var LResultStr         : String;
    LXMLDoc            : IXMLDocument;
    LSoapBodyNode      : IXMLNode;
    LCapabilitieNode   : IXMLNode;
    LNodeTmp1          : IXMLNode;
    LNodeTmp2          : IXMLNode;

    function GetChildNodeValue(const ParentNode: IXMLNode; const ChildNodeName: string): string;
    begin
      Result := '';
      if Assigned(ParentNode) then
      begin
        // Check if the child node exists before accessing its value
        if ParentNode.ChildNodes.IndexOf(ChildNodeName) > -1 then
          Result := ParentNode.ChildNodes[ChildNodeName].Text;
      end;
    end;      
begin
  Result := false;

  ResetCapabilities;
  if not UrlIsValid then Exit;  
  Result := ExecuteRequest(GetUrlByType(atDevice), PrepareGetCapabilitiesRequest, LResultStr);

  if Result then
  begin
    {$REGION 'Log'}
    {TSI:IGNORE ON}
        DoWriteLog('TONVIFManager.GetCapabilities',Format(' XML response [%s]',[LResultStr]),tpLivInfo,true);      
    {TSI:IGNORE OFF}
    {$ENDREGION}
    LXMLDoc := TXMLDocument.Create(nil);
    LXMLDoc.LoadFromXML(LResultStr);

    if not IsValidSoapXML(LXMLDoc.DocumentElement) then exit;
    
    LSoapBodyNode     := GetSoapBody(LXMLDoc.DocumentElement);
    LCapabilitieNode  := RecursiveFindNode(LSoapBodyNode,'Device');

    if Assigned(LCapabilitieNode) then
    begin
      FCapabilities.Device.XAddr := GetChildNodeValue(LCapabilitieNode,'XAddr');

      LNodeTmp1 := RecursiveFindNode(LCapabilitieNode,'Network');

      if Assigned(LNodeTmp1) then
      begin
        FCapabilities.Device.Network.IPFilter          := StrToBoolDef(GetChildNodeValue(LNodeTmp1,'IPFilter'),False);
        FCapabilities.Device.Network.ZeroConfiguration := StrToBoolDef(GetChildNodeValue(LNodeTmp1,'IPFilter'),False);  
        FCapabilities.Device.Network.IPVersion6        := StrToBoolDef(GetChildNodeValue(LNodeTmp1,'IPVersion6'),False);   
        FCapabilities.Device.Network.DynDNS            := StrToBoolDef(GetChildNodeValue(LNodeTmp1,'DynDNS'),False);  

        LNodeTmp2                                      := RecursiveFindNode(LNodeTmp1,'Extension');
        if Assigned(LNodeTmp2) then        
          FCapabilities.Device.Network.Extension.Dot11Configuration := StrToBoolDef(GetChildNodeValue(LNodeTmp2,'Dot11Configuration'),False);
      end;

      LNodeTmp1 := RecursiveFindNode(LCapabilitieNode,'System');

      if Assigned(LNodeTmp1) then
      begin
        FCapabilities.Device.System.DiscoveryResolve        := StrToBoolDef(GetChildNodeValue(LNodeTmp1,'DiscoveryResolve'),False);
        FCapabilities.Device.System.DiscoveryBye            := StrToBoolDef(GetChildNodeValue(LNodeTmp1,'DiscoveryBye'),False);
        FCapabilities.Device.System.RemoteDiscovery         := StrToBoolDef(GetChildNodeValue(LNodeTmp1,'RemoteDiscovery'),False);
        FCapabilities.Device.System.SystemBackup            := StrToBoolDef(GetChildNodeValue(LNodeTmp1,'SystemBackup'),False);
        FCapabilities.Device.System.SystemLogging           := StrToBoolDef(GetChildNodeValue(LNodeTmp1,'SystemLogging'),False);
        FCapabilities.Device.System.FirmwareUpgrade         := StrToBoolDef(GetChildNodeValue(LNodeTmp1,'FirmwareUpgrade'),False);
        
        LNodeTmp2                                           := RecursiveFindNode(LNodeTmp1,'SupportedVersions');
        if Assigned(LNodeTmp2) then
        begin        
          FCapabilities.Device.System.SupportedVersions.Major := StrToIntDef(GetChildNodeValue(LNodeTmp2,'Major'),-1);
          FCapabilities.Device.System.SupportedVersions.Minor := StrToIntDef(GetChildNodeValue(LNodeTmp2,'Minor'),-1);
        end;
      end;    

      {event}
      LCapabilitieNode := RecursiveFindNode(LSoapBodyNode,'Events');

      if Assigned(LCapabilitieNode) then
      begin
        FCapabilities.Events.XAddr                                         := GetChildNodeValue(LCapabilitieNode,'XAddr');
        FCapabilities.Events.WSSubscriptionPolicySupport                   := StrToBoolDef(GetChildNodeValue(LCapabilitieNode,'WSSubscriptionPolicySupport'),False);
        FCapabilities.Events.WSPullPointSupport                            := StrToBoolDef(GetChildNodeValue(LCapabilitieNode,'WSPullPointSupport'),False);
        FCapabilities.Events.WSPausableSubscriptionManagerInterfaceSupport := StrToBoolDef(GetChildNodeValue(LCapabilitieNode,'WSPausableSubscriptionManagerInterfaceSupport'),False);
      end;

      {Media}
      LCapabilitieNode := RecursiveFindNode(LSoapBodyNode,'Media'); 
      if Assigned(LCapabilitieNode) then
      begin            
        FCapabilities.Media.XAddr := GetChildNodeValue(LCapabilitieNode,'XAddr');
        LNodeTmp1                 := RecursiveFindNode(LCapabilitieNode,'StreamingCapabilities');
        if Assigned(LNodeTmp1) then
        begin
          FCapabilities.Media.StreamingCapabilities.RTPMulticast := StrToBoolDef(GetChildNodeValue(LNodeTmp1,'RTPMulticast'),False);
          FCapabilities.Media.StreamingCapabilities.RTP_TCP      := StrToBoolDef(GetChildNodeValue(LNodeTmp1,'RTP_TCP'),False);
          FCapabilities.Media.StreamingCapabilities.RTP_RTSP_TCP := StrToBoolDef(GetChildNodeValue(LNodeTmp1,'RTP_RTSP_TCP'),False);    
        end;
      end;
      {PTZ}
      LCapabilitieNode := RecursiveFindNode(LSoapBodyNode,'PTZ'); 
      if Assigned(LCapabilitieNode) then      
        FCapabilities.PTZ.XAddr := GetChildNodeValue(LCapabilitieNode,'XAddr');
      {Extension}
       LCapabilitieNode := RecursiveFindNode(LSoapBodyNode,'Extension',True); 
      if Assigned(LCapabilitieNode) then
      begin       
        LNodeTmp1 := RecursiveFindNode(LCapabilitieNode,'Search');  
        if Assigned(LNodeTmp1) then
        begin
          FCapabilities.Extension.Search.XAddr           := GetChildNodeValue(LNodeTmp1,'XAddr');
          FCapabilities.Extension.Search.MetadataSearch  := StrToBoolDef(GetChildNodeValue(LNodeTmp1,'MetadataSearch'),False);    
        end;
        LNodeTmp1 := RecursiveFindNode(LCapabilitieNode,'Replay');  
        if Assigned(LNodeTmp1) then
          FCapabilities.Extension.Replay.XAddr := GetChildNodeValue(LNodeTmp1,'XAddr');           
      end;              
    end;
  end
  else
    {$REGION 'Log'}
    {TSI:IGNORE ON}
        DoWriteLog('TONVIFManager.GetCapabilities',Format(' Error [%d] response [%s]',[FLastStatusCode,LResultStr]),tpLivError);      
    {TSI:IGNORE OFF}
    {$ENDREGION}
end;


function TONVIFManager.PrepareGetProfilesRequest: String;
const GET_PROFILES = '<GetProfiles xmlns="http://www.onvif.org/ver10/media/wsdl" /> ' + 
                      '</soap:Body> ' +
                      '</soap:Envelope>';
begin
  Result := GetSoapXMLConnection + GET_PROFILES
end;

function TONVIFManager.GetProfiles: Boolean;
var LResultStr         : String;
    LXMLDoc            : IXMLDocument;
    LSoapBodyNode      : IXMLNode;
    LProfilesNode      : IXMLNode;
    LTokenNode         : IXMLNode;
    LChildNodeRoot     : IXMLNode; 
    LChildNodeNode     : IXMLNode;
    LChildNodeNode2    : IXMLNode;
    LChildNodeNode3    : IXMLNode;
    I                  : Integer;
    LProfile           : TProfile;
    LCurrentIndex      : integer;

    function GetAttribute(const Node: IXMLNode; const AttributeName: string): string;
    begin
      Result := '';
      if Assigned(Node) and Node.HasAttribute(AttributeName) then
        Result := Node.Attributes[AttributeName];
    end;

    function GetChildNodeValue(const ParentNode: IXMLNode; const ChildNodeName: string): string;
    begin
      Result := '';
      if Assigned(ParentNode) then
      begin
        // Check if the child node exists before accessing its value
        if ParentNode.ChildNodes.IndexOf(ChildNodeName) > -1 then
          Result := ParentNode.ChildNodes[ChildNodeName].Text;
      end;
    end;    
begin
  Result := False;
  ResetProfiles;
  if not UrlIsValid then Exit;
  Result := ExecuteRequest(GetUrlByType(atDeviceService), PrepareGetProfilesRequest, LResultStr);

  if Result then
  begin
    Result := False;
    {$REGION 'Log'}
    {TSI:IGNORE ON}
        DoWriteLog('TONVIFManager.GetProfiles',Format(' XML response [%s]',[LResultStr]),tpLivInfo,true);      
    {TSI:IGNORE OFF}
    {$ENDREGION}  
    LXMLDoc := TXMLDocument.Create(nil);
    LXMLDoc.LoadFromXML(LResultStr);

    if not IsValidSoapXML(LXMLDoc.DocumentElement) then exit;
    
    LSoapBodyNode := GetSoapBody(LXMLDoc.DocumentElement);
    LProfilesNode := RecursiveFindNode(LSoapBodyNode,'GetProfilesResponse');

    if Assigned(LProfilesNode) then
    begin
      Result := LProfilesNode.ChildNodes.Count > 0;   

      if FToken.Trim.IsEmpty then
        SetLength(FProfiles,LProfilesNode.ChildNodes.Count)
      else
        SetLength(FProfiles,1);
        
      LCurrentIndex := 0;  
      for I := 0 to LProfilesNode.ChildNodes.Count -1 do
      begin  
      
        LProfile.token :=  String(LProfilesNode.ChildNodes[I].Attributes['token']);  
        if not FToken.Trim.IsEmpty then
        begin
          if LProfile.token.ToLower.Trim <> FToken.Trim.ToLower then
            continue;           
        end;
     
        LProfile.fixed := Boolean(StrToBoolDef(GetAttribute(LProfilesNode.ChildNodes[I],'fixed'), False));

        LProfile.name  := GetChildNodeValue(LProfilesNode.ChildNodes[I],'Name');

        // Continue parsing TVideoSourceConfiguration
        LChildNodeRoot := RecursiveFindNode(LProfilesNode.ChildNodes[I],'VideoSourceConfiguration');
        if Assigned(LChildNodeRoot) then
        begin
          LProfile.VideoSourceConfiguration.token       := GetAttribute(LChildNodeRoot,'token');
          LProfile.VideoSourceConfiguration.name        := GetChildNodeValue(LChildNodeRoot, 'Name'); 
          LProfile.VideoSourceConfiguration.UseCount    := StrToIntDef(GetChildNodeValue(LChildNodeRoot, 'UseCount'), 0);
          LProfile.VideoSourceConfiguration.SourceToken := GetChildNodeValue(LChildNodeRoot, 'SourceToken');


          LChildNodeNode := RecursiveFindNode(LChildNodeRoot,'Bounds');          
          if Assigned(LChildNodeNode) then
          begin
            LProfile.VideoSourceConfiguration.Bounds.x      := StrToIntDef(GetAttribute(LChildNodeNode,'x'), 0);
            LProfile.VideoSourceConfiguration.Bounds.y      := StrToIntDef(GetAttribute(LChildNodeNode,'y'), 0);
            LProfile.VideoSourceConfiguration.Bounds.width  := StrToIntDef(GetAttribute(LChildNodeNode,'width'), 0);
            LProfile.VideoSourceConfiguration.Bounds.height := StrToIntDef(GetAttribute(LChildNodeNode,'height'), 0);
          end;
        end;
        
        // Continue parsing TVideoEncoderConfiguration        
        LChildNodeRoot := RecursiveFindNode(LProfilesNode.ChildNodes[I],'VideoEncoderConfiguration');   
        if Assigned(LChildNodeRoot) then
        begin
          LProfile.VideoEncoderConfiguration.token           := GetAttribute(LChildNodeRoot,'token');
          LProfile.VideoEncoderConfiguration.name            := GetChildNodeValue(LChildNodeRoot, 'Name'); 
          LProfile.VideoEncoderConfiguration.UseCount        := StrToIntDef(GetChildNodeValue(LChildNodeRoot, 'UseCount'), 0);
          LProfile.VideoEncoderConfiguration.Encoding        := GetChildNodeValue(LChildNodeRoot, 'Encoding');
          LProfile.VideoEncoderConfiguration.Quality         := StrToFloatDef(GetChildNodeValue(LChildNodeRoot, 'Quality'),0);
          LProfile.VideoEncoderConfiguration.SessionTimeout  := GetChildNodeValue(LChildNodeRoot, 'SessionTimeout');

          LChildNodeNode := RecursiveFindNode(LChildNodeRoot,'Resolution');    
          if Assigned(LChildNodeNode) then
          begin     
            LProfile.VideoEncoderConfiguration.Resolution.width  := StrToIntDef(GetChildNodeValue(LChildNodeNode,'Width'), 0);
            LProfile.VideoEncoderConfiguration.Resolution.height := StrToIntDef(GetChildNodeValue(LChildNodeNode,'Height'), 0);
          end;
          
          LChildNodeNode := RecursiveFindNode(LChildNodeRoot,'RateControl');  
          if Assigned(LChildNodeNode) then
          begin     
            LProfile.VideoEncoderConfiguration.RateControl.FrameRateLimit   := StrToIntDef(GetChildNodeValue(LChildNodeNode,'FrameRateLimit'), 0);
            LProfile.VideoEncoderConfiguration.RateControl.EncodingInterval := StrToIntDef(GetChildNodeValue(LChildNodeNode,'EncodingInterval'), 0);
            LProfile.VideoEncoderConfiguration.RateControl.BitrateLimit     := StrToIntDef(GetChildNodeValue(LChildNodeNode,'BitrateLimit'), 0);            
          end;   

          LChildNodeNode := RecursiveFindNode(LChildNodeRoot,'H264');    
          if Assigned(LChildNodeNode) then
          begin     
            LProfile.VideoEncoderConfiguration.H264.GovLength   := StrToIntDef(GetChildNodeValue(LChildNodeNode,'GovLength'), 0);
            LProfile.VideoEncoderConfiguration.H264.H264Profile := GetChildNodeValue(LChildNodeNode,'H264Profile')
          end;   

          LChildNodeNode := RecursiveFindNode(LChildNodeRoot,'Multicast');    
          if Assigned(LChildNodeNode) then
          begin     
            LProfile.VideoEncoderConfiguration.Multicast.Port      := StrToIntDef(GetChildNodeValue(LChildNodeNode,'Port'), 0);
            LProfile.VideoEncoderConfiguration.Multicast.TTL       := StrToIntDef(GetChildNodeValue(LChildNodeNode,'TTL'), 0);            
            LProfile.VideoEncoderConfiguration.Multicast.AutoStart := StrToBoolDef(GetChildNodeValue(LChildNodeNode,'AutoStart'),false);

            LChildNodeNode := RecursiveFindNode(LChildNodeNode,'Address'); 
            if Assigned(LChildNodeNode) then
              LProfile.VideoEncoderConfiguration.Multicast.Address.TypeAddr := GetChildNodeValue(LChildNodeNode,'Type')
          end;                                                   
        end;
        
        // Continue parsing TPTZConfiguration    
        LChildNodeRoot := RecursiveFindNode(LProfilesNode.ChildNodes[I],'PTZConfiguration');
        if Assigned(LChildNodeRoot) then
        begin
          LProfile.PTZConfiguration.token     := GetAttribute(LChildNodeRoot,'token');
          LProfile.PTZConfiguration.Name      := GetChildNodeValue(LChildNodeNode,'Name');
          LProfile.PTZConfiguration.UseCount  := StrToIntDef(GetAttribute(LChildNodeRoot,'UseCount'),0);          
          LProfile.PTZConfiguration.NodeToken := GetAttribute(LChildNodeRoot,'NodeToken');
          
          LChildNodeNode                      := RecursiveFindNode(LChildNodeRoot,'DefaultPTZSpeed');
          if Assigned(LChildNodeNode) then
          begin
            LChildNodeNode2 :=RecursiveFindNode(LChildNodeNode,'PanTilt'); 
            if Assigned(LChildNodeNode2) then            
            begin
              LProfile.PTZConfiguration.DefaultPTZSpeed.PanTilt.x := StrToFloatDef(GetAttribute(LChildNodeNode2,'X'),0);
              LProfile.PTZConfiguration.DefaultPTZSpeed.PanTilt.Y := StrToFloatDef(GetAttribute(LChildNodeNode2,'Y'),0);              
            end;  
            LChildNodeNode2 :=RecursiveFindNode(LChildNodeNode,'Zoom'); 
            if Assigned(LChildNodeNode2) then            
              LProfile.PTZConfiguration.DefaultPTZSpeed.Zoom := StrToFloatDef(GetAttribute(LChildNodeNode2,'X'),0);
          end;
          
          LChildNodeNode := RecursiveFindNode(LChildNodeRoot,'PanTiltLimits');
          if Assigned(LChildNodeNode) then
          begin
            LChildNodeNode2 :=RecursiveFindNode(LChildNodeNode,'Range'); 
            if Assigned(LChildNodeNode2) then  
            begin          
              LProfile.PTZConfiguration.PanTiltLimits.Range.URI := GetChildNodeValue(LChildNodeNode2,'URI');
              LChildNodeNode3                                   := RecursiveFindNode(LChildNodeNode2,'XRange'); 

              if Assigned(LChildNodeNode3) then
              begin
                 LProfile.PTZConfiguration.PanTiltLimits.Range.XRange.Min := StrToIntDef(GetChildNodeValue(LChildNodeNode3,'Min'), 0);
                 LProfile.PTZConfiguration.PanTiltLimits.Range.XRange.Max := StrToIntDef(GetChildNodeValue(LChildNodeNode3,'Max'), 0);                 
              end;
              
              LChildNodeNode3  := RecursiveFindNode(LChildNodeNode2,'YRange'); 
              if Assigned(LChildNodeNode3) then
              begin
                 LProfile.PTZConfiguration.PanTiltLimits.Range.YRange.Min := StrToIntDef(GetChildNodeValue(LChildNodeNode3,'Min'), 0);
                 LProfile.PTZConfiguration.PanTiltLimits.Range.YRange.Max := StrToIntDef(GetChildNodeValue(LChildNodeNode3,'Max'), 0);                 
              end;                            
            end;              
          end;  

          LChildNodeNode := RecursiveFindNode(LChildNodeRoot,'ZoomLimits');
          if Assigned(LChildNodeNode) then
          begin
            LChildNodeNode2 :=RecursiveFindNode(LChildNodeNode,'Range'); 
            if Assigned(LChildNodeNode2) then  
            begin 
              LProfile.PTZConfiguration.ZoomLimits.Range.URI := GetChildNodeValue(LChildNodeNode2,'URI');;
              LChildNodeNode3                                := RecursiveFindNode(LChildNodeNode2,'XRange'); 

              if Assigned(LChildNodeNode3) then
              begin
                 LProfile.PTZConfiguration.ZoomLimits.Range.XRange.Min := StrToIntDef(GetChildNodeValue(LChildNodeNode3,'Min'), 0);
                 LProfile.PTZConfiguration.ZoomLimits.Range.XRange.Max := StrToIntDef(GetChildNodeValue(LChildNodeNode3,'Max'), 0);                 
              end;              
            end          
          end;        
         
        end;

        // TODO Continue parsing TAudioEncoderConfiguration         

        // TODO Continue parsing TVideoAnalyticsConfiguration        
        
        
        // TODO Continue parsing TExtension                
        
        FProfiles[LCurrentIndex] := LProfile;
        Inc(LCurrentIndex);
      end;      
    end
    else
      {$REGION 'Log'}
      {TSI:IGNORE ON}
          DoWriteLog('TONVIFManager.GetProfiles','Profiles node not found',tpLivError);
      {TSI:IGNORE OFF}
      {$ENDREGION}      
  end
  else
    {$REGION 'Log'}
    {TSI:IGNORE ON}
        DoWriteLog('TONVIFManager.GetProfiles',Format(' Error [%d] response [%s]',[FLastStatusCode,LResultStr]),tpLivError);      
    {TSI:IGNORE OFF}
    {$ENDREGION}  
end;


function TONVIFManager.PrepareGetDeviceInformationRequest: String;
const GET_DEVICE_INFO =  '<GetDeviceInformation xmlns="http://www.onvif.org/ver10/device/wsdl" />'+
                         '</soap:Body>'+
                         '</soap:Envelope>';
begin
  Result := GetSoapXMLConnection+ GET_DEVICE_INFO;
end;

function TONVIFManager.GetDeviceInformation: Boolean;
var LResultStr         : String;
    LXMLDoc            : IXMLDocument;
    LSoapBodyNode      : IXMLNode;

    Procedure SaveNodeInfo(const aNodeName:String;var aNodeResult:String);
    var LXMLNode    : IXMLNode;
    begin
      LXMLNode := RecursiveFindNode(LSoapBodyNode,aNodeName);

      if Assigned(LXMLNode) then
        aNodeResult := LXMLNode.Text;    
    end;
    
begin
  Result := false;
  ResetDevice;
  if not UrlIsValid then Exit;  
  Result := ExecuteRequest(GetUrlByType(atDevice), PrepareGetDeviceInformationRequest, LResultStr);

  if Result then
  begin
    {$REGION 'Log'}
    {TSI:IGNORE ON}
        DoWriteLog('TONVIFManager.GetDeviceInformation',Format(' XML response [%s]',[LResultStr]),tpLivInfo,true);      
    {TSI:IGNORE OFF}
    {$ENDREGION}  
    LXMLDoc := TXMLDocument.Create(nil);
    LXMLDoc.LoadFromXML(LResultStr);

    if not IsValidSoapXML(LXMLDoc.DocumentElement) then exit;
    
    LSoapBodyNode := GetSoapBody(LXMLDoc.DocumentElement);

    {Init Device information record}
    SaveNodeInfo('Manufacturer',FDevice.Manufacturer);
    SaveNodeInfo('Model',FDevice.Model);
    SaveNodeInfo('FirmwareVersion',FDevice.FirmwareVersion);    
    SaveNodeInfo('SerialNumber',FDevice.SerialNumber);    
    SaveNodeInfo('HardwareId',FDevice.HardwareId);    
    SaveNodeInfo('XAddr',FDevice.XAddr);        
  end
  else
    {$REGION 'Log'}
    {TSI:IGNORE ON}
        DoWriteLog('TONVIFManager.GetDeviceInformation',Format(' Error [%d] response [%s]',[FLastStatusCode,LResultStr]),tpLivError);      
    {TSI:IGNORE OFF}
    {$ENDREGION}
end;

function TONVIFManager.ExecuteRequest(const Addr, Request: String; Var Answer: String): Boolean;
Var LInStream : TStringStream; 
    LOutStream: TStringStream;
begin
  LInStream  := TStringStream.Create(Request);
  Try
    LOutStream := TStringStream.Create;
    try
      Result        := ExecuteRequest(Addr, LInStream, LOutStream);
      Answer        := LOutStream.DataString;  
      FLastResponse := Answer; 
      if FSaveResponseOnDisk then
      {TODO Filename on property}
        TFile.AppendAllText('DumpResponse.log',Answer);
    finally
      FreeAndNil(LOutStream);
    end;
  Finally
    FreeAndNil(LInStream);
  End;
end;

function TONVIFManager.ExecuteRequest(const Addr: String; const InStream, OutStream: TStringStream): Boolean;
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
      FLastStatusCode     := ResponseCode;
      Result      := (FLastStatusCode div 100) = 2
    end;
  finally
    LUri.Free;
    LIdhtp1.Free;
  end;
end;

procedure TONVIFManager.Reset;
begin
  ResetDevice;
  ResetProfiles;
  ResetCapabilities;
  FLastStatusCode         := 0;
  FLastResponse           := String.Empty;
    
end;

Procedure TONVIFManager.ResetProfiles;
begin
 SetLength(FProfiles,0);
end;

Procedure TONVIFManager.ResetDevice;
begin
  FDevice.Manufacturer    := String.Empty;
  FDevice.Model           := String.Empty;
  FDevice.FirmwareVersion := String.Empty;
  FDevice.SerialNumber    := String.Empty;
  FDevice.HardwareId      := String.Empty;
  FDevice.XAddr           := String.Empty;
end;

procedure TONVIFManager.ResetCapabilities;
begin
  {device}
  FCapabilities.Device.XAddr                                         := String.Empty;
  FCapabilities.Device.Network.IPFilter                              := False;
  FCapabilities.Device.Network.ZeroConfiguration                     := False;  
  FCapabilities.Device.Network.IPVersion6                            := False;   
  FCapabilities.Device.Network.DynDNS                                := False;  
  FCapabilities.Device.Network.Extension.Dot11Configuration          := False;          
  FCapabilities.Device.System.DiscoveryResolve                       := False;
  FCapabilities.Device.System.DiscoveryBye                           := False;
  FCapabilities.Device.System.RemoteDiscovery                        := False;
  FCapabilities.Device.System.SystemBackup                           := False;
  FCapabilities.Device.System.SystemLogging                          := False;        
  FCapabilities.Device.System.FirmwareUpgrade                        := False;          
  FCapabilities.Device.System.SupportedVersions.Major                := -1;
  FCapabilities.Device.System.SupportedVersions.Minor                := -1;  
  {event}
  FCapabilities.Events.XAddr                                         := String.Empty;
  FCapabilities.Events.WSSubscriptionPolicySupport                   := False;
  FCapabilities.Events.WSPullPointSupport                            := False;
  FCapabilities.Events.WSPausableSubscriptionManagerInterfaceSupport := False; 
  {Media}
  FCapabilities.Media.XAddr                                          := String.Empty;
  FCapabilities.Media.StreamingCapabilities.RTPMulticast             := False;
  FCapabilities.Media.StreamingCapabilities.RTP_TCP                  := False;
  FCapabilities.Media.StreamingCapabilities.RTP_RTSP_TCP             := False;    
  {PTZ}
  FCapabilities.PTZ.XAddr                                            := String.Empty;
  {Extension}
  FCapabilities.Extension.Search.XAddr                               := String.Empty;
  FCapabilities.Extension.Search.MetadataSearch                      := False;
  FCapabilities.Extension.Replay.XAddr                               := String.Empty;
end;


Function TONVIFManager.IsValidSoapXML(const aRootNode :IXMLNode):Boolean;
CONST cNodeSOAPEnvelope  = 'Envelope';
      cNodeSOAPBodyFault = 'Fault';
      cNodeFaultCode     = 'faultcode';
      cNodeFaultString   = 'faultstring';   
         
var LSoapBodyNode      : IXMLNode;  
    LSoapBodyFaultNode : IXMLNode;    
begin
  Result := false;

  if not Pos(cNodeSOAPEnvelope,aRootNode.NodeName) = 0  then 
  begin
    FLastStatusCode := ONVIF_ERROR_SOAP_INVALID;
    FLastResponse   := InternalErrorToString(ONVIF_ERROR_SOAP_INVALID);
    exit;
  end;

  LSoapBodyNode := GetSoapBody(aRootNode);

  if not Assigned(LSoapBodyNode) then
  begin
    FLastStatusCode := ONVIF_ERROR_SOAP_NOBODY;
    FLastResponse   := InternalErrorToString(ONVIF_ERROR_SOAP_NOBODY);  
    Exit;
  end;

  LSoapBodyFaultNode := LSoapBodyNode.ChildNodes.FindNode(cNodeSOAPBodyFault);

  if Assigned(LSoapBodyFaultNode) then
  begin
    if Assigned(LSoapBodyFaultNode.ChildNodes.FindNode(cNodeFaultCode,String.Empty)) then    
      FLastStatusCode := StrToIntDef(LSoapBodyFaultNode.ChildNodes.FindNode(cNodeFaultCode,String.Empty).Text,ONVIF_ERROR_SOAP_FAULTCODE_NOT_FOUND)
    else
      FLastStatusCode := ONVIF_ERROR_SOAP_FAULTCODE_NOT_FOUND; 
      
    if assigned(LSoapBodyFaultNode.ChildNodes.FindNode(cNodeFaultString,InternalErrorToString(FLastStatusCode))) then      
      FLastResponse := LSoapBodyFaultNode.ChildNodes.FindNode(cNodeFaultString,InternalErrorToString(FLastStatusCode)).Text
    else
      FLastResponse := InternalErrorToString(FLastStatusCode);
    
    exit;
  end;

  Result := True;
end;

function TONVIFManager.GetSoapBody(const aRootNode :IXMLNode) : IXMLNode;
CONST cNodeSOAPBody = 'Body';
begin
  Result := aRootNode.ChildNodes[cNodeSOAPBody];  
end;

function TONVIFManager.RecursiveFindNode(ANode: IXMLNode; const aSearchNodeName: string;const aScanAllNode: Boolean=False): IXMLNode;
var I: Integer;
    LResult : IXMLNode;
begin
  Result := nil;     
  LResult:= nil;         
  if not Assigned(ANode) then exit;

  if CompareText(ANode.DOMNode.localName , aSearchNodeName) = 0 then
  begin
    LResult := ANode;
    if not aScanAllNode then Exit(LResult);
  end;


  if Assigned(ANode.ChildNodes) then
  begin
    for I := 0 to ANode.ChildNodes.Count - 1 do
    begin
      Result := RecursiveFindNode(ANode.ChildNodes[I], aSearchNodeName,aScanAllNode);
      if (Result <> nil ) then
      begin
         if not aScanAllNode then Exit;

         LResult := Result;
      end;
    end;
  end;


  Result := LResult;
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

  Result := GetSoapXMLConnection + Format(CALL_PTZ_COMMAND,[FToken,aCommand]);
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

function TONVIFManager.PTZ_StartMove(aMoveType:TONVIF_PTZ_MoveType;const aCommand: TONVIF_PTZ_CommandType): Boolean;
var LCommandStr: String;  
    LResultStr : String;                                                  
begin
  Result := False;
  if not UrlIsValid then Exit;  
  case aMoveType of
    opmvContinuousMove: 
      begin
        case aCommand of
          opcTop          : LCommandStr := Format('x="0" y="0.%d"',[FSpeed]);
          opcBotton       : LCommandStr := Format('x="0" y="-0.%d"',[FSpeed]);
          opcRight        : LCommandStr := Format('x="0.%d" y="0"',[FSpeed]);  
          opcLeft         : LCommandStr := Format('x="-0.%d" y="0"',[FSpeed]);                                 
          opcTopRight     : LCommandStr := Format('x="0.%d" y="0.%d"',[FSpeed,FSpeed]);                                  
          opcTopLeft      : LCommandStr := Format('x="-0.%d" y="0.%d"',[FSpeed,FSpeed]);                                  
          opcBottonLeft   : LCommandStr := Format('x="-0.%d" y="-0.%d"',[FSpeed,FSpeed]);
          opcBottonRight  : LCommandStr := Format('x="0.%d" y="-0.%d"',[FSpeed,FSpeed]);                                  
        end;
        Result := ExecuteRequest(GetUrlByType(atPtz), PreparePTZ_StartMoveRequest(LCommandStr), LResultStr);      
      end;
      
    opmvtRelativeMove: raise Exception.Create('opmvtRelativeMove non supported');
    opmvtAbsoluteMove: raise Exception.Create('opmvtAbsoluteMove non supported');
  end;

end;

function TONVIFManager.PTZ_StartZoom(aMoveType:TONVIF_PTZ_MoveType;aInZoom: Boolean): Boolean;
var LCommand   : String;
    LResultStr : String; 
begin
  Result := False;
  if not UrlIsValid then Exit;
  case aMoveType of
    opmvContinuousMove :
      begin
        if aInZoom then
           LCommand := Format('x="-0.%d"',[FSpeed])
        else
           LCommand := Format('x="0.%d"',[FSpeed]);
        
        Result := ExecuteRequest(GetUrlByType(atPtz), PreparePTZ_StartZoomRequest(LCommand), LResultStr);      
      end;
    opmvtRelativeMove: raise Exception.Create('opmvtRelativeMove non supported');
    opmvtAbsoluteMove: raise Exception.Create('opmvtAbsoluteMove non supported');    
  end;

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

function TONVIFManager.PTZ_StopMove: Boolean;
var LResultStr: String;
begin
  Result := false;
  if not UrlIsValid then Exit;
  Result := ExecuteRequest(GetUrlByType(atPtz), PreparePTZ_StopMoveRequest, LResultStr);
end;

end.

