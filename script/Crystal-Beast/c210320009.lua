--Crystal Cobalt Wing
local s,id=GetID()
function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    c:RegisterEffect(e1)
    --Excavate
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_SZONE)
    e2:SetTarget(s.target)
    e2:SetOperation(s.operation)
    c:RegisterEffect(e2)
end
s.listed_series={0x1034}
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    local tc=Duel.GetDecktopGroup(tp,1):GetFirst()
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) and tc:IsAbleToHand() end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not Duel.IsPlayerCanDiscardDeck(tp,1) then return end
	Duel.ConfirmDecktop(tp,1)
	local tc=Duel.GetDecktopGroup(tp,1):GetFirst()
	if tc:IsSetCard(0x1034) and Duel.SendtoHand(tc,tp,REASON_EFFECT)>0 then 
        if tc:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
            Duel.DisableShuffleCheck()
            Duel.BreakEffect()
            Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
            --Cannot Special Summon monsters with the same name by this effect until the end of the turn
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_FIELD)
            e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
            e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
            e1:SetTargetRange(1,0)
            e1:SetTarget(s.splimit)
            e1:SetLabel(tc:GetCode())
            e1:SetReset(RESET_PHASE+PHASE_END)
            Duel.RegisterEffect(e1,tp)
        end
    else
        Duel.SendtoGrave(tc,REASON_EFFECT)
        --Negate its effects until the end of the turn
        local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e2)
    end
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsCode(e:GetLabel()) and se:GetHandler()==e:GetHandler()
end