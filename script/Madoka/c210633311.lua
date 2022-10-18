--Madoka's Friends
--updated by pyrQ
function c210633311.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,210633311)
	e1:SetTarget(c210633311.target)
	e1:SetOperation(c210633311.operation)
	c:RegisterEffect(e1)
end
c210633311.listed_names={210633306}
function c210633311.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xf73)
end
function c210633311.filter1(c,tp)
	return not c:IsCode(210633306) and c:IsSetCard(0xf72) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function c210633311.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local op=1
	if Duel.IsExistingMatchingCard(c210633311.cfilter,tp,LOCATION_ONFIELD,0,1,nil) then op=2 end
	if chk==0 then
		if op==1 then return Duel.IsExistingMatchingCard(c210633311.filter1,tp,LOCATION_DECK,0,1,nil,tp)
		elseif op==2 then return Duel.IsExistingMatchingCard(c210633311.filter1,tp,LOCATION_DECK,0,2,nil,tp) end
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,op,tp,LOCATION_DECK)
end
function c210633311.operation(e,tp,eg,ep,ev,re,r,rp)
	local op=1
	if Duel.IsExistingMatchingCard(c210633311.cfilter,tp,LOCATION_ONFIELD,0,1,nil) then op=2 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g1=Duel.SelectMatchingCard(tp,c210633311.filter1,tp,LOCATION_DECK,0,op,op,nil,tp)
	if #g1>0 then
		Duel.SendtoHand(g1,tp,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g1)
	end
end