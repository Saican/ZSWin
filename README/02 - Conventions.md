# ZScript Windows v0.1

![](https://github.com/Saican/ZSWin/blob/master/README/ZSWin_Logo.png)

## Code Conventions

**Commonality**
ZScript does not have a "public" keyword therefore any class member that is not private will not have any denotion as such.

Public members that are meant to be used by implementations have the first word of their name capitalized.  Public members that are meant to be internal - or used in specifc circumstances - follow standard Camel Case conventions, using lowercase for the first word of a name and capitalizing the first letter of every word after.

Other internals, method variables, arguments, constants, etc., do not neccesarily follow this convention because these things are internal and not meant to be exernally manipulated.

Code submissions are expected to follow these conventions.

**Enumerations**
ZScript Windows makes good use of enumerations to assign a unique identifier to a variable that would otherwise just be an integer.  Enumeration names are always spelled in all caps and all members are prefixed by the enumeration name.

[Back to Project Main](https://github.com/Saican/ZSWin "Back to Project Main")