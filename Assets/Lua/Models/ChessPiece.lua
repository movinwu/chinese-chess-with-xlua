--持有棋子数据，并提供了获取棋子、移动棋子、删除棋子等的基础方法
ChessPiece = class("ChessPiece")

local module = ChessPiece
--下方棋盘玩家的棋子类型，0-红色，1-黑色
module.playerColor = 0
--将读取出的棋子数据存到一张表中，使用Position作为键，棋子对象作为值
--这里使用position转成的字符串作为键，因为xlua中两个Vector2Int对象坐标相同，但是比较结果可能不等，这可能和底层实现有关
module.chessTable = {}
--将帅的位置存储为一张表，键为字符串"Jiang"或"Shuai"，值为将帅的位置
module.kingPosition = {}

--构造方法需要给定下方棋盘玩家的棋子类型
--实例化棋子位置数据
function module:ctor(playerColor)
    local temp = self

    --先将元表中的值设置为默认值，再开始其他操作
    --下方棋盘玩家的棋子类型，0-红色，1-黑色
    temp.playerColor = 0
    --将读取出的棋子数据存到一张表中，使用Position作为键，棋子对象作为值
    --这里使用position转成的字符串作为键，因为xlua中两个Vector2Int对象坐标相同，但是比较结果可能不等，这可能和底层实现有关
    temp.chessTable = {}
    --将帅的位置存储为一张表，键为字符串"Jiang"或"Shuai"，值为将帅的位置
    temp.kingPosition = {}

    temp.playerColor = playerColor

    --所有棋子的位置
    local chessPositions = Tools:LoadJsonFile("ChessPosition")
    local position = nil
    local positionStr = nil
    local chessId = nil
    for k,v in pairs(chessPositions) do
        position = Vector2Int(v.positionX,v.positionY)
        positionStr = position:ToString()
        --根据json字符串中棋子id和棋子类型的关系作出的计算
        --黑色棋子id为棋子类型乘2，红色棋子id为棋子类型乘2加1
        chessId = (temp.playerColor + v.color + 1) % 2 + v.type * 2
        temp.chessTable[positionStr] = chessDic[chessId]
        --发送通知，在棋盘上显示棋子
        local chessInfo = {}
        chessInfo.position = position
        chessInfo.id = chessId
        GameFacade:GetInstance():SendNotification(NotificationNames.INSTANTIATE_A_CHESS,chessInfo)
        --如果棋子是将帅，则同时存储到将帅表中
        --将的id为0，帅的id为1
        if chessId == 0 then
            temp.kingPosition["Jiang"] = position
        elseif chessId == 1 then
            temp.kingPosition["Shuai"] = position
        end
    end
end

--提供方法获取棋子，需要给定棋子位置
function module:GetChess(position)
    local temp = self
    return temp.chessTable[position:ToString()]
end

--提供修改棋子位置的方法
function module:MoveChess(nowPosition,targetPosition)
    local temp = self
    --取出棋子
    if nowPosition and targetPosition then
        local nowChess = temp.chessTable[nowPosition:ToString()]
        temp.chessTable[targetPosition:ToString()] = nowChess
        temp.chessTable[nowPosition:ToString()] = nil
        --判断棋子是否是将帅，如果是需要一并更新将帅的位置表
        if nowChess.id == 0 then
            temp.kingPosition["Jiang"] = targetPosition
        elseif nowChess.id == 1 then
            temp.kingPosition["Shuai"] = targetPosition
        end
        return true
    end
    return false
end

--提供移除棋子的方法
function module:RemoveChess(position)
    local temp = self
    if position then
        --在移除棋子时判断一下棋子是否为将帅，如果是将帅被吃则说明游戏结束
        local chess = temp.chessTable[position:ToString()]
        if chess and chess.type == 0 then
            --播放胜利音乐（PVP模式无论谁胜利都播放胜利音乐），等待1s（使用C#的Sleep函数）后返回主菜单
            local obj = GameObject("Coroutine")
            mono = obj:AddComponent(typeof(ForCoroutine))
            --将协程保存在对象中
            co = mono:StartCoroutine(Util.cs_generator(PrivateCoroutineDoNotCallAtOtherScript))
            return
        end
        temp.chessTable[position:ToString()] = nil
        return true
    end
    return false
end

--定义一个协程函数，异步播放胜利音乐
--如果同步执行，在一个方法中调用Sleep的情况是在执行完Sleep后再执行方法中的其他代码，所以采用异步执行
--私有的协程方法，不要在外部调用
function PrivateCoroutineDoNotCallAtOtherScript()
    AudioSourceManager:PlaySound(SoundNames.WIN)
    coroutine.yield(WaitForSeconds(1))
    mono:StopCoroutine(co)
    GameFacade:GetInstance():SendNotification(NotificationNames.DESTROY_PANEL,PanelNames.SINGLE_GAME)
    GameFacade:GetInstance():SendNotification(NotificationNames.SHOW_PANEL,PanelNames.MAIN)
end

--提供添加棋子的方法
function module:AddChess(position,id)
    local temp = self
    if position and id and id > -1 then
        temp.chessTable[position:ToString()] = chessDic[id]
        return true
    end
    return false
end