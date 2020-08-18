# ZScript Windows v0.1

![](https://github.com/Saican/ZSWin/blob/master/README/ZSWin_Logo.png)

## GibZoning

**What is it?**
- GibZoning is a term that essentially means, "checking if the mouse cursor is within an interactive zone."  An "interactive zone" might be the dimensions of a button, or even a window.  This zone is usually calculated from the location and height and width of the object, and users don't have to do anything for Gibzoning to occur; this is done automatically by ZScript Windows as part of a ZWindow's internal functions.

**Why is it called "GibZoning"?**
- GibZoning actually comes from an acronym, G.I.B.Z.O., which means "Graphic Interface Button Zone Overlay."  During the development of *[all] Alone*, and later *Centre-01*, it was useful to be able to visually see onscreen where the interactive zone of a button had been calculated to be.  These calculations are historically the same, literally ZScript Windows makes these calcuations in exactly the same way as Z-Windows, as does both versions of the R.A.I.D. (*[all] Alone* and *Centre-01* GUI systems).  It's just a big boolean check of point relationships.

- GibZoning became a term in Z-Windows to refer to making the same calculations for a far greater interactive environment.  So the term "GibZone" refers to the interactive area of an object.  Where Z-Windows only technically supported two mouse events, ZScript Windows fully supports eleven mouse events, all of which may be used by any ZControl object.

**Further Information**
[Receiving Mouse Events](https://github.com/Saican/ZSWin/blob/master/README/03%20-%20Receiving%20Mouse%20Events.md)

[Back to Project Main](https://github.com/Saican/ZSWin "Back to Project Main")