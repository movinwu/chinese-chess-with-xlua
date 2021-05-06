--玩家的数据表，用于存储玩家在选择难度时做的各种选择，在加载棋盘时调用这个表中的信息确定加载的棋盘类型
PlayerInfo = {}

local module = PlayerInfo
--玩家选择的模式，-1未选择，0PVE（玩家对战环境），1PVP（玩家对战玩家），2NET（网络对战）
module.mode = -1
--玩家选择的难度，也是AI使用的算法的搜索深度，只在PVE模式下有用，-1未选择或无须选择，3简单，5一般，7困难
module.hard = -1
--玩家所持的棋子颜色,0-红色，1-黑色
module.color = 0

--提供一个方法初始化所有设置，在加载Main面板时使用
function module:Init()
    local temp = self
    temp.mode = -1
    temp.hard = -1
    temp.color = 0
end