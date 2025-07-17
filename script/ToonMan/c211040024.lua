--Pink Gadget
local s,id=GetID()
function s.initial_effect(c)
    --Link Summon
    c:EnableReviveLimit()
    Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_MACHINE),2,3)
    --Special Summon Level 4 Machine from GY + Equip 1 Machine to another monster you control
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
    -- Destruction replacement effect for monsters equipped with "Gadget" while this card is face-up
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EFFECT_DESTROY_REPLACE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTarget(s.reptg2)
    e2:SetValue(s.repval2)
    e2:SetOperation(s.repop2)
    c:RegisterEffect(e2)
end

function s.spfilter(c,e,tp)
    return c:IsRace(RACE_MACHINE) and c:IsLevel(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.eqfilter(c,tp)
    return c:IsFaceup() and c:IsRace(RACE_MACHINE) and (c:IsControler(1-tp) or Duel.IsExistingMatchingCard(s.targetfilter,tp,LOCATION_MZONE,0,1,c))
end
function s.targetfilter(c)
    return c:IsFaceup()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    local b1=Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
    local b2=Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp)
        and Duel.IsExistingMatchingCard(s.targetfilter,tp,LOCATION_MZONE,0,1,nil)
        and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
    if chk==0 then return b1 and b2 end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
    Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,0,LOCATION_MZONE)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local spg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    if #spg>0 and Duel.SpecialSummon(spg,0,tp,tp,false,false,POS_FACEUP)>0 then
        Duel.BreakEffect()
        if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
        local eqc=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp):GetFirst()
        Duel.HintSelection(eqc)
        if not eqc then return end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
        local tc=Duel.SelectMatchingCard(tp,function(c) return s.targetfilter(c) and c~=eqc end,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
        Duel.HintSelection(tc)
        if not tc then return end
        if not Duel.Equip(tp,eqc,tc,false) then return end
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_EQUIP_LIMIT)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetValue(1)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        eqc:RegisterEffect(e1)
    end
end

-- New protection logic provided by the Link Monster
function s.gadgetfilter(c)
    return c:IsSetCard(0x51) and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
end
function s.repfilter2(c,tp)
    local eq=c:GetEquipGroup()
    return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and eq:IsExists(s.gadgetfilter,1,nil)
end
-- Track which Gadget is being used as replacement
function s.reptg2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return eg:IsExists(s.repfilter2,1,nil,tp) end

    -- Let player choose to activate the replacement
    if not Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then return false end

    -- Store chosen Gadget to destroy
    for tc in aux.Next(eg) do
        local eq=tc:GetEquipGroup()
        local g=eq:Filter(s.gadgetfilter,nil)
        if #g>0 then
            local sg=g:Select(tp,1,1,nil)
            if #sg>0 then
                tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
                sg:GetFirst():CreateEffectRelation(e)
                e:SetLabelObject(sg:GetFirst())
                return true
            end
        end
    end
    return false
end

function s.repval2(e,c)
    return c:GetFlagEffect(id)>0
end

function s.repop2(e,tp,eg,ep,ev,re,r,rp)
    local rc=e:GetLabelObject()
    if rc and rc:IsRelateToEffect(e) then
        Duel.Destroy(rc,REASON_EFFECT+REASON_REPLACE)
    end
end

