BasePanel = class("BasePanel")

BasePanel.NAME = "BasePanel"

local module = BasePanel
module.gameObject = nil
module.transform = nil

--使用一个表存储控件
module.controls = {}

function module:ctor()
    if self.gameObject == nil then
        --公共的实例化对象的方法
        self.gameObject = AssetBundleManager:LoadRes("panel",self.NAME,typeof(GameObject))
        self.transform = self.gameObject.transform
        self.transform:SetParent(Canvas,false)
        --找控件
        local allControls = self.gameObject:GetComponentsInChildren(typeof(UIBehaviour))

        for i=0,allControls.Length-1 do
            local controlName = allControls[i].gameObject.name
            --如果是按钮，添加事件监听，播放按键声音
            if allControls[i]:GetType().Name == "Button" then
                allControls[i].onClick:AddListener(function()
                    AudioSourceManager:PlaySound(SoundNames.CLICK_CHESS)
                end)
            end
            --校验是否是可能需要注册监听方法的控件，如果是存起来，方便子类获取然后注册自己的事件监听
            if string.find(controlName,"Btn") ~= nil or
                string.find(controlName,"Tog") ~= nil or
                string.find(controlName,"Img") ~= nil or
                string.find(controlName,"SV") ~= nil or
                string.find(controlName,"Txt") ~= nil then
                    local typeName = allControls[i]:GetType().Name
                    if self.controls[controlName] ~= nil then
                        self.controls[controlName][typeName] = allControls[i]
                    else
                        self.controls[controlName] = {[typeName] = allControls[i]}
                    end
            end
        end
    end
end

--得到控件的方法
function module:GetControl(name,typeName)
    if self.controls[name] ~= nil then
        local sameNameControls = self.controls[name]
        if sameNameControls[typeName] ~= nil then
            return sameNameControls[typeName]
        end
    end
    return nil
end

--显隐方法
function module:ShowMe()
    self.gameObject:SetActive(true)
end
function module:HideMe()
    self.gameObject:SetActive(false)
end

--摧毁自身
function module:DestroyMe()
    local temp = self
    if temp.gameObject then
        GameObject.Destroy(temp.gameObject)
    end
    temp = nil
end