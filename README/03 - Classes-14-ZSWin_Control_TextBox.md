# ZScript Windows v0.3.1

![](https://github.com/Saican/ZSWin/blob/master/README/ZSWin_Logo.png)

## Class ZTextBox : ZControl
### Text Input Control

------------
This control allows for the manual input of text via the keyboard.

------------


#### Public Members: 
 - **IsMultiLine**, bool, this must be set to true for the textbox to allow multi-line text, default is false.
 - **UseTrackingCursor**, bool, if true, a second cursor will follow the cursor to indicate where the cursor will be placed on selection, default is false.
 - **UseTrackingColor**, bool, if true, the tracking cursor, if enabled, will use the specified color, default is false and tracking cursor color follow the located cursor.
 - **InvertCursorColor**, bool, if true, the cursor color will be the inverse of either the specified cursor color, or the inverse of the background color, default is false.
 - **CursorColor**, color, the color of the cursor, defaults to black.
 - **TrackingCursorColor**, color, the color of the tracking cursor, defaults to black.
 - **BackgroundType**, BACKTYP, enumeration representing the background that will be drawn.
 - **BackgroundColor**, color, the color of the background, if the type is a color instead of a texture.
 - **BackgroundTexture**, TextureId, the texture of the background, if the type is a texture.
 - **StretchTexture**, bool, if true the background texture is stretched across the dimensions of textbox.
 - **AnimateTexture**, bool, if true, the background texture will animate, if it is an animated texture.
 - **BorderType**, BORDERTYP, enumeration representing the border drawn around the textbox.
 - **BorderThickness**, int, thickness of the border.
 - **BorderColor**, color, color of the border.
 - **BorderAlpha**, float, alpha of the border.
 - **Text**, ZText, the text control of the textbox.
 - **UsePasswordChars**, bool, if true the string's characters will be replaced with star characters.
 - **CursorX**, int, X location of the cursor.
 - **CursorY**, int, Y location of the cursor.
------------
#### Enumerations:
**BACKTYP** - this enumeration represents the background choice.  It functions almost identical to ZSWindows, with the addition of a color option.
- Valid BACKTYP values:
	 - BACKTYP_GameTex1
	 - BACKTYP_GameTex2
	 - BACKTYP_GameTex3
	 - BACKTYP_Custom
	 - BACKTYP_Color
	 - BACKTYP_NONE

**BORDERTYP** - this enumeration represents the border choice.
- Valid BORDERTYP values:
	- BORDER_Frame
	- BORDER_ThinLine
	- BORDER_ThickLine
	- BORDER_NONE

------------
#### Constants:
**CURSORTIME** - this value represents the blink interval of the cursor.  The cursor blinks at a rate of 30 ticks.

------------
#### Methods:
- *Remember!* - ZScript has a method argument skipping mechanic called "named arguments", which is utilized by ZScript Windows.  Do not be overwhelmed by the constructor argument list, the majority is defaulted allowing you to set what you need and skip the rest.
- Note that defaulted arguments are named in braces [ ].

1. **Init** - textbox constructor.
	- **ControlParent**, ZObjectBase, reference to the ZObject containing this control.
	- **Enabled**, bool, if true the control may be interacted with.
	- **Show**, bool, if true the control will be drawn.
	- **PlayerClient**, int, the consoleplayer this control corresponds to.
	- **UiToggle**, bool, if true the creation of this object causes UI Mode to be activated for the consoleplayer this control's parent window corresponds to.
	- **[BackgroundType]**, BACKTYP, enum representing the background, defaults to BACKTYP_Color.
	- **[BackgroundColor]**, color, color used if the background is set to use a color, defaults to white.
	- **[StretchTexture]**, bool, if true, and the background uses a texture, the texture will be stretched across the control's dimensions.  Default is false and the texture will be tiled.
	- **[AnimateTexture]**, bool, if true the background texture will animate, if the background texture is animated.  Default is false.
	- **[CustomBackgroundTexture]**, string, name of a texture to be used for the background.  Note that the background type must be set to BACKTYP_Custom.
	- **[BorderType]**, BORDERTYP, enum representing the border, defaults to BORDER_ThinLine.
	- **[BorderThickness]**, int, width in pixes of the border thickness if the type is BORDER_ThickLine.  Defaults is 1.
	- **[BorderColor]**, color, color used to draw the border if the type is one of the Line types.  Default is gray.
	- **[BorderAlpha]**, float, alpha value for the border, default is 1.
	- **[ClipType]**, CLIPTYP, enumeration representing how this control is "cropped" from view.  Default value is CLIP_Parent.
	- **[ScaleType]**, SCALETYP, enumeration representing how this control positions itself in relation to resizing of parent window.  This is relative to other control parents.  The default is SCALE_NONE, this control will not take window resizing into account.
	- **[InvertCursorColor]**, bool, defaults to true, this causes the textbox to use the inverse of the background color for the cursor color.
	- **[CursorColor]**, color, color for the cursor if not inverting, defaults to black.
	- **[UseTrackingCursor]**, bool, defaults to false, if true a second cursor will be drawn to indicate where the type cursor will be placed.
	- **[UseTrackingColor]**, bool, defaults to false, mirroring the type cursor, if true will use the TrackingCursorColor member for the tracking cursor color.
	- **[TrackingCursorColor]**, color, color for the tracking cursor, defaults to black.
	- **[box_xLocation]**, float, starting X location of the control, relative to its parent.  Defaults to 0.
	- **[box_yLocation]**, float, starting Y location of the control, relative to its parent.  Defaults to 0.
	- **[box_Alpha]**, float, alpha for all components that do not have their own, defaults to 1.
	- **[Width]**, int, width of the control, defaults to 100 pixels.
	- **[Height]**, int, height of the control, defaults to 25 pixels.
	- **[UsePasswordChars]**, bool, defaults to false, if true the text is replaced with star characters.
	- **[IsMultiLine]**, bool, defaults to false, if true the textbox will break the string at its edge according to the desired text wrapping.  If this is set to true and the control's text object is not assigned a text wrap state, the control will default the state to TXTWRAP_Wrap.  You do not have to set the text object's wrap state unless you want dynamic wrapping.
	- **[TextAlignment]**, TEXTALIGN, enum representing the text alignment.  Default is TEXTALIGN_Left.
	- **[TextWrap]**, TXTWRAP, enum representing the text wrap state.  Default is TXTWRAP_NONE.
	- **[WrapWidth]**, int, defaults to 0, if left 0 and the wrap state is TXTWRAP_Wrap, the text will be broken off at the width of the control, otherwise a non-zero with same state controls with line break width in pixels.   This value is ignored if wrapping is dynamic.
	- **[FontName]**, name, string sent in 'single quotes', this is the name of the font.  The default is 'consolefont'.
	- **[TextColor]**, name, string sent in 'single quotes', this is the name of the font color.  The default is 'black'.
	- **[Text]**, string, this is the actual text that will be displayed in the textbox.  Defaults to an empty string.
	- **[txt_xLocation]**, float, X location of the text relative to its parent.  Defaults to 0.
	- **[txt_yLocation]**, float, Y location of the text relative to its parent.  Defaults to 0.
	- **[txt_Alpha]**, float, alpha value for the text.  Defaults to 1.

------------
#### Usage Example:
The following snippet comes from the BFG Terminal in the demo map.
```cpp
    		AddControl(new("ZTextBox").Init(self, Enabled, Show, "BFGPasswordBox", PlayerClient, UiToggle,
    			BorderColor:0xff0000, BorderAlpha:0.5,
    			box_xLocation:5, box_yLocation:(self.Height - 125), Width:(self.Width - 10), Text:"What's the password?"));
```


------------


[Back to Class Detail Links](https://github.com/Saican/ZSWin/blob/master/README/03%20-%20Classes.md)

------------


[Back to Project Main](https://github.com/Saican/ZSWin "Back to Project Main")
