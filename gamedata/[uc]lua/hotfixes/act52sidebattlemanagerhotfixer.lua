local eutil = CS.Torappu.Lua.Util

local Act52SideBattleManagerHotfixer = Class("Act52SideBattleManagerHotfixer", HotfixBase)

local Act52SideBattleManager = CS.Torappu.Battle.Act52SideBattleManager
local Act52SideIsBlockingBeam = CS.Torappu.Battle.Action.Nodes.Act52SideIsBlockingBeam
local ActionNodes = CS.Torappu.Battle.Action.Nodes
local GridPosition = CS.Torappu.GridPosition
local ProfessionCategory = CS.Torappu.ProfessionCategory

local s_manager = nil

local function _CircleOverlapsAABB(center, radiusSqr, minX, maxX, minY, maxY)
  local closestX = math.max(minX, math.min(center.x, maxX))
  local closestY = math.max(minY, math.min(center.y, maxY))
  local dx = center.x - closestX
  local dy = center.y - closestY
  return dx * dx + dy * dy <= radiusSqr
end

local function _IsBlockingBeamAtMapPosition(manager, mapPosition, radius)
  if manager == nil or mapPosition == nil or manager.m_blockedPositions == nil then
    return false
  end

  radius = math.max(radius or 0, 0)
  local minCol = math.floor(mapPosition.x - radius + 0.5)
  local maxCol = math.floor(mapPosition.x + radius + 0.5)
  local minRow = math.floor(mapPosition.y - radius + 0.5)
  local maxRow = math.floor(mapPosition.y + radius + 0.5)
  local radiusSqr = radius * radius

  for row = minRow, maxRow do
    for col = minCol, maxCol do
      if _CircleOverlapsAABB(
          mapPosition, radiusSqr, col - 0.5, col + 0.5, row - 0.5, row + 0.5)
          and manager.m_blockedPositions:Contains(GridPosition(row, col)) then
        return true
      end
    end
  end
  return false
end

local function _IsEnemyBlockingBeam(manager, enemy)
  if manager == nil or enemy == nil or not enemy.isValid or not enemy.alive then
    return false
  end
  if not manager:IsBeamBlocker(enemy) then
    return false
  end
  return _IsBlockingBeamAtMapPosition(manager, enemy.mapPosition, manager._blockerRadius)
end

local function _IsBeamBlocker(self, enemy)
  return self:IsBeamBlocker(enemy) and not enemy.isDisappeared
end

local function _ExecuteIsBlockingBeam(self, snapshot)
  local target, updatedSnapshot = ActionNodes.GetActionTarget(snapshot, self._targetType)
  updatedSnapshot = updatedSnapshot or snapshot
  return _IsEnemyBlockingBeam(s_manager, target), updatedSnapshot
end

local function _OnCharacterBorn(self, character)
  self:_OnCharacterBorn(character)
  if character ~= nil and character.data ~= nil
      and character.data.profession == ProfessionCategory.TOKEN then
    self:_MarkDirty()
  end
end

function Act52SideBattleManagerHotfixer:OnInit()
  if HOTFIX_ENABLE then
    xlua.private_accessible(Act52SideBattleManager)
    xlua.private_accessible(Act52SideIsBlockingBeam)

    self:Fix_ex(Act52SideBattleManager, "Init", function(self, envSystem)
      self:Init(envSystem)
      s_manager = self
    end)

    self:Fix_ex(Act52SideBattleManager, "_OnCharacterBorn", function(self, character)
      local ok, result = xpcall(_OnCharacterBorn, debug.traceback, self, character)
      if not ok then
        eutil.LogHotfixError(
          "[Act52SideBattleManagerHotfixer] fix _OnCharacterBorn: " .. tostring(result))
      end
    end)

    self:Fix_ex(Act52SideBattleManager, "IsBeamBlocker", function(self, enemy)
      local ok, result = xpcall(_IsBeamBlocker, debug.traceback, self, enemy)
      if not ok then
        eutil.LogHotfixError(
          "[Act52SideBattleManagerHotfixer] fix IsBeamBlocker: " .. tostring(result))
        return self:IsBeamBlocker(enemy)
      end
      return result
    end)

    self:Fix_ex(Act52SideIsBlockingBeam, "Execute",
      function(self, blackboard, sourceType, snapshot)
        local ok, result, updatedSnapshot = xpcall(
          _ExecuteIsBlockingBeam, debug.traceback, self, snapshot)
        if not ok then
          eutil.LogHotfixError(
            "[Act52SideBattleManagerHotfixer] fix Act52SideIsBlockingBeam.Execute: "
              .. tostring(result))
          return false, snapshot
        end
        return result, updatedSnapshot
      end)
  end
end

return Act52SideBattleManagerHotfixer
