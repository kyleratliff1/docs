# PowerFlex 750 Series Drives Network Communication
Parameter changes can be made through the HIM, Connected Components Workbench Software, or after adding the drive to Studio 5000 
then uploading the existing configuration. If Connected Components Workbench or Studio 5000 software is used
to modify the drive parameters then first setup the network configurations to the drive using the HIM, DHCP, or BOOTP.
___

## Establishing communication to the drive using the following methods:
1. Human Interface Module (HIM)
    > - Navigate to the Port/Peripheral were the parameters will be changed, it's very important that you are changing the parameters for the correct Port/Peripheral. 
    > - Set Parameter 5 (Net Addr Sel) to `Parameter` if using Dual-Port EtherNet/IP Network Adapter or Parameter 36 (BOOTP) to `Disabled` if using 
        the Embedded EtherNet/IP Adapter to enable the network settings to be set from adapter parameters.
    > - Parameters 7-18 if using Dual-Port EtherNet/IP Network Adapter or Parameters 38-49 if using Embedded EtherNet/IP Adapter set the ip address, subnet, and, gateway.
    > - Power cycle drive.
2. BOOTP Server 
    > - Open BOOTP application and find the ethernet mac address for the interface through which communication 
        is being established.
    > - The best thing before mapping an ip address to the ethernet mac address is to first set the BOOTP server ip address
        on the same network that'll be used to assign an ip address.
    > - Disable BOOTP after the network settings are set.
___

## Network Communication Dual-Port EtherNet/IP Network Adapter
1. Parameter 52 (Web Enable) - `Enabled`
2. Parameters 54-57 (XXX Flt Action) - `Hold Last` - this will enable the drive to retain it current state if network communication is lost.
3. Parameters 17-32 (DL To Net 1-16) - `Port 0: <Last Fault Code, Output Current, Output Power, Commanded SpdRef, etc>` - optional data that can be sent over the network.
4. The following parameters need to be changed through the PowerFlex Port/Peripheral which is usually zero.
    > - Parameter 522 (Min Fwd Speed) - `20.00`
    > - Parameter 370 (Stop Mode A) - `Coast`
    > - Parameter 545 (Spd Ref A Sel) - `Port 0: Port XX Reference` xx is the port where the network adapter is installed usually this is Port 4.
    > - Parameters 871-878 are speed references from port devices and the speed reference value in parameter 874 is what's of interest.
___

## Network Communication Embedded EtherNet/IP Network Adapter
1. Parameter 26 (Web Enable) - `Enabled`
2. Parameters 33-36 (XXX Flt Action) - `Hold Last` - this will enable the drive to retain it current state if network communication is lost.
3. Parameters 17-32 (DL To Net 1-16) - `Port 0: <Last Fault Code, Output Current, Output Power, Commanded SpdRef, etc>` - optional data that can be sent over the network.
4. The following parameters need to be changed through the PowerFlex Port/Peripheral which is usually zero.
    > - Parameter 522 (Min Fwd Speed) - `20.00`
    > - Parameter 370 (Stop Mode A) - `Coast`
    > - Parameter 545 (Spd Ref A Sel) - `Port 0: Port XX Reference` xx is the port where the network adapter is installed usually this is Port 13.
    > - Parameters 871-878 are speed references from port devices and the speed reference value in parameter 877 is what's of interest.
___

## Drive Setup Studio 5000
1. Add the drive to Studio 5000 and only set the name and ip address and download the updates to the PLC.
2. Once the drive is added to Studio 5000, it can then be discovered by right-clicking the Ethernet module in the I/O tree where the drive was added.
   The actual drive configuration can then be uploaded and synchronized with the drive that's in the PLC project.
3. Verify the connection format which will display the type of data sent over the network to/from the drive:
   > - Click the drive module -> Overview -> Edit Peripherals -> Connection Format.
   > - You should then see the following:
     ![Connection Format](img/pf_520_connection_format.png)




