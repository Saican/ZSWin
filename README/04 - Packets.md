# ZScript Windows v0.3.1

![](https://github.com/Saican/ZSWin/blob/master/README/ZSWin_Logo.png)

## Packets
Packets are small utility classes used internally by the system in the process of completing certain operations or sharing information.  

- [UI Event Packets](https://github.com/Saican/ZSWin/blob/master/README/03%20-%20Classes-05-ZSWin_UIEventPacket.md) - are basically a copy of the native UiEvent struct and are used by the *ZObj_UiProcess* method to allow ZObjects to process input information themselves.

- [Event Packets](https://github.com/Saican/ZSWin/blob/master/README/03%20-%20Classes-06-ZSWin_EventPacket.md) - are dangerous if used incorrectly.  Event packets are used to essentially "order up" an event as the result of a UI process.  What this means is that the event being "ordered up" by the UI process, needs to be executed prior to the execution of the next UI event.

- [Window Packets](https://github.com/Saican/ZSWin/blob/master/README/03%20-%20Classes-13-ZSWin_WindowPacket.md) - there are multiple ways of spawning windows into a level, including through line events using ZScript.  The WorldLineActivated event is supported to read UDMF variables stored in a linedef that can be activated.  Assuming the supplied information passes validation, Window packets are used to store that information and pass it to the event system for creation.


------------


[Back to Project Main](https://github.com/Saican/ZSWin "Back to Project Main")
