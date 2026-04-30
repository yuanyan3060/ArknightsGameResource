
local FogCameraHotfixer = Class("FogCameraHotfixer", HotfixBase)
local eutil = CS.Torappu.Lua.Util

local function _OnInit(self)
  self:OnInit()
  local camera = self.m_camera
  if camera and not eutil.IsDestroyed(camera) then
    camera.enabled = true
  end
end

function FogCameraHotfixer:OnInit()
  if HOTFIX_ENABLE then
    if xlua and xlua.private_accessible then
      xlua.private_accessible(CS.Torappu.Rendering.FogCamera)
    end
    self:Fix_ex(CS.Torappu.Rendering.FogCamera, "OnInit", _OnInit)
  end
end

return FogCameraHotfixer