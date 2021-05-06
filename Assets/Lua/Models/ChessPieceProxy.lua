ChessPieceProxy = class("ChessPieceProxy",PureMVC.Proxy)
ChessPieceProxy.NAME = "ChessPieceProxy"

local module = ChessPieceProxy
--当前下棋者的棋子颜色
module.nowPlayerColor = PlayerInfo.color
--使用表存储上一次移动的信息和上上次移动的信息
module.moveInfo = {}
--上一次移动信息
module.moveInfo.lastMoveInfo = {}
module.moveInfo.lastMoveInfo.startPosition = nil     --上次棋子移动的开始坐标
module.moveInfo.lastMoveInfo.endPosition = nil       --上次棋子移动的结束坐标
module.moveInfo.lastMoveInfo.beEatChessId = -1       --被吃的棋子id，-1代表没有棋子被吃
--上上次移动信息
module.moveInfo.lastLastMoveInfo = {}
module.moveInfo.lastLastMoveInfo.startPosition = nil     --上上次棋子移动的开始坐标
module.moveInfo.lastLastMoveInfo.endPosition = nil       --上上次棋子移动的结束坐标
module.moveInfo.lastLastMoveInfo.beEatChessId = -1       --被吃的棋子id，-1代表没有棋子被吃

function module:ctor()
    local temp = self

    --先将类表中的内容设置为默认值（也就是将元表初始化），再做其他操作
    --当前下棋者的棋子颜色
    temp.nowPlayerColor = 0
    --使用表存储上一次移动的信息和上上次移动的信息
    temp.moveInfo = {}
    --上一次移动信息
    temp.moveInfo.lastMoveInfo = {}
    temp.moveInfo.lastMoveInfo.startPosition = nil     --上次棋子移动的开始坐标
    temp.moveInfo.lastMoveInfo.endPosition = nil       --上次棋子移动的结束坐标
    temp.moveInfo.lastMoveInfo.beEatChessId = -1       --被吃的棋子id，-1代表没有棋子被吃
    --上上次移动信息
    temp.moveInfo.lastLastMoveInfo = {}
    temp.moveInfo.lastLastMoveInfo.startPosition = nil     --上上次棋子移动的开始坐标
    temp.moveInfo.lastLastMoveInfo.endPosition = nil       --上上次棋子移动的结束坐标
    temp.moveInfo.lastLastMoveInfo.beEatChessId = -1       --被吃的棋子id，-1代表没有棋子被吃

    --内部实例化持有的数据类型
    local data = ChessPiece.new()
    temp.super.ctor(temp,temp.NAME,data)
end

--提供获取棋子、移动棋子、移除棋子等方法，在作出相应操作后需要发出通知让mediator作出显示
function module:GetChess(position)
    local temp = self
    return temp.Data:GetChess(position)
end

--[[function module:RemoveChess(position)
    temp.Data:RemoveChess(position)
end]]

--提供方法获取存储所有棋子位置的表
function module:GetChessTable()
    local temp = self
    return temp.Data.chessTable
end

--根据判断目标位置棋子状态，0-没有棋子，1-自家棋子，2-对家棋子，3-棋子自身
--color：棋子颜色，targetPos：目标位置
function module:TargetPositionStatus(color,targetPos)
    local temp = self
    --获取存储棋子的表
    local chessTable = temp:GetChessTable()
    local str = targetPos:ToString()
    if chessTable[str] == nil then
        return 0
    else
        if chessTable[str].color == color then
            return 1
        else
            return 2
        end
    end 
end

--棋子计算可移动位置的方法，根据棋子类型进行具体的计算，返回存储所有可移动位置的表
function module:CalcChessCanMove(position)
    local temp = self

    local positions = {}

    --将棋子自身位置添加到表中返回，用于设置当前棋子位置
    positions[position] = 3

    --先校验当前下棋的玩家和棋子的颜色是否相同，如果是再进入下一步,不是直接返回当前棋子位置
    if not temp:IsNowPlayerChessTouched(position) then
        return positions
    end

    local chessTable = temp:GetChessTable()
    --取出当前棋子的位置的坐标
    local x = position.x
    local y = position.y
    local chess = chessTable[position:ToString()]

    --使用bool值记录当前棋子是否是将帅之间的唯一棋子，是的话当前棋子是不能左右移动的
    local isOnlyChessBetweenKings = false
    --计算当前棋子是否是将帅之间的唯一棋子
    local redKingPos = temp:GetKingPosition(0)
    local blackKingPos = temp:GetKingPosition(1)
    local countChess = 0        --记录将帅之间的棋子个数
    if redKingPos.x == blackKingPos.x and x == redKingPos.x and --x值相等
        (redKingPos.y - y) * (blackKingPos.y - y) < 0 then      --y值在将帅之间
        for i = redKingPos.y,blackKingPos.y,1 - temp.nowPlayerColor * 2 do
            if chessTable[Vector2Int(x,i):ToString()] then
                countChess = countChess + 1
            end
            if countChess > 3 then
                break
            end
        end
        if countChess == 3 then
            isOnlyChessBetweenKings = true
        end
    end

    --根据棋子类型不同，校验可移动位置的方法不同
    if chess.type == 0 then        --将或者帅
        --可移动范围横坐标3、4、5，纵坐标根据颜色确定，0、1、2或7、8、9
        local left = 2
        local right = 6
        local up = nil
        local down = nil
        if temp.nowPlayerColor == 0 then
            up = 3
            down = -1
        else
            up = 10
            down = 6
        end 
        --将帅往上下左右各移动一格，依次判断是否可以移动，将可移动的位置添加到结果表中
        --只可能往前后左右移动，同时校验是否已有自家棋子，如果有不能移动以及左右移动后将帅是否面对面
        if (y + 1 < up) then   --向上
            positions[Vector2Int(x,y + 1)] = temp:TargetPositionStatus(chess.color,Vector2Int(x,y + 1))
        end
        if (y - 1 > down) then  --向下
            positions[Vector2Int(x,y - 1)] = temp:TargetPositionStatus(chess.color,Vector2Int(x,y - 1))
        end
        if (x - 1 > left) then   --向左
            --左右移动时除了移动范围判断，还要有将帅是否面对面的判断，移动后没有面对面才能移动
            if not temp:IsTwoKingFacaToFace(Vector2Int(position.x - 1,y)) then
                positions[Vector2Int(x - 1,y)] = temp:TargetPositionStatus(chess.color,Vector2Int(x - 1,y))
            end
        end
        if (x + 1 < right) then   --向右
            if not temp:IsTwoKingFacaToFace(Vector2Int(position.x + 1,y)) then
                positions[Vector2Int(x + 1,y)] = temp:TargetPositionStatus(chess.color,Vector2Int(x + 1,y))
            end
        end
    elseif chess.type == 1 then    --士
        --如果是将帅之间的唯一棋子的话，不能移动
        if isOnlyChessBetweenKings then
            return positions
        end
        local left = 2
        local right = 6
        local up = nil
        local down = nil
        if temp.nowPlayerColor == 0 then
            up = 3
            down = -1
        else
            up = 10
            down = 6
        end 
        --士往左上、右上、左下、右下移动一格，需要注意判断是否超出移动范围，和将帅的判断类似
        if (x + 1 < right) and (y + 1 < up) then   --右上
            positions[Vector2Int(x + 1,y + 1)] = temp:TargetPositionStatus(chess.color,Vector2Int(x + 1,y + 1))
        end
        if (x + 1 < right) and (y - 1 > down) then      --右下
            positions[Vector2Int(x + 1,y - 1)] = temp:TargetPositionStatus(chess.color,Vector2Int(x + 1,y - 1))
        end
        if (x - 1 > left) and (y + 1 < up) then       --左上
            positions[Vector2Int(x - 1,y + 1)] = temp:TargetPositionStatus(chess.color,Vector2Int(x - 1,y + 1))
        end
        if (x - 1 > left) and (y - 1 > down) then       --左下
            positions[Vector2Int(x - 1,y - 1)] = temp:TargetPositionStatus(chess.color,Vector2Int(x - 1,y - 1))
        end
    elseif chess.type == 2 then    --相
        --如果是将帅之间的唯一棋子的话，不能移动
        if isOnlyChessBetweenKings then
            return positions
        end
        --相往左上、右上、左下、右下移动两格，需要注意判断是否超出移动范围，和将帅的判断类似，相校验时还要校验是否别相腿
        local left = -1
        local right = 9
        local up = nil
        local down = nil
        if temp.nowPlayerColor == 0 then
            up = 5
            down = -1
        else
            up = 10
            down = 4
        end 
        if (x + 2 < right) and (y + 2 < up) and not chessTable[Vector2Int(x + 1,y + 1):ToString()] then   --右上
            positions[Vector2Int(x + 2,y + 2)] = temp:TargetPositionStatus(chess.color,Vector2Int(x + 2,y + 2))
        end
        if (x + 2 < right) and (y - 2 > down) and not chessTable[Vector2Int(x + 1,y - 1):ToString()] then      --右下
            positions[Vector2Int(x + 2,y - 2)] = temp:TargetPositionStatus(chess.color,Vector2Int(x + 2,y - 2))
        end
        if (x - 2 > left) and (y + 2 < up) and not chessTable[Vector2Int(x - 1,y + 1):ToString()] then       --左上
            positions[Vector2Int(x - 2,y + 2)] = temp:TargetPositionStatus(chess.color,Vector2Int(x - 2,y + 2))
        end
        if (x - 2 > left) and (y - 2> down) and not chessTable[Vector2Int(x - 1,y - 1):ToString()] then       --左下
            positions[Vector2Int(x - 2,y - 2)] = temp:TargetPositionStatus(chess.color,Vector2Int(x - 2,y - 2))
        end
    elseif chess.type == 3 then    --马
        --如果是将帅之间的唯一棋子的话，不能移动
        if isOnlyChessBetweenKings then
            return positions
        end
        --和之前的校验类似，只是马的校验有8个位置，且需要校验是否蹩馬腿
        --外层校验是否蹩馬腿，内层校验可能位置是否在棋盘内且是否合规
        if chessTable[Vector2Int(x + 1,y):ToString()] == nil then --右侧是否蹩馬腿
            if (x + 2 < 9) and (y + 1 < 10) then
                positions[Vector2Int(x + 2,y + 1)] = temp:TargetPositionStatus(chess.color,Vector2Int(x + 2,y + 1))
            end 
            if (x + 2 < 9) and (y - 1 > -1) then
                positions[Vector2Int(x + 2,y - 1)] = temp:TargetPositionStatus(chess.color,Vector2Int(x + 2,y - 1))
            end 
        end
        if chessTable[Vector2Int(x - 1,y):ToString()] == nil then --左侧是否蹩馬腿
            if (x - 2 > -1) and (y + 1 < 10) then
                positions[Vector2Int(x - 2,y + 1)] = temp:TargetPositionStatus(chess.color,Vector2Int(x - 2,y + 1))
            end 
            if (x - 2 > -1) and (y - 1 > -1) then
                positions[Vector2Int(x - 2,y - 1)] = temp:TargetPositionStatus(chess.color,Vector2Int(x - 2,y - 1))
            end 
        end
        if chessTable[Vector2Int(x,y + 1):ToString()] == nil then --上方是否蹩馬腿
            if (x + 1 < 9) and (y + 2 < 10) then
                positions[Vector2Int(x + 1,y + 2)] = temp:TargetPositionStatus(chess.color,Vector2Int(x + 1,y + 2))
            end 
            if (x - 1 > -1) and (y + 2 < 10) then
                positions[Vector2Int(x - 1,y + 2)] = temp:TargetPositionStatus(chess.color,Vector2Int(x - 1,y + 2))
            end 
        end
        if chessTable[Vector2Int(x,y - 1):ToString()] == nil then --下方是否蹩馬腿
            if (x + 1 < 9) and (y - 2 > -1) then
                positions[Vector2Int(x + 1,y - 2)] = temp:TargetPositionStatus(chess.color,Vector2Int(x + 1,y - 2))
            end 
            if (x - 1 > -1) and (y - 2 > -1) then
                positions[Vector2Int(x - 1,y - 2)] = temp:TargetPositionStatus(chess.color,Vector2Int(x - 1,y - 2))
            end 
        end
    elseif chess.type == 4 then    --车
        local status = nil
        --车的可走位置需要向上下左右依次遍历，直到遇到其他棋子或者边界停下
        if x < 8 and (not isOnlyChessBetweenKings) then   --不在最右列向右遍历
            for j = x + 1,8 do 
                status = temp:TargetPositionStatus(chess.color,Vector2Int(j,y))
                if status == 0 then
                    positions[Vector2Int(j,y)] = 0
                elseif status == 2 then
                    positions[Vector2Int(j,y)] = 2
                    break
                else
                    break
                end
            end
        end
        if x > 0 and (not isOnlyChessBetweenKings) then   --不在最左列向左遍历
            for j = x - 1,0,-1 do 
                status = temp:TargetPositionStatus(chess.color,Vector2Int(j,y))
                if status == 0 then
                    positions[Vector2Int(j,y)] = 0
                elseif status == 2 then
                    positions[Vector2Int(j,y)] = 2
                    break
                else
                    break
                end
            end
        end
        if y < 9 then   --不在最上行向上遍历
            for j = y + 1,9 do 
                status = temp:TargetPositionStatus(chess.color,Vector2Int(x,j))
                if status == 0 then
                    positions[Vector2Int(x,j)] = 0
                elseif status == 2 then
                    positions[Vector2Int(x,j)] = 2
                    break
                else
                    break
                end
            end
        end
        if y > 0 then   --不在最下行向下遍历
            for j = y - 1,0,-1 do 
                status = temp:TargetPositionStatus(chess.color,Vector2Int(x,j))
                if status == 0 then
                    positions[Vector2Int(x,j)] = 0
                elseif status == 2 then
                    positions[Vector2Int(x,j)] = 2
                    break
                else
                    break
                end
            end
        end
    elseif chess.type == 5 then    --炮
        --炮的可走位置判断和车非常相似，但是在遇到任意其他棋子后的处理方法不同
        local status = nil
        if x < 8 and ((not isOnlyChessBetweenKings)) then   --不在最右列向右遍历
            for j = x + 1,8 do 
                if temp:TargetPositionStatus(chess.color,Vector2Int(j,y)) == 0 then
                    positions[Vector2Int(j,y)] = 0
                else
                    --如果遍历到了棋子，需要再开启一个for循环，找有没有能吃的子
                    for m = j + 1,8 do
                        status = temp:TargetPositionStatus(chess.color,Vector2Int(m,y))
                        if status == 2 then
                            positions[Vector2Int(m,y)] = 2
                            break
                        elseif status == 1 then
                            break
                        end
                    end
                    break
                end
            end
        end
        if x > 0 and ((not isOnlyChessBetweenKings)) then   --不在最左列向左遍历
            for j = x - 1,0,-1 do 
                if temp:TargetPositionStatus(chess.color,Vector2Int(j,y)) == 0 then
                    positions[Vector2Int(j,y)] = 0
                else
                    --如果遍历到了棋子，需要再开启一个for循环，找有没有能吃的子
                    for m = j - 1,0,-1 do
                        status = temp:TargetPositionStatus(chess.color,Vector2Int(m,y))
                        if status == 2 then
                            positions[Vector2Int(m,y)] = 2
                            break
                        elseif status == 1 then
                            break
                        end
                    end
                    break
                end
            end
        end
        if y < 9 then   --不在最上行向上遍历
            for j = y + 1,9 do 
                if temp:TargetPositionStatus(chess.color,Vector2Int(x,j)) == 0 then
                    positions[Vector2Int(x,j)] = 0
                else
                    --如果遍历到了棋子，需要再开启一个for循环，找有没有能吃的子
                    for m = j + 1,9 do
                        status = temp:TargetPositionStatus(chess.color,Vector2Int(x,m))
                        if status == 2 then
                            positions[Vector2Int(x,m)] = 2
                            break
                        elseif status == 1 then
                            break
                        end
                    end
                    break
                end
            end
        end
        if y > 0 then   --不在最下行向下遍历
            for j = y - 1,0,-1 do 
                if temp:TargetPositionStatus(chess.color,Vector2Int(x,j)) == 0 then
                    positions[Vector2Int(x,j)] = 0
                else
                    --如果遍历到了棋子，需要再开启一个for循环，找有没有能吃的子
                    for m = j - 1,0,-1 do
                        status = temp:TargetPositionStatus(chess.color,Vector2Int(x,m))
                        if status == 2 then
                            positions[Vector2Int(x,m)] = 2
                            break
                        elseif status == 1 then
                            break
                        end
                    end
                    break
                end
            end
        end
    elseif chess.type == 6 then    --兵或卒
        --兵或卒未过河时只能向前，过河后可以向左右，始终不能退后
        --先校验是兵还是卒，兵和卒都执行自己的判断
        if temp.nowPlayerColor == 0 then
            --校验是否能向前走
            if (y + 1 < 10) then
                positions[Vector2Int(x,y + 1)] = temp:TargetPositionStatus(chess.color,Vector2Int(x,y + 1))
            end
            --如果过河了校验是否能向左右走
            if y > 4 and (not isOnlyChessBetweenKings) then   --过河
                if (x + 1 < 9) then
                    positions[Vector2Int(x + 1,y)] = temp:TargetPositionStatus(chess.color,Vector2Int(x + 1,y))
                end
                if (x - 1 > -1) then
                    positions[Vector2Int(x - 1,y)] = temp:TargetPositionStatus(chess.color,Vector2Int(x - 1,y))
                end
            end
        else
            --校验是否能向前走
            if (y - 1 > -1) then
                positions[Vector2Int(x,y - 1)] = temp:TargetPositionStatus(chess.color,Vector2Int(x,y - 1))
            end
            --如果过河了校验是否能向左右走
            if y < 5 and (not isOnlyChessBetweenKings) then   --过河
                if (x + 1 < 9) then
                    positions[Vector2Int(x + 1,y)] = temp:TargetPositionStatus(chess.color,Vector2Int(x + 1,y))
                end
                if (x - 1 > -1) then
                    positions[Vector2Int(x - 1,y)] = temp:TargetPositionStatus(chess.color,Vector2Int(x - 1,y))
                end
            end
        end            
    end

    return positions
end

--校验将帅是否面对面，传入其中将或帅的坐标
function module:IsTwoKingFacaToFace(kingPosition)
    local temp = self
    local chessTable = temp:GetChessTable()
    --根据传入的将帅坐标判断是上方将帅还是下方将帅，校验的方向不同（遍历的方式不同）
    --比如将帅在上方，每次坐标减1依次遍历坐标上是否有棋子
    --第一次遇到有棋子就必须返回（遇到第一个棋子就可以判断是否面对面了）
    --这个棋子是将帅返回true（将帅之间没有其他棋子）
    --不是将帅返回false（将帅要么不在同一列，要么中间有其他棋子）
    --如果遍历完都没有其他棋子，说明肯定不在同一列，所以遍历完成后返回一个false
    if kingPosition.y > 4 then
        for i = kingPosition.y - 1,0,-1 do
            local tempPos = Vector2Int(kingPosition.x,i)
            local tempStr = tempPos:ToString()
            if chessTable[tempStr] ~= nil then
                if chessTable[tempStr].type == 0 then
                    return true
                end
                return false
            end
        end
    elseif kingPosition.y < 5 then
        for i = kingPosition.y + 1,9 do
            local tempPos = Vector2Int(kingPosition.x,i)
            local tempStr = tempPos:ToString()
            if chessTable[tempStr] ~= nil then
                if chessTable[tempStr].type == 0 then
                    return true
                end
                return false
            end
        end
    end
    return false
end

--移动棋子位置
function module:MoveChess(nowPosition,targetPosition,beEatChessId)
    local temp = self
    --先尝试移动棋子，如果移动后仍然是将军状态，则取消移动
    temp.Data:MoveChess(nowPosition,targetPosition)
    --移动完成后更改当前下棋玩家，实现轮次下棋
    --这个移动可能是棋子移动，也可能是棋子吃子导致的移动
    --总之某个棋子移动后就可以进入下一轮了
    temp:SwitchNowPlayerColor()
    --每次切换完玩家后进入下一轮之前都需要判断是否将军
    if temp:IsKingWillBeKill() then
        --发送将军的通知
        GameFacade:GetInstance():SendNotification(NotificationNames.KING_WILL_BE_KILL)
    end
    --移动棋子完成后更新上一个棋子位置（如果是吃子时的移动棋子，id是有值的，如果只是移动棋子到空位置，id为nil）
    temp:SaveLastChessInfo(nowPosition,targetPosition,beEatChessId)
end

--吃子时触发的方法
function module:EatChess(nowPosition,targetPosition)
    local temp = self
    --先将被吃棋子的id存起来
    local id = temp.Data:GetChess(targetPosition).id
    temp.Data:RemoveChess(targetPosition)
    temp:MoveChess(nowPosition,targetPosition,id)
end

--棋子移动信息得保存和读取，这里只保存两步，如果保存更多，可以使用json文件进行保存读取
--添加一次移动的信息，只存储两次移动信息，再往前的移动信息会被顶掉
function module:SaveLastChessInfo(startPosition,endPosition,beEatChessId)
    local temp = self
    --将信息封装为一个表
    local info = {}
    info.startPosition = startPosition
    info.endPosition = endPosition
    if beEatChessId then
        info.beEatChessId = beEatChessId
    else
        info.beEatChessId = -1
    end
    --将表存储起来
    temp.moveInfo.lastLastMoveInfo = temp.moveInfo.lastMoveInfo
    temp.moveInfo.lastMoveInfo = info
end
--得到上一次的移动信息，最多只能得到两次，再得就全是nil了
function module:LoadLastChessInfo()
    local temp = self
    --读取信息
    local targetPosition = temp.moveInfo.lastMoveInfo.endPosition
    local nowPosition = temp.moveInfo.lastMoveInfo.startPosition
    local id = temp.moveInfo.lastMoveInfo.beEatChessId
    --用上上次的移动信息顶掉上次的移动信息
    temp.moveInfo.lastMoveInfo.startPosition = temp.moveInfo.lastLastMoveInfo.startPosition
    temp.moveInfo.lastMoveInfo.endPosition = temp.moveInfo.lastLastMoveInfo.endPosition
    temp.moveInfo.lastMoveInfo.beEatChessId = temp.moveInfo.lastLastMoveInfo.beEatChessId
    --构建一个临时变量作为上上次移动信息的默认值，存储起来
    local info = {}
    info.startPosition = nil
    info.endPosition = nil
    info.beEatChessId = -1
    temp.moveInfo.lastLastMoveInfo = info
    --将值返回出去
    return targetPosition,nowPosition,id
end

--撤销操作（悔棋）时的数据更新，同时会返回坐标，由命令转发给mediator作数据更新
function module:Undo()
    local temp = self
    --将上一次移动的信息读取出来
    local targetPosition,nowPosition,id = temp:LoadLastChessInfo()
    --更新chess表中的数据
    local isMoved = temp.Data:MoveChess(targetPosition,nowPosition)
    if id ~= -1 then
        temp.Data:AddChess(targetPosition,id)
    end
    --清空上一次移动信息
    temp.lastMoveInfo = {}
    temp.lastMoveInfo.beEatChessId = -1
    --切换当前玩家
    if isMoved then
        temp:SwitchNowPlayerColor()
    end
    --返回
    return nowPosition,targetPosition,id
end

--判断当前touch的棋子是否是当前玩家的棋子
--这个函数配合切换玩家的函数实现交替下棋
function module:IsNowPlayerChessTouched(position)
    local temp = self
    local chess = temp.Data:GetChess(position)
    if chess.color == temp.nowPlayerColor then
        return true
    end
    return false
end

--切换玩家的颜色
function module:SwitchNowPlayerColor()
    local temp = self
    --更改当前玩家的颜色数字
    temp.nowPlayerColor = (temp.nowPlayerColor + 1) % 2
end

--判断是否将军
function module:IsKingWillBeKill()
    local temp = self
    --取出当前的玩家对应的将帅位置，这个方法在切换完玩家后调用，因此判断当前玩家的将帅是否可能被吃
    local kingPosition = temp:GetKingPosition(temp.nowPlayerColor)
    --取出x值和y值备用
    local x = kingPosition.x
    local y = kingPosition.y
    --用于暂存用于判断的临时位置
    local tempPos = nil
    --用于暂存用于判断的棋子
    local tempChess = nil

    --只有可能被车、马、炮、兵或卒将军，一一作出判断
    --检验周围四个棋子，是否是兵或卒、车，左右一定不会出边界，上下有可能出边界
    tempPos = Vector2Int(x - 1,y)       --左侧
    tempChess = temp:GetChess(tempPos)
    if tempChess then
        --对面车
        if tempChess.type == 4 and tempChess.color ~= temp.nowPlayerColor then
            return true
        --对面卒
        elseif tempChess.type == 6 and tempChess.color ~= temp.nowPlayerColor then
            return true
        end
    end
    tempPos = Vector2Int(x + 1,y)       --右侧
    tempChess = temp:GetChess(tempPos)
    if tempChess then
        --对面车
        if tempChess.type == 4 and tempChess.color ~= temp.nowPlayerColor then
            return true
        --对面卒
        elseif tempChess.type == 6 and tempChess.color ~= temp.nowPlayerColor then
            return true
        end
    end
    if y + 1 < 10 then                  --上方
        tempPos = Vector2Int(x,y + 1)       
        tempChess = temp:GetChess(tempPos)
        if tempChess then
            --对面车
            if tempChess.type == 4 and tempChess.color ~= temp.nowPlayerColor then
                return true
            --对面卒
            elseif tempChess.type == 6 and tempChess.color ~= temp.nowPlayerColor and tempChess.color == 1 then
                return true
            end
        end
    end
    if y - 1 > -1 then                  --下方
        tempPos = Vector2Int(x,y - 1)       
        tempChess = temp:GetChess(tempPos)
        if tempChess then
            --对面车
            if tempChess.type == 4 and tempChess.color ~= temp.nowPlayerColor then
                return true
            --对面兵
            elseif tempChess.type == 6 and tempChess.color ~= temp.nowPlayerColor and tempChess.color == 0 then
                return true
            end
        end
    end
    --检验是否被马吃，先检验范围，再检验蹩马腿的可能，不蹩马腿的情况下再看是否有马
    if y - 1 > -1 then                  --下方的四个马可能位置
        tempPos = Vector2Int(x - 1,y - 1)   --左下角马腿位
        tempChess = temp:GetChess(tempPos)
        if not tempChess then               --没有马腿
            tempPos = Vector2Int(x - 2,y - 1)  
            tempChess = temp:GetChess(tempPos)
            if tempChess and tempChess.type == 3 and tempChess.color ~= temp.nowPlayerColor then
                return true
            elseif y - 2 > -1 then
                tempPos = Vector2Int(x - 1,y - 2)
                tempChess = temp:GetChess(tempPos)
                if tempChess and tempChess.type == 3 and tempChess.color ~= temp.nowPlayerColor then
                    return true
                end
            end
        end
        tempPos = Vector2Int(x + 1,y - 1)   --右下角马腿位
        tempChess = temp:GetChess(tempPos)
        if not tempChess then               --没有马腿
            tempPos = Vector2Int(x + 2,y - 1)  
            tempChess = temp:GetChess(tempPos)
            if tempChess and tempChess.type == 3 and tempChess.color ~= temp.nowPlayerColor then
                return true
            elseif y - 2 > -1 then
                tempPos = Vector2Int(x + 1,y - 2)
                tempChess = temp:GetChess(tempPos)
                if tempChess and tempChess.type == 3 and tempChess.color ~= temp.nowPlayerColor then
                    return true
                end
            end
        end
    end
    if y + 1 < 10 then                  --上方的四个马可能位置
        tempPos = Vector2Int(x - 1,y + 1)   --左上角马腿位
        tempChess = temp:GetChess(tempPos)
        if not tempChess then               --没有马腿
            tempPos = Vector2Int(x - 2,y + 1)  
            tempChess = temp:GetChess(tempPos)
            if tempChess and tempChess.type == 3 and tempChess.color ~= temp.nowPlayerColor then
                return true
            elseif y + 2 < 10 then
                tempPos = Vector2Int(x - 1,y + 2)
                tempChess = temp:GetChess(tempPos)
                if tempChess and tempChess.type == 3 and tempChess.color ~= temp.nowPlayerColor then
                    return true
                end
            end
        end
        tempPos = Vector2Int(x + 1,y + 1)   --右上角马腿位
        tempChess = temp:GetChess(tempPos)
        if not tempChess then               --没有马腿
            tempPos = Vector2Int(x + 2,y + 1)  
            tempChess = temp:GetChess(tempPos)
            if tempChess and tempChess.type == 3 and tempChess.color ~= temp.nowPlayerColor then
                return true
            elseif y + 2 < 10 then
                tempPos = Vector2Int(x + 1,y + 2)
                tempChess = temp:GetChess(tempPos)
                if tempChess and tempChess.type == 3 and tempChess.color ~= temp.nowPlayerColor then
                    return true
                end
            end
        end
    end
    --向上下左右遍历，遇到的第一个棋子判断是否是对方车，遇到的第二个棋子判断是否是对方炮
    local index = 1
    for i = x - 1,0,-1 do               --向左遍历
        tempPos = Vector2Int(i,y)
        tempChess = temp:GetChess(tempPos)
        --当前棋子不为空时做如下判断
        --index为1时是遇到的第一个棋子，这个棋子是对方车返回true，否则index设置为2代表接下来是第二个棋子
        --index为2时遇到的是第二个棋子，这个棋子是对方炮返回true，否则结束循环
        if tempChess then
            if tempChess.type == 4 and tempChess.color ~= temp.nowPlayerColor and index == 1 then
                return true
            else
                if tempChess.type == 5 and tempChess.color ~= temp.nowPlayerColor and index == 2 then
                    return true
                elseif index == 2 then
                    break
                end
                index = 2
            end
        end
    end
    index = 1
    for i = x + 1,8 do                  --向右遍历
        tempPos = Vector2Int(i,y)
        tempChess = temp:GetChess(tempPos)
        --当前棋子不为空时做如下判断
        --index为1时是遇到的第一个棋子，这个棋子是对方车返回true，否则index设置为2代表接下来是第二个棋子
        --index为2时遇到的是第二个棋子，这个棋子是对方炮返回true，否则结束循环
        if tempChess then
            if tempChess.type == 4 and tempChess.color ~= temp.nowPlayerColor and index == 1 then
                return true
            else
                if tempChess.type == 5 and tempChess.color ~= temp.nowPlayerColor and index == 2 then
                    return true
                elseif index == 2 then
                    break
                end
                index = 2
            end
        end
    end
    index = 1
    if y + 1 < 10 then                  --向上判断
        for i = y + 1,9 do
            tempPos = Vector2Int(x,i)
            tempChess = temp:GetChess(tempPos)
            --当前棋子不为空时做如下判断
            --index为1时是遇到的第一个棋子，这个棋子是对方车返回true，否则index设置为2代表接下来是第二个棋子
            --index为2时遇到的是第二个棋子，这个棋子是对方炮返回true，否则结束循环
            if tempChess then
                if tempChess.type == 4 and tempChess.color ~= temp.nowPlayerColor and index == 1 then
                    return true
                else
                    if tempChess.type == 5 and tempChess.color ~= temp.nowPlayerColor and index == 2 then
                        return true
                    elseif index == 2 then
                        break
                    end
                    index = 2
                end
            end
        end
    end
    index = 1
    if y - 1 > -1 then                  --向下判断
        for i = y - 1,0,-1 do
            tempPos = Vector2Int(x,i)
            tempChess = temp:GetChess(tempPos)
            --当前棋子不为空时做如下判断
            --index为1时是遇到的第一个棋子，这个棋子是对方车返回true，否则index设置为2代表接下来是第二个棋子
            --index为2时遇到的是第二个棋子，这个棋子是对方炮返回true，否则结束循环
            if tempChess then
                if tempChess.type == 4 and tempChess.color ~= temp.nowPlayerColor and index == 1 then
                    return true
                else
                    if tempChess.type == 5 and tempChess.color ~= temp.nowPlayerColor and index == 2 then
                        return true
                    elseif index == 2 then
                        break
                    end
                    index = 2
                end
            end
        end
    end

    --如果上述情况都判断完了，则返回false
    return false
end

--获取将帅的位置
function module:GetKingPosition(kingColor)
    local temp = self
    if kingColor == 0 then
        return temp.Data.kingPosition["Shuai"]
    elseif kingColor == 1 then
        return temp.Data.kingPosition["Jiang"]
    else
        error("wrong kingColor in function GetKingPosition Class ChessPieceProxy")
    end
end