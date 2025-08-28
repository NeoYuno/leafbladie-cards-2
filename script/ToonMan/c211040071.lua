--Moon Gate, Gateway to the Mythisch
local s,id=GetID()
function s.initial_effect(c)
    -- Xyz Summon procedure
    Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0xf8a),4,2)
    c:EnableReviveLimit()
    -- Cannot attack
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CANNOT_ATTACK)
    c:RegisterEffect(e1)
    -- Cannot be targeted for attacks
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_IGNORE_BATTLE_TARGET)
    e2:SetValue(1)
    c:RegisterEffect(e2)
    -- Unaffected by opponent's card effects
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_IMMUNE_EFFECT)
    e3:SetValue(function(e,te)
        return te:GetOwnerPlayer()~=e:GetHandlerPlayer()
    end)
    c:RegisterEffect(e3)
    -- Effect 1: Look at top 5 cards, attach up to 3 "Mythisch" monsters
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,0))
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1)
    e4:SetCondition(s.ignition_condition)
    e4:SetTarget(s.attachtg)
    e4:SetOperation(s.attachop)
    c:RegisterEffect(e4)
    local e4q=e4:Clone()
    e4q:SetType(EFFECT_TYPE_QUICK_O)
    e4q:SetCondition(s.quick_condition)
    c:RegisterEffect(e4q)
    -- Effect 2: Special Summon Mythisch Xyz, attach 2 materials
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,1))
    e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e5:SetType(EFFECT_TYPE_IGNITION)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCountLimit(1,id)
    e5:SetCondition(s.ignition_condition)
    e5:SetTarget(s.sptg)
    e5:SetOperation(s.spop)
    c:RegisterEffect(e5)
    local e5q=e5:Clone()
    e5q:SetType(EFFECT_TYPE_QUICK_O)
    e5q:SetCondition(s.quick_condition)
    c:RegisterEffect(e5q)
    -- Effect 3: Move 1 material to top of Deck
    local e6=Effect.CreateEffect(c)
    e6:SetDescription(aux.Stringid(id,2))
    e6:SetCategory(CATEGORY_TODECK)
    e6:SetType(EFFECT_TYPE_IGNITION)
    e6:SetRange(LOCATION_MZONE)
    e6:SetCountLimit(1,{id,1})
    e6:SetCondition(s.ignition_condition)
    e6:SetTarget(s.toptg)
    e6:SetOperation(s.topop)
    c:RegisterEffect(e6)
    local e6q=e6:Clone()
    e6q:SetType(EFFECT_TYPE_QUICK_O)
    e6q:SetCondition(s.quick_condition)
    c:RegisterEffect(e6q)
end
s.listed_series={0xf8a}

function s.quick_condition(e)
    return Duel.IsExistingMatchingCard(Card.IsCode,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil,211040072)
end
function s.ignition_condition(e)
    return not s.quick_condition(e)
end

function s.attachtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=5 end
end
function s.attachop(e,tp,eg,ep,ev,re,r,rp)
    Duel.ConfirmDecktop(tp,5)
    local g=Duel.GetDecktopGroup(tp,5)
    local attachable=g:Filter(function(c) return c:IsSetCard(0xf8a) and c:IsType(TYPE_MONSTER) end,nil)
    if #attachable>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACH)
        local sel=attachable:Select(tp,1,math.min(3,#attachable),nil)
        Duel.Overlay(e:GetHandler(),sel)
        g:Sub(sel)
    end
    if #g>0 then
        Duel.MoveToDeckBottom(g,tp)
        Duel.SortDeckbottom(tp,tp,#g)
    end
end

function s.spfilter(c,e,tp)
    return c:IsType(TYPE_XYZ) and c:IsSetCard(0xf8a) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.GetLocationCountFromEx(tp,tp,c)>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
        and c:GetOverlayCount()>=2 end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.GetLocationCountFromEx(tp,tp,c)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
    local tc=g:GetFirst()
    if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
        local mat=c:GetOverlayGroup()
        if #mat>=2 then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACH)
            local sel=mat:Select(tp,2,2,nil)
            Duel.Overlay(tc,sel)
        end
    end
end

function s.toptg(e,tp,eg,ep,ev,re,r,rp,chk)
    return chk==0 and e:GetHandler():GetOverlayCount()>0
end
function s.topop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local g=c:GetOverlayGroup():Filter(Card.IsAbleToDeck,nil)
    if #g>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
        local sel=g:Select(tp,1,1,nil)
        Duel.SendtoDeck(sel,nil,SEQ_DECKTOP,REASON_EFFECT)
    end
end