local luaUtils = CS.Torappu.Lua.Util;

CheckinVideoUtil = Class("CheckinVideoUtil");

CheckinVideoUtil.ACT_VIDEO_CHECKIN_SCE_BTN_NEW_FORMAT = "ACT_VIDEO_CHECKIN_SCE_BTN_NEW_{0}_{1}"



function CheckinVideoUtil.LoadGameData(actId)
  if string.isNullOrEmpty(actId) then
    luaUtils.LogError("[ActMainlineBp] activity Id is empty.");
    return nil;
  end
  local suc, jObject = CS.Torappu.ActivityDB.data.dynActs:TryGetValue(actId);
  if not suc then
    luaUtils.LogError("[ActMainlineBp] Can't find gamedata of [".. actId .. "]");
    return nil;
  end
  return luaUtils.ConvertJObjectToLuaTable(jObject);
end



function CheckinVideoUtil.LoadPlayerData(actId)
  if string.isNullOrEmpty(actId) then
    luaUtils.LogError("[CheckinVideoUtil] activity Id is empty.");
    return nil;
  end
  local suc, jObject = CS.Torappu.PlayerData.instance.data.activity.checkinVideoActivityList:TryGetValue(actId);
  if not suc then
    luaUtils.LogError("[CheckinVideoUtil] Can't find gamedata of [".. actId .. "]");
    return nil;
  end
  return luaUtils.ConvertJObjectToLuaTable(jObject);
end

function CheckinVideoUtil.IsSecondBtnNewChecked(activityId, index)
  local cacheKey = luaUtils.Format(CheckinVideoUtil.ACT_VIDEO_CHECKIN_SCE_BTN_NEW_FORMAT, activityId,  index);
  return CS.Torappu.Activity.ActLocalCacheHandler.GetParamFromCache(cacheKey) > 0;
end

function CheckinVideoUtil.SetSecondBtnNewChecked(activityId, index)
  local cacheKey = luaUtils.Format(CheckinVideoUtil.ACT_VIDEO_CHECKIN_SCE_BTN_NEW_FORMAT, activityId,  index);
  CS.Torappu.Activity.ActLocalCacheHandler.SaveParamToCache(cacheKey, 1);
end