
local AdvancedSelectorForSandboxV3GatherHotfixer = Class("AdvancedSelectorForSandboxV3GatherHotfixer", HotfixBase)

local Map = CS.Torappu.Battle.Map
local SelectorCls = CS.Torappu.Battle.AdvancedSelectorForSandboxV3Gather
local FilterType = SelectorCls.SandboxV3GatherFilterType
local MotionMode = CS.Torappu.MotionMode

local function _OnPostFilter(self, candidates)
  local ret = self:OnPostFilter(candidates)
  if ret and ret.Count > 0 and Map.hasInstance and self._filterType == FilterType.SEARCH_RES then
    for i = ret.Count - 1, 0, -1 do
      local candidate = ret[i]
      if not Map.instance:CheckReachable(MotionMode.WALK, self.owner.gridPosition, candidate.gridPosition, false) then
        ret:RemoveAt(i)
      end
    end
  end
  return ret
end

function AdvancedSelectorForSandboxV3GatherHotfixer:OnInit()
  if HOTFIX_ENABLE then
    if xlua and xlua.private_accessible then
      xlua.private_accessible(SelectorCls)
    end

    self:Fix_ex(SelectorCls, "OnPostFilter", _OnPostFilter)
  end
end

return AdvancedSelectorForSandboxV3GatherHotfixer