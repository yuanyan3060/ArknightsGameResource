local eutil = CS.Torappu.Lua.Util
local CopyDepthTextureHotfixer = Class("CopyDepthTextureHotfixer", HotfixBase)

local SceneDofController = CS.Torappu.Rendering.SceneDofController
local SceneShaderEffect = CS.Torappu.Rendering.SceneShaderEffect

local TARGET_SCENES = {
  ["level_act53side_09"] = true,
  ["level_act53side_ex08"] = true,
  ["level_act53side_sub-1-4"] = true,
}

local TARGET_GPU_PREFIXES = {
  "Mali-G78",
  "Mali-G77",
  "Mali-G68",
  "Mali-G57",
}

local buggyCopyBuffer = nil

local function _ParseLeadingInt(s)
  local value = tonumber(string.match(s or "", "^(%d+)"))
  return value or 0
end

local function _IsTargetGpu(name)
  if name == nil then
    return false
  end
  for _, prefix in ipairs(TARGET_GPU_PREFIXES) do
    if string.sub(name, 1, #prefix) == prefix then
      return true
    end
  end
  return false
end

local function _HasBuggyCopyBufferDependencyHandling()
  if CS.UnityEngine.Application.platform ~= CS.UnityEngine.RuntimePlatform.Android then
    return false
  end
  local gdt = CS.UnityEngine.SystemInfo.graphicsDeviceType
  local GDT = CS.UnityEngine.Rendering.GraphicsDeviceType
  if gdt ~= GDT.OpenGLES3 and gdt ~= GDT.OpenGLES2 then
    return false
  end
  local name = CS.UnityEngine.SystemInfo.graphicsDeviceName
  if not _IsTargetGpu(name) then
    return false
  end
  local versionStr = CS.UnityEngine.SystemInfo.graphicsDeviceVersion
  local prefix = "OpenGL ES 3.2 v1.r"
  local pos = string.find(versionStr, prefix, 1, true)
  if not pos then
    return false
  end
  return _ParseLeadingInt(string.sub(versionStr, pos + #prefix)) < 27
end

local function _IsBuggyCopyBuffer()
  if buggyCopyBuffer == nil then
    buggyCopyBuffer = _HasBuggyCopyBufferDependencyHandling()
  end
  return buggyCopyBuffer
end

local function _GetDof(self)
  if not _IsBuggyCopyBuffer() then
    return self:_GetDof()
  end
  local dof = self:_GetDof()
  if dof ~= nil then
    dof.active = false
  end
  return nil
end

local function _GetDofFixer(self)
  local ok, result = xpcall(_GetDof, debug.traceback, self)
  if not ok then
    eutil.LogHotfixError("[CopyDepthTextureHotfixer] fix _GetDof: " .. tostring(result))
    return self:_GetDof()
  end
  return result
end

local function _IsTargetScene(self)
  local go = self.gameObject
  if go == nil then
    return false
  end
  local scene = go.scene
  if scene == nil then
    return false
  end
  return TARGET_SCENES[scene.name] == true
end

local function _OnCameraChanged(self, old, current)
  self:OnCameraChanged(old, current)
  if not _IsBuggyCopyBuffer() then
    return
  end
  if not _IsTargetScene(self) then
    return
  end
  if current ~= nil then
    current.depthCopy = false
  end
end

local function _OnCameraChangedFixer(self, old, current)
  local ok, errorInfo = xpcall(_OnCameraChanged, debug.traceback, self, old, current)
  if not ok then
    eutil.LogHotfixError("[CopyDepthTextureHotfixer] fix OnCameraChanged: " .. tostring(errorInfo))
    self:OnCameraChanged(old, current)
  end
end

function CopyDepthTextureHotfixer:OnInit()
  if HOTFIX_ENABLE then
    if xlua and xlua.private_accessible then
      xlua.private_accessible(SceneDofController)
    end
    self:Fix_ex(SceneDofController, "_GetDof", _GetDofFixer)
    self:Fix_ex(SceneShaderEffect, "OnCameraChanged", _OnCameraChangedFixer)
  end
end

return CopyDepthTextureHotfixer
