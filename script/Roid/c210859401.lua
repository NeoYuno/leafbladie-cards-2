--Einroid
local s,id=GetID()
function s.initial_effect(c)
	--Fusion summon
	local params = {aux.FilterBoolFunction(Card.IsRace,RACE_MACHINE)}
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(Fusion.SummonEffTG(table.unpack(params)))
	e1:SetOperation(Fusion.SummonEffOP(table.unpack(params)))
	c:RegisterEffect(e1)
    --Search
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_series={0x16}
function s.thfilter(c,tp)
	return c:IsSetCard(0x16) and c:IsMonster() and (c:IsAbleToHand() or c:IsAbleToGrave())
        and not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,c:GetCode()),tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,tp) end
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil,tp)
	if #g<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sg1=g:Select(tp,1,1,nil)
    aux.ToHandOrElse(sg1,tp)
	g:Remove(Card.IsCode,nil,sg1:GetFirst():GetCode())
	if #g>0 and e:GetHandler():IsReason(REASON_BATTLE) and Duel.SelectYesNo(tp,210) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg2=g:Select(tp,1,1,nil)
		aux.ToHandOrElse(sg2,tp)
	end
end