--Mettaton Neo
local COUNTER_LV=0x1950
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
    c:SetUniqueOnField(1,0,aux.FilterBoolFunction(Card.IsSetCard,0x0f4b),LOCATION_MZONE)
	--Cannot Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
    --Immune
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.efilter)
	c:RegisterEffect(e2)
    --Change position
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e3:SetCode(EVENT_PHASE+PHASE_END)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
    e3:SetCondition(s.defcon)
    e3:SetTarget(s.deftg)
    e3:SetOperation(s.defop)
    c:RegisterEffect(e3)
    --Counter
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_COUNTER)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e4:SetCode(EVENT_BE_BATTLE_TARGET)
    e4:SetCondition(s.ctcon)
	e4:SetTarget(s.cttg)
	e4:SetOperation(s.ctop)
	c:RegisterEffect(e4)
end
s.counter_place_list={COUNTER_LV}
s.listed_names={210144001,210144016}
s.listed_series={0x0f4b}
function s.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end

function s.defcon(e,tp,eg,ep,ev,re,r,rp)
	return tp==Duel.GetTurnPlayer()
end
function s.deftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,e:GetHandler(),1,0,0)
end
function s.defop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
end

function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetAttacker():IsCode(210144001)
end
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local at=Duel.GetAttacker()
	if chk==0 then return at and at:IsFaceup() and at:IsRelateToBattle() end
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local at=Duel.GetAttacker()
	if at:GetCounter(COUNTER_LV)==19 or not (at:IsFaceup() and at:IsLocation(LOCATION_MZONE)) then return end
	if at:IsCanAddCounter(COUNTER_LV,10) then
		Duel.Hint(HINT_CARD,tp,id)
		at:AddCounter(COUNTER_LV,10)
	elseif at:IsCanAddCounter(COUNTER_LV,9) then
		Duel.Hint(HINT_CARD,tp,id)
		at:AddCounter(COUNTER_LV,9)
	elseif at:IsCanAddCounter(COUNTER_LV,8) then
		Duel.Hint(HINT_CARD,tp,id)
		at:AddCounter(COUNTER_LV,8)
	elseif at:IsCanAddCounter(COUNTER_LV,7) then
		Duel.Hint(HINT_CARD,tp,id)
		at:AddCounter(COUNTER_LV,7)
	elseif at:IsCanAddCounter(COUNTER_LV,6) then
		Duel.Hint(HINT_CARD,tp,id)
		at:AddCounter(COUNTER_LV,6)
	elseif at:IsCanAddCounter(COUNTER_LV,5) then
		Duel.Hint(HINT_CARD,tp,id)
		at:AddCounter(COUNTER_LV,5)
	elseif at:IsCanAddCounter(COUNTER_LV,4) then
		Duel.Hint(HINT_CARD,tp,id)
		at:AddCounter(COUNTER_LV,4)
	elseif at:IsCanAddCounter(COUNTER_LV,3) then
		Duel.Hint(HINT_CARD,tp,id)
		at:AddCounter(COUNTER_LV,3)
	elseif at:IsCanAddCounter(COUNTER_LV,2) then
		Duel.Hint(HINT_CARD,tp,id)
		at:AddCounter(COUNTER_LV,2)
	elseif at:IsCanAddCounter(COUNTER_LV,1) then
		Duel.Hint(HINT_CARD,tp,id)
		at:AddCounter(COUNTER_LV,1)
    end
end