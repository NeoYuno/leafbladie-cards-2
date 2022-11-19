--Divine Rebirth of the Herald
local s,id=GetID()
function s.initial_effect(c)
	--Ritual summon "Herald of Perfection"
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg1)
	e1:SetOperation(s.spop1)
	c:RegisterEffect(e1)
	--Ritual summon "Herald of Ultimateness"
    local e2=e1:Clone()
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
    c:RegisterEffect(e2)
    --Special summon from gy
    local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,{id,1})
	e3:SetHintTiming(0,TIMING_END_PHASE)
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
end
s.listed_names={44665365,48546368}
function s.rmfilter1(c)
	return c:IsRace(RACE_FAIRY) and c:IsAbleToRemove()
end
function s.spfilter1(c,e,tp)
    return c:IsCode(44665365) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true)
end
function s.rescon(sg,e,tp,mg)
    local sum=sg:GetSum(Card.GetLevel)
	return sg:GetClassCount(Card.GetCode)==3 and sum==6
end
function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local g1=Duel.GetMatchingGroup(s.rmfilter1,tp,LOCATION_GRAVE,0,nil)
    local g2=Duel.GetMatchingGroup(s.spfilter1,tp,LOCATION_HAND+LOCATION_DECK,0,nil,e,tp)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and #g1>0 and #g2>0 and aux.SelectUnselectGroup(g1,e,tp,3,3,s.rescon,0) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,3,tp,LOCATION_GRAVE)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.GetMatchingGroup(s.rmfilter1,tp,LOCATION_GRAVE,0,nil)
    local g2=Duel.GetMatchingGroup(s.spfilter1,tp,LOCATION_HAND+LOCATION_DECK,0,nil,e,tp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local sg1=aux.SelectUnselectGroup(g1,e,tp,3,3,s.rescon,1,tp,HINTMSG_REMOVE)
	if #sg1==0 then return end
    if Duel.Remove(sg1,POS_FACEUP,REASON_EFFECT)==0 then return end
    local sg2=g2:Select(tp,1,1,nil)
    if #sg2==0 then return end
    Duel.SpecialSummon(sg2,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
end
function s.rmfilter2(c)
	return c:IsRace(RACE_FAIRY) and not c:IsSummonableCard() and c:IsAbleToRemove()
end
function s.spfilter2(c,e,tp)
    return c:IsCode(48546368) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true)
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local g1=Duel.GetMatchingGroup(s.rmfilter2,tp,LOCATION_GRAVE,0,nil)
    local g2=Duel.GetMatchingGroup(s.spfilter2,tp,LOCATION_HAND+LOCATION_DECK,0,nil,e,tp)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and #g1>0 and #g2>0 and aux.SelectUnselectGroup(g1,e,tp,3,3,aux.dncheck,0) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,3,tp,LOCATION_GRAVE)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.GetMatchingGroup(s.rmfilter2,tp,LOCATION_GRAVE,0,nil)
    local g2=Duel.GetMatchingGroup(s.spfilter2,tp,LOCATION_HAND+LOCATION_DECK,0,nil,e,tp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local sg1=aux.SelectUnselectGroup(g1,e,tp,3,3,aux.dncheck,1,tp,HINTMSG_REMOVE)
	if #sg1==0 then return end
    if Duel.Remove(sg1,POS_FACEUP,REASON_EFFECT)==0 then return end
    local sg2=g2:Select(tp,1,1,nil)
    if #sg2==0 then return end
    Duel.SpecialSummon(sg2,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
end
function s.spfilter3(c,e,tp)
	return c:IsRace(RACE_FAIRY) and c:IsType(TYPE_RITUAL) and c:IsCanBeSpecialSummoned(e,0,tp,true,false,POS_FACEUP)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.spfilter3(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter3,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter3,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,LOCATION_GRAVE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
        Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
    end
end