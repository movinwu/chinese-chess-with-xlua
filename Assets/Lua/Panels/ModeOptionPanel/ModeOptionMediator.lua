ModeOptionMediator = class("ModeOptionMediator",PureMVC.Mediator)
ModeOptionMediator.NAME = "ModeOptionMediator"
local module = ModeOptionMediator

function module:ctor()
    --在本项目中，panel都是只有一个，每个mediator和panel都是一一对应
    --由于不会出现一个panel被多个mediator中介的情况，所以在mediator的构造方法内部实例化panel
    local panel = ModeOptionPanel.new()
    self.super.ctor(self,self.NAME,panel)
    self:AddListener()
end

--为panel上的控件添加监听方法
function module:AddListener()
    self.View:GetControl(ControlNames.MODE_OPTION_PANEL_PVE_BUTTON,"Button").onClick:AddListener(function()
        --存储选择的模式
        PlayerInfo.hard = 0
        GameFacade:GetInstance():SendNotification(NotificationNames.SHOW_PANEL,PanelNames.LEVEL_OPTION)
        GameFacade:GetInstance():SendNotification(NotificationNames.HIDE_PANEL,PanelNames.MODE_OPTION)
    end)
    self.View:GetControl(ControlNames.MODE_OPTION_PANEL_PVP_BUTTON,"Button").onClick:AddListener(function()
        --存储选择的模式
        PlayerInfo.hard = 1
        GameFacade:GetInstance():SendNotification(NotificationNames.SHOW_PANEL,PanelNames.SINGLE_GAME)
        GameFacade:GetInstance():SendNotification(NotificationNames.HIDE_PANEL,PanelNames.MODE_OPTION)
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