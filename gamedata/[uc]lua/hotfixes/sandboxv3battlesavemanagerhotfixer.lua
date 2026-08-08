

local eutil = CS.Torappu.Lua.Util

local SandboxV3BattleSaveManagerHotfixer = Class("SandboxV3BattleSaveManagerHotfixer", HotfixBase)
local ActionType = CS.Torappu.LevelData.WaveData.FragmentData.ActionData.ActionType

local function _ClearAvgActionIfRoomActiveAfterFirstDay(self, info)
  if not info.isActive then return end
  if self:IsFirstDay() then return end
  
  local waveSafeLength = info.subLevelData.waves == nil and 0 or info.subLevelData.waves.Length
  for waveI = 0, waveSafeLength - 1 do
    local waveData = info.subLevelData.waves[waveI];
    local fragSafeLength = waveData.fragments == nil and 0 or waveData.fragments.Length
    for fragI = 0, fragSafeLength - 1 do
      local fragData = waveData.fragments[fragI]
      local actionSafeLength = fragData.actions == nil and 0 or fragData.actions.Length
      for actionI = 0, actionSafeLength - 1 do
        local actionData = fragData.actions[actionI]
        local actionType = actionData.actionType
        if actionType == ActionType.DIALOG or actionType == ActionType.STORY or actionType == ActionType.DISPLAY_ENEMY_INFO or actionType == ActionType.ACTIVATE_PREDEFINED then
          if actionData.isValid then
            actionData.isValid = actionData.preDelay > 0;
          end
        end
      end
    end
  end
end

local function _ClearAvgActionIfRoomActiveAfterFirstDayImpl(self, info)
  local ok, errorInfo = xpcall(_ClearAvgActionIfRoomActiveAfterFirstDay, debug.traceback, self, info);
  if not ok then
    eutil.LogHotfixError("[SandboxV3BattleSaveManagerHotfixer] fix ClearAvgActionIfRoomActiveAfterFirstDay: " .. tostring(errorInfo));
    self:_ClearAvgActionIfRoomActiveAfterFirstDay(info);
  end
end

function SandboxV3BattleSaveManagerHotfixer:OnInit()
  if HOTFIX_ENABLE then
    if xlua and xlua.private_accessible then
      xlua.private_accessible(CS.Torappu.Battle.SandboxV3.SandboxV3BattleSaveManager)
    end
    self:Fix_ex(CS.Torappu.Battle.SandboxV3.SandboxV3BattleSaveManager, "_ClearAvgActionIfRoomActiveAfterFirstDay", _ClearAvgActionIfRoomActiveAfterFirstDayImpl)
  end
end

return SandboxV3BattleSaveManagerHotfixer