EatChessCommand = class("EatChessCommand",PureMVC.SimpleCommand)

local module = EatChessCommand

function module:Execute(notification)
    local nowPosition = notification.Body.nowPosition
    local targetPosition = notification.Body.targetPosition
    local facadeInstance = GameFacade:GetInstance()
    if facadeInstance:HasProxy(ChessPieceProxy.NAME) then
        facadeInstance:RetrieveProxy(ChessPieceProxy.NAME):EatChess(nowPosition,targetPosition)
    end
    AudioSourceManager:PlaySound(SoundNames.EAT_CHESS)
end