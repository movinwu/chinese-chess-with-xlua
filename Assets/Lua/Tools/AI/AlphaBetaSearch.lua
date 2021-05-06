AlphaBetaSearch = class("AlphaBetaSearch")

local module = AlphaBetaSearch

function module:ctor(chessTable)
    --AI持有的棋子颜色
    self.color = PlayerInfo.color == 0 and 1 or 0
    --将棋盘表的信息存储到对象中，不要存储到类（元表）中
    self.chessTable = chessTable
    --声明一个空表存储已经移动的信息，这个表当作list使用
    self.moveInfo = {}
    --声明一个空表存储可移动的信息列表，键走棋起始位置的封装表，值为子走棋方法的封装表，得到的评价值计算出来后也一并封装到里面
    --这个表和上一个表需要组合使用，上一个表中存储的元素作为这个表中嵌套子表的键，上个表中1号位元素就是最后的棋子移动
    self.moveSteps = {}
    --下面的元素作为指针使用，指示最大最小算法遍历到的元素位置，而moveInfo表说明了遍历的深度和节点，配合使用实现模拟电脑下棋
    self.index = 0
    --当前的移动信息
    self.nowMoveInfo = nil
    --当前搜索的深度值
    self.nowDepth = -1
end

--最大最小算法
function module:MinMax(depth)
    return self:Max(depth)
end

function module:Max(depth)
    self.nowDepth = depth
    local best = -65526
    if depth <= 0 then
        return Evaluation:Evaluate(self.chessTable)
    end
    local score = 0
    while self.MovesLeft() do 
        self:MakeNextMove()
        score = self:Min(depth - 1)
        self:UnmakeMove()
        if score > best then
            best = score
        end
    end
    return best
end

function module:Min(depth)
    local best = 65526
    self.nowDepth = depth
    if depth <= 0 then
        return Evaluation:Evaluate(self.chessTable)
    end
    local score = 0
    while self.MovesLeft() do 
        self:MakeNextMove()
        score = self:Max(depth - 1)
        self:UnmakeMove()
        if score < best then
            best = score
        end
    end
    return best
end

--这个方法计算哪里可以下棋，返回bool值代表是否可以继续下棋
--下棋的过程需要将棋盘进行修改，并将下棋的步骤一并存储起来，评价值也一并存储在封装的表里
--下棋信息封装时，如果封装信息中有评价值说明计算过了，如果没有说明还未计算
function module:MovesLeft()
    --找到存储和读取移动信息的位置
    local saveLoadPosition = self.moveSteps
    for _,moveInfomation in pairs(self.moveInfo) do
        saveLoadPosition = saveLoadPosition[moveInfomation]
    end
    --校验如果index为0，说明还没有开始遍历，就要先生成并存储可能做的移动信息
    if self.index == 0 then
        for chessPosition, chess in pairs(self.chessTable) do
            local color = self.nowDepth % 2
            if chess.color == color then
                local positions = Evaluation:GetRelatePosition(self.chessTable,chessPosition)
                --id用于存储值时使用，也便于取值
                local id = 1
                for targetPosition, type in pairs(positions) do
                    if type ~= 1 and type ~= 3 then
                        local info = {}
                        info.id = id
                        id = id + 1
                        info.chessPosition = chessPosition
                        info.targetPosition = targetPosition
                        info.chess = self.chessTable[chessPosition]
                        info.tartgetChess = self.chessTable[targetPosition]
                        --存储起来
                        saveLoadPosition[info] = {}
                    end
                end
            end
        end
    --index的值已经大于数组长度，那么说明已经遍历完了，重置index返回false就可以了
    elseif self.index == #saveLoadPosition then
        self.index = 0
        return false
    end
    --取出当前指针指向的值
    for moveInfo,_ in pairs(saveLoadPosition) do
        if moveInfo.id == index then
            self.nowMoveInfo = moveInfo
            self.index = self.index + 1
        end
    end
    return true
end

--下棋和撤销下棋方法没有校验，在外部不要随意调用，使用时也要注意使用顺序，和MovesLeft方法配合一起使用
--下一步棋
function module:MakeNextMove()
    self.index = self.index + 1
    local moveInfo = self.nowMoveInfo
    --存储做出的移动
    table.insert(self.moveInfo,moveInfo)  

    --更改棋盘表的信息
    self.chessTable[moveInfo.targetPosition] = moveInfo.chess
    self.chessTable[moveInfo.chessPosition] = nil
end

--撤销一步下棋
function module:UnmakeMove()
    --从移动信息表中读取最后的移动的信息
    local info = self.moveInfo[#self.moveInfo]
    --校验是否取到了移动信息
    if not info then
        return false
    end
    --还原移动
    self.chessTable[info.chessPosition] = self.chessTable[info.targetPosition]
    self.chessTable[info.targetPosition] = info.targetChess     --不用校验targetChess是否为nil
    --从移动信息表中删去最后一个元素
    table.remove(self.moveInfo)
    --返回成功撤销移动的信息
    return true
end
