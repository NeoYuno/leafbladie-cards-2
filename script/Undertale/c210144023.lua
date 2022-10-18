--Undyne the Undying
local COUNTER_LV=0x1950
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Cannot Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
    --Equip
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)
    --Actlimit
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetTargetRange(0,1)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.actcon)
	e3:SetValue(1)
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
    --Destroy replace
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_NO_TURN_RESET)
	e5:SetCode(EFFECT_DESTROY_REPLACE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTarget(s.reptg)
	c:RegisterEffect(e5)
end
s.counter_place_list={COUNTER_LV}
s.listed_names={210144001,210144018,210144070}
function s.eqsfilter(c,tp,ec)
	return c:IsCode(210144070) and c:CheckEquipTarget(ec) and c:CheckUniqueOnField(tp)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.eqsfilter,tp,LOCATION_DECK,0,1,nil,tp,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,0,LOCATION_DECK)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(s.eqsfilter,tp,LOCATION_DECK,0,nil,tp,c)
	if #g==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local sg=g:Select(tp,1,1,nil)
	if #sg>0 then
		Duel.Equip(tp,sg:GetFirst(),c,true,true)
	end
    Duel.EquipComplete()
end

function s.actcon(e)
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
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

function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsReason(REASON_REPLACE) and (c:IsReason(REASON_EFFECT) or c:IsReason(REASON_BATTLE))
		and c:GetDefense()>=1000 end
	if Duel.SelectEffectYesNo(tp,c,96) then
        local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
        local e2=e1:Clone()
        e2:SetCode(EFFECT_UPDATE_DEFENSE)
		e2:SetValue(-1000)
        c:RegisterEffect(e2)
		return true
	else return false end
end