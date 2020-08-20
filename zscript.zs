version "4.2.1"

//abstract class for all windows
#include "zscript/zswin/ZSWin_Base.zs"
//defintion of windows border
#include "zscript/zswin/ZSWin_Border.zs"
//clickable buttons definition
#include "zscript/zswin/ZSWin_Button.zs"
//abstract class for all things that can be described as "interface"
#include "zscript/zswin/ZSWin_ControlBase.zs"
//point of entry, event that draw all windows and send data from ui to play
#include "zscript/zswin/ZSWin_Handler.zs"
//wrapper for methods that drawing things on the screen
#include "zscript/zswin/ZSWin_Processor.zs"
//screen lines and boxes drawer
#include "zscript/zswin/ZSWin_Shapes.zs"
//all string related things goes here
#include "zscript/zswin/ZSWin_Text.zs"
//texture related shenanigans
#include "zscript/zswin/ZSWin_TextureUtil.zs"
//specific window storage
#include "zscript/zswin/ZSWin_WindowUtil.zs"
//actual window base
#include "zscript/zswin/ZSWindow.zs"

//demo things of how it works
#include "zscript/test/ZSWin_Console.zs"
#include "zscript/test/ZSWin_Terminal.zs"
#include "zscript/test/ZSWin_TerminalButton.zs"
