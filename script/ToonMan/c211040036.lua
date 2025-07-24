-- Land-Cutter, The Superconductive Lancer
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    Fusion.AddProcMix(c,true,true,42901635,211040032)
    --Piercing Damage
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_PIERCE)
    c:RegisterEffect(e1)
    --Double Attack
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id)
    e2:SetCost(s.atkcost)
    e2:SetOperation(s.atkop)
    c:RegisterEffect(e2)
    -- Revive 2 on destruction
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_DESTROYED)
    e3:SetCountLimit(1,{id,1})
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)
end
s.listed_names={42901635,211040032}

function s.cfilter(c)
    return c:IsSetCard(0x2066) and c:IsAbleToDeckAsCost() and c:IsMonster()
end
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    -- Can attack two monsters this Battle Phase
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
    e1:SetValue(1)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    c:RegisterEffect(e1)
end

function s.spfilter(c,e,tp)
    return c:IsCode(42901635,211040032) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>1 
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,2,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
    local g=Group.CreateGroup()
    for _,code in ipairs({42901635,211040032}) do
        local tc=Duel.GetFirstMatchingCard(function(c) return c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,true,true) end,tp,LOCATION_GRAVE,0,nil)
        if tc then g:AddCard(tc) end
    end
    if #g>0 then Duel.SpecialSummon(g,0,tp,tp,true,true,POS_FACEUP) end
end