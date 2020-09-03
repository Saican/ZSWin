# ZScript Windows v0.3

![](https://github.com/Saican/ZSWin/blob/master/README/ZSWin_Logo.png)

## Class ZButton : ZControl abstract
### Base Class for All Button Controls

------------

#### Why is a ZButton marked "abstract" when other controls are not?
 - Controls that are generally passive do not neccessarily need inherited from in order to be used.  The main reason to inherit from a ZObject class is to override the mouse events for some particular purpose.  This is why a ZButton must be inherited from, a button is not passive and it is up to the user to determine what events it responds to and what actions it takes.

#### Public Members:


#### Constants:


#### Enumerations:


#### Methods:


------------


[Back to Class Detail Links](https://github.com/Saican/ZSWin/blob/master/README/03%20-%20Classes.md)

------------


[Back to Project Main](https://github.com/Saican/ZSWin "Back to Project Main")
