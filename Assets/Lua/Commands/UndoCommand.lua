UndoCommand = class("UndoCommand",PureMVC.SimpleCommand)

local module = UndoCommand

function module:Execute(notification)
    local proxy = GameFacade:GetInstance():RetrieveProxy(ChessPieceProxy.NAME)
    --得到棋子刚才移动的反向移动信息
    local nowPosition,targetPosition,chessId = proxy:Undo()
    --调用mediator的方法进行移动
    --这里不使用mediator监听命令，而是调用mediator的方法，因为需要从proxy中取出信息提供给mediator方法使用
    local mediator = GameFacade:GetInstance():RetrieveMediator(SingleGameMediator.NAME)
    mediator:Undo(nowPosition,targetPosition,chessId)
end