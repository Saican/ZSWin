# ZScript Windows v0.1

![](urltozswinlogo.png)

## A Generic GUI API for (G)ZDoom

###Written in ZScript!

ZScript Windows is a generic GUI API aimed at enabling unique implementations that are flexible and dynamic, specific to the needs of the user, fast, powerful, and simple to use. The entire ZScript Windows API is written in (G)ZDoom's native ZScript, allowing users to design GUI systems rendered at the game's framerate **and multiplayer compatible**.

Unlike the old GDCC dinosaur, Z-Windows, ZScript Windows is actually fairly straightforward to use for developers who are familiar with C++, if not familiar with ZScript.  Getting ZScript Windows up and working is even easier than Z-Windows, requiring no extra compilers or batch files.  ZScript Windows functions just like any other (G)ZDoom mod.

##### A Bit of History and the Concept of ZScript Windows:
I started delving into GUI design several years ago when I wanted mouse-driven menus for a long dead project called *[all] Alone*.  At the time the only way to do this was through ACS methods.  This pretty much immediately made my GUI systems incompatible with multiplayer games.  My project was singleplayer so it that did not matter.  The project went through three iterations before finally being shelved, and the GUI system went through two distinct iterations as well, one being a full rewrite.  Both systems included the HUD.  This ACS GUI system, while functional, was not expandable.  Then I did an experiment.

I wanted to see if I could create any sort of tiling method for a background image in preparation to create a text-box system.  My method was unreasonable, but it gave me another idea: use one image for a background and clip it off based on a specific width and height.  Z-Windows was born.  Over the course of development, Z-Windows was quickly ported to GDCC, a full C compiler that compiles to ACS bytecode.  This laid the foundation for the concept of a ZWindow.

ZScript Windows, and obviously Z-Windows, gets its name not from Microsoft Windows, but from the X Window System (also ZDoom), which provides the basic GUI functionality for many UNIX-like operating systems. Just like X, ZScript Windows provides just the basic GUI framework without mandating what the actual interface is supposed to look like. The term windows is both a GUI organizational concept and a programming concept the interpretations of which can vary dramatically. ZScript Windows does deviate from X in that the functionality of ZScript Windows is geared toward complete GUI management in a video game architecture and as such can mimic the appearance of an actual operating system but is not actually an operating system.  However, implementation does not restrict what the user intends to do with a window, thus only the limits of ZScript actually restrict the user.

###### The Z-Windows Concept
C is not an object-oriented programming language, however it supports structures so it sort of is.  C++, however is an object-oriented programming language, thus ZScript is too.  So a ZWindow is an object.  In fact, ZWindows are ZScript Actors!  To function correctly, a window must be somehow spawned into the game world, and this can only be done through the Actor class.

While ZWindows are actors, they aren't meant to have sprites, but there's nothing stopping a ZWindow from becoming a full-fledged actor that interacts with the game world.  ZWindows, and all related classes are mostly containers for the plethora of information required to create the GUI abstraction.

A window is assigned to a player, usually the player that spawned the window actor.  **There are no modifications made to the player class by ZScript Windows**, a ZWindow is most often spawned through a short ACS script or by another window.  This means that ZScript Windows does not require much, if any, tweaking to be integrated into another mod.