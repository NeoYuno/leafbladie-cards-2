--Sayaka's Healing
--updated by MasterQuest
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)

	-- Check for activating the turn it is set.
	aux.GlobalCheck(s, function()
    local e3= Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_SSET)
    e3:SetOperation(s.gblop)
    Duel.RegisterEffect(e3,0)
  end)

end
s.listed_names={210633303} -- Sayaka Miki
s.listed_series={0xf72} -- Puella Magi
s.counter_place_list={COUNTER_SPELL}

function s.conf(c)
	return c:IsFaceup() and c:IsCode(210633303)
end
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xf72) and c:IsCanAddCounter(COUNTER_SPELL,1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_ONFIELD,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,tp,COUNTER_SPELL)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_ONFIELD,0,nil)
	-- Place 1 Counter
	for tc in aux.Next(g) do
		tc:AddCounter(COUNTER_SPELL,1)
	end

	if Duel.IsExistingMatchingCard(s.conf,tp,LOCATION_ONFIELD,0,1,nil) then
		-- Place additional counter? (first check if any more counters can be placed)
		g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_ONFIELD,0,nil)
		if #g > 0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.BreakEffect()
			for tc in aux.Next(g) do
				tc:AddCounter(COUNTER_SPELL,1)
			end
		end
		-- Waboku Effect
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xf72))
		e1:SetValue(1)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)

		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetTargetRange(1,0)
		e2:SetValue(1)
		e2:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e2,tp)
	end
end

-- Check set cards to see if this card was set by Sayaka
function s.gblop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(Card.IsCode,nil,id)
	for ec in aux.Next(g) do
		if re and re:GetOwner() and re:GetOwner():IsCode(210633303) then
      -- Activate the turn it is set.
      local e0=Effect.CreateEffect(ec)
      e0:SetType(EFFECT_TYPE_SINGLE)
      e0:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
      e0:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
      e0:SetReset(RESET_EVENT+RESETS_STANDARD)
      ec:RegisterEffect(e0)
		end
	end
end
