--Weapon of the Underground - Stick
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c,nil,aux.FilterBoolFunction(Card.IsCode,210144001))
    --Search 1
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
    --Destroy
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_EQUIP)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(s.descon)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
    --Search 2
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCountLimit(1,id)
	e4:SetCondition(s.thcon)
	e4:SetTarget(s.thtg2)
	e4:SetOperation(s.thop2)
	c:RegisterEffect(e4)
end
s.listed_names={210144001,id}
s.listed_series={0x0f4d,0x0f5a}
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() end
	Duel.SendtoGrave(c,REASON_COST)
end
function s.thfilter(c,tp)
	return c:IsSetCard(0x0f4d) and c:IsMonster() and c:IsAbleToHand()
	    and not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,c:GetCode()),tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil)
end
function s.tdfilter(c)
	return c:IsSetCard(0x0f4a) and c:IsMonster() and c:IsAbleToDeck()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local g=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_HAND,0,1,1,nil)
		if #g>0 then
			Duel.BreakEffect()
			if Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))==0 then
				Duel.SendtoDeck(g,nil,0,REASON_EFFECT)
			else
				Duel.SendtoDeck(g,nil,1,REASON_EFFECT)
			end
		end
	end
end

function s.desfilter(c,tp)
	return c:IsSetCard(0x0f5a) and c:IsLocation(LOCATION_SZONE) and c:IsControler(tp)
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg and eg:IsExists(s.desfilter,1,e:GetHandler(),tp) and eg:GetFirst():GetEquipTarget()==e:GetHandler():GetEquipTarget()
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end

function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
function s.thfilter2(c)
	return c:IsSetCard(0x0f5a) and c:IsAbleToHand() and not c:IsCode(id)
end
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter2,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
