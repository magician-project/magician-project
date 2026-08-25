# Bill of Materials

## Defect Detection System - FORTH

The following table contains all components for the first version of the defect acquisition system developed by the FORTH partner.


<!-- 
Last update: November 2024.

| Item | Description | Quantity | Links |
| ---: | :---------- | :------- | ----- |
| Sony XCG-CP510 | Gigabit Ethernet camera| 1 | [Italy](https://www.tecnosens.it/telecamere-industriali/xcg-cp510) |
| TP-Link TL-POE150S | Power Over Ethernet Injector | 1 | [Greece](https://www.bhphotovideo.com/c/product/885633-REG/TP_Link_TL_POE150S_Power_Over_Ethernet.html), [Amazon](https://amzn.eu/d/cIaFhj6) |
| | A4 polarizer sheets | 2 | [Amazon](https://amzn.eu/d/eoilMHq) |
| IRF-44N | Mosfets | 6 | [Greece](https://electron-kriti.gr/el/ilektronika-exartimata/mosfet/irfz-44n), [Italy](https://mou.sr/4hszwTX) |
| PWLS 05‑10 | 600 lumen LED lights | 6 | [Greece](https://www.themart.gr/fakos-proboleas-led-ergasias-10w-2117864700019.html), [Italy](https://scontimania.com/mini-torcia-tascabile-led-10000-lumen-torcia-ricaricabile-modalita-torcia-tattica-zoomabile-per-campeggio-escursionismo-ed-emergenze-2.html) |
| Arduino MEGA 2560 | | 1 | [Amazon](https://amzn.eu/d/9xASDQn) |
| Arduino Ethernet shield | | 1 | [Greece](https://electron-kriti.gr/el/fakoi/w-5100), [Amazon](https://amzn.eu/d/iXizI9B) |
| VL53L0X | Laser Range Sensors | 3 | [Amazon](https://amzn.eu/d/fJD8Z1o) |
| RPI 16mm | type C mount 16mm lens | 1 | [Greece](https://nettop.gr/index.php/raspberry-pi/camera/16mm-telephoto-lens.html), [Italy](https://it.farnell.com/3381606) |
-->



Last update: August 2026.

| Item | Description | Quantity | Links |
| ---: | :---------- | :------- | ----- |
| Sony XCG-CP510 | Gigabit Ethernet camera| 1 | [Italy](https://www.tecnosens.it/telecamere-industriali/xcg-cp510) |
| RPI 16mm | type C mount 16mm lens | 1 | [Greece](https://nettop.gr/index.php/raspberry-pi/camera/16mm-telephoto-lens.html), [Italy](https://it.farnell.com/3381606) |
| | A4 polarizer sheets | 2 | [Amazon](https://amzn.eu/d/eoilMHq) |
| HP Laptop Charger | TBA exact model | 1 |  |
| W.W 3000K 3-3.7V | 2W 1000mA 60x8mm LED COBs | 18 | [Global](https://www.aliexpress.com/item/1000006624305.html) | 
| VL53L5CX | Laser Range Sensors | 3 | [Global](https://www.aliexpress.com/item/1000006624305.html) |
| Magician Chassis | CAD Assembly | 1 |  |

### PCB Bill of Materials (MagicianCam4)

| Reference | Value | RS Sourcing | RS Sourcing (alt) |
| ---: | :---------- | :------- | :------- |
| A1 | RaspberryPi_Pico_2 | | |
| C1 | 270u | Panasonic EEHZA1V271P --> 758-1262P | |
| C2,C5,C12,C19 | 100n | Kyocera AVX 06035C104KAZ2A --> 698-3263 | Wurth Elektronik 885012206095R --> 257-1100 |
| C3,C4,C10,C11 | 10u | Murata GCM32EC71H106KA03K --> 247-7917P | |
| C6,C13 | 100n | Yageo CC0805JRX7R9BB104 --> 198-8056 | |
| C7 | 100p | Samsung CL10C101JB81PNC --> 257-5923 | |
| C8,C9 | 100u | Samsung CL32A107MQVNNNE --> 766-1166 | |
| C14 | 220p | Samsung CL10C221JB81PNC --> 257-5899 | |
| C15,C16,C17,C18 | 22u | Samsung CL32A226KAJNNNE --> 766-1182 | |
| D1 | LED | ROHM CSL1901DW1 Orange Led --> 2523132P | |
| D2 | LED | ROHM CSL1901YW1 Yellow Led --> 2523141P | |
| J1 | COB LED #1 | TE Connectivity MTA 100 Connector --> 132-0355 | |
| J2 | COB LED #2 | TE Connectivity MTA 100 Connector --> 132-0355 | |
| J3 | COB LED #3 | TE Connectivity MTA 100 Connector --> 132-0355 | |
| J4 | COB LED #4 | TE Connectivity MTA 100 Connector --> 132-0355 | |
| J5 | COB LED #5 | TE Connectivity MTA 100 Connector --> 132-0355 | |
| J6 | COB LED #6 | TE Connectivity MTA 100 Connector --> 132-0355 | |
| J7 | Power Conn | Amphenol Industrial TC0203620000G --> 446-321 | |
| J8 | Camera Conn | RS-PRO --> 790-1102 | |
| J9 | ToF #1 | Harwin M20-9990546 --> 681-2985 | |
| J10 | ToF #2 | Harwin M20-9990546 --> 681-2985 | |
| J11 | ToF #3 | Harwin M20-9990546 --> 681-2985 | |
| J12 | OLED Conn | Harwin M20-9990446 --> 681-2988 | |
| J13 | DB9 I/O Conn | Amphenol Communications Solutions T821108A1S100CEU --> 832-3569 | |
| J14,J15 | I/O Conn | Amphenol Communications Solutions 10129378-910002BLF --> 205-6264 | |
| J16 | Cam. Pwr | Amphenol Communications Solutions 10129378-902002BLF --> 205-6261 | |
| L1,L2 | 10uH | TDK SLF10165T-100M3R83PF --> 181-5309 | |
| Q1,Q3,Q5,Q7,Q9,Q11,Q14,Q15 | BSS138 | Nexperia BSS138P,215 --> 792-0891P | Infineon BSS138IXTSA1 --> 225-0561 |
| Q2,Q4,Q6,Q8,Q10,Q12 | BSZ180P03NS3GATMA1 | INFINEON - BSZ180P03NS3GATMA1 --> 214-8990 | |
| Q13 | DMG2305UX | DiodesZetex DMG2305UX-7 --> 827-0452 | |
| R1,R7,R13,R19,R25,R31 | 100Ω | Vishay MCT06030C1000FP500 --> 188-5907 | |
| R2,R8,R14,R20,R26,R32,R42 | 15KΩ | Vishay MCT06030C1502FP500 --> 188-6139 | |
| R3,R9,R15,R21,R27,R33 | 475Ω | Panasonic ERA6AEB4750V --> 708-6039 | Yageo RT0603BRD0715KL --> 199-1422 |
| R4,R10,R16,R22,R28,R34 | 2.2KΩ | KOA RN73R2BTTD2201B25 --> 253-3397 | Panasonic ERA8AEB222V --> 669-6562 |
| R5,R11,R17,R23,R29,R35 | 200KΩ | Panasonic ERJ3EKF2003V --> 176-3537 | |
| R6,R12,R18,R24,R30,R36 | 200mΩ | TE Connectivity TLRP3A30DR200FTE --> 231-3999 | |
| R37,R38,R39,R40,R41,R48 | 4.7KΩ | Panasonic ERJPA3F4701V --> 862-6975 | |
| R43,R46 | 100KΩ | Panasonic ERA3AEB104V --> 056-6787 | |
| R44 | 13.7KΩ | Panasonic ERA3AEB1372V --> 708-8760 | |
| R45 | 1.5KΩ | Panasonic ERJPA3F1501V --> 862-6773 | |
| R47 | 5.49KΩ | Panasonic ERA3AEB5491V --> 782-688P | TE Connectivity CPF0603B5K49E1 --> 122-9561 |
| R49,R50 | 680KΩ | Vishay CRCW0603680KFKEA --> 679-0623 | |
| S1 | RESET | C & K COMPONENTS --> 135-9618P | |
| U1,U2 | TPS54302 | Texas Instruments TPS54302DDCR --> 229-7102P | |
| U3 | MCP23018-E/SO | Microchip MCP23018-E/SO --> 669-6446 | |
| U4 | WIZ850io | | |



In addition to this material, it is required to have breadboards, cables and resistor to wire all the setup.

## Tactile Perception Module - IIT

The following table contains all components for the first version of the tactile perception module developed by the IIT partner.

Last update: November 2024.

| Item | Description | Quantity | Links |
| ---: | :---------- | :------- | ----- |
| ATI Nano 17 | Force/Torque sensor | 1 | [link](https://www.ati-ia.com/company/contacts.aspx) * |
| TP-Link TL-POE150S | Power Over Ethernet Injector | 1 |  [Amazon](https://amzn.eu/d/cIaFhj6) |
| ADXL335 | 3-axis accelerometer | 1 | [link](https://mou.sr/3Oi0AHZ)|
| Teensy 4.0 | | 1 | [link](https://www.pjrc.com/store/teensy40.html) |


In addition to this material, it is required to have breadboards, cables and resistor to wire all the setup.

**It is not possible to direct purchase an ATI sensor**.
You will need to contact the ATI sales office, which will direct you to the appropriate reseller for your country. 
Below, we provide the specifications of the purchased system and the required components, ordered by the Italian reseller, SCHUNK Intec S.r.l.:

```
FTN-NANO17-E-1.8-NETBA- DUAL SI-12-0.12/25-0.25:
- 1 x Nano17 sensor
- 1 x 1.8m cable between the sensor and the Net BA box
- 1 x Net BA box
- 1 x Calibration SI-25-0.25 e
- FTN-C-ES-RJ45-0.2 adapter
```
