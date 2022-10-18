--Crystal Ruby Flash
local s,id=GetID()
function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    c:RegisterEffect(e1)
    --Banish
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1)
	e2:SetCondition(s.rmcon)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
    --Special Summon
    local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCountLimit(1)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
s.listed_series={0x1034}
s.listed_names={32710364}
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSetCard,1,nil,0x1034)
end
function s.cbfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x1034)
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_DECK)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
    local g1=Duel.GetMatchingGroup(s.cbfilter,tp,LOCATION_MZONE,0,nil)
    local ct1=g1:GetClassCount(Card.GetCode)
	local ct2=Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)
	local ct3=Duel.GetMatchingGroupCount(aux.AND(Card.IsAbleToRemove,Card.IsFacedown),tp,0,LOCATION_EXTRA,nil)
	if ct1>ct2 then ct1=ct2 end
	if ct1>ct3 then ct1=ct3 end
	if ct1==0 then return end
	if ct3>=ct1 and Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsCode,32710364),tp,LOCATION_MZONE,0,1,nil)
	    and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		local t={}
		for i=1,ct1 do t[i]=i end
		local ac=Duel.AnnounceNumber(tp,table.unpack(t))
		local g=Duel.GetMatchingGroup(aux.AND(Card.IsAbleToRemove,Card.IsFacedown),tp,0,LOCATION_EXTRA,nil)
		local sg=g:RandomSelect(tp,ac)
		Duel.DisableShuffleCheck()
		Duel.Remove(sg,POS_FACEDOWN,REASON_EFFECT)
	else
		local t={}
		for i=1,ct1 do t[i]=i end
		local ac=Duel.AnnounceNumber(tp,table.unpack(t))
		local g=Duel.GetDecktopGroup(1-tp,ac)
		Duel.DisableShuffleCheck()
		Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
	end
end
function s.filter(c,e,tp)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsCode(32710364) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(tp) and s.filter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_SZONE+LOCATION_GRAVE,0,1,nil,e,tp)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_SZONE+LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
	end
end
