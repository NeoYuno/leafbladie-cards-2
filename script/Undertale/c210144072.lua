--The Six Human Souls
local s,id=GetID()
function s.initial_effect(c)
	Ritual.AddProcGreaterCode(c,8,nil,210144026)
    --To hand
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetRange(LOCATION_GRAVE)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.thcon)
    e1:SetCost(s.thcost)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2)
end
s.listed_names={210144001,210144021,210144026,210144074}
s.listed_series={0x0f4c}
function s.confilter(c,tp)
    return c:IsFaceup() and c:IsCode(210144001) and c:IsSummonPlayer(tp)
end
function s.costfilter(c)
    return c:IsSetCard(0x0f4c) and c:IsType(TYPE_TRAP) and c:IsAbleToGraveAsCost()
end
function s.thfilter(c)
    return c:IsCode(210144026) and c:IsAbleToHand()
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    return eg and eg:IsExists(s.confilter,1,nil,tp)
        and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,210144021),tp,LOCATION_MZONE,0,1,nil)
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoGrave(g:GetFirst(),REASON_COST)
    end
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsAbleToHand() end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and Duel.SendtoHand(c,nil,REASON_EFFECT)>0
    and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,210144074),tp,LOCATION_MZONE,0,1,nil)
    and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
    and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
        if #g>0 then
            Duel.BreakEffect()
            Duel.SendtoHand(g:GetFirst(),nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,g:GetFirst())
        end
    end
end