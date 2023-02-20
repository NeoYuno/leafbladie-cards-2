--The Hermit's Solitude
local s,id=GetID()
function s.initial_effect(c)
    --Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Protection
	local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.eftg)
	e2:SetOperation(s.efop)
	c:RegisterEffect(e2)
    --Special Summon
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
s.toss_coin=true
s.listed_names={CARD_LIGHT_BARRIER}
s.listed_series={SET_ARCANA_FORCE}
--[Protection]
function s.eftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end
function s.efop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local sel
	if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_LIGHT_BARRIER),tp,LOCATION_FZONE,0,1,nil) then
		local op=Duel.SelectOption(tp,aux.GetCoinEffectHintString(COIN_HEADS),aux.GetCoinEffectHintString(COIN_TAILS))
		if op==0 then
			sel=COIN_HEADS
		elseif op==1 then
			sel=COIN_TAILS
		else
			return
		end
	else
		sel=Duel.TossCoin(tp,1)
	end
	if sel==COIN_HEADS then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
        e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
        e1:SetTargetRange(LOCATION_ONFIELD,0)
        e1:SetValue(aux.tgoval)
        e1:SetReset(RESET_PHASE+PHASE_END,2)
        Duel.RegisterEffect(e1,tp)
        aux.RegisterClientHint(c,nil,tp,0,1,aux.Stringid(id,3),nil)
	elseif sel==COIN_TAILS then
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_FIELD)
        e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
        e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
        e2:SetTargetRange(0,LOCATION_ONFIELD)
        e2:SetValue(aux.tgoval(e,re,rp==tp))
        e2:SetReset(RESET_PHASE+PHASE_END,2)
        Duel.RegisterEffect(e2,tp)
        aux.RegisterClientHint(c,nil,tp,1,0,aux.Stringid(id,3),nil)
	end
end
function s.tglimit(e,re,rp)
    return rp==e:GetHandlerPlayer()
end
--[Special Summon]
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_ARCANA_FORCE) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.selchk(tp)
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local loc=LOCATION_HAND+LOCATION_GRAVE
	if s.selchk(tp) then loc=loc+LOCATION_DECK end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,loc,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,loc)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if s.selchk(tp) and not Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) then
		loc=LOCATION_DECK
	else
		if s.selchk(tp) and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			loc=LOCATION_DECK
		else
			loc=LOCATION_HAND+LOCATION_GRAVE
		end
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,loc,0,1,1,nil,e,tp)
	if #g>0 then 
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end