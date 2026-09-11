local DynNameCardSettingHotfixer = Class("DynNameCardSettingHotfixer", HotfixBase)

local PLAYER_PREFS_KEY_PREFIX = "hotfix_dyn_name_card_migration_v1_"

local function TryMigrateSetting()
  local uid = CS.U8.SDK.U8SDKInterface.Instance.uid
  if uid == nil or uid == "" then
    return
  end

  local playerPrefsKey = PLAYER_PREFS_KEY_PREFIX .. uid
  if CS.UnityEngine.PlayerPrefs.GetInt(playerPrefsKey, 0) ~= 0 then
    return
  end

  local settingManager = CS.Torappu.Setting.SettingManager.instance
  if settingManager == nil then
    return
  end

  local personalSettingData = settingManager.m_personalSettingData
  local needSave = false
  if not personalSettingData.dynNameCardEnabled then
    personalSettingData.dynNameCardEnabled = true
    needSave = true
  end
  if not personalSettingData.dynNameCardEntranceEnabled then
    personalSettingData.dynNameCardEntranceEnabled = true
    needSave = true
  end
  if needSave then
    settingManager:Save()
  end

  CS.UnityEngine.PlayerPrefs.SetInt(playerPrefsKey, 1)
  CS.UnityEngine.PlayerPrefs.Save()
end

function DynNameCardSettingHotfixer:OnInit()
  if xlua and xlua.private_accessible then
    xlua.private_accessible(CS.Torappu.Setting.SettingManager)
  end

  self:Fix_ex(CS.Torappu.Setting.SettingManager, "LoadPersonal", function(self)
    self:LoadPersonal()
    local success, error = pcall(TryMigrateSetting)
    if not success then
      CS.Torappu.Lua.Util.LogError(
          "[DynNameCardSettingHotfixer] Migration failed: " .. tostring(error))
    end
  end)
end

return DynNameCardSettingHotfixer