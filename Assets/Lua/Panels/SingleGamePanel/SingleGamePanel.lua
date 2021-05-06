SingleGamePanel = class("SingleGamePanel",BasePanel)
SingleGamePanel.NAME = "SingleGamePanel"

local module = SingleGamePanel

--使用表存储棋盘上的每个棋子位置和实例对象
module.chesses = {}
--使用表存储实例化出来的棋子能移动位置的游戏对象
module.chessCanMoveButtons = {}
--所有棋子的父物体
module.chessFather = nil
module.nowSelectedPosition = nil
--用一个表格存储所有有显示状态（被吃、可移动等）的位置
module.statusPositions = {}
--上一个移动棋子的位置
module.lastMovePostion = nil

function module:ctor()
    local temp = self
    temp.super.ctor(temp)
    --赋值所有棋子的父物体transform
    --使用transform的成员Find方法，需要一层一层地查找，这里使用GameObject的静态Find方法有一些问题
    temp.chessFather = temp.transform:Find("BoardImg"):Find("ChessPieces")
end

--基础操作的一系列函数封装
--基础操作一：设置可移动位置
function module:ShowChessCanMoveBtn(position)
    --将自身先转存起来，方便在注册方法时调用
    local temp = self

    local str = position:ToString()
    if not temp.chessCanMoveButtons[str] then
        --实例化物体
        local gameObject = AssetBundleManager:LoadRes("button","CanMoveBtn",typeof(GameObject))
        --设置父物体
        gameObject.transform:SetParent(temp.chessFather,false)
        --设置位置
        gameObject.transform.localPosition = Tools:PositionCastToLocal(position)
        --设置显示
        gameObject:SetActive(true)

        --添加监听方法
        gameObject:GetComponent(typeof(Button)).onClick:AddListener(function()
            --封装消息体
            local info = {}
            info.nowPosition = temp.nowSelectedPosition
            info.targetPosition = position
            --发送通知进行棋子的移动
            GameFacade:GetInstance():SendNotification(NotificationNames.MOVE_CHESS,info)
        end)

        --将物体存储起来
        temp.chessCanMoveButtons[str] = gameObject
    else
        temp.chessCanMoveButtons[str]:SetActive(true)
    end
end
--基础操作一：取消可移动位置
function module:HideChessCanMoveBtn(position)
    local temp = self
    local btn = nil
    --取出棋子
    if position then
        btn = temp.chessCanMoveButtons[position:ToString()]
    end
    --不为空则设置隐藏，不能直接设置，否则可能报错
    if btn then
        btn:SetActive(false)
    end
end
--基础操作二：设置可被吃状态
function module:ChessCanBeEat(position)
    local temp = self
    local chess = nil
    --取出棋子
    if position then
        chess = temp.chesses[position:ToString()]
    end
    --不为空，设置状态显示
    if chess then
        chess.canBeEatImg:SetActive(true)
    end
end
--基础操作二：取消可被吃状态
function module:CancelChessCanBeEat(position)
    local temp = self
    local chess = nil
    --取出棋子
    if position then
        chess = temp.chesses[position:ToString()]
    end
    --不为空，设置状态显示
    if chess then
        chess.canBeEatImg:SetActive(false)
    end
end
--基础操作三：设置被选中状态
function module:ChessBeSelected(position)
    local temp = self
    local chess = nil
    --取出棋子
    if position then
        chess = temp.chesses[position:ToString()]
    end
    if chess then
        chess.selectedImg:SetActive(true)
    end
end
--基础操作三：取消被选中状态
function module:CancelChessBeSelected(position)
    local temp = self
    local chess = nil
    --取出棋子
    if position then
        chess = temp.chesses[position:ToString()]
    end
    --不为空，设置状态显示
    if chess then
        chess.selectedImg:SetActive(false)
    end
end
--基础操作四：实例化一个棋子
function module:InstantiateAChess(position,id)
    local temp = self
    --使用一个表存储棋子
    local chess = {}

    --实例化棋子
    chess.gameObject = AssetBundleManager:LoadRes("chesspiece",chessDic[id].name,typeof(GameObject))
    chess.transform = chess.gameObject.transform
    --设置实例出来的棋子的位置
    chess.transform:SetParent(temp.chessFather,false)
    chess.transform.localPosition = Tools:PositionCastToLocal(position)

    --棋子需要存储自己的位置
    chess.position = position

    --为标识棋子状态的图片赋值
    chess.selectedImg = chess.transform:Find(ControlNames.CHESS_SELECTED_IMAGE).gameObject
    chess.selectedImg:SetActive(false)
    chess.canBeEatImg = chess.transform:Find(ControlNames.CHESS_CAN_BE_EAT_IMAGE).gameObject
    chess.canBeEatImg:SetActive(false)
    chess.lastImg = chess.transform:Find(ControlNames.LAST_CHESS_IMAGE).gameObject
    chess.lastImg:SetActive(false)

    --为棋子上的Button添加监听事件
    chess.gameObject:GetComponent(typeof(Button)).onClick:AddListener(function()
        if chess.canBeEatImg.activeInHierarchy then
            --如果当前被触摸棋子是可能被吃状态，且是将帅，发送游戏结束通知
            if temp.chesses[chess.position:ToString()].type == 0 then
                return
            end
            local info = {}
            info.nowPosition = temp.nowSelectedPosition
            info.targetPosition = chess.position
            GameFacade:GetInstance():SendNotification(NotificationNames.EAT_CHESS,info)
        elseif not chess.selectedImg.activeInHierarchy then
            --取消所有状态
            temp:CancelAllStatus()
            --发送消息通知当前棋子被选中
            GameFacade:GetInstance():SendNotification(NotificationNames.CHESS_TOUCHED,chess.position)
        end
    end)

    --将棋子返回出去
    return chess
end
--基础操作四：销毁一个棋子
function module:DestroyAChess(position)
    local temp = self
    local str = position:ToString()
    local chess = temp.chesses[str]
    if chess then
        GameObject.Destroy(chess.gameObject)
        chess = nil
        temp.chesses[str] = nil
    end

end
--基础操作五：移动棋子
function module:JustMoveChess(targetPosition)
    local temp = self
    --得到字符串，棋子的表是用坐标的字符串作为键的
    local now = temp.nowSelectedPosition:ToString()
    local target = targetPosition:ToString()
    --取出棋子
    local chess = temp.chesses[now]
    --播放棋子动画
    chess.transform:DOLocalMove(Tools:PositionCastToLocal(targetPosition),0.5,false)
    --设值棋子更改自己的位置
    chess.position = targetPosition
end
--基础操作六：设置选中位置
function module:SetNowSelectedChess(position)
    local temp = self
    if position then
        temp:CancelChessBeSelected(temp.nowSelectedPosition)
        temp.nowSelectedPosition = position
        temp:ChessBeSelected(temp.nowSelectedPosition)
    end
end
--基础操作七：同步棋子table--移动
function module:ChangeChessTableWhenMove(nowPosition,targetPosition)
    local temp = self
    local now = nowPosition:ToString()
    local target = targetPosition:ToString()
    temp.chesses[target] = temp.chesses[now]
    temp.chesses[now] = nil
end
--基础操作七：同步棋子table--添加
function module:ChangeChessTableWhenAdd(position,chess)
    local temp = self
    if position then
        local str = position:ToString()
        temp.chesses[str] = chess
    end
end
--基础操作七：同步棋子table--删除
function module:ChangeChessTableWhenRemove(position)
    local temp = self
    if position then
        local str = position:ToString()
        temp.chesses[str] = nil
    end
end
--基础操作八：销毁所有棋子
function module:DestroyAllChess()
    local temp = self
    for str,chess in pairs(temp.chesses) do 
        GameObject.Destroy(chess.gameObject)
        chess = nil
        temp.chesses[str] = nil
    end

end
--基础操作九：显示上一个棋子状态
function module:LastMoveChess(position)
    local temp = self
    if position then
        temp.lastMovePostion = position
        local chess = temp.chesses[position:ToString()]
        if chess then
            chess.lastImg:SetActive(true)
        end
    end
end
--基础操作九：取消上一个棋子状态
function module:CancelLastMoveChess()
    local temp = self
    local position = temp.lastMovePostion
    if position then
        local chess = temp.chesses[position:ToString()]
        if chess then
            chess.lastImg:SetActive(false)
        end
        temp.lastMovePostion = nil
    end
end

--组合操作一：设置所有棋子状态显示
function module:SetAllStatus(positions)
    local temp = self
    --将状态表存起来
    temp.statusPositions = positions
    --遍历，根据得到的数据类型进行响应的处理
    for position,type in pairs(positions) do
        if type == 0 then
            temp:ShowChessCanMoveBtn(position)
        elseif type == 2 then
            temp:ChessCanBeEat(position)
        elseif type == 3 then
            temp.nowSelectedPosition = position
        end
    end
    --设置自身显示被选中状态
    temp:ChessBeSelected(temp.nowSelectedPosition)
end
--组合操作一：取消所有的状态显示
function module:CancelAllStatus()
    local temp = self
    --取消上一个棋子的选中状态
    temp:CancelChessBeSelected(temp.nowSelectedPosition)
    --遍历，根据得到的数据类型进行响应的处理
    for position,type in pairs(temp.statusPositions) do
        if type == 0 then
            temp:HideChessCanMoveBtn(position)
        elseif type == 2 then
            temp:CancelChessCanBeEat(position)
        end
    end
end
--组合操作二：移动棋子
function module:MoveChess(targetPosition)
    local temp = self
    --移动棋子位置
    temp:JustMoveChess(targetPosition)
    --修改棋子table
    temp:ChangeChessTableWhenMove(temp.nowSelectedPosition,targetPosition)
    --修改当前选中位置
    temp:SetNowSelectedChess(targetPosition)
end
--组合操作三：销毁自身
function module:DestroyMe()
    local temp = self
    temp.super.DestroyMe(temp)
    --销毁所有棋子
    temp:DestroyAllChess()
    --销毁棋子能移动位置的游戏对象
    for positionStr,gameObject in pairs(temp.chessCanMoveButtons) do
        GameObject.Destroy(gameObject)
        temp.chessCanMoveButtons[positionStr] = nil
    end
    --销毁其他变量
    temp.nowSelectedPosition = nil
    temp.chessFather = nil
    temp.statusPositions = {}
end