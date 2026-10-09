local luaUtils = CS.Torappu.Lua.Util;







local RewardOnlyPoolViewModel = Class("RewardOnlyPoolViewModel");


function RewardOnlyPoolViewModel:LoadData(poolData)
  self.poolName = "";
  self.poolId = "";
  self.charList = {};
  self.sortId = 0;

  if poolData == nil then
    return;
  end
  self.poolId = poolData.poolId;
  self.poolName = poolData.poolName;
  self.sortId = poolData.sortId;

  self.charList = poolData.charIdList;
end















local RewardOnlyViewModel = Class("RewardOnlyViewModel", UIViewModel);



function RewardOnlyViewModel:LoadData(actId)
  self.actId = actId;
  self.claimStartTime = 0;
  self.countTime = 0;
  self.actEndTime = 0;
  self.poolModelList = {};
  self.selectPoolId = "";
  self.receivedCharId = "";
  self.beCheckPoolDetail = false;

  if string.isNullOrEmpty(actId) then
    return;
  end
  
  local gameData = RewardOnlyUtil.LoadGameData(actId);
  if gameData == nil or gameData.rewardPoolDataDict == nil then
    return;
  end

  if gameData.constData ~= nil then
    self.claimStartTime = gameData.constData.claimStartTime;
    self.countTime = gameData.constData.countTime;
  end

  local suc, basicData = CS.Torappu.ActivityDB.data.basicInfo:TryGetValue(self.actId)
  if suc then 
    self.actEndTime = basicData.endTime;
  end

  
  for poolId, poolData in pairs(gameData.rewardPoolDataDict) do
    local rewardPoolModel = RewardOnlyPoolViewModel.new();
    rewardPoolModel:LoadData(poolData);
    table.insert(self.poolModelList, rewardPoolModel);
  end
  table.sort(self.poolModelList, 
    function(a,b)
      return a.sortId < b.sortId;
    end
  );
  self:RefreshPlayerData();
end

function RewardOnlyViewModel:RefreshPlayerData()
  if string.isNullOrEmpty(self.actId) then
    return;
  end

  local playerData = RewardOnlyUtil.LoadPlayerData(self.actId);
  if playerData == nil then
    return;
  end
  self.selectPoolId = playerData.choice;
  self.receivedCharId = playerData.hit;
end



function RewardOnlyViewModel:TrySelectPool(poolId)
  if string.isNullOrEmpty(poolId) then
    return false;
  end
  if not string.isNullOrEmpty(self.receivedCharId) then
    return false;
  end
  if poolId == self.selectPoolId then
    return false;
  end
  self.selectPoolId = poolId;
  return true;
end



function RewardOnlyViewModel:CheckPoolDetail(checkPoolId, canDetailConfirmGetReward)
  self.beCheckDetailPoolId = checkPoolId;
  self.canDetailConfirmGetReward = canDetailConfirmGetReward;
end


function RewardOnlyViewModel:FindCheckPoolModel()
  if string.isNullOrEmpty(self.beCheckDetailPoolId) then
    return;
  end

  for index, data in pairs(self.poolModelList) do
    if data.poolId == self.beCheckDetailPoolId then
      return data;
    end
  end
  return nil;
end

return RewardOnlyViewModel;