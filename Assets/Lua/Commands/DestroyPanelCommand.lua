DestroyPanelCommand = class("DestroyPanelCommand",PureMVC.SimpleCommand)

function DestroyPanelCommand:Execute(notification)
    if notification.Body == PanelNames.MAIN then
        if GameFacade:GetInstance():HasMediator(MainMediator.NAME) then
            GameFacade:GetInstance():RetrieveMediator(MainMediator.NAME):DestroyMe()
            GameFacade:GetInstance():RemoveMediator(MainMediator.NAME)
        end
    elseif notification.Body == PanelNames.LEVEL_OPTION then
        if GameFacade:GetInstance():HasMediator(LevelOptionMediator.NAME) then
            GameFacade:GetInstance():RetrieveMediator(LevelOptionMediator.NAME):DestroyMe()
            GameFacade:GetInstance():RemoveMediator(LevelOptionMediator.NAME)
        end
    elseif notification.Body == PanelNames.MODE_OPTION then
        if GameFacade:GetInstance():HasMediator(ModeOptionMediator.NAME) then
            GameFacade:GetInstance():RetrieveMediator(ModeOptionMediator.NAME):DestroyMe()
            GameFacade:GetInstance():RemoveMediator(ModeOptionMediator.NAME)
        end
    elseif notification.Body == PanelNames.NET_GAME then
        if GameFacade:GetInstance():HasMediator(NetGameMediator.NAME) then
            GameFacade:GetInstance():RetrieveMediator(NetGameMediator.NAME):DestroyMe()
            GameFacade:GetInstance():RemoveMediator(NetGameMediator.NAME)
        end
    elseif notification.Body == PanelNames.SINGLE_GAME then
        if GameFacade:GetInstance():HasMediator(SingleGameMediator.NAME) then
            GameFacade:GetInstance():RetrieveMediator(SingleGameMediator.NAME):DestroyMe()
            GameFacade:GetInstance():RemoveMediator(SingleGameMediator.NAME)
        end
        --一并移除Proxy
        if GameFacade:GetInstance():HasProxy(ChessPieceProxy.NAME) then
            GameFacade:GetInstance():RemoveProxy(ChessPieceProxy.NAME)
        end
    else
        error("notification "..notification.Name.."is illegle")
    end
    --销毁完成后需要释放一下luaenv
    LuaEnv:Tick()
end