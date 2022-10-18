--Cross Change
local s,id=GetID()
function s.initial_effect(c)
	--Special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.sptg)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_NEOS}
s.listed_series={0x1f,0x8}
function s.costchk(ct)
	return function(sg,tp)
		return aux.ChkfMMZ(#sg) and ct:GetClassCount(Card.GetCode)>=#sg
	end
end
function s.tdfilter1(c)
    return c:IsSetCard(0x1f) and c:IsAbleToDeckOrExtraAsCost()
end
function s.spfilter1(c,e,tp)
    return c:IsSetCard(0x8) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.tdfilter2(c)
    return c:IsSetCard(0x8) and c:IsAbleToDeckOrExtraAsCost()
end
function s.spfilter2(c,e,tp)
    return c:IsSetCard(0x1f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local loc=LOCATION_MZONE
	if Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_MZONE,0,1,nil,CARD_NEOS) then
		loc=LOCATION_MZONE+LOCATION_GRAVE
	end

	local g1=Duel.GetMatchingGroup(s.tdfilter1,tp,loc,0,nil)
	local cg1=Duel.GetMatchingGroup(s.spfilter1,tp,LOCATION_DECK,0,nil,e,tp)
	local ct1=#cg1
	local g2=Duel.GetMatchingGroup(s.tdfilter2,tp,loc,0,nil)
	local cg2=Duel.GetMatchingGroup(s.spfilter2,tp,LOCATION_DECK,0,nil,e,tp)
	local ct2=#cg2
	if chk==0 then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<0 then return false end
		return (ct1>0 or ct2>0) and (aux.SelectUnselectGroup(g1,e,tp,1,1,s.costchk(cg1),0) or aux.SelectUnselectGroup(g2,e,tp,1,1,s.costchk(cg2),0))
	end
	local op=0
	if (#g1>0 and ct1>0) and (#g2>0 and ct2>0) then
		op=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
	elseif (#g1>0 and ct1>0) then
		op=Duel.SelectOption(tp,aux.Stringid(id,0))
	else
		op=Duel.SelectOption(tp,aux.Stringid(id,1))+1
	end
	e:SetLabel(op)
	if op==0 then
		if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ct1=1 end
		local sg=aux.SelectUnselectGroup(g1,e,tp,1,3,s.costchk(cg1),1,tp,HINTMSG_TODECK)
		Duel.SendtoDeck(sg,tp,2,REASON_COST)
		e:SetLabel(#sg)
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e:SetProperty(0)
		e:SetOperation(s.spop1)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,#sg,tp,LOCATION_DECK)
	else
		if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ct2=1 end
		local sg=aux.SelectUnselectGroup(g2,e,tp,1,3,s.costchk(cg2),1,tp,HINTMSG_TODECK)
		Duel.SendtoDeck(sg,tp,2,REASON_COST)
		e:SetLabel(#sg)
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e:SetProperty(0)
		e:SetOperation(s.spop2)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,#sg,tp,LOCATION_DECK)
	end
end
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	local ct=e:GetLabel()
	if ft<ct then return end
	local g=Duel.GetMatchingGroup(s.spfilter1,tp,LOCATION_DECK,0,nil,e,tp)
	if #g<ct then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=aux.SelectUnselectGroup(g,e,tp,ct,ct,aux.dncheck,1,tp,HINTMSG_SPSUMMON)
	if #sg>0 then
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	local ct=e:GetLabel()
	if ft<ct then return end
	local g=Duel.GetMatchingGroup(s.spfilter2,tp,LOCATION_DECK,0,nil,e,tp)
	if #g<ct then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=aux.SelectUnselectGroup(g,e,tp,ct,ct,aux.dncheck,1,tp,HINTMSG_SPSUMMON)
	if #sg>0 then
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
