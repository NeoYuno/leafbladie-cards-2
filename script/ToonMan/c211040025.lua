--Boot-Up Siege Dynamo, The Moving Castle
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    -- Fusion Material
    local f1=Fusion.AddProcMixN(c,true,true,aux.FilterBoolFunction(Card.IsSetCard,0x51),3)[1]
    f1:SetDescription(aux.Stringid(id,0))
    local f2=Fusion.AddProcMix(c,true,true,
        aux.FilterBoolFunction(Card.IsCode,36322312),
        aux.FilterBoolFunction(Card.IsSetCard,0x51))[1]
    f2:SetDescription(aux.Stringid(id,1))
    Fusion.AddContactProc(c,s.contactfil,s.contactop,s.splimit,nil,nil,nil,false)
    -- Equip a "Gadget" to a "Boot-Up" or "Moving" monster
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,2))
    e1:SetCategory(CATEGORY_EQUIP)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetTarget(s.eqtg)
    e1:SetOperation(s.eqop)
    c:RegisterEffect(e1)
    -- Can attack in DEF position using DEF
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_DEFENSE_ATTACK)
    e2:SetValue(1)
    c:RegisterEffect(e2)
    -- On destruction: revive up to 3 "Gadget" monsters with effects negated
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,3))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_DESTROYED)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCountLimit(1,id)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)
end

function s.splimit(e,se,sp,st)
	return (st&SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
end
function s.contactfil(tp)
	return Duel.GetMatchingGroup(Card.IsAbleToGraveAsCost,tp,LOCATION_MZONE+LOCATION_SZONE,0,nil)
end
function s.contactop(g)
	Duel.SendtoGrave(g,REASON_COST|REASON_MATERIAL)
end
-- Equip Target
function s.eqfilter(c,tp)
    return c:IsSetCard(0x51) and c:IsFaceup() and Duel.IsExistingMatchingCard(s.targetfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.targetfilter(c)
    return c:IsFaceup() and c:IsCode(36322312,938717,13316346,211040025,211040026,30190809,13955608,35100834,42237854)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then 
        return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
            and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_GRAVE+LOCATION_MZONE,0,1,nil,tp)
            and Duel.IsExistingMatchingCard(s.targetfilter,tp,LOCATION_MZONE,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_GRAVE+LOCATION_MZONE)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
    local eqc=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_GRAVE+LOCATION_MZONE,0,1,1,nil,tp):GetFirst()
    if not eqc then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local tc=Duel.SelectMatchingCard(tp,s.targetfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
    Duel.HintSelection(tc)
    if not tc then return end
    if not Duel.Equip(tp,eqc,tc,false) then return end

    -- Equip limit
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_EQUIP_LIMIT)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetValue(1)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    eqc:RegisterEffect(e1)
end

-- Revive up to 3 "Gadget" monsters
function s.spfilter(c,e,tp)
    return c:IsSetCard(0x51) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
    local ft=math.min(3,Duel.GetLocationCount(tp,LOCATION_MZONE))
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,ft,tp,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local ft=math.min(3,Duel.GetLocationCount(tp,LOCATION_MZONE))
    if ft<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,ft,nil,e,tp)
    for tc in aux.Next(g) do
        if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_DISABLE)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e1)
            local e2=Effect.CreateEffect(e:GetHandler())
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetCode(EFFECT_DISABLE_EFFECT)
            e2:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e2)
        end
    end
    Duel.SpecialSummonComplete()
end
