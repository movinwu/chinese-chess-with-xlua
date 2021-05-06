--[[require "LevelOptionMediator"
require "MainMediator"
require "ModeOptionMediator"
require "NetGameMediator"
require "SingleGameMediator"
require "ChessPieceProxy"]]

ShowPanelCommand = class("ShowPanelCommand",PureMVC.SimpleCommand)

function ShowPanelCommand:Execute(notification)
    if notification.Body == PanelNames.MAIN then
        local mediator = nil
        if not GameFacade:GetInstance():HasMediator(MainMediator.NAME) then
            mediator = MainMediator.new()
            GameFacade:GetInstance():RegisterMediator(mediator)
        else
            mediator = GameFacade:GetInstance():RetrieveMediator(MainMediator.NAME)
        end
        mediator:ShowMe()
        --播放主bgm
        AudioSourceManager:PlaySound(SoundNames.MAIN_BGM)
        --初始化玩家信息
        PlayerInfo:Init()
    elseif notification.Body == PanelNames.LEVEL_OPTION then
        local mediator = nil
        if not GameFacade:GetInstance():HasMediator(LevelOptionMediator.NAME) then
            mediator = LevelOptionMediator.new()
            GameFacade:GetInstance():RegisterMediator(mediator)
        else
            mediator = GameFacade:GetInstance():RetrieveMediator(LevelOptionMediator.NAME)
        end
        mediator:ShowMe()
        --播放主bgm
        AudioSourceManager:PlaySound(SoundNames.MAIN_BGM)
    elseif notification.Body == PanelNames.MODE_OPTION then
        local mediator = nil
        if not GameFacade:GetInstance():HasMediator(ModeOptionMediator.NAME) then
            mediator = ModeOptionMediator.new()
            GameFacade:GetInstance():RegisterMediator(mediator)
        else
            mediator = GameFacade:GetInstance():RetrieveMediator(ModeOptionMediator.NAME)
        end
        mediator:ShowMe()
        --播放主bgm
        AudioSourceManager:PlaySound(SoundNames.MAIN_BGM)
    elseif notification.Body == PanelNames.NET_GAME then
        local mediator = nil
        if not GameFacade:GetInstance():HasMediator(NetGameMediator.NAME) then
            mediator = NetGameMediator.new()
            GameFacade:GetInstance():RegisterMediator(mediator)
        else
            mediator = GameFacade:GetInstance():RetrieveMediator(NetGameMediator.NAME)
        end
        mediator:ShowMe()
        --播放游戏bgm
        AudioSourceManager:PlaySound(SoundNames.GAME_BGM)
        --播放开始游戏音效
        AudioSourceManager:PlaySound(SoundNames.START)
    elseif notification.Body == PanelNames.SINGLE_GAME then
        local mediator = nil
        if not GameFacade:GetInstance():HasMediator(SingleGameMediator.NAME) then
            mediator = SingleGameMediator.new()
            GameFacade:GetInstance():RegisterMediator(mediator)
        else
            mediator = GameFacade:GetInstance():RetrieveMediator(SingleGameMediator.NAME)
        end
        mediator:ShowMe()
        --先实例化棋盘，再实例化棋盘数据，因为在棋盘的实例化过程中会使用到棋盘数据
        if not GameFacade:GetInstance():HasProxy(ChessPieceProxy.NAME) then
            GameFacade:GetInstance():RegisterProxy(ChessPieceProxy.new())
        end
        --播放游戏bgm
        AudioSourceManager:PlaySound(SoundNames.GAME_BGM)
        --播放开始游戏音效
        AudioSourceManager:PlaySound(SoundNames.START)
    else
        error("notification "..notification.Name.."is illegle")
    end
end