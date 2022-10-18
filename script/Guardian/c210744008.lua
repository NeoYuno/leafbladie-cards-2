--ガーディアン・トレジャー
--Guardian Treasure
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--Draw 2
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DRAW_COUNT)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(1,0)
	e2:SetValue(2)
	c:RegisterEffect(e2)
	--gain LP
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_RECOVER)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(s.lpcon)
	e3:SetTarget(s.lptg)
	e3:SetOperation(s.lpop)
	c:RegisterEffect(e3)
end
s.listed_series={0x52}
s.listed_names={id}
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	local ct=#g
	if e:GetHandler():IsLocation(LOCATION_HAND) then ct=ct-1 end
	if chk==0 then return #g>0 and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,ct,e:GetHandler()) end
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end
function s.thfilter1(c)
	return c:IsSetCard(0x52) and c:IsAbleToHand() and not c:IsCode(id)
end
function s.thfilter2(c)
	return c:IsType(TYPE_SPELL) and c:IsType(TYPE_EQUIP) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g1=Duel.GetMatchingGroup(s.thfilter1,tp,LOCATION_DECK,0,1,nil)
	local g2=Duel.GetMatchingGroup(s.thfilter2,tp,LOCATION_DECK,0,1,nil)
	g1:Merge(g2)
	if chk==0 then return aux.SelectUnselectGroup(g1,e,tp,2,2,s.rescon,0,tp,HINTMSG_ATOHAND,nil,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
function s.rescon(sg,e,tp,mg)
	return sg:FilterCount(s.thfilter1,nil)>=1 and sg:FilterCount(s.thfilter2,nil)>=1
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g1=Duel.GetMatchingGroup(s.thfilter1,tp,LOCATION_DECK,0,1,nil)
	local g2=Duel.GetMatchingGroup(s.thfilter2,tp,LOCATION_DECK,0,1,nil)
	g1:Merge(g2)
	if #g1>0 then
		local g=aux.SelectUnselectGroup(g1,e,tp,2,2,s.rescon,1,tp,HINTMSG_ATOHAND,nil,nil)
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.lpcfilter(c,tp)
    return c:IsFaceup() and c:IsSetCard(0x52) and c:IsControler(tp)
end
function s.lpcon(e,tp,eg,ep,ev,re,r,rp)
    return s.lpcfilter(eg:GetFirst(),tp)
end
function s.lptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local tc=eg:Filter(Card.IsControler,nil,tp)
	local bc=tc:GetFirst():GetBattleTarget()
	local dam=bc:GetBaseAttack()
	if dam<0 then dam=0 end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(dam)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,dam)
end
function s.lpop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Recover(p,d,REASON_EFFECT)
end