HidePanelCommand = class("HidePanelCommand",PureMVC.SimpleCommand)

function HidePanelCommand:Execute(notification)
    if notification.Body == PanelNames.MAIN then
        if GameFacade:GetInstance():HasMediator(MainMediator.NAME) then
            GameFacade:GetInstance():RetrieveMediator(MainMediator.NAME):HideMe()
        end
    elseif notification.Body == PanelNames.LEVEL_OPTION then
        if GameFacade:GetInstance():HasMediator(LevelOptionMediator.NAME) then
            GameFacade:GetInstance():RetrieveMediator(LevelOptionMediator.NAME):HideMe()
        end
    elseif notification.Body == PanelNames.MODE_OPTION then
        if GameFacade:GetInstance():HasMediator(ModeOptionMediator.NAME) then
            GameFacade:GetInstance():RetrieveMediator(ModeOptionMediator.NAME):HideMe()
        end
    elseif notification.Body == PanelNames.NET_GAME then
        if GameFacade:GetInstance():HasMediator(NetGameMediator.NAME) then
            GameFacade:GetInstance():RetrieveMediator(NetGameMediator.NAME):HideMe()
        end
    elseif notification.Body == PanelNames.SINGLE_GAME then
        if GameFacade:GetInstance():HasMediator(SingleGameMediator.NAME) then
            GameFacade:GetInstance():RetrieveMediator(SingleGameMediator.NAME):HideMe()
        end
    else
        error("notification "..notification.Name.."is illegle")
    end
end