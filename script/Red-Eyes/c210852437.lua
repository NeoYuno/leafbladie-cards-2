--Red-Eyes Graverobber
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(s.condition)
    e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={0x3b}
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x3b)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,1500) end
	Duel.PayLPCost(tp,1500)
end
function s.filter(c,e,tp)
	if c:IsType(TYPE_MONSTER) then
		return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
    elseif c:IsType(TYPE_SPELL) then
        return c:IsAbleToHand()
    else
		local ct=Duel.GetLocationCount(tp,LOCATION_SZONE)
		if e:IsHasType(EFFECT_TYPE_ACTIVATE) and not e:GetHandler():IsLocation(LOCATION_SZONE) then ct=ct-1 end
		return c:IsSSetable(true) and (c:IsType(TYPE_FIELD) or ct>0)
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and s.filter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_GRAVE,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_GRAVE,1,1,nil,e,tp)
	if g:GetFirst():IsType(TYPE_MONSTER) then
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
    elseif g:GetFirst():IsType(TYPE_SPELL) then
        Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
    else
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	if tc:IsType(TYPE_MONSTER) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
    elseif tc:IsType(TYPE_SPELL) then
        Duel.SendtoHand(tc,tp,REASON_EFFECT)
	else
        if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
		Duel.SSet(tp,tc)
        local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end