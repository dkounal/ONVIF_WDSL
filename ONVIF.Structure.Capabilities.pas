unit ONVIF.Structure.Capabilities;

interface

  Type

  /// <summary>
  ///   Represents extension settings for network configuration in ONVIF.
  /// </summary>
  /// <record name="TExtensionNetworkONVIF">
  ///   <field name="Dot11Configuration" type="Boolean">
  ///     Indicates whether Dot11 configuration is supported.
  ///   </field>
  /// </record>  
  TExtensionNetworkONVIF = record
    Dot11Configuration : Boolean;
  end;

  /// <summary>
  ///   Represents network configuration settings in ONVIF.
  /// </summary>
  /// <record name="TNetworkONVIF">
  ///   <field name="IPFilter" type="Boolean">
  ///     Indicates whether IP filtering is supported.
  ///   </field>
  ///   <field name="ZeroConfiguration" type="Boolean">
  ///     Indicates whether zero configuration is supported.
  ///   </field>
  ///   <field name="IPVersion6" type="Boolean">
  ///     Indicates whether IP version 6 is supported.
  ///   </field>
  ///   <field name="DynDNS" type="Boolean">
  ///     Indicates whether DynDNS is supported.
  ///   </field>
  ///   <field name="Extension" type="TExtensionNetworkONVIF">
  ///     Extension settings for network configuration.
  ///   </field>
  /// </record>  
  TNetworkONVIF = Record
    IPFilter         : Boolean;
    ZeroConfiguration: Boolean;
    IPVersion6       : Boolean;
    DynDNS           : Boolean;
    Extension        : TExtensionNetworkONVIF;
  end;

  /// <summary>
  ///   Represents supported versions for system configuration in ONVIF.
  /// </summary>
  /// <record name="TSupportedVersionsSytemONVIF">
  ///   <field name="Major" type="Integer">
  ///     The major version number.
  ///   </field>
  ///   <field name="Minor" type="Integer">
  ///     The minor version number.
  ///   </field>
  /// </record>  
  TSupportedVersionsSytemONVIF = record
    Major : Integer;
    Minor : integer;
  end;

  /// <summary>
  ///   Represents system configuration settings in ONVIF.
  /// </summary>
  /// <record name="TSystemONVIF">
  ///   <field name="DiscoveryResolve" type="Boolean">
  ///     Indicates whether discovery resolve is supported.
  ///   </field>
  ///   <field name="DiscoveryBye" type="Boolean">
  ///     Indicates whether discovery bye is supported.
  ///   </field>
  ///   <field name="RemoteDiscovery" type="Boolean">
  ///     Indicates whether remote discovery is supported.
  ///   </field>
  ///   <field name="SystemBackup" type="Boolean">
  ///     Indicates whether system backup is supported.
  ///   </field>
  ///   <field name="SystemLogging" type="Boolean">
  ///     Indicates whether system logging is supported.
  ///   </field>
  ///   <field name="FirmwareUpgrade" type="Boolean">
  ///     Indicates whether firmware upgrade is supported.
  ///   </field>
  ///   <field name="SupportedVersions" type="TSupportedVersionsSytemONVIF">
  ///     Supported versions for system configuration.
  ///   </field>
  /// </record>  
  TSystemONVIF = Record
     DiscoveryResolve : Boolean;
     DiscoveryBye     : Boolean;
     RemoteDiscovery  : Boolean;
     SystemBackup     : Boolean;
     SystemLogging    : Boolean;  
     FirmwareUpgrade  : Boolean;  
     SupportedVersions: TSupportedVersionsSytemONVIF;             
  end;

  /// <summary>
  ///   Represents ONVIF device information.
  /// </summary>
  /// <record name="TDeviceONVIF">
  ///   <field name="XAddr" type="String">
  ///     The XAddr (service endpoint) of the ONVIF device.
  ///   </field>
  ///   <field name="Network" type="TNetworkONVIF">
  ///     Network configuration settings for the ONVIF device.
  ///   </field>
  ///   <field name="System" type="TSystemONVIF">
  ///     System configuration settings for the ONVIF device.
  ///   </field>
  /// </record>  
  TDeviceONVIF = Record
    XAddr     : String;
    Network   : TNetworkONVIF;
    System    : TSystemONVIF;
  end;

  /// <summary>
  ///   Represents ONVIF events information.
  /// </summary>
  /// <record name="TEventsONVIF">
  ///   <field name="XAddr" type="String">
  ///     The XAddr (service endpoint) for ONVIF events.
  ///   </field>
  ///   <field name="WSSubscriptionPolicySupport" type="Boolean">
  ///     Indicates whether WS Subscription Policy is supported.
  ///   </field>
  ///   <field name="WSPullPointSupport" type="Boolean">
  ///     Indicates whether WS Pull Point is supported.
  ///   </field>
  ///   <field name="WSPausableSubscriptionManagerInterfaceSupport" type="Boolean">
  ///     Indicates whether WS Pausable Subscription Manager is supported.
  ///   </field>
  /// </record>  
  TEventsONVIF = Record
     XAddr                                         : String;
     WSSubscriptionPolicySupport                   : Boolean;
     WSPullPointSupport                            : Boolean;     
     WSPausableSubscriptionManagerInterfaceSupport : Boolean;          
  end;
  
  /// <summary>
  ///   Represents streaming capabilities information for ONVIF.
  /// </summary>
  /// <record name="TStreamingCapabilitiesONVIF">
  ///   <field name="RTPMulticast" type="Boolean">
  ///     Indicates whether RTP Multicast is supported.
  ///   </field>
  ///   <field name="RTP_TCP" type="Boolean">
  ///     Indicates whether RTP over TCP is supported.
  ///   </field>
  ///   <field name="RTP_RTSP_TCP" type="Boolean">
  ///     Indicates whether RTP over RTSP over TCP is supported.
  ///   </field>
  /// </record>  
  TStreamingCapabilitiesONVIF = record
     RTPMulticast : Boolean;
     RTP_TCP      : Boolean;
     RTP_RTSP_TCP : Boolean;
  end;
  
  /// <summary>
  ///   Represents ONVIF media information.
  /// </summary>
  /// <record name="TMediaONVIF">
  ///   <field name="XAddr" type="String">
  ///     The XAddr (service endpoint) for ONVIF media.
  ///   </field>
  ///   <field name="StreamingCapabilities" type="TStreamingCapabilitiesONVIF">
  ///     Streaming capabilities for ONVIF media.
  ///   </field>
  /// </record>  
  TMediaONVIF = Record
    XAddr                 : String;
    StreamingCapabilities : TStreamingCapabilitiesONVIF;
  end;

  /// <summary>
  ///   Represents ONVIF PTZ (Pan-Tilt-Zoom) information.
  /// </summary>
  /// <record name="TPTZONVIF">
  ///   <field name="XAddr" type="String">
  ///     The XAddr (service endpoint) for ONVIF PTZ.
  ///   </field>
  /// </record>  
  TPTZONVIF = Record
     XAddr : String;
  end;  


  /// <summary>
  ///   Represents ONVIF search extension information.
  /// </summary>
  /// <record name="TSearchExtensionONVIF">
  ///   <field name="XAddr" type="String">
  ///     The XAddr (service endpoint) for ONVIF search extension.
  ///   </field>
  ///   <field name="MetadataSearch" type="Boolean">
  ///     Indicates whether metadata search is supported.
  ///   </field>
  /// </record>  
  TSearchExtensionONVIF = record
    XAddr          : String;
    MetadataSearch : Boolean;
  end;

  /// <summary>
  ///   Represents ONVIF replay extension information.
  /// </summary>
  /// <record name="TReplayExtensionONVIF">
  ///   <field name="XAddr" type="String">
  ///     The XAddr (service endpoint) for ONVIF replay extension.
  ///   </field>
  /// </record>  
  TReplayExtensionONVIF = record
    XAddr : String;
  end;

  /// <summary>
  ///   Represents ONVIF extension information.
  /// </summary>
  /// <record name="TExtensionONVIF">
  ///   <field name="Search" type="TSearchExtensionONVIF">
  ///     ONVIF search extension information.
  ///   </field>
  ///   <field name="Replay" type="TReplayExtensionONVIF">
  ///     ONVIF replay extension information.
  ///   </field>
  /// </record>  
  TExtensionONVIF = Record
     Search  : TSearchExtensionONVIF;
     Replay  : TReplayExtensionONVIF
  end;
  
  /// <summary>
  ///   Represents ONVIF capabilities information.
  /// </summary>
  /// <record name="TCapabilitiesOVIF">
  ///   <field name="Device" type="TDeviceONVIF">
  ///     ONVIF device capabilities.
  ///   </field>
  ///   <field name="Events" type="TEventsONVIF">
  ///     ONVIF events capabilities.
  ///   </field>
  ///   <field name="Media" type="TPTZONVIF">
  ///     ONVIF PTZ capabilities.
  ///   </field>
  ///   <field name="Extension" type="TExtensionONVIF">
  ///     ONVIF extension capabilities.
  ///   </field>
  /// </record>  
  TCapabilitiesONVIF = Record
    Device     : TDeviceONVIF;
    Events     : TEventsONVIF;
    Media      : TMediaONVIF;
    PTZ        : TPTZONVIF;
    Extension  : TExtensionONVIF;
  end;

implementation

end.
