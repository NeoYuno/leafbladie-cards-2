--Cantrell Draw
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_END_PHASE,TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
    --to hand
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_JACK_KNIGHT,CARD_KING_KNIGHT,CARD_QUEEN_KNIGHT,id}
function s.filter(c,deckCount)
	return not c:IsCode(id) and c:ListsCode(CARD_JACK_KNIGHT)
        and c:ListsCode(CARD_KING_KNIGHT) and c:ListsCode(CARD_QUEEN_KNIGHT)
		and (c:IsLocation(LOCATION_DECK) and deckCount>1 or not c:IsLocation(LOCATION_DECK) and c:IsAbleToDeck())
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function s.gfilter(c)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsCode(CARD_JACK_KNIGHT,CARD_KING_KNIGHT,CARD_QUEEN_KNIGHT)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(23020408,2))
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,ct):GetFirst()
	if tc then
		if tc:IsLocation(LOCATION_DECK) then
			Duel.ShuffleDeck(tp)
			Duel.MoveSequence(tc,0)
		else 
			Duel.SendtoDeck(tc,nil,0,REASON_EFFECT) 
		end
		if not tc:IsLocation(LOCATION_EXTRA) then
			Duel.ConfirmDecktop(tp,1)
		end
        local g=Duel.GetMatchingGroup(s.gfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
        local ct=g:GetClassCount(Card.GetCode)
        local hg=Duel.GetMatchingGroup(Card.IsDiscardable,tp,LOCATION_HAND,0,nil)
        local dg=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
        if ct>0 and #hg>0 and dg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
            Duel.BreakEffect()
            if dg==1 then ct=1 end
            local d=Duel.DiscardHand(tp,nil,1,ct,REASON_DISCARD+REASON_EFFECT)
            Duel.Draw(tp,d,REASON_EFFECT)
        end
	end
end
function s.tdfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_WARRIOR) and c:IsAbleToDeck()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tdfilter(chkc) end
	if chk==0 then return e:GetHandler():IsAbleToHand()
		and Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	if tc and tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)~=0
		and tc:IsLocation(LOCATION_DECK+LOCATION_EXTRA) and c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end