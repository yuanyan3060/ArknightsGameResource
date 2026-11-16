

local AutoChessEmotionalManagerHotfixer = Class("AutoChessEmotionalManagerHotfixer", HotfixBase)

local EmotionalChess = CS.Torappu.Battle.AutoChess.AutoChessEmotionalManager.EmotionalChess

local AutoChessDataCenter = CS.Torappu.Battle.DataCenter.AutoChessDataCenter
local TileType = typeof(CS.Torappu.Battle.Tile)

local BATTLE_CLICK_ANIM_KEY = "battle_click"


local function _TryPlayBattleClick(self, arg)
  
  if arg == nil or not TileType:IsInstanceOfType(arg) or not arg:Equals(self.m_tile) then
    return
  end
  local dataCenter = AutoChessDataCenter.instanceOrNull
  if dataCenter == nil or dataCenter.selfPlayerIndex ~= self.m_playerIndex then
    return
  end
  if self.m_inBattle and not self:_IsPlayingAnim(BATTLE_CLICK_ANIM_KEY) then
    local animator = self.m_currentAnimator
    if animator ~= nil then
      animator:SetTrigger(BATTLE_CLICK_ANIM_KEY)
    end
  end
end

function AutoChessEmotionalManagerHotfixer:OnInit()
  
  xlua.private_accessible(EmotionalChess)
  self:Fix_ex(EmotionalChess, "_OnTileClicked", function(self, arg)
    self:_OnTileClicked(arg)
    _TryPlayBattleClick(self, arg)
  end)
end

return AutoChessEmotionalManagerHotfixer
