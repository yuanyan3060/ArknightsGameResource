local PCHotfixer = Class("PCHotfixer", HotfixBase);

local TorappuKeyBoardLogic = CS.Torappu.KeyEntityGroupBase.TorappuKeyBoardLogic;
local KeyEntityGroupBase = CS.Torappu.KeyEntityGroupBase;

local function _Fix_LoadDefaultGroupData(self)
  local group = CS.Torappu.NormalKeyEntityGroup();
  group.showBtnCard = self.m_displaySetting.showNormalBtn;
  self.m_normalGroupDict:Add(CS.Torappu.UI.UIButtonUtil.DEFAULT_ESC_GROUP, group);
  group:_LoadData(CS.Torappu.PCKeyConst.DEFAULT_GROUP_DATA);
  group:_CheckKeyCodeSetting(self.m_userSettingDict);
end

function PCHotfixer:OnInit()
  if not CS.Torappu.DeviceInfoUtil:IsPCMode() then
      return;
  end

  local groupData = CS.Torappu.PCKeyConst.DEFAULT_GROUP_DATA;
  if groupData ~= nil and groupData.itemList ~= nil and groupData.itemList[0] ~= nil then
    groupData.itemList[0].funcName = CS.Torappu.UI.UIButtonUtil.DEFAULT_ESC_GROUP;
  end

  xlua.private_accessible(KeyEntityGroupBase);
  xlua.private_accessible(TorappuKeyBoardLogic);
  self:Fix_ex(TorappuKeyBoardLogic, "_LoadDefaultGroupData", function(self)
    local ok, err = xpcall(_Fix_LoadDefaultGroupData, debug.traceback, self);
    if not ok then
      LogError("[PCHotfixer] _LoadDefaultGroupData fix: " .. tostring(err));
      self:_LoadDefaultGroupData();
    end
  end);
end

function PCHotfixer:OnDispose()
end

return PCHotfixer
