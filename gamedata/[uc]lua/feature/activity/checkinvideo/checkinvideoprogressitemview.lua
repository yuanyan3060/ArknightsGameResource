local luaUtils = CS.Torappu.Lua.Util;











local CheckinVideoProgressItemView = Class("CheckinVideoProgressItemView", UIWidget);

local SWITCH_ANIM_NAME = "anim_checkin_video_switch";

function CheckinVideoProgressItemView:OnInitialize()
  local location = CS.Torappu.UI.UIAnimationLocation();
  location.animationWrapper = self._animWrapper;
  location.animationName = SWITCH_ANIM_NAME;
  local builder = CS.Torappu.UI.AnimationSwitchTween.Builder(location);
  builder.ease = CS.DG.Tweening.Ease.OutQuint;
  builder.inactivateTargetIfHide = false;
  builder.tweenFromStart = false;
  self.m_switchTween = builder:Build();
  self.m_switchTween:Reset(false);
end





function CheckinVideoProgressItemView:Render(viewModel, isSelected, isEnter, dotColor)
  if viewModel == nil or isSelected == nil then
    return;
  end
  local canReceive = viewModel.status == CheckinVideoItemStatus.CAN_RECEIVE;
  luaUtils.SetActiveIfNecessary(self._panelCanReceive, canReceive);
  luaUtils.SetActiveIfNecessary(self._panelCannotReceive, not canReceive);

  if isEnter then
    self:_InitElementsColor(dotColor);
  end

  if self.m_switchTween ~= nil then
    if isEnter then
      self.m_switchTween:Reset(isSelected);
    else
      self.m_switchTween.isShow = isSelected;
    end
  end
end

function CheckinVideoProgressItemView:_InitElementsColor(dotColor)
  if dotColor ~= nil then
    local dotCol = CS.Torappu.ColorRes.TweenHtmlStringToColor(dotColor);
    self._receiveSelectImg.color = dotCol;
    self._receiveUnselectImg.color = dotCol;
    self._cannotReceiveSelectImg.color = dotCol;
    self._cannotReceiveUnselectImg.color = dotCol;
  end
end

return CheckinVideoProgressItemView;