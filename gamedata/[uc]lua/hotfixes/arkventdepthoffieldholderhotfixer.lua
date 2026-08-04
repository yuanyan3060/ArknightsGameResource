local eutil = CS.Torappu.Lua.Util

local ArkventDepthOfFieldHolderHotfixer = Class("ArkventDepthOfFieldHolderHotfixer", HotfixBase)

local ArkventDepthOfFieldHolder = CS.Torappu.Arkvent.ArkventDepthOfFieldHolder;
local SceneDofController = CS.Torappu.Rendering.SceneDofController;


local function _Start(self)
  self.m_sceneDofController = self.transform:GetComponentInChildren(typeof(SceneDofController), true);
  if self.m_sceneDofController == nil then
    eutil.LogHotfixError("[ArkventDepthOfFieldHolderHotfixer] fix Start: m_sceneDofController is nil");
  end
end

local function _StartFixer(self)
  local ok, errorInfo = xpcall(_Start, debug.traceback, self);
  if not ok then
    eutil.LogHotfixError("[ArkventDepthOfFieldHolderHotfixer] fix Start: " .. tostring(errorInfo));
    self:Start();
  end
end


local function _Update(self)
  if self.m_sceneDofController == nil then
    self.m_sceneDofController = self.transform:GetComponentInChildren(typeof(SceneDofController), true);
  end
  self:Update();
end

local function _UpdateFixer(self)
  local ok, errorInfo = xpcall(_Update, debug.traceback, self);
  if not ok then
    eutil.LogHotfixError("[ArkventDepthOfFieldHolderHotfixer] fix Update: " .. tostring(errorInfo));
    self:Update();
  end
end


function ArkventDepthOfFieldHolderHotfixer:OnInit()
  if HOTFIX_ENABLE then
    if xlua and xlua.private_accessible then
      xlua.private_accessible(ArkventDepthOfFieldHolder)
    end
    self:Fix_ex(ArkventDepthOfFieldHolder, "Start", _StartFixer)
    self:Fix_ex(ArkventDepthOfFieldHolder, "Update", _UpdateFixer)
  end
end

return ArkventDepthOfFieldHolderHotfixer
