
local SandboxV3BattleManagerHotfixer = Class("SandboxV3BattleManagerHotfixer", HotfixBase)

local function IsEnemyInKillBlacklist(battleMgr, enemy)
  if not CS.Torappu.Battle.Entity.IfReasonIsDeath(enemy.finishReason) then
    return true
  end
  return battleMgr:IsEnemyInKillBlacklist(enemy)
end
function SandboxV3BattleManagerHotfixer:OnInit()
  if HOTFIX_ENABLE then
    self:Fix_ex(CS.Torappu.Battle.SandboxV3.SandboxV3BattleManager, "IsEnemyInKillBlacklist", IsEnemyInKillBlacklist)
  end
end

return SandboxV3BattleManagerHotfixer