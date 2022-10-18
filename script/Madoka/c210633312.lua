--Homura's Shield
--updated by MasterQuest
local s,id=GetID()
local COUNTER_TIME=0xf00
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	c:EnableCounterPermit(COUNTER_TIME,LOCATION_SZONE)
	c:SetCounterLimit(COUNTER_TIME,3)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--place Time counter
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(aux.chainreg)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EVENT_CHAIN_SOLVED)
	e3:SetRange(LOCATION_SZONE)
	e3:SetOperation(s.acop)
	c:RegisterEffect(e3)
	--Skip Phases
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetCost(s.cost)
	e4:SetCondition(s.condition)
	e4:SetTarget(s.target)
	e4:SetOperation(s.operation)
	c:RegisterEffect(e4)
end
function s.acop(e,tp,eg,ep,ev,re,r,rp)
	local p,loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_LOCATION)
	local c=e:GetHandler()
	local tc=re:GetHandler()
	if c:GetCounter(COUNTER_TIME)<3 and p==tp and tc:IsSetCard(0xf72) and c:GetFlagEffect(1)>0 and not re:IsHasType(EFFECT_TYPE_ACTIVATE) then
		c:AddCounter(COUNTER_TIME,1)
	end
end
s.listed_names={210633302} -- Homura Akemi
s.listed_series={0xf72} -- Puella Magi
s.counter_place_list = {COUNTER_TIME}

-- Filter for all monsters are Puella Magi
function s.pmfilter(c)
	return c:IsFacedown() or not c:IsSetCard(0xf72)
end
-- During your End Phase + All monsters must be Puella Magi monsters.
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp and not Duel.IsExistingMatchingCard(s.pmfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- Filter for monster to banish as cost.
function s.rfgfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xf72) and c:IsAbleToRemoveAsCost()
end
-- remove 3 counters and banish PM monster until opp. End Phase.
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,COUNTER_TIME,3,REASON_COST)
	 	and Duel.IsExistingMatchingCard(s.rfgfilter,tp,LOCATION_MZONE,0,1,nil) end
	e:GetHandler():RemoveCounter(tp,COUNTER_TIME,3,REASON_COST)

	-- Select card to banish
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local rg = Duel.SelectMatchingCard(tp,s.rfgfilter,tp,LOCATION_MZONE,0,1,1,nil)
	local rc = rg:GetFirst()
	-- Save selected card to check if you can activate both effects
	e:SetLabelObject(rc)
	--Banish until opponent's End Phase.
	if Duel.Remove(rg,POS_FACEUP,REASON_COST+REASON_TEMPORARY) ~= 0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		e1:SetLabelObject(rc)
		e1:SetCountLimit(1)
		e1:SetCondition(s.retcon)
		e1:SetOperation(s.retop)
		Duel.RegisterEffect(e1,tp)
	end
end
-- Return from Banish functions
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer() == (1-tp)
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ReturnToField(e:GetLabelObject())
end
-- Target: Select Options
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- Can select both if you banished Homura
	local rc = e:GetLabelObject()
	local op
	if rc and rc:GetOriginalCode() == 210633302 then
		op=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))
	else
		op=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
	end
	e:SetLabel(op)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local op=e:GetLabel()
	-- If "Skip Main" is not the only selected option, skip Draw Phase
	if op~=1 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(0,1)
		e1:SetCode(EFFECT_SKIP_DP)
		e1:SetReset(RESET_PHASE+PHASE_DRAW+RESET_OPPO_TURN,1)
		Duel.RegisterEffect(e1,tp)
	end
	-- If "Skip Draw" is not the only selected option, skip Main Phase
	if op~=0 then
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetTargetRange(0,1)
		e2:SetCode(EFFECT_SKIP_M1)
		e2:SetReset(RESET_PHASE+PHASE_MAIN1+RESET_OPPO_TURN,1)
		Duel.RegisterEffect(e2,tp)
	end
end
