MainMediator = class("MainMediator",PureMVC.Mediator)
MainMediator.NAME = "MainMediator"
local module = MainMediator

function module:ctor()
    --在本项目中，panel都是只有一个，每个mediator和panel都是一一对应
    --由于不会出现一个panel被多个mediator中介的情况，所以在mediator的构造方法内部实例化panel
    local panel = MainPanel.new()
    self.super.ctor(self,self.NAME,panel)
    self:AddListener()
end

--为panel上的控件添加监听方法
function module:AddListener()
    self.View:GetControl(ControlNames.MAIN_PANEL_STAND_ALONE_BUTTON,"Button").onClick:AddListener(function()
        GameFacade:GetInstance():SendNotification(NotificationNames.SHOW_PANEL,PanelNames.MODE_OPTION)
        GameFacade:GetInstance():SendNotification(NotificationNames.HIDE_PANEL,PanelNames.MAIN)
    end)
    self.View:GetControl(ControlNames.MAIN_PANEL_NETWORK_BUTTON,"Button").onClick:AddListener(function()
        --存储选择的模式
        PlayerInfo.mode = 2
        --加载网络游戏面板
        --TODO
    end)
    self.View:GetControl(ControlNames.MAIN_PANEL_EXITGAME_BUTTON,"Button").onClick:AddListener(function()
        Application.Exit(0)
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