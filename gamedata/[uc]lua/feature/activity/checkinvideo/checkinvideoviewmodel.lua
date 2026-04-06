local luaUtils = CS.Torappu.Lua.Util;




















local CheckinVideoItemViewModel = Class("CheckinVideoItemViewModel");

function CheckinVideoItemViewModel:ctor()
  self.order = 0;
  self.introImgList = {};
  self.rewardList = {};
  self.lockedTip = "";
  self.resType = CheckinVideoDailyInfoResType.NO_RES
  self.videoId = "";
  self.picId = "";
  self.mainBtnTxt = "";
  self.mainBtnAfterClickTxt = "";
  self.hasSecondBtn = false;
  self.secondBtnCol = "";
  self.secondBtnTxtCol = "";
  self.secondBtnTxt = "";
  self.secondBtnLink = "";
  self.signLockedTxt = "";
  self.hasShareBtn = false;
  self.shareImgList = {};
  self.status = CheckinVideoItemStatus.LOCKED;
end


function CheckinVideoItemViewModel:LoadData(data)
  if data == nil then
    return;
  end
  self.order = data.order;
  self.introImgList = data.introImgList;
  self.shareImgList = data.shareImgList;
  self.rewardList = {};
  for index, reward in pairs(data.itemList) do
    local viewModel = CS.Torappu.UI.UIItemViewModel();
    viewModel:LoadGameData(reward.id, reward.type);
    viewModel.itemCount = reward.count;
    table.insert(self.rewardList, viewModel);
  end
  
  self.videoId = data.videoId;
  self.picId = data.picId;
  if self.videoId ~= nil and self.picId == nil then
    self.resType = CheckinVideoDailyInfoResType.VIDEO_RES;
  elseif self.videoId == nil and self.picId ~= nil then
    self.resType = CheckinVideoDailyInfoResType.PIC_RES;
  else
    self.resType = CheckinVideoDailyInfoResType.NO_RES;
  end

  self.mainBtnTxt = data.mainBtnTxt;
  self.mainBtnAfterClickTxt = data.mainBtnAfterClickTxt;
  self.hasSecondBtn = data.hasSecondBtn;
  self.secondBtnCol = data.secondBtnCol;
  self.secondBtnTxtCol = data.secondBtnTxtCol;
  self.secondBtnTxt = data.secondBtnTxt;
  self.secondBtnLink = data.secondBtnLink;
  self.signLockedTxt = data.signLockedTxt;
  self.hasShareBtn = data.hasShareBtn;
  self.status = CheckinVideoItemStatus.LOCKED;
end



function CheckinVideoItemViewModel:RefreshPlayerData(historyInfo, currCount)
  if currCount == nil then
    return;
  end
  if historyInfo == nil then
    self.status = CheckinVideoItemStatus.LOCKED;
    self.lockedTip = luaUtils.Format(self.signLockedTxt, self.order - currCount);
  elseif historyInfo == 0 then
    self.status = CheckinVideoItemStatus.RECEIVED;
  else
    self.status = CheckinVideoItemStatus.CAN_RECEIVE;
  end
end














local CheckinVideoViewModel = Class("CheckinVideoViewModel", UIViewModel);


function CheckinVideoViewModel:LoadData(actId)
  self.actId = "";
  self.itemList = {};
  self.currFocusItem = 0;
  self.isNext = false;
  self.isEnter = false;
  self.isCommonElementColSet = false;
  self.mainBgCol = "";
  self.mainBtnCol = "";
  self.blurCol = "";
  self.newCol = "";
  self.mainBtnLightCol = "";
  self.progressDotCol = "";

  local gameData = CheckinVideoUtil.LoadGameData(actId);
  if gameData == nil or gameData.checkInList == nil then
    return;
  end
  self.actId = actId;
  self.shareMissionId = luaUtils.LoadCrossAppShareMissionId(actId);
  self.itemList = {};
  for index, dailyInfo in pairs(gameData.checkInList) do
    if dailyInfo ~= nil then
      local itemModel = CheckinVideoItemViewModel.new();
      itemModel:LoadData(dailyInfo);
      table.insert(self.itemList, itemModel);
      if self.isCommonElementColSet == false then
        self.mainBgCol = dailyInfo.mainBgCol;
        self.mainBtnCol = dailyInfo.mainBtnCol;
        self.blurCol = dailyInfo.blurCol;
        self.newCol = dailyInfo.newCol;
        self.mainBtnLightCol = dailyInfo.mainBtnLightCol;
        self.progressDotCol = dailyInfo.progressDotCol;
        self.isCommonElementColSet = true;
      end
    end
  end
  table.sort(self.itemList, function(a, b)
    return a.order < b.order;
  end);

  self:RefreshPlayerData();
  for index, dailyInfo in pairs(self.itemList) do
    if dailyInfo ~= nil and dailyInfo.status == CheckinVideoItemStatus.CAN_RECEIVE then
      self.currFocusItem = index;
      break;
    end
  end
  if self.currFocusItem <= 0 or self.currFocusItem > #self.itemList then
    self.currFocusItem = 1;
  end
  self.isEnter = true;
end

function CheckinVideoViewModel:RefreshPlayerData()
  self.isEnter = false;
  local playerData = CheckinVideoUtil.LoadPlayerData(self.actId);
  if playerData == nil or playerData.history == nil then
    return;
  end
  local currCount = #playerData.history;
  for index, dailyInfo in pairs(self.itemList) do
    local historyInfo = playerData.history[index];
    if dailyInfo ~= nil then
      dailyInfo:RefreshPlayerData(historyInfo, currCount);
    end
  end
end

return CheckinVideoViewModel;