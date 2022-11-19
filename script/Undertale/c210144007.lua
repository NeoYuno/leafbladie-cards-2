--Froggit the Underground Novice
local COUNTER_LV=0x1950
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
    --Counter
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_COUNTER)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_BE_BATTLE_TARGET)
    e3:SetCondition(s.ctcon)
	e3:SetTarget(s.cttg)
	e3:SetOperation(s.ctop)
	c:RegisterEffect(e3)
end
s.counter_place_list={COUNTER_LV}
s.listed_names={210144001}
s.listed_series={0x0f4a}
function s.spfilter(c,e,tp,lv)
	return c:IsSetCard(0x0f4a) and c:IsLevelBelow(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
        local ct=Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsSetCard,0x0f4a),tp,LOCATION_MZONE,0,nil)
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,ct) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or not (c:IsFaceup() and c:IsLocation(LOCATION_MZONE)) then return end
	if not c:IsRelateToEffect(e) then return end
	local ct=Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsSetCard,0x0f4a),tp,LOCATION_MZONE,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,ct)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetAttacker():IsCode(210144001)
end
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local at=Duel.GetAttacker()
	if chk==0 then return at and at:IsFaceup() and at:IsRelateToBattle() end
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local at=Duel.GetAttacker()
	if at:GetCounter(COUNTER_LV)==19 or not (at:IsFaceup() and at:IsLocation(LOCATION_MZONE)) then return end
	if at:IsCanAddCounter(COUNTER_LV,2) then
		Duel.Hint(HINT_CARD,tp,id)
		at:AddCounter(COUNTER_LV,2)
	elseif at:IsCanAddCounter(COUNTER_LV,1) then
		Duel.Hint(HINT_CARD,tp,id)
		at:AddCounter(COUNTER_LV,1)
	end
end