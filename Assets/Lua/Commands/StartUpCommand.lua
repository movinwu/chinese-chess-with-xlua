StartUpCommand = class("StartUpCommand",PureMVC.SimpleCommand)

function StartUpCommand:Execute(notification)
    AudioSourceManager:PlaySound(SoundNames.MAIN_BGM)
    GameFacade:GetInstance():SendNotification(NotificationNames.SHOW_PANEL,PanelNames.MAIN)
end