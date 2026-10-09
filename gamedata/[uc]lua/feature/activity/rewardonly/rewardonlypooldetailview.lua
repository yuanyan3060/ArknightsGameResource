local luaUtils = CS.Torappu.Lua.Util;











local RewardOnlyPoolDetailView = Class("RewardOnlyPoolDetailView", UIPanel)

function RewardOnlyPoolDetailView:OnInit()
  self:AddButtonClickListener(self._backBtn, self._OnClickBackBtn);
  self:AddButtonClickListener(self._cancelBtn, self._OnClickBackBtn);
  self:AddButtonClickListener(self._confirmBtn, self._OnClickConfirmGetReward);
  CS.Torappu.Lua.LuaUIUtil.BindBackPressToButton(self._backBtn);

  if self.m_groupView ~= nil and self.m_viewBuilder ~= nil then
    return;
  end
  local prefab = luaUtils.LoadCommonSingleChooseCharGroupView();
  if prefab == nil then
    return;
  end
  local groupObj = CS.UnityEngine.GameObject.Instantiate(prefab.gameObject, self._viewContainer);
  self.m_groupView = groupObj:GetComponent("Torappu.UI.ChooseChar.CommonSingleChooseCharGroupView");
  if self.m_groupView == nil then
    return;
  end
  self.m_viewBuilder = CS.Torappu.UI.ChooseChar.CommonSingleChooseCharLuaViewBuilder();
  self.m_viewBuilder:BindView(self.m_groupView);
end



function RewardOnlyPoolDetailView:OnViewModelUpdate(data)
  if data == nil then
    self:_DisplayBlurPanel(false);
    return;
  end

  local hasCheckPool = not string.isNullOrEmpty(data.beCheckDetailPoolId);
  if not hasCheckPool then
    self:_DisplayBlurPanel(false);
    return;
  end

  self:_DisplayBlurPanel(true);
  local checkPoolModel = data:FindCheckPoolModel();
  if checkPoolModel == nil then
    self:_DisplayBlurPanel(false);
    return;
  end

  local charList = checkPoolModel.charList;
  local showBtnGroup = data.canDetailConfirmGetReward;
  if self.m_groupView == nil or self.m_viewBuilder == nil then
    return;
  end
  local StringList = CS.System.Collections.Generic.List(CS.System.String);
  local charIdList = StringList();
  for _, charId in ipairs(charList) do
    if not string.isNullOrEmpty(charId) then
      charIdList:Add(charId);
    end
  end

  local onClickCharFunc = function(charId)
    self:_OnClickCharItemBtn(charId);
  end;

  local onClickCancelBtnFunc = function()
    self:_OnClickBackBtn();
  end

  local onClickConfirmBtnFunc = function()
    self:_OnClickConfirmGetReward();
  end;

  local title = "";
  if showBtnGroup then
    title = I18NTextRes.ACT_REWARD_COMMON_POOL_DETAIL_JUDGE_TITLE;
  else
    title = I18NTextRes.ACT_REWARD_COMMON_POOL_DETAIL_TITLE;
  end
  self.m_viewBuilder:LoadData(title, charIdList, true, onClickCharFunc, showBtnGroup, onClickCancelBtnFunc, onClickConfirmBtnFunc);
  self.m_groupView:Render(self.m_viewBuilder);
end


function RewardOnlyPoolDetailView:_DisplayBlurPanel(beShow)
  if beShow and not self._blurPanel.isShown then
    self._blurPanel:Show();
  end

  if not beShow and self._blurPanel.isShown then
    self._blurPanel:Hide();
  end
end

function RewardOnlyPoolDetailView:_OnClickBackBtn()
  if self.onClickBackBtn == nil then
    return;
  end
  Event.Call(self.onClickBackBtn);
end


function RewardOnlyPoolDetailView:_OnClickCharItemBtn(charId)
  if self.onClickCharItemBtn == nil then
    return;
  end
  Event.Call(self.onClickCharItemBtn, charId);
end

function RewardOnlyPoolDetailView:_OnClickConfirmGetReward()
  if self.onClickConfirmGetReward == nil then
    return;
  end
  Event.Call(self.onClickConfirmGetReward);
end

return RewardOnlyPoolDetailView;