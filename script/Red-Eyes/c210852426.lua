--Red-Eyes Darkness Metal Plus Dragon
local s,id=GetID()
function s.initial_effect(c)
	--Link summon
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x3b),2)
	c:EnableReviveLimit()
    --Special summon
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_FIELD)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e0:SetCode(EFFECT_SPSUMMON_PROC)
    e0:SetRange(LOCATION_EXTRA)
    e0:SetCountLimit(1,id)
    e0:SetCondition(s.spcon)
    e0:SetOperation(s.spop)
    e0:SetValue(SUMMON_TYPE_LINK+1)
    c:RegisterEffect(e0)
    --ATK Boost
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.val)
	c:RegisterEffect(e1)
    --Immune
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EFFECT_IMMUNE_EFFECT)
    e2:SetValue(s.efilter)
    c:RegisterEffect(e2)
    --Negate Spell/Trap or effect
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.discon)
    e3:SetCost(s.discost)
	e3:SetTarget(s.distg)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
end
s.listed_series={0x3b}
function s.lkfilter(c)
    return c:IsFaceup() and (c:IsLevelAbove(7) or c:IsRankAbove(7)) and c:IsSetCard(0x3b) and c:IsRace(RACE_DRAGON) and c:GetEquipCount()>0 and c:IsAbleToGrave()
end
function s.spcon(e,c,sc)
    if c==nil then return true end
    local tp=c:GetControler()
    local rg=Duel.GetMatchingGroup(s.lkfilter,tp,LOCATION_MZONE,0,nil)
    return aux.SelectUnselectGroup(rg,e,tp,1,1,nil,0,c) and Duel.GetLocationCountFromEx(tp,tp,c,sc)>-1
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
    local rg=Duel.GetMatchingGroup(s.lkfilter,tp,LOCATION_MZONE,0,nil)
    if Duel.GetLocationCountFromEx(tp,tp,c,sc)<=-1 then return false end
    local g=aux.SelectUnselectGroup(rg,e,tp,1,1,nil,1,tp,HINTMSG_TOGRAVE,false)
    Duel.BreakEffect()
    Duel.SendtoGrave(g,REASON_MATERIAL+REASON_LINK)
end
function s.val(e,c)
	return Duel.GetMatchingGroupCount(Card.IsRace,c:GetControler(),LOCATION_GRAVE,0,nil,RACE_DRAGON)*400
end
function s.efilter(e,re)
	return e:GetOwnerPlayer()~=re:GetOwnerPlayer() and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and Duel.IsChainDisablable(ev)
end
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_DISCARD+REASON_COST)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.spfilter(c,e,tp,zone)
	return c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
    local zone=e:GetHandler():GetLinkedZone(tp)
	if Duel.NegateEffect(ev) and re:GetHandler():IsRelateToEffect(re) and Duel.Destroy(eg,REASON_EFFECT)>0 and zone>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp,zone)
        if #g>0 then
            Duel.BreakEffect()
            Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP,zone)
        end
	end
end