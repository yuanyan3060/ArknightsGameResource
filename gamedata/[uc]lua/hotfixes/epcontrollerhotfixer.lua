local EPControllerHotfixer = Class("EPControllerHotfixer", HotfixBase)

local EPController = CS.Torappu.Battle.Entity.EPController
local EPBreakBuffDB = CS.Torappu.Battle.EPBreakBuffDB
local BattleController = CS.Torappu.Battle.BattleController
local ElementType = CS.Torappu.Battle.ElementType
local SideType = CS.Torappu.Battle.SideType
local CharacterType = typeof(CS.Torappu.Battle.Character)

local function _Fix_OnElementBreak(self, curEPDamageType)
    if curEPDamageType == ElementType.NONE or self.isInBreakRecovery then
        return
    end

    local ok, data = EPBreakBuffDB.instance:GetBreakData(curEPDamageType)
    if not ok then
        return
    end

    
    local useCharDuration = CharacterType:IsInstanceOfType(self.m_owner) and (self.m_owner.side == SideType.ALLY)
    local epBreakDuration
    if useCharDuration then
        epBreakDuration = data.elementBreakDuration
    else
        epBreakDuration = data.enemyElementBreakDuration
    end

    self.recoveryType = curEPDamageType
    self.m_owner.buffContainer:OnBeforeEPBreakStart()
    self:_CreateBrokenBuff(data, epBreakDuration)
    self:_StartEPRecovery(epBreakDuration)

    local source = BattleController.instance.context.source:Peek()
    if source ~= nil and CharacterType:IsInstanceOfType(source) then
        BattleController.instance.logger:LogEpBreakModifier(source, curEPDamageType)
    end
end

function EPControllerHotfixer:OnInit()
    xlua.private_accessible(EPController)

    self:Fix_ex(EPController, "OnElementBreak", function(self, curEPDamageType)
        local ok, errorInfo = xpcall(_Fix_OnElementBreak, debug.traceback, self, curEPDamageType)
        if not ok then
            LogError("[EPControllerHotfixer] OnElementBreak fix: " .. tostring(errorInfo))
        end
    end)
end

function EPControllerHotfixer:OnDispose()
end

return EPControllerHotfixer
