/*
	ZSWin_Border.txt
	
	ZBorder - container class for the "Classic Z-Windows" Border
	
	Each of the 9 TextureId's are pretty self explanatory.
	The 9 graphics used are created from 2 actual graphic lumps
	in the pk3 in a TEXTURES lump.
	
	The BorderWidth/Height is calculated from the Corner_TopLeft
	texture.  While corners are assumed to have uniform dimensions,
	those dimensions themselves do not have to be equal.
	
	The Classic look is made from corners that are 26px square,
	scaled by 2, for a result of 13px square.  Corners are not
	required to be square, however side graphics must be provided
	to match.
	
	The Classic look uses a side graphic the same dimensions as its
	corner, allowing each TEXTURES entry to point to the same graphic
	and just rotate it.  Another implementation could point to
	multiple graphics to achieve different appearance results; thicker
	or thinner sides depending on dimension variance.
	
	The handler will tile the side graphics, allowing for windows of any
	size.  This was a limitation of GDCC-based Z-Windows which could
	only display a window as large as the maximum dimensions of the
	border side graphics.  This wasn't difficult to work around,
	but unfeasible to maintain; as monitor resolutions increase you'd
	have to make the graphic larger.  Tiling a smaller graphic is the
	far superior option.
	
	Tiling would have been doable with GDCC-based Z-Windows, but in
	theory, could have overconsumed HUDMessage IDs.  The management
	of those IDs was never meant to deal with something like that.

*/
class ZBorder
{
	TextureId Corner_TopLeft, Corner_TopRight, 
		Corner_BottomLeft, Corner_BottomRight,
		Side_Top, Side_Bottom, 
		Side_Left, Side_Right;
		
	int BorderWidth, BorderHeight;
}