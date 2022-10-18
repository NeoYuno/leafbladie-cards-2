--GEM Burst
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
    --Shuffle and destroy
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TODECK+CATEGORY_DESTROY+CATEGORY_DAMAGE)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetTarget(s.tg)
    e2:SetOperation(s.op)
    c:RegisterEffect(e2)
end
s.listed_series={0x1034,0x2034}
s.listed_names={210320004,210320005,210320006}
function s.cfilter(c)
	return c:IsCode(210320004,210320005,210320006) and c:IsAbleToRemoveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_GRAVE,0,nil)
    if #g>0 then
        Duel.Remove(g,POS_FACEUP,REASON_COST)
    end
end
function s.filter(c)
	return c:IsSetCard(0x2034) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.tdfilter(c)
	return c:IsCode(210320004,210320005,210320006) and c:IsAbleToDeck()
end
function s.tffilter(c)
    return c:IsSetCard(0x1034) and not c:IsForbidden()
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g1=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_REMOVED,0,nil)
    local g2=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_SZONE,LOCATION_SZONE,nil)
    local g3=Duel.GetMatchingGroup(s.tffilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,nil)
    local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
    if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_REMOVED,0,1,nil)
        and #g1>0 and #g2>0 and aux.SelectUnselectGroup(g3,e,tp,1,ft,aux.dncheck,0) end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,g1,#g1,tp,LOCATION_REMOVED)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g2,#g2,0,LOCATION_SZONE)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
    local g1=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_REMOVED,0,nil)
    local g2=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_SZONE,LOCATION_SZONE,nil)
    local g3=Duel.GetMatchingGroup(s.tffilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,nil)
    if Duel.SendtoDeck(g1,tp,2,REASON_EFFECT)>0 and Duel.Destroy(g2,REASON_EFFECT)>0 and #g3>0 then
        g3:Merge(Duel.GetOperatedGroup())
        local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
        local sg=aux.SelectUnselectGroup(g3,e,tp,1,ft,aux.dncheck,1,tp,HINTMSG_TOFIELD)
        for tc in aux.Next(sg) do
            Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetCode(EFFECT_CHANGE_TYPE)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
			e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
			tc:RegisterEffect(e1)
		end
		Duel.RaiseEvent(sg,EVENT_CUSTOM+47408488,e,0,tp,0,0)
        local g4=Duel.GetMatchingGroup(aux.FilterFaceupFunction(Card.IsSetCard,0x1034),tp,LOCATION_SZONE,0,nil)
        if #g4>0 then
            Duel.BreakEffect()
            Duel.Damage(1-tp,#g4*500,REASON_EFFECT)
        end
    end
end