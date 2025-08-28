--Vassal Of The Mythisch, Ramsden
local s,id=GetID()
function s.initial_effect(c)
    -- Trigger: When a "Mythisch" monster is Summoned
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2)
    -- Grant effect: Unaffected by opponent's Spell/Trap effects
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_XMATERIAL)
    e3:SetCode(EFFECT_IMMUNE_EFFECT)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCondition(function(e) return e:GetHandler():IsSetCard(0xf8a) end)
    e3:SetValue(function(e,te)
        return te:IsActiveType(TYPE_SPELL+TYPE_TRAP) and te:GetOwnerPlayer()~=e:GetHandlerPlayer()
    end)
    c:RegisterEffect(e3)
end
s.listed_series={0xf8a}
-- Trigger Condition: A "Mythisch" monster is summoned
function s.cfilter(c,tp)
    return c:IsFaceup() and c:IsSetCard(0xf8a) and c:IsControler(tp)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.cfilter,1,nil,tp)
end

-- Target: Choose to Special Summon or Attach
function s.xyzfilter(c)
    return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(0xf8a)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
            or Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_MZONE,0,1,nil)
    end
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local canSS = Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
    local canAttach = Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_MZONE,0,1,nil)
    if not (canSS or canAttach) then return end
    local opt = 0
    if canSS and canAttach then
        opt = Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2)) -- 0 = SS, 1 = Attach
    elseif canSS then
        opt = 0
    else
        opt = 1
    end

    if opt==0 then
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
    else
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
        local g=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil)
        local tc=g:GetFirst()
        if tc and c:IsRelateToEffect(e) then
            Duel.Overlay(tc,c)
        end
    end
end