

local AutoChessDataBridgeMultiPlayerHotfixer = Class("AutoChessDataBridgeMultiPlayerHotfixer", HotfixBase)

local AutoChessDataBridgeMultiPlayer = CS.Torappu.Battle.AutoChess.AutoChessDataBridgeMultiPlayer
local AutoChessDataCenter = CS.Torappu.Battle.DataCenter.AutoChessDataCenter
local HelpBattleData = CS.Torappu.Battle.AutoChess.HelpBattleData
local AutoChessGameStatus = CS.Torappu.Battle.AutoChess.AutoChessGameStatus

local ReqAutoResenderTypeName = "Torappu.Battle.AutoChess.AutoChessDataBridgeMultiPlayer+ReqAutoResender"



local s_cachedState = nil

local function _GetCurrentGameState()
  local gameStatus = AutoChessGameStatus.instanceOrNull
  if gameStatus == nil then
    return nil
  end
  return gameStatus.currentState
end

function AutoChessDataBridgeMultiPlayerHotfixer:OnInit()
  
  xlua.private_accessible(AutoChessDataBridgeMultiPlayer)
  self:Fix_ex(AutoChessDataBridgeMultiPlayer, "_ReqHelpBattleFinish", function(self, fromRejoin, round)
    local dataCenter = AutoChessDataCenter.instanceOrNull
    if dataCenter ~= nil and dataCenter.helpBattleData == nil then
      
      dataCenter:UpdateData(HelpBattleData())
    end
    self:_ReqHelpBattleFinish(fromRejoin, round)
  end)

  
  xlua.private_accessible(ReqAutoResenderTypeName)

  
  self:Fix_ex(ReqAutoResenderTypeName, "SetDesiredPlayerState", function(self, state)
    self:SetDesiredPlayerState(state)
    s_cachedState = _GetCurrentGameState()
  end)

  
  self:Fix_ex(ReqAutoResenderTypeName, "Refresh", function(self, dataCenter)
    if self.m_needResend and s_cachedState ~= _GetCurrentGameState() then
      self.m_needResend = false
      return
    end
    self:Refresh(dataCenter)
  end)
end

return AutoChessDataBridgeMultiPlayerHotfixer
