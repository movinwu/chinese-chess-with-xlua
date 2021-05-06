--运行AllRequires，所有预先执行的脚本都在这里面执行
require "AllRequires"

--读取棋子的类型并封装成一个全局表，方便调用
chessDic = Tools:LoadJsonFile("ChessPieces")

--启动游戏
GameFacade:GetInstance():SendNotification(NotificationNames.START_UP_GAME)
