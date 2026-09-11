local eutil = CS.Torappu.Lua.Util

local SchedulerHotfixer = Class("SchedulerHotfixer", HotfixBase)

Log("[SchedulerHotfixer] loaded")

local ActionType = CS.Torappu.LevelData.WaveData.FragmentData.ActionData.ActionType

local function _CheckActionEnabled(self, actionData)
  local battleController = CS.Torappu.Battle.BattleController.instance
  if actionData.actionType == ActionType.DIALOG then
    Log("[SchedulerHotfixer] levelId=" .. tostring(battleController.levelId)
      .. ", isAutoReplayOn=" .. tostring(battleController.isAutoReplayOn) .. ", key=" .. tostring(actionData.key))
    if battleController.isAutoReplayOn and battleController.levelId == "Activities/act54side/level_act54side_04" then
      Log("[SchedulerHotfixer] skip DIALOG: " .. tostring(actionData.key))
      return false
    end
  end
  return self:CheckActionEnabled(actionData)
end

function SchedulerHotfixer:OnInit()
  Log("[SchedulerHotfixer] OnInit HOTFIX_ENABLE=" .. tostring(HOTFIX_ENABLE))
  if HOTFIX_ENABLE then
    xlua.private_accessible(CS.Torappu.Battle.Scheduler)
    self:Fix_ex(CS.Torappu.Battle.Scheduler, "CheckActionEnabled", function(self, actionData)
      local ok, result = xpcall(_CheckActionEnabled, debug.traceback, self, actionData)
      if not ok then
        eutil.LogHotfixError("[SchedulerHotfixer] fix CheckActionEnabled: " .. tostring(result))
        return self:CheckActionEnabled(actionData)
      end
      return result
    end)
    Log("[SchedulerHotfixer] CheckActionEnabled registered")
  end
end

return SchedulerHotfixer
