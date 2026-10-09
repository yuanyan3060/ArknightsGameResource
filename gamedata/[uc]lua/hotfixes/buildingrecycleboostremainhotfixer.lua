local eutil = CS.Torappu.Lua.Util


local BuildingRecycleBoostRemainHotfixer = Class("BuildingRecycleBoostRemainHotfixer", HotfixBase)

local SnapShot = CS.Torappu.Building.UI.Recycle.RecycleRoomSnapShot

local function _GetBoostRemainTime(self)
  if self.boostRemainTime <= 0 then
    return 0
  end
  return self:GetBoostRemainTime()
end

function BuildingRecycleBoostRemainHotfixer:OnInit()
  if HOTFIX_ENABLE then
    self:Fix_ex(SnapShot, "GetBoostRemainTime", function(self)
      local ok, result = xpcall(_GetBoostRemainTime, debug.traceback, self)
      if not ok then
        eutil.LogHotfixError(
          "[BuildingRecycleBoostRemainHotfixer] fix GetBoostRemainTime: " .. tostring(result))
        return self:GetBoostRemainTime()
      end
      return result
    end)
  end
end

return BuildingRecycleBoostRemainHotfixer
