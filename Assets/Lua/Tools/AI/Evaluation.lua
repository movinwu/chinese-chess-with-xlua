Evaluation = class("Evaluation")

local module = Evaluation

--提供一个方法进行棋盘评估（为棋盘打分，分值代表这个棋盘上双方的优劣，0-势均力敌，>0-红方优势，<0黑方优势）
function module:Evaluate(chessTable) 

    --先遍历一遍数组，为chess表添加元素，其实也是重置表中元素
    for position,chess in pairs(chessTable) do 
        --将计算得到的保护值（protexted）、威胁值（threated）、机动值（mobility）等信息存储到chess表中
        --因此先为chess表添加这几个元素，给定初值0，在使用这几个值计算总分时就不用校验空值了
        chess.protexted = 0
        chess.threated = 0
        chess.mobility = 0
    end

    --遍历棋子，扫描得到所有棋子的关联位置，并根据关联位置的信息做对应的处理
    for position,chess in pairs(chessTable) do
        --得到可移动位置的数组
        local positions = self:GetRelatePosition(chessTable,position)
        --遍历数组，根据可移动位置的棋子类型作出反应
        for position, type in pairs(positions) do
            --先转存
            local targetChess = chessTable[position]
            if type == 0 then           --没有棋子
                chess.mobility = chess.mobility + 1
            elseif type == 1 then       --自家棋子
                targetChess.protexted = targetChess.protexted + 1
            elseif type == 2 then       --对家棋子
                targetChess.threated = targetChess.threated + 1
                chess.mobility = chess.mobility + 1
            end
        end
    end

    --再次遍历棋子，分别计算红黑棋子的总分值
    local blackScore = 0
    local redScore = 0
    for _, chess in pairs(chessTable) do
        if chess.color == 0 then
            redScore = redScore + chess.baseValue + (chess.mobility + chess.protexted - chess.threated) * chess.baseFlexValue
        else
            blackScore = blackScore + chess.baseValue + (chess.mobility + chess.protexted - chess.threated) * chess.baseFlexValue
        end
    end

    --返回计算得到的分数
    return redScore - blackScore
end

--棋子计算可移动位置的方法，根据棋子类型进行具体的计算，返回存储所有可移动位置的表
function module:GetRelatePosition(chessTable,position)
    local temp = self

    local positions = {}

    --取出当前棋子的位置的坐标
    local x = position.x
    local y = position.y
    local chess = chessTable[position]

    --使用bool值记录当前棋子是否是将帅之间的唯一棋子，是的话当前棋子是不能左右移动的
    local isOnlyChessBetweenKings = false
    --计算当前棋子是否是将帅之间的唯一棋子
    local redKingPos = nil
    local blackKingPos = nil
    for position, chess in pairs(chessTable) do
        if chess.id == 0 then
            blackKingPos = position
        elseif chess.id == 1 then
            redKingPos = position
        end
    end
    local countChess = 0        --记录将帅之间的棋子个数
    if redKingPos.x == blackKingPos.x and x == redKingPos.x and --x值相等
        (redKingPos.y - y) * (blackKingPos.y - y) < 0 then      --y值在将帅之间
        local step = 1 - PlayerInfo.color * 2
        for i = redKingPos.y,blackKingPos.y,step do
            if chessTable[Vector2Int(x,i)] then
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
        if chess.color == PlayerInfo.color then
            up = 3
            down = -1
        else
            up = 10
            down = 6
        end 
        --将帅往上下左右各移动一格，依次判断是否可以移动，将可移动的位置添加到结果表中
        --只可能往前后左右移动，同时校验是否已有自家棋子，如果有不能移动以及左右移动后将帅是否面对面
        if (y + 1 < up) then   --向上
            positions[Vector2Int(x,y + 1)] = temp:TargetPositionStatus(chessTable,position,Vector2Int(x,y + 1))
        end
        if (y - 1 > down) then  --向下
            positions[Vector2Int(x,y - 1)] = temp:TargetPositionStatus(chessTable,position,Vector2Int(x,y - 1))
        end
        if (x - 1 > left) then   --向左
            --左右移动时除了移动范围判断，还要有将帅是否面对面的判断，移动后没有面对面才能移动
            if not temp:IsTwoKingFacaToFace(chessTable,Vector2Int(position.x - 1,y)) then
                positions[Vector2Int(x - 1,y)] = temp:TargetPositionStatus(chessTable,position,Vector2Int(x - 1,y))
            end
        end
        if (x + 1 < right) then   --向右
            if not temp:IsTwoKingFacaToFace(chessTable,Vector2Int(position.x + 1,y)) then
                positions[Vector2Int(x + 1,y)] = temp:TargetPositionStatus(chessTable,position,Vector2Int(x + 1,y))
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
        if chess.color == PlayerInfo.color then
            up = 3
            down = -1
        else
            up = 10
            down = 6
        end 
        --士往左上、右上、左下、右下移动一格，需要注意判断是否超出移动范围，和将帅的判断类似
        if (x + 1 < right) and (y + 1 < up) then   --右上
            positions[Vector2Int(x + 1,y + 1)] = temp:TargetPositionStatus(chessTable,position,Vector2Int(x + 1,y + 1))
        end
        if (x + 1 < right) and (y - 1 > down) then      --右下
            positions[Vector2Int(x + 1,y - 1)] = temp:TargetPositionStatus(chessTable,position,Vector2Int(x + 1,y - 1))
        end
        if (x - 1 > left) and (y + 1 < up) then       --左上
            positions[Vector2Int(x - 1,y + 1)] = temp:TargetPositionStatus(chessTable,position,Vector2Int(x - 1,y + 1))
        end
        if (x - 1 > left) and (y - 1 > down) then       --左下
            positions[Vector2Int(x - 1,y - 1)] = temp:TargetPositionStatus(chessTable,position,Vector2Int(x - 1,y - 1))
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
        if chess.color == PlayerInfo.color then
            up = 5
            down = -1
        else
            up = 10
            down = 4
        end 
        if (x + 2 < right) and (y + 2 < up) and not chessTable[Vector2Int(x + 1,y + 1)] then   --右上
            positions[Vector2Int(x + 2,y + 2)] = temp:TargetPositionStatus(chessTable,position,Vector2Int(x + 2,y + 2))
        end
        if (x + 2 < right) and (y - 2 > down) and not chessTable[Vector2Int(x + 1,y - 1)] then      --右下
            positions[Vector2Int(x + 2,y - 2)] = temp:TargetPositionStatus(chessTable,position,Vector2Int(x + 2,y - 2))
        end
        if (x - 2 > left) and (y + 2 < up) and not chessTable[Vector2Int(x - 1,y + 1)] then       --左上
            positions[Vector2Int(x - 2,y + 2)] = temp:TargetPositionStatus(chessTable,position,Vector2Int(x - 2,y + 2))
        end
        if (x - 2 > left) and (y - 2> down) and not chessTable[Vector2Int(x - 1,y - 1)] then       --左下
            positions[Vector2Int(x - 2,y - 2)] = temp:TargetPositionStatus(chessTable,position,Vector2Int(x - 2,y - 2))
        end
    elseif chess.type == 3 then    --马
        --如果是将帅之间的唯一棋子的话，不能移动
        if isOnlyChessBetweenKings then
            return positions
        end
        --和之前的校验类似，只是马的校验有8个位置，且需要校验是否蹩馬腿
        --外层校验是否蹩馬腿，内层校验可能位置是否在棋盘内且是否合规
        if chessTable[Vector2Int(x + 1,y)] == nil then --右侧是否蹩馬腿
            if (x + 2 < 9) and (y + 1 < 10) then
                positions[Vector2Int(x + 2,y + 1)] = temp:TargetPositionStatus(chessTable,position,Vector2Int(x + 2,y + 1))
            end 
            if (x + 2 < 9) and (y - 1 > -1) then
                positions[Vector2Int(x + 2,y - 1)] = temp:TargetPositionStatus(chessTable,position,Vector2Int(x + 2,y - 1))
            end 
        end
        if chessTable[Vector2Int(x - 1,y)] == nil then --左侧是否蹩馬腿
            if (x - 2 > -1) and (y + 1 < 10) then
                positions[Vector2Int(x - 2,y + 1)] = temp:TargetPositionStatus(chessTable,position,Vector2Int(x - 2,y + 1))
            end 
            if (x - 2 > -1) and (y - 1 > -1) then
                positions[Vector2Int(x - 2,y - 1)] = temp:TargetPositionStatus(chessTable,position,Vector2Int(x - 2,y - 1))
            end 
        end
        if chessTable[Vector2Int(x,y + 1)] == nil then --上方是否蹩馬腿
            if (x + 1 < 9) and (y + 2 < 10) then
                positions[Vector2Int(x + 1,y + 2)] = temp:TargetPositionStatus(chessTable,position,Vector2Int(x + 1,y + 2))
            end 
            if (x - 1 > -1) and (y + 2 < 10) then
                positions[Vector2Int(x - 1,y + 2)] = temp:TargetPositionStatus(chessTable,position,Vector2Int(x - 1,y + 2))
            end 
        end
        if chessTable[Vector2Int(x,y - 1)] == nil then --下方是否蹩馬腿
            if (x + 1 < 9) and (y - 2 > -1) then
                positions[Vector2Int(x + 1,y - 2)] = temp:TargetPositionStatus(chessTable,position,Vector2Int(x + 1,y - 2))
            end 
            if (x - 1 > -1) and (y - 2 > -1) then
                positions[Vector2Int(x - 1,y - 2)] = temp:TargetPositionStatus(chessTable,position,Vector2Int(x - 1,y - 2))
            end 
        end
    elseif chess.type == 4 then    --车
        local status = nil
        --车的可走位置需要向上下左右依次遍历，直到遇到其他棋子或者边界停下
        if x < 8 and (not isOnlyChessBetweenKings) then   --不在最右列向右遍历
            for j = x + 1,8 do 
                status = temp:TargetPositionStatus(chessTable,position,Vector2Int(j,y))
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
                status = temp:TargetPositionStatus(chessTable,position,Vector2Int(j,y))
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
                status = temp:TargetPositionStatus(chessTable,position,Vector2Int(x,j))
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
                status = temp:TargetPositionStatus(chessTable,position,Vector2Int(x,j))
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
                if temp:TargetPositionStatus(chessTable,position,Vector2Int(j,y)) == 0 then
                    positions[Vector2Int(j,y)] = 0
                else
                    --如果遍历到了棋子，需要再开启一个for循环，找有没有能吃的子
                    for m = j + 1,8 do
                        status = temp:TargetPositionStatus(chessTable,position,Vector2Int(m,y))
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
                if temp:TargetPositionStatus(chessTable,position,Vector2Int(j,y)) == 0 then
                    positions[Vector2Int(j,y)] = 0
                else
                    --如果遍历到了棋子，需要再开启一个for循环，找有没有能吃的子
                    for m = j - 1,0,-1 do
                        status = temp:TargetPositionStatus(chessTable,position,Vector2Int(m,y))
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
                if temp:TargetPositionStatus(chessTable,position,Vector2Int(x,j)) == 0 then
                    positions[Vector2Int(x,j)] = 0
                else
                    --如果遍历到了棋子，需要再开启一个for循环，找有没有能吃的子
                    for m = j + 1,9 do
                        status = temp:TargetPositionStatus(chessTable,position,Vector2Int(x,m))
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
                if temp:TargetPositionStatus(chessTable,position,Vector2Int(x,j)) == 0 then
                    positions[Vector2Int(x,j)] = 0
                else
                    --如果遍历到了棋子，需要再开启一个for循环，找有没有能吃的子
                    for m = j - 1,0,-1 do
                        status = temp:TargetPositionStatus(chessTable,position,Vector2Int(x,m))
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
        if chess.color == PlayerInfo.color then
            --校验是否能向前走
            if (y + 1 < 10) then
                positions[Vector2Int(x,y + 1)] = temp:TargetPositionStatus(chessTable,position,Vector2Int(x,y + 1))
            end
            --如果过河了校验是否能向左右走
            if y > 4 and (not isOnlyChessBetweenKings) then   --过河
                if (x + 1 < 9) then
                    positions[Vector2Int(x + 1,y)] = temp:TargetPositionStatus(chessTable,position,Vector2Int(x + 1,y))
                end
                if (x - 1 > -1) then
                    positions[Vector2Int(x - 1,y)] = temp:TargetPositionStatus(chessTable,position,Vector2Int(x - 1,y))
                end
            end
        else
            --校验是否能向前走
            if (y - 1 > -1) then
                positions[Vector2Int(x,y - 1)] = temp:TargetPositionStatus(chessTable,position,Vector2Int(x,y - 1))
            end
            --如果过河了校验是否能向左右走
            if y < 5 and (not isOnlyChessBetweenKings) then   --过河
                if (x + 1 < 9) then
                    positions[Vector2Int(x + 1,y)] = temp:TargetPositionStatus(chessTable,position,Vector2Int(x + 1,y))
                end
                if (x - 1 > -1) then
                    positions[Vector2Int(x - 1,y)] = temp:TargetPositionStatus(chessTable,position,Vector2Int(x - 1,y))
                end
            end
        end            
    end

    return positions
end

--校验将帅是否面对面，传入其中将或帅的坐标
function module:IsTwoKingFacaToFace(chessTable,kingPosition)
    local temp = self
    --根据传入的将帅坐标判断是上方将帅还是下方将帅，校验的方向不同（遍历的方式不同）
    --比如将帅在上方，每次坐标减1依次遍历坐标上是否有棋子
    --第一次遇到有棋子就必须返回（遇到第一个棋子就可以判断是否面对面了）
    --这个棋子是将帅返回true（将帅之间没有其他棋子）
    --不是将帅返回false（将帅要么不在同一列，要么中间有其他棋子）
    --如果遍历完都没有其他棋子，说明肯定不在同一列，所以遍历完成后返回一个false
    if kingPosition.y > 4 then
        for i = kingPosition.y - 1,0 do
            local tempPos = Vector2Int(kingPosition.x,i)
            if chessTable[tempPos] ~= nil then
                if chessTable[tempPos].type == 0 then
                    return true
                end
                return false
            end
        end
    elseif kingPosition.y < 5 then
        for i = kingPosition.y + 1,9 do
            local tempPos = Vector2Int(kingPosition.x,i)
            if chessTable[tempPos] ~= nil then
                if chessTable[tempPos].type == 0 then
                    return true
                end
                return false
            end
        end
    end
    return false
end

--根据判断目标位置棋子状态，0-没有棋子，1-自家棋子，2-对家棋子，3-棋子自身
--position：当前棋子位置，targetPos：目标位置
function module:TargetPositionStatus(chessTable,position,targetPosition)
    local temp = self
    
    local chess = assert(chessTable[position])
    local targetChess = assert(chessTable[targetPosition])
    if not targetChess then
        return 0
    else
        return chess.color == targetChess.color and 1 or 2
    end 
end