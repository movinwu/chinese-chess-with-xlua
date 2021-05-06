--所有背景音乐及音效管理脚本
--提供了根据声音名称播放声音的函数、改变背景音量或者音效音量的函数、停止背景音播放的函数（没有必要提供停止音效播放的函数）

AudioSourceManager = class("AudioSourceManager")
--将所有播放的音效存储到一个表中，键为声音名，值为播放组件
AudioSourceManager.clipSources = {}
--背景音单独存储，只持有一个背景音组件
AudioSourceManager.bgmSource = nil
--挂载播放声音组件的游戏物体
AudioSourceManager.audioObject = nil
--背景音音量和音效音量
AudioSourceManager.BgmVolume = 1
AudioSourceManager.SoundVolume = 1

--播放声音的函数，根据声音文件名称播放声音（不论是背景音还是音效）
function AudioSourceManager:PlaySound(soundName) 
    --校验播放音效的空物体是否存在
    if AudioSourceManager.audioObject == nil then
        self.audioObject = GameObject("AudioObject")
        GameObject.DontDestroyOnLoad(self.audioObject)
    end

    --校验是否是背景音，如果是背景音处理完后直接返回
    if soundName == SoundNames.GAME_BGM or soundName == SoundNames.MAIN_BGM then
        --校验背景音组件是否挂载，没有就挂载一下
        if not self.bgmSource then
            self.bgmSource = self.audioObject:AddComponent(typeof(AudioSource))
        end
        --如果已经在播放当前背景音，不用重新播放
        if (not self.bgmSource.clip) or self.bgmSource.clip.name ~= soundName then
            --直接更改背景音
            local bgmClip = AssetBundleManager:LoadRes("sound",soundName)
            self.bgmSource.clip = bgmClip
            self.bgmSource.volume = self.BgmVolume
            self.bgmSource.loop = true
            --播放背景音然后返回
            self.bgmSource:Play()
        end
        return
    end

    --校验播放音效的组件是否挂载，已经有挂载就直接取出组件播放
    if self.clipSources[soundName] == nil then
        local audioClip = AssetBundleManager:LoadRes("sound",soundName)
        local audioSource = self.audioObject:AddComponent(typeof(AudioSource))
        audioSource.clip = audioClip
        audioSource.volume = self.SoundVolume
        audioSource.loop = false
        self.clipSources[soundName] = audioSource
    end
    --取出组件播放音效
    if not self.clipSources[soundName].isPlaying then
        self.clipSources[soundName]:Play()
    end    
end


--改变背景音量的函数
function AudioSourceManager:ChangeBgmVolume(volume)
    self.BgmVolume = Mathf.Clamp(volume,0,1)
    self.bgmSource.volume = self.BgmVolume
end
--改变音效音量的函数
function AudioSourceManager:ChangeSoundVolume(volume)
    self.SoundVolume = Mathf.Clamp(volume,0,1)
    for _,v in pairs(self.clipSources) do
        v.volume = self.SoundVolume
    end
end

--停止声音播放函数
function AudioSourceManager:StopBgm()
    self.bgmSource:Stop()
end