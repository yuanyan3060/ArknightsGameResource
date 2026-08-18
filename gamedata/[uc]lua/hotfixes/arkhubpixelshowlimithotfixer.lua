local ArkhubPixelShowLimitHotfixer = Class("ArkhubPixelShowLimitHotfixer", HotfixBase)

local PLAYER_PREFS_KEY_PREFIX = "hotfix_arkhub_pixel_show_limit_v1_"

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

  if settingManager.m_personalSettingData.arkhubPixelShowLimit == 0 then
    settingManager.m_personalSettingData.arkhubPixelShowLimit = 1
    settingManager:Save()
  end

  CS.UnityEngine.PlayerPrefs.SetInt(playerPrefsKey, 1)
  CS.UnityEngine.PlayerPrefs.Save()
end

function ArkhubPixelShowLimitHotfixer:OnInit()
  if xlua and xlua.private_accessible then
    xlua.private_accessible(CS.Torappu.Setting.SettingManager)
  end

  self:Fix_ex(CS.Torappu.Arkvent.ArkventContainerPage, "OnStart", function(self)
    self:OnStart()
    local success, error = pcall(TryMigrateSetting)
    if not success then
      CS.Torappu.Lua.Util.LogError(
          "[ArkhubPixelShowLimitHotfixer] Migration failed: " .. tostring(error))
    end
  end)
end

return ArkhubPixelShowLimitHotfixer
