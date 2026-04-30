
local SandboxV3BattleUtilsHotfixer = Class("SandboxV3BattleUtilsHotfixer", HotfixBase)

local NEED_WALKABLE_TRAP_DICT = {
  ["trap_513_xb2bas"] = true,
  ["trap_514_xb2brh"] = true,
  ["trap_525_xb2sta"] = true,
  ["trap_526_xb2sit"] = true,
  ["trap_527_xb2tml"] = true,
  ["trap_529_xb2crv"] = true,
  ["trap_529_xb2trk"] = true,
  ["trap_551_xb2fnc"] = true,
  ["trap_552_xb2fnc2"] = true,
  ["trap_549_xb2pwr"] = true,
}

local function _IsNeedWalkableTrap(trapId)
  if NEED_WALKABLE_TRAP_DICT[trapId] then
    return true
  end
  return false
end

function SandboxV3BattleUtilsHotfixer:OnInit()
  if HOTFIX_ENABLE then
    self:Fix_ex(CS.Torappu.Battle.SandboxV3.SandboxV3BattleUtils, "IsNeedWalkableTrap", _IsNeedWalkableTrap)
  end
end

return SandboxV3BattleUtilsHotfixer