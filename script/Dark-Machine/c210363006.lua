--Pillager
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DICE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
    --Search
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
    e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.toss_coin=true
s.listed_names={3113667}
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	if chk==0 then return Duel.CheckLPCost(tp,1000) and g:IsExists(aux.NOT(Card.IsPublic),1,e:GetHandler()) end
	Duel.PayLPCost(tp,1000)
    Duel.ConfirmCards(1-tp,g)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,2)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local c1,c2=Duel.TossCoin(tp,2)
	local ct=c1+c2
	if ct==2 then
		s.op1(e,tp,eg,ep,ev,re,r,rp)
	elseif ct==1 then
		s.op2(e,tp,eg,ep,ev,re,r,rp)
	else
		s.op3(e,tp,eg,ep,ev,re,r,rp)
	end
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	Duel.ConfirmCards(tp,g)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sg=g:Select(tp,1,1,nil)
	Duel.SendtoHand(sg,tp,REASON_EFFECT)
	Duel.ShuffleHand(1-tp)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	Duel.ConfirmCards(tp,g)
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,4))
	local sg=g:Select(tp,1,1,nil)
	Duel.SendtoHand(sg,1-tp,REASON_EFFECT)
	Duel.ShuffleHand(tp)
end
--
function s.thfilter(c,fc)
	return c:IsCode(3113667) or (fc and c.toss_coin and not c:IsCode(id)) and c:IsAbleToHand()
end
function s.fieldcond(c)
	return c:IsFaceup() and c:IsCode(3113667)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		local fc=Duel.IsExistingMatchingCard(s.fieldcond,tp,LOCATION_FZONE,0,1,nil)
		return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,fc)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local fc=Duel.IsExistingMatchingCard(s.fieldcond,tp,LOCATION_FZONE,0,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,fc)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end