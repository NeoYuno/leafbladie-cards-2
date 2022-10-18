--Venom Burst
local s,id=GetID()
function s.initial_effect(c)
	--Destroy and special summon
	local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.destg)
    e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
    --Distribute Counters
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.target)
    e2:SetOperation(s.operation)
    c:RegisterEffect(e2)
end
s.listed_series={0x50}
s.listed_names={72677437,8062132}
s.counter_list={COUNTER_VENOM}
function s.desfilter(c,e,tp)
	local atk=c:GetAttack()
	return atk>0 and c:IsFaceup() and c:IsDestructable() and (c:IsControler(tp) or (c:IsControler(1-tp) and c:GetCounter(COUNTER_VENOM)>0))
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,atk,e,tp)
end
function s.spfilter(c,atk,e,tp)
	return c:IsAttackBelow(atk) and c:IsSetCard(0x50) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.desfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.rescon(atk)
	return function(sg,e,tp,mg)
		return sg:GetSum(Card.GetAttack)<=atk and sg:GetClassCount(Card.GetCode)==#sg
	end
end
function s.cfilter(c)
	return c:IsFacedown() or not c:IsRace(RACE_REPTILE)
end
function s.vfilter(c,e,tp)
    return c:IsCode(72677437) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
    if Duel.Destroy(tc,REASON_EFFECT)>0 then
        local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
        if ft<=0 then return end
        if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
        local satk=tc:GetAttack()
        local sg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil,satk,e,tp)
        if #sg==0 then return end
        local tg=aux.SelectUnselectGroup(sg,e,tp,1,ft,s.rescon(satk),1,tp,HINTMSG_SPSUMMON)
        if not Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEUP) then return end
        if Duel.GetFieldGroupCount(tp,LOCATION_MZONE+LOCATION_GRAVE,0)>0 
            and not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil)
            and Duel.IsExistingMatchingCard(s.vfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp)
            and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
            local sc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.vfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
            Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
        end
    end
    local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,3))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	--lizard check
	aux.addTempLizardCheck(e:GetHandler(),tp,s.lizfilter)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsRace(RACE_REPTILE) and c:IsLocation(LOCATION_EXTRA)
end
function s.lizfilter(e,c)
	return not c:IsOriginalRace(RACE_REPTILE)
end
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x50) or c:IsCode(72677437,8062132)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=Duel.GetMatchingGroupCount(s.filter,tp,LOCATION_MZONE,0,nil)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if ct>0 then
		for i=1,ct do
			local sg=g:Select(tp,1,1,nil)
			sg:GetFirst():AddCounter(COUNTER_VENOM,1)
		end
    end
end