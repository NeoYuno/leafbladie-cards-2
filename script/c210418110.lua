--Darkness Shield
local s,id=GetID()
local COUNTER_PUMPKIN=0x1902
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
    --DEF Up
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK))
	e2:SetValue(s.defval)
	c:RegisterEffect(e2)
    --Unaffected by activated effect
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetTarget(s.etarget)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetValue(s.unaval)
	c:RegisterEffect(e3)
end
s.counter_list={COUNTER_PUMPKIN}
function s.cfilter(c)
	local atk=c:GetAttack()
    local def=c:GetDefense()
    return (atk%50~=0 or def%50~=0) and c:IsAttribute(ATTRIBUTE_DARK) and (c:IsAbleToHand() or c:IsAbleToGrave())
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_DECK,0,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
        local tc=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
        aux.ToHandOrElse(tc,tp)
	end
end
function s.defval(e,c)
	return Duel.GetCounter(0,1,1,COUNTER_PUMPKIN)*300
end
function s.etarget(e,c)
    return c:GetCounter(COUNTER_PUMPKIN)>0 and c:IsDefensePos()
end
function s.unaval(e,te)
	local tc=te:GetOwner()
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer() and te:IsActiveType(TYPE_MONSTER) and te:IsActivated()
end