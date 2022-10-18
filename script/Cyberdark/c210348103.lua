--Cyberdark Factory
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
    --Double damage
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.damtg)
	e2:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
	c:RegisterEffect(e2)
    --Activate from deck
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetCondition(s.actcon)
    e3:SetCost(s.actcost)
    e3:SetTarget(s.acttg)
	e3:SetOperation(s.actop)
	c:RegisterEffect(e3)
end
s.listed_names={44352516,77565204,45064756}
s.listed_series={0x4093}
function s.filter(c,tp)
	return c:IsCode(44352516) and c:GetActivateEffect() and c:GetActivateEffect():IsActivatable(tp,true,true)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil,tp)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local tc=g:Select(tp,1,1,nil):GetFirst()
		if aux.PlayFieldSpell(tc,e,tp,eg,ep,ev,re,r,rp) then
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
            e1:SetCode(EVENT_SUMMON_SUCCESS)
            e1:SetRange(LOCATION_FZONE)
            e1:SetOperation(s.cedop)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e1,true)
            local e2=e1:Clone()
            e2:SetCode(EVENT_SPSUMMON_SUCCESS)
            tc:RegisterEffect(e2,true)
            local e3=Effect.CreateEffect(c)
            e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
            e3:SetCode(EVENT_CHAIN_END)
            e3:SetRange(LOCATION_FZONE)
            e3:SetOperation(s.cedop2)
            e3:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e3,true)
        end
    end
end
function s.cfilter(c,tp)
    return c:IsFaceup() and c:IsSetCard(0x4093) and c:IsSummonPlayer(tp)
end
function s.cedop(e,tp,eg,ep,ev,re,r,rp)
    if eg and eg:IsExists(s.cfilter,1,nil,tp) then
        Duel.SetChainLimitTillChainEnd(s.chlimit)
    end
end
function s.cedop2(e,tp,eg,ep,ev,re,r,rp)
    local _,g=Duel.CheckEvent(EVENT_SPSUMMON_SUCCESS,true)
    if g and g:IsExists(s.cfilter,1,nil,tp) and Duel.CheckEvent(EVENT_SPSUMMON_SUCCESS) then
        Duel.SetChainLimitTillChainEnd(s.chlimit)
    end
end
function s.chlimit(re,rp,tp)
    return rp==tp
end
function s.damtg(e,c)
	return c:IsSetCard(0x4093) and c:GetBattleTarget()~=nil
end
function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==1-tp
end
function s.actcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
function s.actfilter(c,tp)
	return c:IsCode(77565204,45064756) and c:GetActivateEffect():IsActivatable(tp,true,true) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
end
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.actfilter,tp,LOCATION_DECK,0,1,nil,tp) end
end
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,s.actfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
    local te=tc:GetActivateEffect()
    if not te:IsActivatable(tp,true,true) or Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
    if Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
        local te=tc:GetActivateEffect()
        local tep=tc:GetControler()
        local cost=te:GetCost()
        if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
    end
end