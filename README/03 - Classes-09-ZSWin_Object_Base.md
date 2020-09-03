# ZScript Windows v0.3

![](https://github.com/Saican/ZSWin/blob/master/README/ZSWin_Logo.png)

## Class ZObjectBase : thinker abstract
### Base Class for All ZObjects

------------

#### ZObjects Exist IN the Running Level
 - Thus, ZObjects think.  ZObjects are capable of using their Tick and PostBeginPlay methods, however the former is used by ZScript Windows as the ZObject's self-deletion check, and the latter is not used by ZScript Windows at all.
 
 - This also means that there has to exist a significant interface between contexts.  ZObjects exist in the engine's "play" context, however their result exists in the "ui" context, and meaningful interaction also occurs in the "ui" context.  The advantage is this interface itself which allows "ui" interactions to actually have an impact on the game playism in a multi-player compatible way.  This is achieved by "play" context virtual methods that are functionally reactive to "ui" context mouse events.  These event methods are overriden by controls and users to achieve the desired result.

#### Public Members:


#### Constants:


#### Enumerations:


#### Methods:


------------


[Back to Class Detail Links](https://github.com/Saican/ZSWin/blob/master/README/05%20-%20Classes.md)

------------


[Back to Project Main](https://github.com/Saican/ZSWin "Back to Project Main")