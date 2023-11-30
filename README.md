# ONVIF_WSDL Project
Welcome to the ONVIF_WSDL project! This repository is dedicated to providing a comprehensive solution for handling ONVIF 

# Project Overview
The ONVIF_WSDL project focuses on managing essential aspects of ONVIF protocols, offering functionality for:

Device Information: Effortlessly retrieve and manage information about connected devices.

Profiles: Seamlessly handle ONVIF profiles, ensuring compatibility and easy integration.

Capabilities: Access and manage device capabilities to optimize functionality.

The PTZ (Pan-Tilt-Zoom): functionality in this project provides support for controlling camera movement.

- **Continuous Move:** The current implementation supports continuous movement. You can start, stop, and control the speed of continuous panning and tilting.

- **Zoom Control:** Basic zoom control is available. For example, you can zoom in or out.

**Note:** As of now, only continuous movement (ContinuousMove) is supported.

# How to Use
Example Delphi code for using the ONVIF_WSDL project:
```delphi
// Create an instance of TONVIFManager with login credentials and set up URL
LONVIFManager := TONVIFManager.Create(String.Empty, <Login>, <Password>);
LONVIFManager.SaveResponseOnDisk := True;
LONVIFManager.Url := <URL onvif example http://xxx.xxx.xxx.xxx:580/>;
```
Now you can interact with ONVIF features using LONVIFManager
For instance, you can retrieve device information, handle profiles, and more.

Don't forget to replace <Login>, <Password>, and <URL onvif example http://xxx.xxx.xxx.xxx:580/>
with your actual credentials and ONVIF device URL.

# Documentation
comprehensive English documentation set is embedded directly in the source code in XML format, providing an easily accessible reference for developers.es.

# Contributions
Contributions are welcome! If you encounter any issues, have suggestions for improvements, or want to contribute new features, please check our Contribution Guidelines.

# License
This project is licensed under the MIT License, making it open and accessible for a wide range of applications.

Thank you for choosing ONVIF_WSDL for your project. Happy coding! 🚀
