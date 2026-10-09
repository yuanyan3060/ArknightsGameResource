local luaUtils = CS.Torappu.Lua.Util;





RewardOnlyDlg = Class("RewardOnlyDlg", DlgBase);

local RewardOnlyViewModel = require("Feature/Activity/RewardOnly/RewardOnlyViewModel");
local RewardOnlyMainView = require("Feature/Activity/RewardOnly/RewardOnlyMainView");
local RewardOnlyPoolDetailView = require("Feature/Activity/RewardOnly/RewardOnlyPoolDetailView");

function RewardOnlyDlg:OnInit()
  local actId = self.m_parent:GetData("actId");
  self.m_viewModel = self:CreateViewModel(RewardOnlyViewModel);
  self.m_viewModel:LoadData(actId);
  self:_BindDismissControl();

  local mainView = self:CreateWidgetByGO(RewardOnlyMainView, self._mainView);
  mainView.onClickUnselectBtn = Event.Create(self, self._OnClickUnSelectBtn);
  mainView.onClickSelectBtn = Event.Create(self, self._OnClickSelectBtn);
  mainView.onClickCloseBtn = Event.Create(self, self._OnClickCloseBtn);
  mainView.onClickCheckPoolItemDetail = Event.Create(self, self._OnClickCheckPoolItemDetailBtn);
  mainView.onClickSelectPoolItem = Event.Create(self, self._OnClickSelectPoolItemBtn);
  
  local detailView = self:CreateWidgetByGO(RewardOnlyPoolDetailView, self._poolDetailView);  
  detailView.onClickBackBtn = Event.Create(self, self._OnClickCloseCheckPoolItemDetailBtn);
  detailView.onClickCharItemBtn = Event.Create(self, self._OnClickCharItemBtn);
  detailView.onClickConfirmGetReward = Event.Create(self, self._OnClickConfirmGetRewardBtn);
  
  self.m_viewModel:NotifyUpdate();
end

function RewardOnlyDlg:_BindDismissControl()
  local bridge = self.m_parent:GetCompLuaBinder(CS.Torappu.Lua.LuaActivityEntry.KEY_DISMISS_CONTROL);
  if bridge == nil then
    return;
  end
  bridge:Bind({
    TryDismiss = function()
      self:_OnBackPressed();
      return true;
    end
  });
end

function RewardOnlyDlg:_OnBackPressed()
  if self.m_viewModel ~= nil and not string.isNullOrEmpty(self.m_viewModel.beCheckDetailPoolId) then
    self:_OnClickCloseCheckPoolItemDetailBtn();
    return;
  end
  self:_OnClickCloseBtn();
end

function RewardOnlyDlg:_OnClickUnSelectBtn()
  luaUtils.TextToast(I18NTextRes.ACT_REWARD_COMMON_UNSELECT_TOAST, true);
end

function RewardOnlyDlg:_OnClickSelectBtn()
  if self.m_viewModel == nil then 
    return;
  end
  if string.isNullOrEmpty(self.m_viewModel.selectPoolId) or not string.isNullOrEmpty(self.m_viewModel.receivedCharId) then
    return;
  end
  self.m_viewModel:CheckPoolDetail(self.m_viewModel.selectPoolId, true);
  self.m_viewModel:NotifyUpdate();
end

function RewardOnlyDlg:_OnClickConfirmGetRewardBtn()
  if CS.Torappu.UI.UISyncDataUtil.instance:CheckCrossDaysAndResync() then
    return;
  end
  if self.m_viewModel == nil or string.isNullOrEmpty(self.m_viewModel.actId) then 
    return;
  end

  if string.isNullOrEmpty(self.m_viewModel.selectPoolId) or not string.isNullOrEmpty(self.m_viewModel.receivedCharId) then
    return;
  end

  UISender.me:SendRequest(RewardOnlyServiceCode.GET_REWARD, 
    {
      activityId = self.m_viewModel.actId,
      poolId = self.m_viewModel.selectPoolId,
    }, 
    {
      onProceed = Event.Create(self, self._HandleGetReward);
    }
  )
end

function RewardOnlyDlg:_HandleGetReward(response)
  if response == nil then
    return;
  end
  local charGet = response.charGet;

  if charGet ~= nil then
    charGet.isNew = charGet.isNew == true or charGet.isNew == 1;
    luaUtils.LogNewCharAchieved(charGet);
    luaUtils.PlayGachaEffect(nil, charGet, nil);
  end

  if self.m_viewModel == nil then
    return;
  end
  self.m_viewModel:RefreshPlayerData();
  self.m_viewModel:CheckPoolDetail(nil, false);
  self.m_viewModel:NotifyUpdate();
end

function RewardOnlyDlg:_OnClickCloseBtn()
  if CS.Torappu.UI.UISyncDataUtil.instance:CheckCrossDaysAndResync() then
    self:Close();
    return;
  end
  if self.m_viewModel == nil or string.isNullOrEmpty(self.m_viewModel.actId) then 
    self:Close();
    return;
  end

  if string.isNullOrEmpty(self.m_viewModel.selectPoolId) or not string.isNullOrEmpty(self.m_viewModel.receivedCharId) then
    self:Close();
    return;
  end

  UISender.me:SendRequest(RewardOnlyServiceCode.SET_CHOICE, 
    {
      activityId = self.m_viewModel.actId,
      poolId = self.m_viewModel.selectPoolId,
    }, 
    {
      onProceed = Event.Create(self, self.Close);
    }
  )
end


function RewardOnlyDlg:_OnClickCheckPoolItemDetailBtn(poolId)
  if string.isNullOrEmpty(poolId) or self.m_viewModel == nil then
    return;
  end
  
  CS.Torappu.GameAnalytics.RecordRewardOnlyCheckPoolDetailBtnClicked(self.m_viewModel.actId, poolId);
  self.m_viewModel:CheckPoolDetail(poolId, false);
  self.m_viewModel:NotifyUpdate();
end

function RewardOnlyDlg:_OnClickCloseCheckPoolItemDetailBtn()
  if self.m_viewModel == nil or string.isNullOrEmpty(self.m_viewModel.beCheckDetailPoolId) then
    return;
  end
  self.m_viewModel:CheckPoolDetail(nil, false);
  self.m_viewModel:NotifyUpdate();
end


function RewardOnlyDlg:_OnClickCharItemBtn(charId)
  if string.isNullOrEmpty(charId) then
    return;
  end
  luaUtils.OpenCharacterShow(charId);
end


function RewardOnlyDlg:_OnClickSelectPoolItemBtn(poolId)
  if self.m_viewModel == nil then
    return;
  end
  
  if self.m_viewModel:TrySelectPool(poolId) then
    self.m_viewModel:NotifyUpdate();
  end
end


