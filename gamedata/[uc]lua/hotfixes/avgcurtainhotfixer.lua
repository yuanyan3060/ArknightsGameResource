
local AVGCurtainHotfixer = Class("AVGCurtainHotfixer", HotfixBase)

local LayoutRebuilder = CS.UnityEngine.UI.LayoutRebuilder
local LAYOUT_GROUP_TYPE = typeof(CS.UnityEngine.UI.LayoutGroup)
local RECT_TRANSFORM_TYPE = typeof(CS.UnityEngine.RectTransform)




local SIZE_EPSILON = 0.01




local s_originPaddings = {}

local function _GetOriginPadding(curtain, layoutGroup)
  local origin = s_originPaddings[curtain]
  if origin == nil then
    local padding = layoutGroup.padding
    origin = {left = padding.left, right = padding.right, top = padding.top, bottom = padding.bottom}
    s_originPaddings[curtain] = origin
  end
  return origin
end




local function _SetEdgeFeatherEnabled(curtain, enabled)
  local layoutGroup = curtain:GetComponent(LAYOUT_GROUP_TYPE)
  if layoutGroup == nil then
    return
  end
  local origin = _GetOriginPadding(curtain, layoutGroup)
  local left, right, top, bottom = 0, 0, 0, 0
  if enabled then
    left, right, top, bottom = origin.left, origin.right, origin.top, origin.bottom
  end
  local padding = layoutGroup.padding
  if padding.left == left and padding.right == right and padding.top == top and padding.bottom == bottom then
    return
  end
  padding.left = left
  padding.right = right
  padding.top = top
  padding.bottom = bottom
  
  
  
  LayoutRebuilder.MarkLayoutForRebuild(curtain:GetComponent(RECT_TRANSFORM_TYPE))
end

local function _NeedEdgeFeather(curtain, targetSize, useGradient)
  if useGradient then
    return true
  end
  local originSize = curtain.originSize
  local isFullCover = math.abs(targetSize.x - originSize.x) < SIZE_EPSILON
    and math.abs(targetSize.y - originSize.y) < SIZE_EPSILON
  return not isFullCover
end

local function SetCurtainSize(curtain, targetSize, useGradient)
  _SetEdgeFeatherEnabled(curtain, _NeedEdgeFeather(curtain, targetSize, useGradient))
  curtain:SetCurtainSize(targetSize, useGradient)
end

local function SetCurtainSizeTween(curtain, targetSize, fadetime, useGradient)
  _SetEdgeFeatherEnabled(curtain, _NeedEdgeFeather(curtain, targetSize, useGradient))
  return curtain:SetCurtainSizeTween(targetSize, fadetime, useGradient)
end

local function ResetCurtain(curtain)
  _SetEdgeFeatherEnabled(curtain, true)
  curtain:ResetCurtain()
end

function AVGCurtainHotfixer:OnInit()
  if HOTFIX_ENABLE then
    local AVGCurtain = CS.Torappu.AVG.AVGCurtain
    self:Fix_ex(AVGCurtain, "SetCurtainSize", SetCurtainSize)
    self:Fix_ex(AVGCurtain, "SetCurtainSizeTween", SetCurtainSizeTween)
    self:Fix_ex(AVGCurtain, "ResetCurtain", ResetCurtain)
  end
end

function AVGCurtainHotfixer:OnDispose()
  s_originPaddings = {}
end

return AVGCurtainHotfixer
