--Crystal Hall
local s,id=GetID()
function s.initial_effect(c)
    --Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
    --"Crystal" cards are treated as "Crystal Beasts" in Spell/Trap zones
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_ADD_SETCODE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_SZONE,0)
	e2:SetTarget(s.eftg)
	e2:SetValue(0x1034)
	c:RegisterEffect(e2)
    --Reset flag
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTarget(s.tg)
	e3:SetOperation(s.op)
	c:RegisterEffect(e3)
    --Apply effect
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCost(s.cost)
	e4:SetOperation(s.operation)
	c:RegisterEffect(e4)
end
s.listed_series={0x34,0x1034}
s.listed_names={34487429,12644061,79856792,79407975}
function s.rrfilter(c,tp)
	return c:IsCode(34487429) and c:GetActivateEffect() and c:GetActivateEffect():IsActivatable(tp,true)
end
function s.adfilter(c,tp)
	return c:IsCode(12644061) and c:GetActivateEffect() and c:GetActivateEffect():IsActivatable(tp,true)
end
function s.rdfilter(c)
    return c:IsCode(79856792) and c:IsAbleToHand()
end
function s.rddfilter(c)
    return c:IsCode(79407975) and c:IsAbleToHand()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local frr=Duel.GetMatchingGroup(s.rrfilter,tp,LOCATION_DECK,0,nil,tp)
	local fad=Duel.GetMatchingGroup(s.adfilter,tp,LOCATION_DECK,0,nil,tp)
    if (#frr==0 and #fad==0) or not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then return end
    local op=nil
    if #frr>0 and #fad>0 then 
        op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
    elseif #frr>0 and #fad==0 then 
        op=Duel.SelectOption(tp,aux.Stringid(id,1))
    else
        op=Duel.SelectOption(tp,aux.Stringid(id,2))+1
    end
    if op==0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local tc=frr:Select(tp,1,1,nil):GetFirst()
		if Duel.ActivateFieldSpell(tc,e,tp,eg,ep,ev,re,r,rp) then
            local g=Duel.GetMatchingGroup(s.rdfilter,tp,LOCATION_DECK,0,nil,tp)
            if #g==0 or not Duel.SelectYesNo(tp,aux.Stringid(id,3)) then return end
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
            local sg=g:Select(tp,1,1,nil)
            Duel.SendtoHand(sg,tp,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,sg)
        end
    else
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local tc=fad:Select(tp,1,1,nil):GetFirst()
		if Duel.ActivateFieldSpell(tc,e,tp,eg,ep,ev,re,r,rp) then
            local g=Duel.GetMatchingGroup(s.rddfilter,tp,LOCATION_DECK,0,nil,tp)
            if #g==0 or not Duel.SelectYesNo(tp,aux.Stringid(id,4)) then return end
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
            local sg=g:Select(tp,1,1,nil)
            Duel.SendtoHand(sg,tp,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,sg)
        end
    end
end
function s.eftg(e,c)
	local c=e:GetHandler()
	return c:IsFaceup() and c:IsSetCard(0x34) and c:GetSequence()<5
end
function s.filter(c,e)
	return c:IsCode(79856792) and c:IsCanBeEffectTarget(e)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and s.filter(chkc,e) end
	if chk==0 then return eg:IsExists(s.filter,1,nil,e) end
    if #eg==1 then
		Duel.SetTargetCard(eg:GetFirst())
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
		local g=eg:Select(tp,1,1,nil)
		Duel.SetTargetCard(g)
	end
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		tc:ResetFlagEffect(tc:GetCode())
	end
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e1:SetCountLimit(1)
	e1:SetCondition(s.tfcon)
	e1:SetOperation(s.tfop)
	e1:SetReset(RESET_PHASE+PHASE_BATTLE_START)
	Duel.RegisterEffect(e1,tp)
end
function s.cbfilter(c,e,tp)
    return c:IsFaceup() and c:IsSetCard(0x1034) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.tfcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cbfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp)
end
function s.tfop(e,tp,eg,ep,ev,re,r,rp)
    local ct=Duel.GetLocationCount(tp,LOCATION_MZONE)+Duel.GetLocationCount(tp,LOCATION_SZONE)
    local g=Duel.GetMatchingGroup(s.cbfilter,tp,LOCATION_REMOVED,0,nil,e,tp)
    if not aux.SelectUnselectGroup(g,e,tp,1,#g,aux.dncheck,0) or not Duel.SelectYesNo(tp,aux.Stringid(id,5)) then return end
    local sg=aux.SelectUnselectGroup(g,e,tp,1,ct,aux.dncheck,1,tp,HINTMSG_FACEUP)
	for tc in aux.Next(sg) do
		tc=sg:Select(tp,1,1,nil):GetFirst()
		local op=nil
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then 
			op=Duel.SelectOption(tp,aux.Stringid(id,6),aux.Stringid(id,7))
		elseif Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then 
			op=Duel.SelectOption(tp,aux.Stringid(id,6))
		else
			op=Duel.SelectOption(tp,aux.Stringid(id,7))+1
		end
		if op==0 then
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
			sg:RemoveCard(tc)
			sg:KeepAlive()
			if #sg==0 then return end
		else
			Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetCode(EFFECT_CHANGE_TYPE)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
			e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
			tc:RegisterEffect(e1)
			sg:RemoveCard(tc)
			sg:KeepAlive()
			if #sg==0 then return end
		end
		Duel.RaiseEvent(sg,EVENT_CUSTOM+47408488,e,0,tp,0,0)
	end
end