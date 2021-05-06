KingWillBeKillCommand = class("KingWillBeKillCommand",PureMVC.SimpleCommand)

local module = KingWillBeKillCommand

function module:Execute(notification)
    AudioSourceManager:PlaySound(SoundNames.JIANG_JUN)
end