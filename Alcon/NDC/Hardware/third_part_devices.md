# New Data Center Hardware and Tags
___
## Hardware Table
| Third Party Device | IP Address  | PEMO Device    | IP Address  |
|--------------------|-------------|----------------|-------------|
| LG_Gateway_7062    | 10.22.70.62 | RedlionDA_7056 | 10.22.70.56 |
|                    |             |                |             |
___
## House Fan Coil Units
The fan coil units are sending data over bacnet to an LG Gateway that converts the data to Modbus TCP/IP for sending.
A Redlion DA10D establishes communication with the LG Gateway over Modbus TCP/IP and then sends the data over MQTT to Ignition SCADA.
### Enumerated Parameters
    Unit Mode (int): 0 = None, 1 = Cool, 2 = Dry, 3 = Fan, 4 = Auto, 5 = Heat
    Fan Speed (int): 0 = None, 1 = Low, 2 = Middle, 3 = High, 4 = Auto
### Description Table
| Fan Coil | Area                | Notes                                                           |
|----------|---------------------|-----------------------------------------------------------------|
| FCU 1    | Unknown             | Verify area that the FCU serves?. Unit on functioning properly. |
| FCU 2    | NDC027 West         | Unit on functioning properly.                                   |
| FCU 3    | NDC027 East         | Unit on functioning properly.                                   |
| FCU 4    | NDC025              | Unit on functioning properly.                                   |
| FCU 5    | NDC024              | Unit on functioning properly.                                   |
| FCU 6    | NDC029 West         | Unit on functioning properly.                                   |
| FCU 7    | NDC028              | Unit on functioning properly.                                   |
| FCU 8    | NDC029 East/NDC020  | Unit on functioning properly.                                   |
| FCU 9    | NDC026/NDC033       | Unit on functioning properly.                                   |
| FCU 10   | NDC023              | Unit on functioning properly.                                   |
| FCU 11   | NDC022              | Unit on functioning properly.                                   |
| FCU 12   | NDC001              | Unit on functioning properly.                                   |
| FCU 13   | NDC021              | Unit on functioning properly.                                   |
| FCU 14   | NDC035              | Unit on functioning properly.                                   |
| FCU 15   | NDC009              | Unit on functioning properly.                                   |
| FCU 16   | NDC035              | Unit on functioning properly.                                   |
| FCU 17   | None                | There's no FCU 17                                               |
| FCU 18   | NDC009              | Unit on functioning properly.                                   |
| FCU 19   | NDC052              | Unit on functioning properly.                                   |
| FCU 20   | NDC019              | UDT Parameter Alarm bounces in alarm and unit is on.            |
| FCU 21   | NDC051              | Unit on functioning properly.                                   |
| FCU 22   | NDC093              | UDT Parameter Alarm in alarm and unit is off                    |
| FCU 23   | NDC050              | Unit on functioning properly.                                   |
| FCU 24   | Facility Management | UDT Parameter Alarm in alarm and unit is off                    |
| FCU 25   | NDC007              | Unit on functioning properly.                                   |
___


