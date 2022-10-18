--Mettaton EX the Underground Star
local COUNTER_LV=0x1950
local s,id=GetID()
function s.initial_effect(c)
    c:SetUniqueOnField(1,0,aux.FilterBoolFunction(Card.IsSetCard,0x0f4b),LOCATION_MZONE)
    --Destroy replace
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_NO_TURN_RESET)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(s.reptg)
	c:RegisterEffect(e1)
	--Counter
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_BE_BATTLE_TARGET)
    e2:SetCondition(s.ctcon)
	e2:SetTarget(s.cttg)
	e2:SetOperation(s.ctop)
	c:RegisterEffect(e2)
	--ATK up
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.atkcon)
	e3:SetValue(s.atkval)
	c:RegisterEffect(e3)
	--Unaffected
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_IMMUNE_EFFECT)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.uncon)
	e4:SetValue(s.efilter)
	c:RegisterEffect(e4)
	--Attack limit
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e5:SetCondition(s.con)
	e5:SetValue(s.limit)
	c:RegisterEffect(e5)
	--Cannot target
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e6:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e6:SetRange(LOCATION_MZONE)
	e6:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e6:SetCondition(s.con)
	e6:SetTarget(s.limit)
	e6:SetValue(aux.tgoval)
	c:RegisterEffect(e6)
end
s.counter_place_list={COUNTER_LV}
s.listed_names={210144001}
s.listed_series={0x0f4b}
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsReason(REASON_REPLACE) and (c:IsReason(REASON_EFFECT) or c:IsReason(REASON_BATTLE))
		and c:GetDefense()>=500 end
	if Duel.SelectEffectYesNo(tp,c,96) then
        local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_DEFENSE)
		e1:SetValue(-500)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
		return true
	else return false end
end

function s.ctcon(e)
	return Duel.GetMatchingGroupCount(Card.IsMonster,e:GetHandlerPlayer(),LOCATION_MZONE,LOCATION_MZONE,nil)>1
	    and Duel.GetAttacker():IsCode(210144001)
end
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local at=Duel.GetAttacker()
	if chk==0 then return at and at:IsFaceup() and at:IsRelateToBattle() end
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local at=Duel.GetAttacker()
	if at:GetCounter(COUNTER_LV)==19 or not (at:IsFaceup() and at:IsLocation(LOCATION_MZONE)) then return end
	if at:IsCanAddCounter(COUNTER_LV,7) then
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

function s.atkcon(e)
	return Duel.GetMatchingGroupCount(Card.IsMonster,e:GetHandlerPlayer(),LOCATION_MZONE,LOCATION_MZONE,nil)>2
end
function s.atkval(e,c)
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,LOCATION_MZONE)*200
end

function s.uncon(e)
	return Duel.GetMatchingGroupCount(Card.IsMonster,e:GetHandlerPlayer(),LOCATION_MZONE,LOCATION_MZONE,nil)>3
end
function s.efilter(e,re)
	return e:GetOwnerPlayer()~=re:GetOwnerPlayer() and re:IsActivated() and not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET)
end

function s.con(e)
	return Duel.GetMatchingGroupCount(Card.IsMonster,e:GetHandlerPlayer(),LOCATION_MZONE,LOCATION_MZONE,nil)>4
end
function s.limit(e,c)
	return not c:IsCode(id)
end