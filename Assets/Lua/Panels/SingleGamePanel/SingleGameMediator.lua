SingleGameMediator = class("SingleGameMediator",PureMVC.Mediator)
SingleGameMediator.NAME = "SingleGameMediator"
local module = SingleGameMediator

function module:ctor()
    --在本项目中，panel都是只有一个，每个mediator和panel都是一一对应
    --由于不会出现一个panel被多个mediator中介的情况，所以在mediator的构造方法内部实例化panel
    local panel = SingleGamePanel.new()
    self.super.ctor(self,self.NAME,panel)

    self:AddListener()
end

--为panel上的控件添加监听方法
function module:AddListener()
    self.View:GetControl(ControlNames.SINGLE_GAME_PANEL_UNDO_BUTTON,"Button").onClick:AddListener(function()
        GameFacade:GetInstance():SendNotification(NotificationNames.UNDO)
    end)
    self.View:GetControl(ControlNames.SINGLE_GAME_PANEL_REPLAY_BUTTON,"Button").onClick:AddListener(function()
        GameFacade:GetInstance():SendNotification(NotificationNames.DESTROY_PANEL,PanelNames.SINGLE_GAME)
        GameFacade:GetInstance():SendNotification(NotificationNames.SHOW_PANEL,PanelNames.SINGLE_GAME)
    end)
    self.View:GetControl(ControlNames.SINGLE_GAME_PANEL_BACK_BUTTON,"Button").onClick:AddListener(function()
        GameFacade:GetInstance():SendNotification(NotificationNames.SHOW_PANEL,PanelNames.MAIN)
        GameFacade:GetInstance():SendNotification(NotificationNames.DESTROY_PANEL,PanelNames.SINGLE_GAME)
    end)
end

--提供供外界调用的显隐方法
function module:ShowMe()
    self.View:ShowMe()
end
function module:HideMe()
    self.View:HideMe()
end
function module:DestroyMe()
    self.View:DestroyMe()
end
--需要监听的事件
function module:ListNotificationInterests()
    return {
        NotificationNames.MOVE_CHESS,
        NotificationNames.INSTANTIATE_A_CHESS,
        NotificationNames.INSTANTIATE_CHESS_CAN_MOVE_BUTTON,
        NotificationNames.EAT_CHESS,
    }
end
--事件的响应处理函数
function module:HandleNotification(notification)
    if notification.Name == NotificationNames.MOVE_CHESS then
        --取出消息体中的数据
        local targetPosition = notification.Body.targetPosition
        --取消上一个棋子位置显示
        self.View:CancelLastMoveChess()
        --取消所有的可移动等显示状态
        self.View:CancelAllStatus()
        --移动
        self.View:MoveChess(targetPosition)
        --显示上一个棋子
        self.View:LastMoveChess(targetPosition)
    elseif notification.Name == NotificationNames.INSTANTIATE_A_CHESS then
        --取出消息体中的内容
        local position = notification.Body.position
        local id = notification.Body.id
        --调用View中的方法实例化一个棋子，棋子会返回出来
        local chess = self.View:InstantiateAChess(position,id)
        --将得到的棋子存到表中
        self.View:ChangeChessTableWhenAdd(position,chess)
    elseif notification.Name == NotificationNames.INSTANTIATE_CHESS_CAN_MOVE_BUTTON then
        --取出计算出的位置坐标
        local positions = notification.Body
        self.View:SetAllStatus(positions)
    elseif notification.Name == NotificationNames.EAT_CHESS then
        local nowPosition = notification.Body.nowPosition
        local targetPosition = notification.Body.targetPosition
        --取消上一个棋子位置显示
        self.View:CancelLastMoveChess()
        self.View:CancelAllStatus()
        self.View:DestroyAChess(targetPosition)
        self.View:MoveChess(targetPosition)
        --显示上一个棋子
        self.View:LastMoveChess(targetPosition)
    end
end

--提供一个撤销操作的方法给外部调用
function module:Undo(nowPosition,targetPosition,chessId)
    local temp = self
    --1.校验nowPosition是否为空，如果为空不执行任何操作（只能撤销两次）
    --2.校验chessId是不是-1，如果是-1，上次棋子移动没有吃子，如果不是，这个id就是被吃棋子的id
    --3.撤销一步操作可以理解为实现了一次棋子移动
    if nowPosition then
        if chessId == -1 then
            --设置当前选中棋子，因为在撤销前有可能选择了其他棋子
            temp.View:SetNowSelectedChess(targetPosition)
            temp.View:CancelLastMoveChess()
            temp.View:CancelAllStatus()
            temp.View:MoveChess(nowPosition)
        else
            temp.View:SetNowSelectedChess(targetPosition)
            temp.View:CancelLastMoveChess()
            temp.View:CancelAllStatus()
            temp.View:MoveChess(nowPosition)
            local chess = temp.View:InstantiateAChess(targetPosition,chessId)
            temp.View:ChangeChessTableWhenAdd(targetPosition,chess)
        end
    end
end