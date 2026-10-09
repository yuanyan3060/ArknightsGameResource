local luaUtils = CS.Torappu.Lua.Util;


























local RewardOnlyMainView = Class("RewardOnlyMainView", UIPanel);

local RewardOnlyMainViewPoolItemView = require("Feature/Activity/RewardOnly/RewardOnlyMainViewPoolItemView");

function RewardOnlyMainView:OnInit()

  self:AddButtonClickListener(self._unselectBtn, self._OnClickUnselectBtn);
  self:AddButtonClickListener(self._selectBtn, self._OnClickSelectBtn);
  self:AddButtonClickListener(self._closeBtn, self._OnClickCloseBtn);
  self:AddButtonClickListener(self._backCloseBtn, self._OnClickCloseBtn);
  CS.Torappu.Lua.LuaUIUtil.BindBackPressToButton(self._closeBtn);

  self.m_poolAdapter = self:CreateCustomComponent(UISimpleLayoutAdapter, self, self._poolContent,
      self._CreatePoolItemView, self._GetPoolItemCount, self._UpdatePoolItemView)
      
end



function RewardOnlyMainView:OnViewModelUpdate(data)
  self.m_model = data;
  if data == nil then
    return;
  end

  local currentTime = CS.Torappu.DateTimeUtil.timeStampNow;
  local canReceive = currentTime > data.claimStartTime;
  local beSelected = not string.isNullOrEmpty(data.selectPoolId);
  local beReceived = not string.isNullOrEmpty(data.receivedCharId);
  
  if not canReceive then 
    self._lockBtnText.text = luaUtils.Format(I18NTextRes.ACT_REWARD_COMMON_LOCK_BTN_DESC, luaUtils.FormatTimeDeltaStrFromNow(data.countTime));
  end
  SetGameObjectActive(self._lockBtnGroup,  not canReceive);
  SetGameObjectActive(self._unselectBtnGroup, canReceive and not beSelected and not beReceived);
  SetGameObjectActive(self._selectBtnGroup, canReceive and beSelected and not beReceived);
  SetGameObjectActive(self._receivedBtnGroup, beReceived);

  SetGameObjectActive(self._selectTipsGroup, not beReceived);

  local countDateTime = CS.Torappu.DateTimeUtil.TimeStampToDateTime(data.countTime);
  self._bottomDescTips.text = luaUtils.Format(I18NTextRes.ACT_REWARD_COMMON_BOTTOM_DESC_1, countDateTime.Month, countDateTime.Day);
  
  local actEndTimeDesc = luaUtils.FormatDateTimeyyyyMMddHHmm(data.actEndTime);
  local actEndTimeDeltaDesc = luaUtils.FormatTimeDeltaStrFromNow(data.actEndTime);
  self._actTime.text = luaUtils.Format(I18NTextRes.ACT_REWARD_COMMON_ACT_END_TIME, actEndTimeDesc, actEndTimeDeltaDesc);

  local hubPath = CS.Torappu.ResourceUrls.GetRewardOnlyImageHubPath(data.actId);
  self._bg.sprite = self:LoadSpriteFromAutoPackHub(hubPath, RewardOnlyConsts.BG_IMAGE_FORMAT);

  self.m_poolAdapter:NotifyDataSetChanged();
end




function RewardOnlyMainView:_CreatePoolItemView(gameObj)
  local itemView = self:CreateWidgetByGO(RewardOnlyMainViewPoolItemView, gameObj);
  itemView.onClickCheckPoolDetail = self.onClickCheckPoolItemDetail;
  itemView.onClickSelectPool = self.onClickSelectPoolItem;
  return itemView;
end


function RewardOnlyMainView:_GetPoolItemCount()
  if self.m_model == nil or self.m_model.poolModelList == nil then
    return 0
  end
  return #self.m_model.poolModelList;
end



function RewardOnlyMainView:_UpdatePoolItemView(index, view)
  if self.m_model == nil then
    return;
  end
  view:Render(index, self.m_model);
end


function RewardOnlyMainView:_OnClickUnselectBtn()
  if self.m_model == nil then
    return;
  end
  Event.Call(self.onClickUnselectBtn);
end

function RewardOnlyMainView:_OnClickSelectBtn()
  if self.m_model == nil then
    return;
  end
  Event.Call(self.onClickSelectBtn);
end

function RewardOnlyMainView:_OnClickCloseBtn()
  if self.onClickCloseBtn == nil then
    return;
  end
  Event.Call(self.onClickCloseBtn);
end

return RewardOnlyMainView;