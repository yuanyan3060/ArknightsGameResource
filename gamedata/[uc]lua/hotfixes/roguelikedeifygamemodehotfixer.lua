
local RoguelikeDeifyGameModeHotfixer = Class("RoguelikeDeifyGameModeHotfixer", HotfixBase)

local DeifyGameMode = CS.Torappu.Battle.GameMode.GameModeFactory.RoguelikeDeifyGameMode
local BattleController = CS.Torappu.Battle.BattleController
local BattleOptions = CS.Torappu.Battle.BattleOptions

local function _InitGameStartStageFix(self)
  self.m_gameStage = DeifyGameMode.GameStage.STAGE_CHOSEN

  local battleController = BattleController.instance
  if battleController ~= nil and battleController.levelData ~= nil and battleController.levelData.options ~= nil then
    battleController.levelData.options.costIncreaseTime = 0
  end
end

function RoguelikeDeifyGameModeHotfixer:OnInit()
  xlua.private_accessible(DeifyGameMode)
  xlua.private_accessible(BattleController)

  self:Fix_ex(DeifyGameMode, "InitGameStartStage", function(self)
    local ok, errorInfo = xpcall(_InitGameStartStageFix, debug.traceback, self)
    if not ok then
      LogError("[RoguelikeDeifyGameModeHotfixer] InitGameStartStage fix: " .. tostring(errorInfo))
    end
  end)
end

function RoguelikeDeifyGameModeHotfixer:OnDispose()
end

return RoguelikeDeifyGameModeHotfixer
