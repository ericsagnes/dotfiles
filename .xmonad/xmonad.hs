-- Import statements

-- layout related
import XMonad hiding ( (|||) )
import XMonad.Layout.LayoutCombinators
import XMonad.Layout.NoBorders
import XMonad.Layout.IM
import XMonad.Layout.PerWorkspace
import XMonad.Layout.Reflect
import XMonad.Layout.Grid
import XMonad.Layout.Renamed
import XMonad.Layout.SimpleFloat
import XMonad.Layout.SimpleDecoration
-- hooks related
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.UrgencyHook
-- for xmobar
import XMonad.Util.Run(spawnPipe)
-- actions related
import XMonad.Actions.GridSelect
import XMonad.Actions.Navigation2D
import XMonad.Actions.Warp
-- keymaps related
import XMonad.Util.EZConfig
import Graphics.X11.ExtraTypes.XF86
-- other
import System.IO
import Data.Ratio
import Data.Default

-- Terminal
myTerminal :: [Char]
myTerminal = "termite"

-- Workspaces
myWorkspaces :: [[Char]]
myWorkspaces = [
   "1:メイン"
  ,"2:ブラウザ"
  ,"3:チャット"
  ,"4:開発α"
  ,"5:開発β"
  ,"6:ビデオ"
  ,"7:プレゼン"
  ,"8:浮雲"
  ,"9:仮想"
  ]

-- Use super key as mod
myModMask :: KeyMask
myModMask = mod4Mask 

-- Default layouts
defaultLayouts = 
      (renamed [Replace "|||"] $ tiled)
  ||| (renamed [Replace "三"]  $ Mirror tiled)
  ||| (renamed [Replace "田"]  $ Grid)
  ||| (renamed [Replace "□"]   $ Full)
  where
    tiled   = Tall nmaster delta ratio
    nmaster = 1
    ratio   = 1/2
    delta   = 3/100

-- Custom Layout
myLayoutHook = smartBorders $ avoidStruts $
  onWorkspace "3:チャット" (imGrid ||| imFull) $ 
  onWorkspace "8:浮雲" floating $ 
  defaultLayouts
  where
    floating = renamed [Replace "浮"]    $ simpleFloat' shrinkText mySDTheme ||| defaultLayouts
    imGrid   = renamed [Replace "IM 田"] $ withIM (1/9) skype $ reflectHoriz $ withIM (1/9) pidgin Grid
    imFull   = renamed [Replace "IM □"]  $ withIM (1/9) skype $ reflectHoriz $ withIM (1/9) pidgin Full
    skype    = (ClassName "Skype") `And` (Title "eric.sagnes - Skype™")
    pidgin   = (Role "buddy_list")

-- Simple Decoration Config
mySDTheme :: Theme
--mySDTheme = defaultTheme { 
mySDTheme = def { 
  decoHeight = 19
 ,fontName = "xft:IPAGothic-9:bold"
}

-- GridSelect Config
myGSConfig :: HasColorizer a => GSConfig a
-- myGSConfig = defaultGSConfig {
myGSConfig = def {
  gs_font = "xft:IPAPGothic-9"
}

-- Custom keys handling
myKeyBindings :: [((KeyMask, KeySym), X ())]
myKeyBindings = [
  -- Grid select
  ((mod4Mask, xK_g), goToSelected myGSConfig),
  -- Laptop screen brightness
  ((0, xF86XK_MonBrightnessUp  ), spawn "xbacklight -inc 5"),
  ((0, xF86XK_MonBrightnessDown), spawn "xbacklight -dec 5"),
  -- Volume
  ((0, xF86XK_AudioLowerVolume), spawn "ponymix decrease 5"),
  ((0, xF86XK_AudioRaiseVolume), spawn "ponymix increase 5"),
  -- Layouts change
  ((mod4Mask, xK_f), sendMessage $ JumpToLayout "□"),
  ((mod4Mask, xK_d), sendMessage $ JumpToLayout "田"),
  -- Hide xmobar
  ((mod4Mask, xK_b), sendMessage ToggleStruts),
  -- Window movement
  ((mod4Mask, xK_Right), windowGo R False),
  ((mod4Mask, xK_Left ), windowGo L False),
  ((mod4Mask, xK_Up   ), windowGo U False),
  ((mod4Mask, xK_Down ), windowGo D False),

  ((mod4Mask, xK_h), windowGo L False),
  ((mod4Mask, xK_j), windowGo D False),
  ((mod4Mask, xK_k), windowGo U False),
  ((mod4Mask, xK_l), windowGo R False),

  -- dmenu
  ((mod4Mask, xK_Escape), spawn "dmenu_run"),
  -- Warp mouse to active window
  ((mod4Mask, xK_z), warpToWindow (1%2) (1%2)),
  -- Multiscreen management
  ((mod4Mask, xK_Home  ), spawn "x1"),
  ((mod4Mask, xK_End   ), spawn "x3h"),
  ((mod4Mask, xK_Insert), spawn "x3v"),
  -- Mpc controls
  ((mod4Mask .|. shiftMask, xK_period), spawn "mpc next"),
  ((mod4Mask .|. shiftMask, xK_comma ), spawn "mpc prev"),
  ((mod4Mask .|. shiftMask, xK_slash ), spawn "mpc toggle"),
  -- Lock  screen
  ((mod4Mask .|. shiftMask, xK_Shift_R), spawn "slimlock"),
  -- Sleep
  ((mod4Mask .|. shiftMask, xK_Escape), spawn "systemctl suspend")
  ] 

-- Custom hooks
myManageHook :: ManageHook
myManageHook = manageDocks 
  <+> (isFullscreen --> doFullFloat) 
  <+> (className =? "Skype"  --> doShift "3:チャット")
  <+> (className =? "Pidgin" --> doShift "3:チャット")
--  <+> manageHook defaultConfig
  <+> manageHook def

-- Xmobar appearance
--myLogHook h = dynamicLogWithPP $ defaultPP { 
myLogHook h = dynamicLogWithPP $ def { 
    ppTitle   = xmobarColor "white" "" . shorten 50
   ,ppCurrent = xmobarColor "white" ""
   ,ppVisible = xmobarColor "gray"  "" . wrap "(" ")"
   ,ppUrgent  = xmobarColor "green" "" . xmobarStrip
   ,ppOutput  = hPutStrLn h 
  }

-- Main config
--myConfig h = defaultConfig {
myConfig h = def {
  terminal   = myTerminal,
  workspaces = myWorkspaces,
  logHook    = myLogHook h,
  manageHook = myManageHook,
  modMask    = myModMask,
  layoutHook = myLayoutHook
} `additionalKeys` myKeyBindings

-- Run XMonad
main :: IO ()
main = do 
  h <- spawnPipe "xmobar"
  xmonad $ docks $ ewmh $ withUrgencyHook NoUrgencyHook $ myConfig h

