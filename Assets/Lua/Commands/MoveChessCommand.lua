MoveChessCommand = class("MoveChessCommand",PureMVC.SimpleCommand)

local module = MoveChessCommand

function module:Execute(notification)
    local nowPosition = notification.Body.nowPosition
    local targetPosition = notification.Body.targetPosition
    local facadeInstance = GameFacade:GetInstance()
    if facadeInstance:HasProxy(ChessPieceProxy.NAME) then
        facadeInstance:RetrieveProxy(ChessPieceProxy.NAME):MoveChess(nowPosition,targetPosition)
    end
    AudioSourceManager:PlaySound(SoundNames.CHESS_MOVE)
end