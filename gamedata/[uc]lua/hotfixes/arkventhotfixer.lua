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

function ArkventHotfixer:OnInit()
  self:Fix_ex(CS.Torappu.UI.ArkOdc.ArkOdcDataSourceComponent.PlayerTaskChangeListener, "CheckIfDataChanged", function(self, prevData, curData, delta)
    local ok, result = xpcall(CheckIfDataChangedFixed, debug.traceback, self, prevData, curData, delta)
    if not ok then
      LogError("[ArkventHotfixer] fix" .. result)
    end
    return ok and result or false
  end)
end

function ArkventHotfixer:OnDispose()
end

return ArkventHotfixer
