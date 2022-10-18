--Incubator's Contract
--updated by pyrQ
function c210633310.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c210633310.target)
	e1:SetOperation(c210633310.operation)
	c:RegisterEffect(e1)
end
c210633310.listed_names={210633301}
function c210633310.filter1(c)
	return c:IsFaceup() and c:IsSetCard(0xf72)
end
function c210633310.filter2(c,tp)
	return c:IsAbleToHand() and c:IsCode(210633301)
		and (c:IsFaceup() or c:IsLocation(LOCATION_DECK))
		and Duel.IsExistingMatchingCard(c210633310.filter3,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,c)
end
function c210633310.filter3(c)
	return c:IsAbleToHand() and c:IsSetCard(0xf72) and c:IsType(TYPE_MONSTER) and (c:IsFaceup() or c:IsLocation(LOCATION_DECK))
end
function c210633310.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c210633310.filter1,tp,LOCATION_ONFIELD,0,1,nil)
		and Duel.IsExistingMatchingCard(c210633310.filter2,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,tp) end
	local g=Duel.GetMatchingGroup(c210633310.filter1,tp,LOCATION_ONFIELD,0,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK+LOCATION_EXTRA)
end
function c210633310.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local dg=Duel.SelectMatchingCard(tp,c210633310.filter1,tp,LOCATION_ONFIELD,0,1,1,nil)
	if #dg>0 and Duel.Destroy(dg,REASON_EFFECT)~=0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g1=Duel.SelectMatchingCard(tp,c210633310.filter2,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,tp)
		if #g1>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local g2=Duel.SelectMatchingCard(tp,c210633310.filter3,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,g1)
			g1=g1+g2
			Duel.SendtoHand(g1,tp,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g1)
		end
	end
end