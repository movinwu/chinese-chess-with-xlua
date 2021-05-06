local module = class("NotificationNames")

module.START_UP_GAME = "StartUpGame"
module.SHOW_PANEL = "ShowPanel"
module.HIDE_PANEL = "HidePanel"
module.DESTROY_PANEL = "DestroyPanel"
module.CHESS_TOUCHED = "ChessTouched"
--module.UPDATE_CHESS_POSITION = "UpdateChessPosition"
module.KING_WILL_BE_KILL = "KingWillBeKill"

module.MOVE_CHESS = "MoveChess"
module.INSTANTIATE_A_CHESS = "InstantiateAChess"
module.INSTANTIATE_CHESS_CAN_MOVE_BUTTON = "InstantiateChessCanMove"
module.EAT_CHESS = "EatChess"
--module.SHOW_LAST_MOVE_CHESS = "ShowLastMoveChess"
module.UNDO = "Undo"

return module