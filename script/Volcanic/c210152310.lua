--Volcanic Mine
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsMainPhase()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    local p=Duel.GetTurnPlayer()
	local ft=Duel.GetLocationCount(p,LOCATION_MZONE)
	if chk==0 then return ft>0
		and Duel.IsPlayerCanSpecialSummonMonster(p,511004107,0,0,1000,1000,1,RACE_PYRO,ATTRIBUTE_FIRE) end
	if Duel.IsPlayerAffectedByEffect(p,CARD_BLUEEYES_SPIRIT) then ft=1 end
	local ft=Duel.GetLocationCount(p,LOCATION_MZONE)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,ft,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,ft,p,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local p=Duel.GetTurnPlayer()
	local ft=Duel.GetLocationCount(p,LOCATION_MZONE)
	if ft<=0 or not Duel.IsPlayerCanSpecialSummonMonster(p,511004107,0,0,1000,1000,1,RACE_PYRO,ATTRIBUTE_FIRE) then return end
	if Duel.IsPlayerAffectedByEffect(p,CARD_BLUEEYES_SPIRIT) then ft=1 end
	local fid=e:GetHandler():GetFieldID()
	for i=1,ft do
		local token=Duel.CreateToken(p,511004107)
		Duel.SpecialSummonStep(token,0,tp,p,false,false,POS_FACEUP_DEFENSE)
		token:RegisterFlagEffect(51104114,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
        --
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
        e1:SetTargetRange(1,0)
        e1:SetTarget(s.splimit)
        if Duel.GetCurrentPhase()==PHASE_MAIN1 then
            e1:SetReset(RESET_PHASE+PHASE_MAIN1)
        else
            e1:SetReset(RESET_PHASE+PHASE_MAIN2)
        end
        if Duel.GetCurrentPhase()==PHASE_MAIN1 then
            Duel.RegisterFlagEffect(p,id,RESET_PHASE+PHASE_MAIN1,0,1)
        else
            Duel.RegisterFlagEffect(p,id,RESET_PHASE+PHASE_MAIN2,0,1)
        end
        Duel.RegisterEffect(e1,p)
        --Damage
        local e2=Effect.CreateEffect(e:GetHandler())
        e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
        e2:SetCode(EVENT_LEAVE_FIELD)
        e2:SetOperation(s.damop)
        token:RegisterEffect(e2,true)
	end
	Duel.SpecialSummonComplete()
end
function s.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsReason(REASON_DESTROY) then
		Duel.Damage(c:GetPreviousControler(),500,REASON_EFFECT)
	end
	e:Reset()
end