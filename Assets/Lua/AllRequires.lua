--运行PureMVC框架
require "PureMVC"

--运行取别名脚本
require "Alias"
--存储控件名称的全局表
ControlNames = require "ControlNames"
--存储通知名称的全局表
NotificationNames = require "NotificationNames"
--存储声音名称的全局表
SoundNames = require "SoundNames"
--存储所有面板名称的全局表
PanelNames = require "PanelNames"
--存储玩家信息的全局表
require "PlayerInfo"

--启动工具类脚本，定义工具类
Tools = require "Tools"

--使用协程的工具表
Util = require "xlua.util"

--启动各种管理类脚本
require("AudioSourceManager")

--启动基础Panel脚本，这个脚本用于持有panel控件并提供显隐panel的方法
require "BasePanel"

--运行启动命令脚本
require "StartUpCommand"
--运行自定义Facade脚本
require "GameFacade"
--运行网络脚本
--require "Netword"

--各种mediator、proxy、panel、model等脚本
require "MainMediator"
require "LevelOptionMediator"
require "ModeOptionMediator"
require "NetGameMediator"
require "SingleGameMediator"
require "ChessPieceProxy"
require "ShowPanelCommand"
require "HidePanelCommand"
require "ChessPiece"
require "LevelOptionPanel"
require "MainPanel"
require "ModeOptionPanel"
require "SingleGamePanel"
require "ChessTouchedCommand"
require "MoveChessCommand"
require "EatChessCommand"
require "KingWillBeKillCommand"
require "DestroyPanelCommand"
require "Undocommand"
