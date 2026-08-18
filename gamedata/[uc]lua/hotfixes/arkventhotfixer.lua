local ArkventHotfixer = Class("ArkventHotfixer", HotfixBase)

local function GetVarSeqsKeyCount(data, topicId)
  if data == nil then
    return 0
  end
  if data.arkOdc == nil then
    return 0
  end
  if data.arkOdc.topics == nil then
    return 0
  end
  local ok, value = data.arkOdc.topics:TryGetValue(topicId)
  local result = ok and value or nil
  if result == nil then
    return 0
  end
  if result.varSeqs == nil then
    return 0
  end
  return result.varSeqs.Count
end

local function CheckIfDataChangedFixed(self, prevData, curData, delta)
  local topicId = self.m_topicId
  local prevVarSeqsCount = GetVarSeqsKeyCount(prevData, topicId)
  local curVarSeqsCount = GetVarSeqsKeyCount(curData, topicId)
  if prevVarSeqsCount > 0 and curVarSeqsCount == 0 then
    return false
  end
  return self:CheckIfDataChanged(prevData, curData, delta)
end

local function ClearUnitsFixed(self)
  self:ClearUnits()
  local furniSrc = self.furniUpdateSeqSrc
  furniSrc:TriggerAction()
  self.furniUpdateSeqSrc = furniSrc
  local creatureSrc = self.creatureUpdateSeqSrc
  creatureSrc:TriggerAction()
  self.creatureUpdateSeqSrc = creatureSrc
end

local function FillUnitInfoFixed(self, playerData, hallBrief)
  if hallBrief == nil then
    return
  end
  self.selfUnitInfo.attributes:Clear()
  self:FillUnitInfo(playerData, hallBrief)
end

local function SyncSelfCaptureAreaFixed(self, playerInfo)
  if self.m_captureAreaWriter == nil then
    return
  end

  local captureAreaAttrKey = CS.Torappu.ActArkhubPlayerAttribute.ATTR_ENTER_CAPTURE_AREA.value__
  local hasCaptureAreaAttr = playerInfo.attributes:TryGetValue(captureAreaAttrKey)
  if hasCaptureAreaAttr then
    self:_SyncSelfCaptureArea(playerInfo)
    return
  end

  local areaId = 0
  local hasState, state = self.m_captureAreaWriter:TryGet(self.m_selfUnitId)
  if not hasState then
    state = CS.Torappu.Arkvent.UnitSystem.UnitCaptureAreaState()
    self.m_captureAreaWriter:Add(self.m_selfUnitId, state)
  end
  if state.areaId ~= areaId then
    state.areaId = areaId
  end
end

function ArkventHotfixer:OnInit()
  if xlua and xlua.private_accessible then
    xlua.private_accessible(CS.Torappu.UI.ActArkhub.ArkhubUnitSyncSystem)
  end
  self:Fix_ex(CS.Torappu.UI.ArkOdc.ArkOdcDataSourceComponent.PlayerTaskChangeListener, "CheckIfDataChanged", function(self, prevData, curData, delta)
    local ok, result = xpcall(CheckIfDataChangedFixed, debug.traceback, self, prevData, curData, delta)
    if not ok then
      LogError("[ArkventHotfixer] fix" .. result)
    end
    return ok and result or false
  end)
  self:Fix_ex(CS.Torappu.UI.ActArkhub.Server.ActArkhubServerRoleUnitGroupInfo, "ClearUnits", function(self)
    local ok, result = xpcall(ClearUnitsFixed, debug.traceback, self)
    if not ok then
      LogError("[ArkventHotfixer] ClearUnits fix " .. result)
    end
  end)
  self:Fix_ex(CS.Torappu.UI.ActArkhub.Server.ActArkhubGamePlayServerData, "FillUnitInfo", function(self, playerData, hallBrief)
    local ok, result = xpcall(FillUnitInfoFixed, debug.traceback, self, playerData, hallBrief)
    if not ok then
      LogError("[ArkventHotfixer] FillUnitInfo fix " .. result)
    end
  end)
  self:Fix_ex(CS.Torappu.UI.ActArkhub.ArkhubUnitSyncSystem, "_SyncSelfCaptureArea", function(self, playerInfo)
    local ok, result = xpcall(SyncSelfCaptureAreaFixed, debug.traceback, self, playerInfo)
    if not ok then
      LogError("[ArkventHotfixer] SyncSelfCaptureArea fix " .. result)
    end
  end)
end

function ArkventHotfixer:OnDispose()
end

return ArkventHotfixer
