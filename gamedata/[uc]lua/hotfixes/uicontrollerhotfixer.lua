

local UIControllerHotfixer = Class("UIControllerHotfixer", HotfixBase)

local UIController = CS.Torappu.Battle.UI.UIController
local BattleController = CS.Torappu.Battle.BattleController
local EntityType = typeof(CS.Torappu.Battle.Entity)

function UIControllerHotfixer:OnInit()
  
  xlua.private_accessible(UIController)
  self:Fix(UIController, "_OnGiantBossHudUsed", function(self, target)
    if target == nil then
      return
    end
    if EntityType:IsInstanceOfType(target) and target.mapLayer ~= BattleController.instance.playerLayer then
      return
    end
    self.enemyBossInfo:Attach(target)
  end)
end

return UIControllerHotfixer
