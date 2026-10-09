local luaUtils = CS.Torappu.Lua.Util;

RewardOnlyUtil = Class("RewardOnlyUtil");



function RewardOnlyUtil.LoadGameData(actId)
  if string.isNullOrEmpty(actId) then
    luaUtils.LogError("[ActRewardOnly] activity Id is empty.");
    return nil;
  end
  local suc, jObject = CS.Torappu.ActivityDB.data.dynActs:TryGetValue(actId);
  if not suc then
    luaUtils.LogError("[ActRewardOnly] Can't find gamedata of [".. actId .. "]");
    return nil;
  end
  return luaUtils.ConvertJObjectToLuaTable(jObject);
end



function RewardOnlyUtil.LoadPlayerData(actId)
  if string.isNullOrEmpty(actId) then
    luaUtils.LogError("[ActRewardOnly] activity Id is empty.");
    return nil;
  end
  local suc, jObject = CS.Torappu.PlayerData.instance.data.activity.rewardOnlyList:TryGetValue(actId);
  if not suc then
    luaUtils.LogError("[ActRewardOnly] Can't find playerData of [".. actId .. "]");
    return nil;
  end
  return luaUtils.ConvertJObjectToLuaTable(jObject);
end




function RewardOnlyUtil.CheckIfRewardOnlyConsumedByActId(actId)
  local playerData = RewardOnlyUtil.LoadPlayerData(actId);
  if playerData == nil then 
    return;
  end
  return not string.isNullOrEmpty(playerData.hit);
end