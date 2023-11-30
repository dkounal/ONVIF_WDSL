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


unit ONVIF.Structure.Profile;

interface

Type

  /// <summary>
  ///   Represents a simple item for ONVIF configuration.
  /// </summary>
  /// <record name="TSimpleItem">
  ///   <field name="Name" type="String">
  ///     The name of the simple item.
  ///   </field>
  ///   <field name="Value" type="String">
  ///     The value of the simple item.
  ///   </field>
  /// </record>
  TSimpleItem = record
    Name : String;
    Value: String;
  end;
  
  /// <summary>
  ///   Represents a point X and Y for ONVIF configuration.
  /// </summary>
  /// <record name="TRealPoint">
  ///   <field name="x" type="Real">
  ///     The x value.
  ///   </field>
  ///   <field name="y" type="Real">
  ///     The y value
  ///   </field>
  /// </record>
  TRealPoint = record
    x: Real;
    y: Real;
  end;

  /// <summary>
  ///   Represents a point with real coordinates for ONVIF configuration (alias for TRealPoint).
  /// </summary>
  /// <record name="TElementItemXY">
  ///   Same structure as TRealPoint.
  /// </record>  
  TElementItemXY = TRealPoint;
  
  /// <summary>
  ///   Represents the layout configuration for an element item in ONVIF.
  /// </summary>
  /// <record name="TElementItemLayout">
  ///   <field name="Columns" type="Integer">
  ///     The number of columns in the layout.
  ///   </field>
  ///   <field name="Rows" type="Integer">
  ///     The number of rows in the layout.
  ///   </field>
  ///   <field name="Translate" type="TElementItemXY">
  ///     Translation configuration for the layout.
  ///   </field>
  ///   <field name="Scale" type="TElementItemXY">
  ///     Scaling configuration for the layout.
  ///   </field>
  /// </record>  
  TElementItemLayout = record
    Columns  : Integer;
    Rows     : Integer;
    Translate: TElementItemXY;
    Scale    : TElementItemXY;
  end;
  
  /// <summary>
  ///   Represents the transform configuration for an element item in ONVIF.
  /// </summary>
  /// <record name="TElementItemTransform">
  ///   <field name="Translate" type="TElementItemXY">
  ///     Translation configuration for the transform.
  ///   </field>
  ///   <field name="Scale" type="TElementItemXY">
  ///     Scaling configuration for the transform.
  ///   </field>
  /// </record>  
  TElementItemTransform = record
    Translate : TElementItemXY;
    Scale     : TElementItemXY;
  end;
  
  /// <summary>
  ///   Represents a polygon with real coordinates for ONVIF configuration.
  /// </summary>
  /// <record name="TPolygon">
  ///   Same structure as TRealPoint.
  /// </record>  
  TPolygon          = TRealPoint;  
  TElementItemField = TArray<TPolygon>;

  /// <summary>
  ///   Represents an element item for ONVIF configuration.
  /// </summary>
  /// <record name="TElementItem">
  ///   <field name="Name" type="String">
  ///     The name of the element item.
  ///   </field>
  ///   <field name="Layout" type="TElementItemLayout">
  ///     The layout configuration for the element item.
  ///   </field>
  ///   <field name="Field" type="TElementItemField">
  ///     The field configuration for the element item.
  ///   </field>
  ///   <field name="Transform" type="TElementItemTransform">
  ///     The transform configuration for the element item.
  ///   </field>
  /// </record>  
  TElementItem = record
    Name     : String;
    Layout   : TElementItemLayout;
    Field    : TElementItemField;
    Transform: TElementItemTransform;
  end;
  

  /// <summary>
  ///   Represents an analytics module for ONVIF configuration.
  /// </summary>
  /// <record name="TAnalyticsModule">
  ///   <field name="Type_" type="String">
  ///     The type of analytics module.
  ///   </field>
  ///   <field name="Name" type="String">
  ///     The name of the analytics module.
  ///   </field>
  ///   <field name="SimpleItem" type="TArray<TSimpleItem>">
  ///     Array of simple items associated with the analytics module.
  ///   </field>
  ///   <field name="ElementItem" type="TArray<TElementItem>">
  ///     Array of element items associated with the analytics module.
  ///   </field>
  /// </record>  
  TAnalyticsModule = record
    Type_      : String;
    Name       : String;
    SimpleItem : TArray<TSimpleItem>;
    ElementItem: TArray<TElementItem>;
  end;
  
  /// <summary>
  ///   Represents an analytics rule for ONVIF configuration.
  /// </summary>
  /// <record name="TRule">
  ///   Same structure as TAnalyticsModule.
  /// </record>  
  TRule = TAnalyticsModule;


  /// <summary>
  ///   Represents the bounds for ONVIF configuration.
  /// </summary>
  /// <record name="TBoundsONVIF">
  ///   <field name="x" type="Integer">
  ///     The x-coordinate of the bounds.
  ///   </field>
  ///   <field name="y" type="Integer">
  ///     The y-coordinate of the bounds.
  ///   </field>
  ///   <field name="width" type="Integer">
  ///     The width of the bounds.
  ///   </field>
  ///   <field name="height" type="Integer">
  ///     The height of the bounds.
  ///   </field>
  /// </record>  
  TBoundsONVIF  = record
    x     : Integer;
    y     : Integer;
    width : Integer;
    height: Integer;
  end;

  /// <summary>
  ///   Represents the configuration of an ONVIF video source.
  /// </summary>
  /// <record name="TVideoSourceConfiguration">
  ///   <field name="token" type="String">
  ///     The token associated with the video source configuration.
  ///   </field>
  ///   <field name="Name" type="String">
  ///     The name of the video source configuration.
  ///   </field>
  ///   <field name="UseCount" type="Integer">
  ///     The count of how many times the video source configuration is used.
  ///   </field>
  ///   <field name="SourceToken" type="String">
  ///     The token associated with the source.
  ///   </field>
  ///   <field name="Bounds" type="TBoundsONVIF">
  ///     The bounds associated with the video source configuration.
  ///   </field>
  /// </record>  
  TVideoSourceConfiguration = record
    token      : string;
    Name       : String;
    UseCount   : Integer;
    SourceToken: string;
    Bounds     : TBoundsONVIF;
  end;

  /// <summary>
  ///   Represents the address for ONVIF configuration.
  /// </summary>
  /// <record name="TAddressONVIF">
  ///   <field name="TypeAddr" type="String">
  ///     The type of address.
  ///   </field>
  /// </record>  
  TAddressONVIF = record
    TypeAddr    : string;
  end;  

  /// <summary>
  ///   Represents multicast settings for ONVIF video encoder configuration.
  /// </summary>
  /// <record name="TMulticastONVIF">
  ///   <field name="Address" type="TAddressONVIF">
  ///     The multicast address settings.
  ///   </field>
  ///   <field name="Port" type="Word">
  ///     The port number for multicast.
  ///   </field>
  ///   <field name="TTL" type="Integer">
  ///     The time-to-live (TTL) value for multicast.
  ///   </field>
  ///   <field name="AutoStart" type="Boolean">
  ///     Indicates whether multicast should start automatically.
  ///   </field>
  /// </record>  
  TMulticastONVIF = record
    Address  : TAddressONVIF;
    Port     : Word;
    TTL      : Integer;
    AutoStart: Boolean;
  end;  

  /// <summary>
  ///   Represents rate control settings for ONVIF video encoder configuration.
  /// </summary>
  /// <record name="TRateControlONVIF">
  ///   <field name="FrameRateLimit" type="Integer">
  ///     The limit on the frame rate.
  ///   </field>
  ///   <field name="EncodingInterval" type="Integer">
  ///     The encoding interval.
  ///   </field>
  ///   <field name="BitrateLimit" type="Integer">
  ///     The limit on the bitrate.
  ///   </field>
  /// </record>  
  TRateControlONVIF  = record
    FrameRateLimit  : Integer;
    EncodingInterval: Integer;
    BitrateLimit    : Integer;
  end;  
  
  /// <summary>
  ///   Represents resolution settings for ONVIF video encoder configuration.
  /// </summary>
  /// <record name="TResolutionONVIF">
  ///   <field name="width" type="Integer">
  ///     The width of the resolution.
  ///   </field>
  ///   <field name="height" type="Integer">
  ///     The height of the resolution.
  ///   </field>
  /// </record>    
  TResolutionONVIF = Record  
    width : Integer;
    height: Integer;
  end;   

  /// <summary>
  ///   Represents H.264 settings for ONVIF video encoder configuration.
  /// </summary>
  /// <record name="TH264ONVIF">
  ///   <field name="GovLength" type="Integer">
  ///     The group of video frames between keyframes.
  ///   </field>
  ///   <field name="H264Profile" type="String">
  ///     The H.264 profile used by the video encoder.
  ///   </field>
  /// </record>
           
  TH264ONVIF = record
    GovLength  : Integer;
    H264Profile: String;
  end;   
  
  /// <summary>
  ///   Represents an ONVIF video encoder configuration.
  /// </summary>
  /// <record name="TVideoEncoderConfiguration">
  ///   <field name="token" type="String">
  ///     The token associated with the video encoder configuration.
  ///   </field>
  ///   <field name="Name" type="String">
  ///     The name of the video encoder configuration.
  ///   </field>
  ///   <field name="UseCount" type="Integer">
  ///     The count of how many times the video encoder configuration is used.
  ///   </field>
  ///   <field name="Encoding" type="String">
  ///     The encoding type used by the video encoder.
  ///   </field>
  ///   <field name="Quality" type="Double">
  ///     The quality setting of the video encoder.
  ///   </field>
  ///   <field name="SessionTimeout" type="String">
  ///     The session timeout for the video encoder.
  ///   </field>
  ///   <field name="Resolution" type="TResolutionONVIF">
  ///     Resolution settings associated with the video encoder.
  ///   </field>
  ///   <field name="RateControl" type="TRateControlONVIF">
  ///     Rate control settings associated with the video encoder.
  ///   </field>
  ///   <field name="H264" type="TH264ONVIF">
  ///     H.264 settings associated with the video encoder.
  ///   </field>
  ///   <field name="Multicast" type="TMulticastONVIF">
  ///     Multicast settings associated with the video encoder.
  ///   </field>
  /// </record>  
  TVideoEncoderConfiguration = record
    token          : String;
    Name           : String;
    UseCount       : Integer;
    Encoding       : string;
    Quality        : Double;
    SessionTimeout : String;
    Resolution     : TResolutionONVIF;      
    RateControl    : TRateControlONVIF;
    H264           : TH264ONVIF;
    Multicast      : TMulticastONVIF;   
  end;  

  /// <summary>
  ///   Represents an ONVIF audio encoder configuration.
  /// </summary>
  /// <record name="TAudioEncoderConfiguration">
  ///   <field name="token" type="String">
  ///     The token associated with the audio encoder configuration.
  ///   </field>
  ///   <field name="Name" type="String">
  ///     The name of the audio encoder configuration.
  ///   </field>
  ///   <field name="UseCount" type="Integer">
  ///     The count of how many times the audio encoder configuration is used.
  ///   </field>
  ///   <field name="Encoding" type="String">
  ///     The encoding type used by the audio encoder.
  ///   </field>
  ///   <field name="Bitrate" type="Integer">
  ///     The bitrate of the audio encoder.
  ///   </field>
  ///   <field name="SampleRate" type="Integer">
  ///     The sample rate of the audio encoder.
  ///   </field>
  ///   <field name="MultiCast" type="TMulticastONVIF">
  ///     Multicast configuration associated with the audio encoder.
  ///   </field>
  ///   <field name="SessionTimeout" type="String">
  ///     The session timeout for the audio encoder.
  ///   </field>
  /// </record>
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


  /// <summary>
  ///   Represents an ONVIF video analytics configuration.
  /// </summary>
  /// <record name="TVideoAnalyticsConfiguration">
  /// <field name="token" type="String">
  ///   The token associated with the video analytics configuration.
  /// </field>
  /// <field name="Name" type="String">
  ///   The name of the video analytics configuration.
  /// </field>
  /// <field name="UseCount" type="Integer">
  ///   The count of how many times the video analytics configuration is used.
  /// </field>
  /// <field name="AnalyticsEngineConfiguration" type="TArray<TAnalyticsModule>">
  ///   Configuration for the analytics engine associated with the video analytics.
  /// </field>
  /// <field name="RuleEngineConfiguration" type="TArray<TRule>">
  ///   Configuration for the rule engine associated with the video analytics.
  /// </field>
  /// </record>  
  TVideoAnalyticsConfiguration = record
    token                       : String;
    Name                        : string;
    UseCount                    : Integer;
    AnalyticsEngineConfiguration: TArray<TAnalyticsModule>;
    RuleEngineConfiguration     : TArray<TRule>;
  end;  

  /// <summary>
  ///   Represents the minimum and maximum values for a range.
  /// </summary>
  /// <record name="TMinMaxValue">
  /// <field name="Min" type="Real">
  ///   The minimum value in the range.
  /// </field>
  /// <field name="Max" type="Real">
  ///   The maximum value in the range.
  /// </field>
  /// </record>  
  TMinMaxValue = Record
     Min : Real;
     Max : Real;
  end;

  /// <summary>
  ///   Represents a range for Pan-Tilt movement in ONVIF PTZ (Pan-Tilt-Zoom) configuration.
  /// </summary>
  /// <record name="TRangePTZONVIF">
  /// <field name="URI" type="String">
  ///   URI associated with the range.
  /// </field>
  /// <field name="XRange" type="TMinMaxValue">
  ///   X-axis range for Pan movement.
  /// </field>
  /// <field name="YRange" type="TMinMaxValue">
  ///   Y-axis range for Tilt movement.
  /// </field>
  /// </record>  
  TRangePTZONVIF = Record
    URI    : String;
    XRange : TMinMaxValue;
    YRange : TMinMaxValue; 
  end;
  
  /// <summary>
  ///   Represents Pan-Tilt limits for ONVIF PTZ (Pan-Tilt-Zoom) configuration.
  /// </summary>
  /// <record name="TPanTiltLimits">
  /// <field name="Range" type="TRangePTZONVIF">
  ///   Limits for Pan-Tilt movement.
  /// </field>
  ///  </record>  
  TPanTiltLimits = Record
    Range : TRangePTZONVIF;
  End;

  /// <summary>
  ///   Represents the range of Zoom for ONVIF PTZ (Pan-Tilt-Zoom) configuration.
  /// </summary>
  /// <record name="TRangeZoomPTZONVIF">
  /// <field name="URI" type="String">
  ///   URI associated with the Zoom range.
  /// </field>
  /// <field name="XRange" type="TMinMaxValue">
  ///   X-axis range for Zoom.
  /// </field>
  /// </record>  
  TRangeZoomPTZONVIF = Record
    URI    : String;
    XRange : TMinMaxValue; 
  End;  

  /// <summary>
  ///   Represents Zoom limits for ONVIF PTZ (Pan-Tilt-Zoom) configuration.
  /// </summary>
  /// <record name="TZoomLimits">
  /// <field name="Range" type="TRangeZoomPTZONVIF">
  ///   Limits for Zoom movement.
  /// </field>
  /// </record>  
  TZoomLimits = Record
    Range : TRangeZoomPTZONVIF;
  End;  

  /// <summary>
  ///   Represents the default PTZ (Pan-Tilt-Zoom) speed configuration.
  /// </summary>
  ///<record name="TDefaultPTZSpeed">
  /// <field name="PanTilt" type="TElementItemXY">
  ///   Default speed for Pan-Tilt movement.
  /// </field>
  /// <field name="Zoom" type="Real">
  ///   Default speed for Zoom movement.
  /// </field>
  ///</record>  
  TDefaultPTZSpeed = record
     PanTilt         : TElementItemXY;
     Zoom            : Real;
  end;

  /// <summary>
  ///   Represents an ONVIF PTZ (Pan-Tilt-Zoom) configuration.
  /// </summary>
  /// <record name="TPTZConfiguration">
  /// <field name="token" type="String">
  ///   The token associated with the PTZ configuration.
  /// </field>
  /// <field name="Name" type="String">
  ///   The name of the PTZ configuration.
  /// </field>
  /// <field name="UseCount" type="Integer">
  ///   The count of how many times the PTZ configuration is used.
  /// </field>
  /// <field name="NodeToken" type="String">
  ///   The token associated with the node.
  /// </field>
  /// <field name="DefaultPTZSpeed" type="TDefaultPTZSpeed">
  ///   Default PTZ speed associated with the PTZ configuration.
  /// </field>
  /// <field name="PanTiltLimits" type="TPanTiltLimits">
  ///   Pan-Tilt limits associated with the PTZ configuration.
  /// </field>
  /// <field name="ZoomLimits" type="TZoomLimits">
  ///   Zoom limits associated with the PTZ configuration.
  /// </field>
  /// </record>  
  TPTZConfiguration = record
    token           : String;
    Name            : string;
    UseCount        : Integer;
    NodeToken       : String;
    DefaultPTZSpeed : TDefaultPTZSpeed;
    PanTiltLimits   : TPanTiltLimits;
    ZoomLimits      : TZoomLimits;    
  end;  

  /// <summary>
  ///   Represents an ONVIF audio decoder configuration.
  /// </summary>
  ///<record name="TAudioDecoderConfiguration">
  ///  <field name="token" type="String">
  ///    The token associated with the audio decoder configuration.
  ///  </field>
  ///  <field name="Name" type="String">
  ///    The name of the audio decoder configuration.
  ///  </field>
  ///  <field name="UseCount" type="Integer">
  ///    The count of how many times the audio decoder configuration is used.
  ///  </field>
  ///</record>  
 TAudioDecoderConfiguration = record
    token   : string;
    Name    : String;
    UseCount: Integer;
  end;    
  
  /// <summary>
  ///   Represents an ONVIF audio output configuration.
  /// </summary>
  ///<record name="TAudioOutputConfiguration">
  ///  <field name="token" type="String">
  ///    The token associated with the audio output configuration.
  ///  </field>
  ///  <field name="Name" type="String">
  ///    The name of the audio output configuration.
  ///  </field>
  ///  <field name="UseCount" type="Integer">
  ///    The count of how many times the audio output configuration is used.
  ///  </field>
  ///  <field name="OutputToken" type="String">
  ///    The token associated with the audio output.
  ///  </field>
  ///  <field name="SendPrimacy" type="String">
  ///    The send primacy of the audio output configuration.
  ///  </field>
  ///  <field name="OutputLevel" type="Integer">
  ///    The output level of the audio output configuration.
  ///  </field>
  ///</record>
  TAudioOutputConfiguration = record
    token      : String;
    Name       : String;
    UseCount   : Integer;
    OutputToken: String;
    SendPrimacy: string;
    OutputLevel: Integer;
  end;   
  
  /// <summary>
  ///   Represents an ONVIF extension.
  /// </summary>
  /// <record name="TExtension">
  ///   <field name="AudioOutputConfiguration" type="TAudioOutputConfiguration">
  ///     Configuration for the audio output associated with the extension.
  ///   </field>
  ///   <field name="TAudioDecoderConfiguration" type="TAudioDecoderConfiguration">
  ///     Configuration for the audio decoder associated with the extension.
  ///   </field>
  /// </record>  
  TExtension = record
    AudioOutputConfiguration   : TAudioOutputConfiguration;
    TAudioDecoderConfiguration : TAudioDecoderConfiguration;
  end;

  /// <summary>
  ///   Represents an ONVIF profile.
  /// </summary>     
  ///  <record name="TProfile">
  ///  <field name="fixed" type="Boolean">
  ///    Indicates whether the profile is fixed.
  ///  </field>
  ///  <field name="token" type="String">
  ///    The token associated with the profile.
  ///  </field>
  ///  <field name="Name" type="String">
  ///    The name of the profile.
  ///  </field>
  ///  <field name="VideoSourceConfiguration" type="TVideoSourceConfiguration">
  ///    Configuration for the video source associated with the profile.
  ///  </field>
  ///  <field name="VideoEncoderConfiguration" type="TVideoEncoderConfiguration">
  ///    Configuration for the video encoder associated with the profile.
  ///  </field>
  ///  <field name="PTZConfiguration" type="TPTZConfiguration">
  ///    Configuration for the PTZ (Pan-Tilt-Zoom) associated with the profile.
  ///  </field>
  ///  <field name="AudioEncoderConfiguration" type="TAudioEncoderConfiguration">
  ///    Configuration for the audio encoder associated with the profile.
  ///  </field>
  ///  <field name="VideoAnalyticsConfiguration" type="TVideoAnalyticsConfiguration">
  ///    Configuration for the video analytics associated with the profile.
  ///  </field>
  ///  <field name="Extension" type="TExtension">
  ///    Extension information associated with the profile.
  ///  </field>
  TProfile = record
    fixed                      : Boolean;
    token                      : string;
    Name                       : String;
    VideoSourceConfiguration   : TVideoSourceConfiguration;
    VideoEncoderConfiguration  : TVideoEncoderConfiguration;
    PTZConfiguration           : TPTZConfiguration;
    AudioEncoderConfiguration  : TAudioEncoderConfiguration;
    VideoAnalyticsConfiguration: TVideoAnalyticsConfiguration;
    Extension                  : TExtension;
  end;   
  
  /// <summary>
  ///   Represents an array of ONVIF profiles.
  /// </summary>  
  TProfiles = TArray<TProfile>;    


implementation

end.
