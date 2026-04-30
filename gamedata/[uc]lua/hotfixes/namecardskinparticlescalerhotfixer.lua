
local NameCardSkinParticleScalerHotfixer = Class("NameCardSkinParticleScalerHotfixer", HotfixBase)

local ScalerCls = CS.Torappu.UI.Friend.NameCardSkinParticleScaler
local PGU = CS.Torappu.Particle.ParticleGeometryUtils
local s_pguVisible = false


local function _EnsureParticleGeometryUtilsVisible()
  if s_pguVisible then
    return
  end
  if xlua and xlua.private_accessible then
    xlua.private_accessible(PGU)
  end
  s_pguVisible = true
end

local function _SyncTrailContextPoolFromScaler(scaler)
  local ok, poolsInst = pcall(function()
    return PGU.Pools.instance
  end)
  if not ok or poolsInst == nil then
    return
  end
  local pool = poolsInst.trailContextPool
  if pool == nil then
    return
  end
  local ctx = pool:Get()
  if ctx == nil then
    return
  end
  ctx.externParticleScale = scaler.localScale
  pool:Release(ctx)
end

local function _FixApply(self, uip, scaler)
  local function _Try()
    _EnsureParticleGeometryUtilsVisible()
    self:_ApplyParticleScale(uip, scaler)
    if uip ~= nil and scaler ~= nil then
      _SyncTrailContextPoolFromScaler(scaler)
    end
  end
  local ok, err = xpcall(_Try, debug.traceback)
  if not ok then
    LogError("[NameCardSkinParticleScalerHotfixer] _ApplyParticleScale hotfix: " .. tostring(err))
    pcall(function()
      self:_ApplyParticleScale(uip, scaler)
    end)
  end
end

function NameCardSkinParticleScalerHotfixer:OnInit()
  if not HOTFIX_ENABLE then
    return
  end
  if xlua and xlua.private_accessible then
    xlua.private_accessible(ScalerCls)
  end
  self:Fix_ex(ScalerCls, "_ApplyParticleScale", _FixApply)
end

function NameCardSkinParticleScalerHotfixer:OnDispose()
end

return NameCardSkinParticleScalerHotfixer
