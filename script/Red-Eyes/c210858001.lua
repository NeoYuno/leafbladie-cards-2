--Red-Eyes Duel Armor
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Negate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
    --Special Summon
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
    --To hand
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id)
	e3:SetCost(s.thcost)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
s.listed_names={CARD_REDEYES_B_DRAGON}
s.listed_series={0x3b}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and re:IsActiveType(TYPE_MONSTER) and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.NegateActivation(ev) and c:IsRelateToEffect(e) and c:IsFaceup() then
        --Immune
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_IMMUNE_EFFECT)
        e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
        e1:SetRange(LOCATION_MZONE)
        e1:SetValue(s.immval)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        c:RegisterEffect(e1)
    end
end
function s.immval(e,te)
	return te:GetOwner()~=e:GetHandler() and te:IsActiveType(TYPE_MONSTER) and e:GetHandlerPlayer()~=te:GetHandlerPlayer() and te:IsActivated()
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsSummonType(SUMMON_TYPE_RITUAL)
end
function s.rescon(sg,e,tp,mg)
	return aux.ChkfMMZ(1)(sg,e,tp,mg) and sg:IsExists(Card.IsType,1,nil,TYPE_NORMAL)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x3b) and c:IsType(TYPE_MONSTER) and c:GetAttack()<2800 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) 
        and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and aux.SelectUnselectGroup(g,1,tp,1,2,s.rescon,0) 
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
    local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	local sg=aux.SelectUnselectGroup(g,1,tp,1,2,s.rescon,1,tp,HINTMSG_SPSUMMON) 
	if #sg<=0 then return end
	Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
end
function s.cfilter(c)
	return c:IsCode(CARD_REDEYES_B_DRAGON) and c:IsAbleToGraveAsCost()
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
	end
end