
# 4.2.1.7 Half Duplex communication between Driver and PCU(PCU).

The PCU alarms are arranged in the following order within the 5 car MZ and 9 car XLZ 
The ELA system provides Half-Duplex communication between PCU alarm stations and the Driver. The PCU modules provide 2 specific modes of operation.  

# 4.2.1.7.1 Passenger Call Request 

A Passenger call Request can be made through both PCU and alarms for people with reduced Mobility DPCU. The request is made through pressing the PCU button. On activation the PCU alarm notifies the master CCU+ of its activation via TRDP and SIP, The CCU+ in turn notifies the TCMS of the PCU activation and location via TRDP. 

After activation the PCU ‘Wait’ LED will illuminates for 0.5 seconds. After 0.5 seconds the PCU ‘Wait’ LED will then start to flash. By default the system will play no alarm tone through the active cab CSPK. The system supports a configurable item which when active causes an audible alarm to play in the active cab on PCU talk request activation. The alarm tone will be stored in the CCU+. 

The driver can accept the PCU call and enter Driver to Passenger Talkback mode through moving the ‘Station’ rotary switch to the ‘speak’ position. At this point the PCU Wait LED will turn on and any audible alarm will be cancelled. 

When the ‘Station’ rotary switch is released back to the ‘0’ position by the driver, the ELA system enters PCU Driver Listen mode. On the PCU the ‘Wait/Listen’ LED turns off and the ‘Speak’ LED illuminates. Audio received by the PCU microphone is then transferred to the active cab CSPK. 

The driver can regain talk priority through turning and holding the ‘Station’ rotary switch in the ‘Speak’ position. While the rotary switch is held in this position the ELA enters PCU-Driver Speak Mode.  

The Driver can cancel the PCU talk request by turning the ‘’Station’ Rotary switch to the ‘Clear’ position. This can only be done after the driver has first accepted the PCU call. Once this is done the talk request is effectively cancelled. 

Audio is no longer distributed between the PCU and cab, and the PCU status LED returns to having the ‘Ready’ LED illuminated. 

In the event of multiple PCU Passenger Call request activations the active PCU’s become parked and enter a queue of first in first out order. Once the first PCU in the queue has been addressed and the call cleared by the driver the next PCU in the que becomes active, starting in the PCU talk request wait mode. While parked the PCU ‘Wait’ LED flashes. In the event of an Emergency Call function the active PCU will become parked and is placed into the first position in the queue if a PCU alarm que is present. 

## Passenger Call Request Modes

Mode 1 : PCU Talk Request Wait 
1. Mode activated on the initiation of the Passenger Call Request. 
2. On the PCU the ‘Wait’ LED illuminates for 0.5 seconds, after which the LED will start to flash. 
3. In the active cab the Intercom request indicator will flash (Alstom Control) 
4. Alarm tone plays through the CSPK if configurable parameter is set.  

Mode 2 : PCU Talk Request Driver Listen 
1. When the ‘Station’ rotary switch is moved to the ‘0’ position the Passenger talk request enters PCU Talk Request Driver Listen mode. 
2. The PCU ‘Wait’ LED turns off and the PCU ‘Speak’ LED turns on. 
3. Audio is now transmitted from the PCU microphone to the active Cab Loudspeaker. 

Mode 3 : PCU Talk Request Driver Speak 
1. When the ‘Station’ rotary switch is held in the ‘Speak’ position the Passenger talk request enters PCU Talk Request Driver Speak mode. 
2. The PCU ‘Speak’ LED turns off and the PCU ‘Wait’ LED turns on. 
3. Audio is now transmitted from the Gooseneck Microphone to the active PCU speaker. 

Mode 4 : PCU Talk Request Parked 
1. The PCU Talk Request Parked mode occurs when either: 
  - A higher priority audio request is received 
  - An Emergency PCU call is received. 
  - Multiple PCU alarms active. 
2. The PCU ‘Wait’ LED starts to flash. 
3. On completion of the higher priority audio function or PCU Emergency call the PCU Talk request enters PCU talk request wait mode, where the driver will need to accept the call to continue. 