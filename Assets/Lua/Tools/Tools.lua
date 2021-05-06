--启动Tools文件夹中的各种工具脚本
Json = require "JsonUtility"

--所有自定义的工具方法存储在一个Tools表中
local module = class("Tools")

--在Json中再封装一个方法，用于读取棋子位置的json文件，存储为一个表，方便使用
function module:LoadJsonFile(jsonFileName)
    local txt = AssetBundleManager:LoadRes("json",jsonFileName)
    local jsonList = Json.decode(txt.text)
    
    local temp = {}
    for _,v in pairs(jsonList) do
        temp[v.id] = v
        --print(v.positionX,v.positionY,v.chessType,v.playerType)
    end

    return temp
end

--提供将代表在棋盘上几行几列的position转化为相对父物体下的坐标的方法
function module:PositionCastToLocal(position)
    local result = Vector3.zero
    result.x = -640 + position.x * 159.5375
    result.y = -685 + position.y * 159.13333
    if position.y > 4 then
        result.y = result.y + 13.9
    end
    return result
end

return module