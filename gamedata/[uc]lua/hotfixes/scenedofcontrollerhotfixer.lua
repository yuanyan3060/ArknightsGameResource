local eutil = CS.Torappu.Lua.Util

local SceneDofControllerHotfixer = Class("SceneDofControllerHotfixer", HotfixBase)

local SceneDofController = CS.Torappu.Rendering.SceneDofController

local function _IsAndroidLowPerformance()
  if CS.UnityEngine.Application.platform ~= CS.UnityEngine.RuntimePlatform.Android then
    return false
  end
  local rate = CS.Torappu.Setting.SettingManager.instance:GetData(
      CS.Torappu.Setting.SettingConstVars.SettingType.PERFORMANCE_RATE)
  return rate ~= nil and tonumber(rate) == 0
end



local function _GetDof(self)
  if not _IsAndroidLowPerformance() then
    return self:_GetDof()
  end
  local dof = self:_GetDof()
  if dof ~= nil then
    dof.active = false
  end
  return nil
end

local function _GetDofFixer(self)
  local ok, result = xpcall(_GetDof, debug.traceback, self)
  if not ok then
    eutil.LogHotfixError("[SceneDofControllerHotfixer] fix _GetDof: " .. tostring(result))
    return self:_GetDof()
  end
  return result
end

function SceneDofControllerHotfixer:OnInit()
  if HOTFIX_ENABLE then
    if xlua and xlua.private_accessible then
      xlua.private_accessible(SceneDofController)
    end
    self:Fix_ex(SceneDofController, "_GetDof", _GetDofFixer)
  end
end

return SceneDofControllerHotfixer
