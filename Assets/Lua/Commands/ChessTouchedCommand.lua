ChessTouchedCommand = class("ChessTouchedCommand",PureMVC.SimpleCommand)

local module = ChessTouchedCommand

function module:Execute(notification)
    local position = notification.Body
    local proxy = GameFacade:GetInstance():RetrieveProxy(ChessPieceProxy.NAME)
    local positions = proxy:CalcChessCanMove(position)
    GameFacade:GetInstance():SendNotification(NotificationNames.INSTANTIATE_CHESS_CAN_MOVE_BUTTON,positions)
    AudioSourceManager:PlaySound(SoundNames.CLICK_CHESS)
end

