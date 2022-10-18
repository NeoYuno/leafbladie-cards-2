--Hope for the Future
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Fusion.CreateSummonEff(c,aux.FilterBoolFunction(Card.IsSetCard,0x8),Card.IsAbleToGrave,s.fextra,nil,nil,nil,nil,0,nil,FUSPROC_NOTFUSION)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetCondition(s.condition)
    e1:SetCost(s.cost)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_NEOS,CARD_POLYMERIZATION}
s.listed_series={0x8}
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(aux.NecroValleyFilter(Fusion.IsMonsterFilter(Card.IsAbleToGrave)),tp,LOCATION_DECK+LOCATION_EXTRA,0,nil)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsCode,CARD_NEOS),tp,LOCATION_ONFIELD,0,1,nil)
end
function s.cfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsDiscardable()
end
function s.polyfilter(c)
    return c:IsCode(CARD_POLYMERIZATION) and c:IsAbleToGraveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.polyfilter,tp,LOCATION_DECK,0,1,nil)
        or Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
    local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
    local tg=Duel.GetMatchingGroup(s.polyfilter,tp,LOCATION_DECK,0,nil)
	if #g==1 and g:GetFirst():IsCode(CARD_NEOS) and #tg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
        local g=Duel.SelectMatchingCard(tp,s.polyfilter,tp,LOCATION_DECK,0,1,1,nil)
        Duel.SendtoGrave(g,REASON_COST)
    else
        Duel.DiscardHand(tp,s.cfilter,1,1,REASON_COST+REASON_DISCARD)
    end
end