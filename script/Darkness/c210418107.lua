--Castle of Darkness
local s,id=GetID()
local COUNTER_PUMPKIN=0x1902
function s.initial_effect(c)
	c:EnableReviveLimit()
	Link.AddProcedure(c,s.matfilter,1,1)
    --Counter
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.ctcon)
	e1:SetOperation(s.ctop)
	c:RegisterEffect(e1)
    --Cannot be targeted
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.tgcon)
	e2:SetValue(aux.imval1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
    --Atk Up
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
    e4:SetCondition(s.atkcon)
	e4:SetTarget(function(e,c) return c~=e:GetHandler() and c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK) end)
	e4:SetValue(s.atkval)
	c:RegisterEffect(e4)
    local e5=e4:Clone()
    e5:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(e5)
    --Destruction Replace
    local e6=Effect.CreateEffect(c)
    e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e6:SetCode(EFFECT_DESTROY_REPLACE)
    e6:SetRange(LOCATION_MZONE)
    e6:SetTarget(s.reptg)
    e6:SetValue(s.repval)
    c:RegisterEffect(e6)
end
s.counter_list={COUNTER_PUMPKIN}
function s.matfilter(c,scard,sumtype,tp)
	return c:IsLevelBelow(9) and c:IsAttribute(ATTRIBUTE_DARK,scard,sumtype,tp)
end
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	for tc in aux.Next(g) do
		tc:AddCounter(COUNTER_PUMPKIN,1)
	end
end

function s.tgcon(e)
	return #(e:GetHandler():GetLinkedGroup():Filter(Card.IsMonster,nil))>0
end
function s.atkcon(e)
	return e:GetHandler():IsInExtraMZone()
end
function s.atkval(e,c)
	return Duel.GetCounter(0,1,1,COUNTER_PUMPKIN)*200
end

function s.repfilter(c,tp)
	return c:IsLocation(LOCATION_ONFIELD) and c:GetCounter(COUNTER_PUMPKIN)>0
		and not c:IsReason(REASON_REPLACE) and c:IsReason(REASON_EFFECT+REASON_BATTLE)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp) end
	Duel.Hint(HINT_CARD,1-tp,id)
	local g=Group.CreateGroup()
	for tc in aux.Next(eg) do
        if Duel.SelectEffectYesNo(tp,tc,aux.Stringid(id,0)) then
            tc:RemoveCounter(tp,COUNTER_PUMPKIN,1,REASON_EFFECT)
            g:AddCard(tc) 
        end
	end
	g:KeepAlive()
	e:SetLabelObject(g)
	return true
end
function s.repval(e,c)
	return e:GetLabelObject():IsContains(c)
end