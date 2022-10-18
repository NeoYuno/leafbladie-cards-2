--Harpie Lady Sparrow Formation
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1, id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Activate 2
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1, id)
	e2:SetHintTiming(0, TIMINGS_CHECK_MONSTER_E)
	e2:SetCondition(s.condition2)
	e2:SetCost(s.cost)
	e2:SetTarget(s.target2)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_HARPIE_LADY, CARD_HARPIE_LADY_SISTERS}
s.listed_series={0x64}
--Activate
function s.cfilter(c)
	return c:IsFaceup() and c:IsCode(CARD_HARPIE_LADY, CARD_HARPIE_LADY_SISTERS)
end
function s.condition(e, tp, eg, ep, ev, re, r, rp)
	local ct=Duel.GetMatchingGroupCount(s.cfilter, tp, LOCATION_MZONE, 0, nil)
	return ct>0
end
function s.cfilter2(c)
	return c:IsFaceup() and c:IsSetCard(0x64)
end
function s.target(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then
		local ct=Duel.GetMatchingGroupCount(s.cfilter, tp, LOCATION_MZONE, 0,nil)
		if ct<=1 then return Duel.IsExistingMatchingCard(s.cfilter2, tp, LOCATION_MZONE, 0, 1, nil) end
		return true
	end
end
function s.activate(e, tp, eg, ep, ev, re, r, rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.cfilter, tp, LOCATION_MZONE, 0, nil)
	local ct=#g
	if ct>=1 and Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
		Duel.Hint(HINT_OPSELECTED, 1-tp, aux.Stringid(id, 0))
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e1:SetTargetRange(1, 0)
        e1:SetValue(1)
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1, tp)
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_FIELD)
        e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
        e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
        e2:SetTargetRange(LOCATION_MZONE, 0)
        e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard, 0x64))
        e2:SetReset(RESET_PHASE+PHASE_END)
        e2:SetValue(1)
        Duel.RegisterEffect(e2, tp)
	end
	if ct>=2 and Duel.SelectYesNo(tp, aux.Stringid(id, 1)) then
		Duel.Hint(HINT_OPSELECTED, 1-tp, aux.Stringid(id, 1))
        local g=Duel.GetMatchingGroup(s.cfilter2, tp, LOCATION_MZONE, 0, nil)
		local tc=g:GetFirst()
		for tc in aux.Next(g) do
			--Immune
			local e3=Effect.CreateEffect(c)
			e3:SetDescription(3110)
			e3:SetProperty(EFFECT_FLAG_CLIENT_HINT)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_IMMUNE_EFFECT)
			e3:SetValue(s.efilter)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e3:SetOwnerPlayer(tp)
			tc:RegisterEffect(e3)
        end
	end
	if ct>=3 and Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
		Duel.Hint(HINT_OPSELECTED, 1-tp, aux.Stringid(id, 2))
        local e4=Effect.CreateEffect(c)
        e4:SetType(EFFECT_TYPE_FIELD)
        e4:SetCode(EFFECT_CANNOT_INACTIVATE)
        e4:SetReset(RESET_PHASE+PHASE_END)
        e4:SetValue(s.effectfilter)
        Duel.RegisterEffect(e4, tp)
        local e5=Effect.CreateEffect(c)
        e5:SetType(EFFECT_TYPE_FIELD)
        e5:SetCode(EFFECT_CANNOT_DISEFFECT)
        e5:SetReset(RESET_PHASE+PHASE_END)
        e5:SetValue(s.effectfilter)
        Duel.RegisterEffect(e5, tp)
	end
end
function s.efilter(e, re)
	return e:GetOwnerPlayer()~=re:GetOwnerPlayer()
end
function s.effectfilter(e, ct)
	local p=e:GetHandler():GetControler()
	local te,tp,loc=Duel.GetChainInfo(ct, CHAININFO_TRIGGERING_EFFECT, CHAININFO_TRIGGERING_PLAYER, CHAININFO_TRIGGERING_LOCATION)
	return p==tp and te:GetHandler():IsSetCard(0x64) and loc&LOCATION_ONFIELD~=0
end
--Activate 2
function s.condition2(e, tp, eg, ep, ev, re, r, rp)
	local ct=Duel.GetMatchingGroupCount(s.cfilter, tp, LOCATION_MZONE, 0, nil)
	return ct>2
end
function s.filter(c)
	return c:IsCode(86308219) and c:IsAbleToGraveAsCost()
		and c:CheckActivateEffect(false, true, false)~=nil and c:CheckActivateEffect(false, true, false):GetOperation()~=nil
end
function s.cost(e, tp, eg, ep, ev, re, r, rp, chk)
	local c=e:GetHandler()
	local chain=Duel.GetCurrentChain()
	if chk==0 then return c:IsAbleToRemoveAsCost()
		and Duel.IsExistingMatchingCard(s.filter, tp, LOCATION_DECK, 0, 1, nil, e, tp, chk, chain) end
	chain=chain-1
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp, s.filter, tp, LOCATION_DECK,0, 1, 1, nil, e, tp, chk, chain)
	local te, teg, tep, tev, tre, tr, trp=g:GetFirst():CheckActivateEffect(false, true, true)
	if not te then te=g:GetFirst():GetActivateEffect() end
	if te:GetCode()==EVENT_CHAINING then
		if chain<=0 then return false end
		local te2, p=Duel.GetChainInfo(chain, CHAININFO_TRIGGERING_EFFECT, CHAININFO_TRIGGERING_PLAYER)
		local tc=te2:GetHandler()
		local g=Group.FromCards(tc)
		teg, tep, tev, tre, tr, trp=g, p, chain, te2, REASON_EFFECT, p
	end
	s[Duel.GetCurrentChain()]=te
	Duel.Remove(c, POS_FACEUP, REASON_COST)
	Duel.BreakEffect()
	Duel.SendtoGrave(g, REASON_COST)
	e:SetTarget(s.targetchk(teg, tep, tev, tre, tr, trp))
	e:SetOperation(s.operationchk(teg, tep, tev, tre, tr, trp))
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_SOLVED)
	e1:SetReset(RESET_CHAIN)
	e1:SetLabelObject(e)
	e1:SetOperation(s.resetop)
	Duel.RegisterEffect(e1,tp)
end
function s.targetchk(teg, tep, tev, tre, tr, trp)
	return function(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
				local te=s[Duel.GetCurrentChain()]
				if chkc then
					local tg=te:GetTarget()
					return tg(e, tp, teg, tep, tev, tre, tr, trp, 0, true)
				end
				if chk==0 then return true end
				if not te then return end
				e:SetCategory(te:GetCategory())
				e:SetProperty(te:GetProperty())
				local tg=te:GetTarget()
				if tg then tg(e, tp, teg, tep, tev, tre, tr, trp, 1) end
			end
end
function s.operationchk(teg, tep, tev, tre, tr, trp)
	return function(e, tp, eg, ep, ev, re, r, rp)
				local te=s[Duel.GetCurrentChain()]
				if not te then return end
				local op=te:GetOperation()
				if op then op(e, tp, teg, tep, tev, tre, tr, trp) end
			end
end
function s.resetop(e, tp, eg, ep, ev, re, r, rp)
	local te=e:GetLabelObject()
	if te then
		te:SetTarget(s.target2)
		te:SetOperation(s.operation)
	end
end
function s.target2(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
	local te=s[Duel.GetCurrentChain()]
	if chkc then
		local tg=te:GetTarget()
		return tg(e, tp, eg, ep, ev, re, r, rp, 0, true)
	end
	if chk==0 then return true end
	if not te then return end
	e:SetProperty(te:GetProperty())
	local tg=te:GetTarget()
	if tg then tg(e, tp, eg, ep, ev, re, r, rp, 1) end
	Duel.ClearOperationInfo(0)
end
function s.operation(e, tp, eg, ep, ev, re, r, rp)
	local te=s[Duel.GetCurrentChain()]
	if not te then return end
	local op=te:GetOperation()
	if op then op(e, tp, eg, ep, ev, re, r, rp) end
end
