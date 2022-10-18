--Inferno Dive Bomb
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_CHAINING)
	e2:SetCondition(s.condition2)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_REDEYES_B_DRAGON,19025379,45410988}
s.listed_series={0x3b}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain(false)==0
end
function s.condition2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain(false)>0
end
function s.thfilter(c)
    return c:IsCode(19025379,45410988) and c:IsAbleToHand()
end
function s.tgfilter(c)
    return c:IsFaceup() and (c:IsSetCard(0x3b) or c:IsCode(19025379))
end
function s.desfilter(c)
    return c:IsFacedown() or not (c:IsSetCard(0x3b) or c:IsCode(19025379))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local cl=Duel.GetCurrentChain()
	if chkc then return false end
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		or (cl>1 or Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,0,1,nil))
		or (cl>2 or Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil))
		or (cl>3 or true)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	if cl>2 then
		local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
	end
	if cl>3 then
		local ng=Group.CreateGroup()
		local dg=Group.CreateGroup()
		for i=1,ev do
			local te,tgp=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
			if tgp~=tp and (te:IsActiveType(TYPE_MONSTER) or te:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(i) then
				local tc=te:GetHandler()
				ng:AddCard(tc)
				if tc:IsOnField() and tc:IsRelateToEffect(te) then
					dg:AddCard(tc)
				end
			end
		end
		Duel.SetTargetCard(dg)
		Duel.SetOperationInfo(0,CATEGORY_NEGATE,ng,#ng,0,0)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,#dg,0,0)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local cl=Duel.GetCurrentChain()
	if cl>0 then
		local ct=1
		if Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,CARD_REDEYES_B_DRAGON) then ct=2 end
		local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
		local sg=aux.SelectUnselectGroup(g,e,tp,1,ct,aux.dncheck,1,tp,HINTMSG_ATOHAND)
		if #sg>0 then
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,sg)
		end
	end
	if cl>1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local tc=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
		if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsControler(tp) then
			--Unaffected by opponent's card effects
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(3110)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_IMMUNE_EFFECT)
			e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
			e1:SetRange(LOCATION_MZONE)
			e1:SetValue(s.efilter)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e1:SetOwnerPlayer(tp)
			tc:RegisterEffect(e1)
			--Cannot be destroyed by battle this turn
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetDescription(3000)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
			e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
			e2:SetValue(1)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
		end
	end
	if cl>2 then
		local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
		if #g>0 then
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
    if cl>3 then
		local dg=Group.CreateGroup()
		for i=1,ev do
			local te,tgp=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
			if tgp~=tp and (te:IsActiveType(TYPE_MONSTER) or te:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.NegateActivation(i) then
				local tc=te:GetHandler()
				if tc:IsRelateToEffect(e) and tc:IsRelateToEffect(te) then
					tc:CancelToGrave()
					dg:AddCard(tc)
				end
			end
		end
		Duel.Destroy(dg,REASON_EFFECT)
    end
end
function s.efilter(e,re)
	return e:GetOwnerPlayer()~=re:GetOwnerPlayer()
end
