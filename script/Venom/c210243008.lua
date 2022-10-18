--Venom Poison & Antidote
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
    e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
    --Search
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	aux.GlobalCheck(s,function()
		s[0]={}
		aux.AddValuesReset(function()
			for _,te in ipairs(s[0]) do
				if Duel.GetTurnPlayer()~=te:GetOwnerPlayer() then
					s.reset(te,te:GetOwnerPlayer(),nil,0,0,nil,0,0)
				end
			end
		end)
	end)
end
s.listed_series={0x50}
s.listed_names={54306223}
s.counter_list={COUNTER_VENOM}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsEnvironment(54306223)
end
function s.desfilter(c,tp)
	return c:IsFaceup() and c:IsDestructable() and (c:IsControler(tp) or (c:IsControler(1-tp) and c:GetCounter(COUNTER_VENOM)>0))
end
function s.filter(c)
	return c:IsFaceup() and c:GetCounter(COUNTER_VENOM)==0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.desfilter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp)
		and Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil)
		Duel.Destroy(g,REASON_EFFECT)
		if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_SUMMON_SUCCESS)
		e1:SetOperation(s.ctop1)
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
		Duel.RegisterEffect(e2,tp)
		local e3=e1:Clone()
		e3:SetCode(EVENT_SPSUMMON_SUCCESS)
		e3:SetOperation(s.ctop2)
		Duel.RegisterEffect(e3,tp)
		local descnum=tp==e:GetHandler():GetOwner() and 0 or 1
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetDescription(aux.Stringid(id,descnum))
		e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
		e4:SetCode(1082946)
		e4:SetOwnerPlayer(tp)
		e4:SetLabel(0)
		e4:SetOperation(s.reset)
		e4:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		c:RegisterEffect(e4)
		table.insert(s[0],e4)
		s[0][e4]={e1,e2,e3}
	end
end
function s.ctop1(e,tp,eg,ep,ev,re,r,rp)
	if ep~=tp then
		eg:GetFirst():AddCounter(COUNTER_VENOM,1)
	end
end
function s.ctop2(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	for tc in aux.Next(eg) do
		if tc:IsFaceup() and not tc:IsSummonPlayer(tp) then
			tc:AddCounter(COUNTER_VENOM,1)
		end
	end
end
function s.reset(e,tp,eg,ep,ev,re,r,rp)
	local label=e:GetLabel()
	label=label+1
	e:SetLabel(label)
	if ev==1082946 then
		e:GetOwner():SetTurnCounter(label)
	end
	e:GetOwner():SetTurnCounter(0)
	if label==3 then
		local e1,e2,e3=table.unpack(s[0][e])
		e:Reset()
		if e1 then e1:Reset() end
		if e2 then e2:Reset() end
		if e3 then e3:Reset() end
		s[0][e]=nil
		for i,te in ipairs(s[0]) do
			if te==e then
				table.remove(s[0],i)
				break
			end
		end
	end
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,0) and Duel.IsCanRemoveCounter(tp,1,1,COUNTER_VENOM,1,REASON_COST) end
	aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,1)
    Duel.BreakEffect()
	Duel.RemoveCounter(tp,1,1,COUNTER_VENOM,1,REASON_COST)
end
function s.thfilter(c)
	return c:IsSetCard(0x50) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,3,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_DECK,0,nil,0x50)
	if #g>=3 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,3,3,nil)
		Duel.ConfirmCards(1-tp,sg)
		Duel.ShuffleDeck(tp)
		local tg=sg:Select(1-tp,1,1,nil)
		local tc=tg:GetFirst()
		if tc:IsAbleToHand() then
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			sg:RemoveCard(tc)
		end
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end