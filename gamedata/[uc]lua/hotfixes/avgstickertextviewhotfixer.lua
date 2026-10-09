
local AVGStickerTextViewHotfixer = Class("AVGStickerTextViewHotfixer", HotfixBase)

local eutil = CS.Torappu.Lua.Util




local TWEEN_DURATION = 0.15
local LARGE_EPS = 1e-5


local ALPHA_EPSILON = 0.01









local function _SyncTrackedAlpha(animSwitch, alpha)
  local tweener = animSwitch.m_tweener
  if tweener ~= nil then
    tweener.current = alpha
  end
end






local function _ForceSwitchHidden(self)
  local animSwitch = self.m_animSwitch
  if animSwitch ~= nil then
    animSwitch:Reset(false)
    return
  end

  local canvasGroup = self._canvasGroup
  if canvasGroup ~= nil then
    canvasGroup.alpha = 0
  end
  eutil.SetActiveIfNecessary(self.gameObject, false)
end



local function _DoHideSticker(self, duration)
  if duration > LARGE_EPS then
    self.m_duration = duration
  else
    self.m_duration = TWEEN_DURATION
  end
  self.m_hidden = true

  
  
  local seq = self.m_seq
  if seq ~= nil then
    seq:Kill()
    self.m_seq = nil
  end

  local canvasGroup = self._canvasGroup
  local needFadeOut = canvasGroup ~= nil and canvasGroup.alpha > ALPHA_EPSILON and self.gameObject.activeSelf
  if needFadeOut then
    local animSwitch = self.m_animSwitch
    if animSwitch ~= nil then
      
      pcall(_SyncTrackedAlpha, animSwitch, canvasGroup.alpha)
    end
    self:_SetHiddenInternal(true)
    return
  end

  
  
  
  
  _ForceSwitchHidden(self)
end



local function _HideSticker(self, duration)
  local ok, err = xpcall(_DoHideSticker, debug.traceback, self, duration)
  if not ok then
    eutil.LogHotfixError("[AVGStickerTextViewHotfixer] HideSticker: " .. tostring(err))

    
    self:HideSticker(duration)
  end
end

function AVGStickerTextViewHotfixer:OnInit()
  if HOTFIX_ENABLE then
    local AVGStickerTextView = CS.Torappu.AVG.AVGStickerTextView
    xlua.private_accessible(AVGStickerTextView)
    xlua.private_accessible(CS.Torappu.UI.FadeSwitchTween)
    self:Fix_ex(AVGStickerTextView, "HideSticker", _HideSticker)
  end
end

return AVGStickerTextViewHotfixer
