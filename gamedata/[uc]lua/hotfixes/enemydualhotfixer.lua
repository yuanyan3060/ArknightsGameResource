local EnemyDualHotfixer = Class("EnemyDualHotfixer", HotfixBase);

local function _FixCopy(self, from)
  self:Copy(from);
  self.secretary = from.secretary;
  self.secretarySkinId = from.secretarySkinId;
  self.secretarySkinSp = from.secretarySkinSp;
end

function EnemyDualHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.UI.EnemyDuel.Service.STDuelPlayerStatus);
  self:Fix_ex(CS.Torappu.UI.EnemyDuel.Service.STDuelPlayerStatus, "Copy", function(self, from)
    local ok, errorInfo = xpcall(_FixCopy, debug.traceback, self, from);
    if not ok then
      LogError("[EnemyDualHotfixer] fix" .. errorInfo);
    end
  end);
end

function EnemyDualHotfixer:OnDispose()
end

return EnemyDualHotfixer;