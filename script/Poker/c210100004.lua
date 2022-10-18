--Royal Flush
local s,id=GetID()
function s.initial_effect(c)
	--Discard and Search
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_HANDES+CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
    --to hand
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+100)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_JACK_KNIGHT,CARD_KING_KNIGHT,CARD_QUEEN_KNIGHT}
function s.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
function s.rescon(sg,e,tp,mg)
	return sg:FilterCount(s.thfilter,nil,e,tp)==5
		and sg:FilterCount(Card.IsLevel,nil,10)==1 and sg:FilterCount(Card.IsLevel,nil,1)==1
        and sg:FilterCount(Card.IsCode,nil,CARD_JACK_KNIGHT)==1 and sg:FilterCount(Card.IsCode,nil,CARD_KING_KNIGHT)==1
        and sg:FilterCount(Card.IsCode,nil,CARD_QUEEN_KNIGHT)==1
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return aux.SelectUnselectGroup(g,e,tp,5,5,s.rescon,chk) end
	Duel.SetOperationInfo(0,CATEGORY_HANDES,Duel.GetFieldGroup(tp,LOCATION_HAND,0),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,0,tp,LOCATION_DECK)
end
function s.filter(c)
	return c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_LIGHT)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    --Cannot Special Summon from the Extra Deck, except LIGHT Warriors
    local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	if Duel.SendtoGrave(Duel.GetFieldGroup(tp,LOCATION_HAND,0),REASON_EFFECT+REASON_DISCARD)>0 then
        local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_DECK,0,nil)
        local sg=aux.SelectUnselectGroup(g,e,tp,5,5,s.rescon,1,tp,HINTMSG_ATOHAND)
        if #sg>0 and Duel.SendtoHand(sg,tp,REASON_EFFECT)>0 then
            Duel.ConfirmCards(1-tp,sg)
            local og=Duel.GetOperatedGroup()
            if og:FilterCount(s.filter,nil)==#og then
                Duel.BreakEffect()
                Duel.Damage(1-tp,2000,REASON_EFFECT)
            end
        end
    end
end
function s.splimit(e,c)
	return not (c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_WARRIOR)) and c:IsLocation(LOCATION_EXTRA)
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