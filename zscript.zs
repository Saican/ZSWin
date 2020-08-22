version "4.2.1"

// Files are included alphabetically

// Abstract class for all windows
#include "zscript/zswin/ZSWin_Base.zs"
// Window border definition
#include "zscript/zswin/ZSWin_Border.zs"
// Button control
#include "zscript/zswin/ZSWin_Button.zs"
// Abstract base class for anything considered a "control or interface"
#include "zscript/zswin/ZSWin_ControlBase.zs"
// Wrapper for UI methods that draw window contents
#include "zscript/zswin/ZSWin_Drawer.zs"
// Point of entry, event handler that draws window contents and and processes UI events
#include "zscript/zswin/ZSWin_Handler.zs"
// Lines and (Group)box control
#include "zscript/zswin/ZSWin_Shapes.zs"
// String control
#include "zscript/zswin/ZSWin_Text.zs"
// Texture related shenanigans - utitlity for passing TextureIds around
#include "zscript/zswin/ZSWin_TextureUtil.zs"
// Specific window storage utlity class
#include "zscript/zswin/ZSWin_WindowUtil.zs"
// Full window base class
#include "zscript/zswin/ZSWindow.zs"

// Demonstration/Testing files
#include "zscript/test/ZSWin_BFGButton.zs"
#include "zscript/test/ZSWin_BFGTerminal.zs"
#include "zscript/test/ZSWin_Console.zs"
#include "zscript/test/ZSWin_MoveButton.zs"
#include "zscript/test/ZSWin_ScaleButton.zs"
#include "zscript/test/ZSWin_Terminal.zs"
#include "zscript/test/ZSWin_TerminalButton.zs"
#include "zscript/test/ZSWin_TalkImp.zs"
