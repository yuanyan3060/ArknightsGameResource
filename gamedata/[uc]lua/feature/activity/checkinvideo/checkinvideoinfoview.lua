local luaUtils = CS.Torappu.Lua.Util;
local UICommonItemCard = require("Feature/Supportor/UI/UICommonItemCard");








































































local CheckinVideoInfoView = Class("CheckinVideoInfoView", UIPanel);

local ALPHA_CAN_RECEIVE = 1.0;
local ALPHA_CANNOT_RECEIVE = 0.5;

local ANIM_PREV_OUT_NAME = "anim_checkin_video_prev_out";
local ANIM_PREV_IN_NAME = "anim_checkin_video_prev_in";
local ANIM_NEXT_OUT_NAME = "anim_checkin_video_next_out";
local ANIM_NEXT_IN_NAME = "anim_checkin_video_next_in";
local ANIM_LOOP_NAME = "anim_checkin_video_loop";

local CheckinVideoRewardItemView = require("Feature/Activity/CheckinVideo/CheckinVideoRewardItemView");
local CheckinVideoDynImageView = require("Feature/Activity/CheckinVideo/CheckinVideoDynImageView");


function CheckinVideoInfoView:OnInit()
  self:AddButtonClickListener(self._btnNext, self._EventOnNextBtnClicked);
  self:AddButtonClickListener(self._btnPrev, self._EventOnPrevBtnClicked);
  self:AddButtonClickListener(self._btnReceive, self._EventOnReceiveBtnClicked);
  self:AddButtonClickListener(self._btnReplay, self._EventOnReplayBtnClicked);
  self:AddButtonClickListener(self._btnShare, self._EventOnShareBtnClicked);
  self:AddButtonClickListener(self._hotspotSecondBtn, self._EventOnSecondBtnClicked);

  self.m_rewardAdapter = self:CreateCustomComponent(UISimpleLayoutAdapter, self, self._rewardContent,
      self._CreateRewardView, self._GetRewardCount, self._UpdateRewardView);
  self.m_receivedAdapter = self:CreateCustomComponent(UISimpleLayoutAdapter, self, self._receivedContent,
      self._CreateReceivedView, self._GetRewardCount, self._UpdateReceivedView);
end


function CheckinVideoInfoView:OnViewModelUpdate(data)
  if data == nil then
    return;
  end

  local hasMultiItem = #data.itemList > 1;
  luaUtils.SetActiveIfNecessary(self._objSwitchPart, hasMultiItem);
  luaUtils.SetActiveIfNecessary(self._objProgressPart, hasMultiItem);

  local currFocusId = data.currFocusItem;
  if data.isEnter or self.m_cachedIndex == data.currFocusItem then
    self.m_cachedIndex = currFocusId;
    self:_InitElementsColor(data);
    self:_Render(data.itemList[data.currFocusItem], data.actId);
    return;
  end

  self:_Render(data.itemList[self.m_cachedIndex], data.actId);
  self.m_cachedIndex = currFocusId;

  if self.m_switchAnim ~= nil and self.m_switchAnim:IsPlaying() then
    self.m_switchAnim:Kill();
    self.m_switchAnim = nil;
  end
  
  local switchAnim = CS.DG.Tweening.DOTween.Sequence();
  local outAnimName = ANIM_PREV_OUT_NAME;
  local inAnimName = ANIM_PREV_IN_NAME;
  if data.isNext then
    outAnimName = ANIM_NEXT_OUT_NAME;
    inAnimName = ANIM_NEXT_IN_NAME;
  end
  switchAnim:Append(self._animWrapper:PlayWithTween(outAnimName));
  switchAnim:AppendCallback(function()
      self:_Render(data.itemList[currFocusId], data.actId);
    end);
  switchAnim:Append(self._animWrapper:PlayWithTween(inAnimName));
  switchAnim:SetEase(CS.DG.Tweening.Ease.Linear);
  self.m_switchAnim = switchAnim;
end

function CheckinVideoInfoView:_InitElementsColor(data)
  if data.mainBgCol ~= nil then
    self._mainBkg.color = CS.Torappu.ColorRes.TweenHtmlStringToColor(data.mainBgCol);
  end
  if data.mainBtnCol ~= nil then
    local mainBtnCol = CS.Torappu.ColorRes.TweenHtmlStringToColor(data.mainBtnCol);
    self._mainBtnBg.color = mainBtnCol;
    self._textMainBtnReceive.color = mainBtnCol;
    self._textMainBtnAfterClick.color = mainBtnCol;
    self._mainBtnRecieveIcon.color = mainBtnCol;
    self._mainBtnRecieveIconGift.color = mainBtnCol;
    self._mainBtnAfterClickIcon.color = mainBtnCol;
    self._mainBtnAfterClickIconGift.color = mainBtnCol;
    self._shareBtnBg.color = mainBtnCol;
    self._shareBtnText.color = mainBtnCol;
    self._shareBtnIcon.color = mainBtnCol;
    self._lockIcon.color = mainBtnCol;
    self._textLocked.color = mainBtnCol;
  end
  if data.blurCol ~= nil then
    local blurCol = CS.Torappu.ColorRes.TweenHtmlStringToColor(data.blurCol);
    self._gradientBottom.color = blurCol;
    self._gradientLeft.color = blurCol;
    self._gradientRight.color = blurCol;
  end
  if data.newCol ~= nil then
    self._secondBtnNew.color = CS.Torappu.ColorRes.TweenHtmlStringToColor(data.newCol);
  end
  if data.mainBtnLightCol ~= nil then
    self._mainBtnLight.color = CS.Torappu.ColorRes.TweenHtmlStringToColor(data.mainBtnLightCol);
  end
end



function CheckinVideoInfoView:_Render(itemModel, actId)
  if itemModel == nil then
    return;
  end

  if itemModel.status == CheckinVideoItemStatus.CAN_RECEIVE then
    self._canvasGroupReward.alpha = ALPHA_CAN_RECEIVE;
    self._canvasGroupReward.blocksRaycasts = false;
  else
    self._canvasGroupReward.alpha = ALPHA_CANNOT_RECEIVE;
    self._canvasGroupReward.blocksRaycasts = true;
  end

  if itemModel.status == CheckinVideoItemStatus.CAN_RECEIVE then
    if self.m_loopAnim == nil or not self.m_loopAnim:IsPlaying() then
      self.m_loopAnim = self._animWrapper:PlayWithTween(ANIM_LOOP_NAME);
      self.m_loopAnim:SetEase(CS.DG.Tweening.Ease.Linear);
      self.m_loopAnim:SetLoops(-1);
    end
  elseif self.m_loopAnim ~= nil and self.m_loopAnim:IsPlaying() then
    self.m_loopAnim:Kill();
    self.m_loopAnim = nil;
  end

  local isLock = itemModel.status == CheckinVideoItemStatus.LOCKED;
  local canReceive = itemModel.status == CheckinVideoItemStatus.CAN_RECEIVE;
  self.m_hasReceived = itemModel.status == CheckinVideoItemStatus.RECEIVED;
  local showRecieveIcon = itemModel.resType == CheckinVideoDailyInfoResType.VIDEO_RES or itemModel.resType == CheckinVideoDailyInfoResType.PIC_RES;
  local showRecieveGiftIcon = itemModel.resType == CheckinVideoDailyInfoResType.NO_RES;
  local hasShareBtn = itemModel.hasShareBtn;
  self.m_showSecondBtn = itemModel.hasSecondBtn and itemModel.status == CheckinVideoItemStatus.RECEIVED;
  local hasSecondBtnNew = self.m_showSecondBtn and not CheckinVideoUtil.IsSecondBtnNewChecked(actId, self.m_cachedIndex);
  luaUtils.SetActiveIfNecessary(self._panelCanReceive, canReceive);
  luaUtils.SetActiveIfNecessary(self._mainBtnRecieveIcon.gameObject, canReceive and showRecieveIcon);
  luaUtils.SetActiveIfNecessary(self._mainBtnRecieveIconGift.gameObject, canReceive and showRecieveGiftIcon);
  luaUtils.SetActiveIfNecessary(self._panelLocked, isLock);
  luaUtils.SetActiveIfNecessary(self._panelLockedMask, isLock);
  luaUtils.SetActiveIfNecessary(self._panelReceived, self.m_hasReceived);
  local showReceivedAndReplay = self.m_hasReceived and showRecieveIcon;
  luaUtils.SetActiveIfNecessary(self._mainBtnAfterClickIcon.gameObject, showReceivedAndReplay);
  luaUtils.SetActiveIfNecessary(self._btnReplay.gameObject, showReceivedAndReplay);
  local showRecievedGift = self.m_hasReceived and showRecieveGiftIcon;
  luaUtils.SetActiveIfNecessary(self._mainBtnAfterClickIconGift.gameObject, showRecievedGift);
  luaUtils.SetActiveIfNecessary(self._panelReplay, not string.isNullOrEmpty(itemModel.videoId));
  luaUtils.SetActiveIfNecessary(self._objSharePart, hasShareBtn);
  luaUtils.SetActiveIfNecessary(self._objSecondBtnPart, self.m_showSecondBtn);
  luaUtils.SetActiveIfNecessary(self._objSecondBtnNew, hasSecondBtnNew);

  if self.m_showSecondBtn then
    self._textSecondBtn.text = itemModel.secondBtnTxt;
    self._textSecondBtn.color = CS.Torappu.ColorRes.TweenHtmlStringToColor(itemModel.secondBtnTxtCol);
    self._imgSecondBtnBg.color = CS.Torappu.ColorRes.TweenHtmlStringToColor(itemModel.secondBtnCol);
  end

  self.m_cachedRewardList = itemModel.rewardList;
  if self.m_rewardAdapter ~= nil then
    self.m_rewardAdapter:NotifyDataSetChanged();
  end
  if self.m_receivedAdapter ~= nil then
    self.m_receivedAdapter:NotifyDataSetChanged();
  end

  if isLock then
    self._textLocked.text = itemModel.lockedTip;
  end

  if canReceive then
    self._textMainBtnReceive.text = itemModel.mainBtnTxt;
  end

  if self.m_hasReceived then
    self._textMainBtnAfterClick.text = itemModel.mainBtnAfterClickTxt;
  end

  local hubPath = CS.Torappu.ResourceUrls.GetCheckinVideoImageHubPath(actId);
  self.m_dynImageViewMain = self:_RenderDynImageView(self.m_dynImageViewMain, actId, self._dynImageMain, self._panelDynMainImageHolder, itemModel.introImgList[1], hubPath);
  self.m_dynImageViewTitle = self:_RenderDynImageView(self.m_dynImageViewTitle, actId, self._dynImageTitle, self._panelDynTitleImageHolder, itemModel.introImgList[2], hubPath);
  self.m_dynImageViewActName = self:_RenderDynImageView(self.m_dynImageViewActName, actId, self._dynImageActName, self._panelDynActNameImageHolder, itemModel.introImgList[3], hubPath);
  self.m_dynImageViewLogo = self:_RenderDynImageView(self.m_dynImageViewLogo, actId, self._dynImageLogo, self._panelDynLogoImageHolder, itemModel.introImgList[4], hubPath);
end

function CheckinVideoInfoView:_PlayLoopAnim()
  if self.m_loopAnim == nil then
    self.m_loopAnim = self._animWrapper:PlayWithTween(ANIM_LOOP_NAME);
  end
end








function CheckinVideoInfoView:_RenderDynImageView(imgaeView, actId, imgId, holder, imgPath, hubPath)
  if imgaeView == nil then
    imgaeView = self:_CreateDynImageView(actId, imgId, holder);
  end
  if imgaeView ~= nil then
    imgaeView:Render(imgPath, hubPath);
  end
  return imgaeView;
end


function CheckinVideoInfoView:_CreateDynImageView(actId, id, holder)
  local prefabPath = CS.Torappu.ResourceUrls.GetCheckinVideoDynImageViewPath(actId, id);
  local layout = self.m_parent:LoadLayout(prefabPath);
  local imageView = self:CreateWidgetByPrefab(CheckinVideoDynImageView, layout, holder);
  return imageView;
end



function CheckinVideoInfoView:_CreateRewardView(gameObj)
  local rewardItem = self:CreateWidgetByGO(UICommonItemCard, gameObj);
  return rewardItem;
end


function CheckinVideoInfoView:_GetRewardCount()
  if self.m_cachedRewardList == nil then
    return 0;
  end
  return #self.m_cachedRewardList;
end



function CheckinVideoInfoView:_UpdateRewardView(index, itemCard)
  local idx = index + 1;
  if itemCard == nil then
    return;
  end
  itemCard:Render(self.m_cachedRewardList[idx], {
    itemScale = tonumber(self._rewardItemScale),
    isCardClickable = true,
    showItemName = false,
    showItemNum = true,
    showBackground = true,
    fastClickBlock = true,
  });
end



function CheckinVideoInfoView:_CreateReceivedView(gameObj)
  local receivedItem = self:CreateWidgetByGO(CheckinVideoRewardItemView, gameObj);
  return receivedItem;
end



function CheckinVideoRewardItemView:_UpdateReceivedView(index, view)
  if view == nil then
    return;
  end
  view:Render(self.m_hasReceived);
end

function CheckinVideoInfoView:_EventOnNextBtnClicked()
  if self.onNextBtnClicked == nil then
    return;
  end
  self.onNextBtnClicked:Call();
end

function CheckinVideoInfoView:_EventOnPrevBtnClicked()
  if self.onPrevBtnClicked == nil then
    return;
  end
  self.onPrevBtnClicked:Call();
end

function CheckinVideoInfoView:_EventOnReceiveBtnClicked()
  if self.onReceiveBtnClicked == nil then
    return;
  end
  self.onReceiveBtnClicked:Call();
end

function CheckinVideoInfoView:_EventOnReplayBtnClicked()
  if self.onReplayBtnClicked == nil then
    return;
  end
  self.onReplayBtnClicked:Call();
end

function CheckinVideoInfoView:_EventOnShareBtnClicked()
  if self.onShareBtnClicked == nil then
    return;
  end
  self.onShareBtnClicked:Call();
end

function CheckinVideoInfoView:_EventOnSecondBtnClicked()
  if self.onSecondBtnClicked == nil or self.m_showSecondBtn == false then
    return;
  end
  self.onSecondBtnClicked:Call();
end

return CheckinVideoInfoView;