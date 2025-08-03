--Infinity’s Red Sun Extinction
local s,id=GetID()
function s.initial_effect(c)
    -- Field wipe if you control Ouroboros
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCondition(s.descon)
    e1:SetTarget(s.destg)
    e1:SetOperation(s.desop)
    c:RegisterEffect(e1)
    -- GY effect: shuffle 1 "Infinity" monster into the Deck
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TODECK)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id)
    e2:SetCost(s.tdcost)
    e2:SetTarget(s.tdtg)
    e2:SetOperation(s.tdop)
    c:RegisterEffect(e2)
end
s.listed_names={211040040}
s.listed_series={0x0f7c}

-- Check for Ouroboros
function s.descon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(function(c) return c:IsFaceup() and c:IsCode(211040040) end,tp,LOCATION_MZONE,0,1,nil)
end
-- Destroy all non-Infinity cards
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(function(c)
        return c:IsDestructable() and not c:IsSetCard(0x0f7c)
    end,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
    if chk==0 then return #g>0 end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(function(c)
        return c:IsDestructable() and not c:IsSetCard(0x0f7c)
    end,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
    Duel.Destroy(g,REASON_EFFECT)
end

-- Banish self as cost
function s.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
    Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end

-- Target and shuffle "Infinity" monster from GY
function s.tdfilter(c)
    return c:IsSetCard(0x0f7c) and c:IsMonster() and c:IsAbleToDeck()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    if #g>0 then
        Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
    end
end