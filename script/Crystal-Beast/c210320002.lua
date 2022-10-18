--Crystal Calling
local s,id=GetID()
function s.initial_effect(c)
    --Place a "Crystal Beast" from hand or field
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.pctg)
    e1:SetOperation(s.pcop)
    c:RegisterEffect(e1)
    --Return to hand
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCondition(aux.exccon)
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
end
s.listed_series={0x1034}
s.listed_names={87475570,14469229}
--Place a "Crystal Beast" from hand or field
function s.pcfilter(c)
	return c:IsSetCard(0x1034) and c:IsType(TYPE_MONSTER) and (c:IsFaceup() or c:IsLocation(LOCATION_HAND)) and not c:IsForbidden()
end
function s.thfilter(c)
	return c:IsCode(87475570,14469229) and (c:IsFaceup() or c:IsLocation(LOCATION_DECK+LOCATION_GRAVE)) and c:IsAbleToHand()
end
function s.thcheck(sg,e,tp)
	return sg:GetClassCount(Card.GetCode)==#sg
end
function s.pctg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.pcfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,nil)
        and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil)
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_EXTRA)
end
function s.pcop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,s.pcfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,1,nil)
    if g:GetFirst():IsLocation(LOCATION_MZONE) then Duel.HintSelection(g) end
	local tc=g:GetFirst()
	if tc then
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
		Duel.RaiseEvent(tc,EVENT_CUSTOM+47408488,e,0,tp,0,0)
        if tc:IsLocation(LOCATION_SZONE) then
            local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_EXTRA,0,nil)
            if #g==0 then return end
            local sg=aux.SelectUnselectGroup(g,e,tp,1,2,s.thcheck,1,tp,HINTMSG_ATOHAND)
            if #sg>0 then
                Duel.SendtoHand(sg,tp,REASON_EFFECT)
                Duel.ConfirmCards(1-tp,sg)
            end
        end
	end
end
--Return to hand
function s.thfilter2(c,e)
    return c:IsFaceup() and c:IsSetCard(0x34) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand() and c:IsCanBeEffectTarget(e)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local thg=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
    if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(tp) and s.thfilter2(chkc,e) end
    if chk==0 then return Duel.IsExistingTarget(s.thfilter2,tp,LOCATION_ONFIELD,0,1,nil,e)
        and #thg>0 end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
    local g=Duel.SelectTarget(tp,s.thfilter2,tp,LOCATION_ONFIELD,0,1,99,nil,e)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,thgh,1,1-tp,LOCATION_MZONE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetTargetCards(e)
    for tc in aux.Next(g) do 
        Duel.SendtoHand(tc,nil,REASON_EFFECT)
    end
    local og=Duel.GetOperatedGroup()
    if #og>0 then
        local thg=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
        local sg=thg:Select(tp,1,#og,nil)
        Duel.HintSelection(sg)
        Duel.SendtoHand(sg,nil,REASON_EFFECT)
    end
end