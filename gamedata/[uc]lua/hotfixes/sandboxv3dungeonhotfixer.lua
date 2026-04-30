
local SandboxV3DungeonHotfixer = Class("SandboxV3DungeonHotfixer", HotfixBase)

local function _RefreshLayer(self, model, recycleAll)
  self:RefreshLayer(model, recycleAll)
  if not recycleAll then 
    self.m_tileViewPool:OnDataChanged();
  end
end

function SandboxV3DungeonHotfixer:OnInit()
  if HOTFIX_ENABLE then
    if xlua and xlua.private_accessible then
      xlua.private_accessible(CS.Torappu.UI.SandboxPerm.SandboxV3.SandboxV3DungeonMapTextureTileLayerView)
    end
    self:Fix_ex(CS.Torappu.UI.SandboxPerm.SandboxV3.SandboxV3DungeonMapTextureTileLayerView, "RefreshLayer", _RefreshLayer)
  end
end

return SandboxV3DungeonHotfixer
