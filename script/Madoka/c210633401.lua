-- Puella Magi - Nagisa Momoe
-- created by MasterQuest
local s, id = GetID()
function s.initial_effect(c)

  c:EnableCounterPermit(COUNTER_SPELL,LOCATION_MZONE+LOCATION_PZONE)
  --counter limit
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetCode(EFFECT_COUNTER_LIMIT|COUNTER_SPELL)
  e1:SetValue(s.CounterValue)
  c:RegisterEffect(e1)
  --pendulum summon
  Pendulum.AddProcedure(c,false)
  --pendulum activation
  local e2=Effect.CreateEffect(c)
  e2:SetDescription(1160)
  e2:SetType(EFFECT_TYPE_ACTIVATE)
  e2:SetCode(EVENT_FREE_CHAIN)
  e2:SetTarget(s.patg)
  e2:SetOperation(s.paop)
  c:RegisterEffect(e2)
  --negate S/T in PZone
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
  e3:SetCode(EVENT_CHAIN_SOLVING)
  e3:SetRange(LOCATION_PZONE)
  e3:SetCondition(s.pnegcon)
  e3:SetOperation(s.pnegop)
  c:RegisterEffect(e3)
  --special summoned by pendulum summon
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e4:SetCode(EVENT_SPSUMMON_SUCCESS)
  e4:SetCondition(s.psccon)
  e4:SetTarget(s.psctg)
  e4:SetOperation(s.pscop)
  c:RegisterEffect(e4)
  --destroy self in PZone
  local e5=Effect.CreateEffect(c)
  e5:SetCategory(CATEGORY_DESTROY)
  e5:SetType(EFFECT_TYPE_IGNITION)
  e5:SetRange(LOCATION_PZONE)
  e5:SetCondition(s.descon)
  e5:SetTarget(s.destg)
  e5:SetOperation(s.desop)
  c:RegisterEffect(e5)
  --atk/def gain
  local e6=Effect.CreateEffect(c)
  e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
  e6:SetType(EFFECT_TYPE_SINGLE)
  e6:SetCode(EFFECT_UPDATE_ATTACK)
  e6:SetValue(s.aduv)
  e6:SetRange(LOCATION_MZONE)
  c:RegisterEffect(e6)
  local e7=e6:Clone()
  e7:SetCode(EFFECT_UPDATE_DEFENSE)
  c:RegisterEffect(e7)
  -- Protection Replacement effect
  local e8=Effect.CreateEffect(c)
  e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
  e8:SetCode(EFFECT_DESTROY_REPLACE)
  e8:SetRange(LOCATION_MZONE)
  e8:SetTarget(s.reptg)
  e8:SetValue(s.repval)
  c:RegisterEffect(e8)
  -- Set S/T on destruction
  local e9=Effect.CreateEffect(c)
  e9:SetCategory(CATEGORY_SEARCH)
  e9:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
  e9:SetProperty(EFFECT_FLAG_DELAY)
  e9:SetCode(EVENT_DESTROYED)
  e9:SetCondition(s.setcon)
  e9:SetTarget(s.settg)
  e9:SetOperation(s.setop)
  c:RegisterEffect(e9)
end
s.counter_place_list={COUNTER_SPELL}
s.listed_series={0xf72}
s.listed_names={id}

-- Spell Counter Limit
function s.CounterValue(e)
	local c=e:GetHandler()
	if c:IsLocation(LOCATION_MZONE) then
		return 2
	elseif c:IsLocation(LOCATION_PZONE) then
		return 1
	else
		return 0
	end
end
-- Pendulum Activation (add counter)
function s.patg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,COUNTER_SPELL)
end
function s.paop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		c:AddCounter(COUNTER_SPELL,1,true)
	end
end
-- Negate S/T on resolve.
function s.cfilter(c)
	return c:IsSetCard(0xf72) and c:IsFaceup()
end
function s.pnegcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler())
		and rp~=tp and re:IsActiveType(TYPE_SPELL+TYPE_TRAP) -- check if this works as 1 call.
		and e:GetHandler():IsCanRemoveCounter(tp,COUNTER_SPELL,1,REASON_EFFECT) and Duel.IsChainDisablable(ev)
end
function s.pnegop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsCanRemoveCounter(tp,COUNTER_SPELL,1,REASON_EFFECT) then
		c:RemoveCounter(tp,COUNTER_SPELL,1,REASON_EFFECT)
		Duel.BreakEffect()
		Duel.NegateEffect(ev)
	end
end
-- Pendulum Summon (add Spell Counter)
function s.psccon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_PENDULUM)
end
function s.psctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,COUNTER_SPELL)
end
function s.pscop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		c:AddCounter(COUNTER_SPELL,1,true)
	end
end
-- Destroy Self in PZone
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetCounter(COUNTER_SPELL) == 0
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDestructable() end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
-- Attack/def Increase Value
function s.aduv(e,c)
	return 300*c:GetCounter(COUNTER_SPELL)
end
-- Protection Replacement Effect
function s.repfilter(c,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_ONFIELD) and c:GetReasonPlayer()~=tp
		and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp) and c:IsCanRemoveCounter(tp,COUNTER_SPELL,1,REASON_EFFECT) end
  -- !system Do you want to use effect to avoid destruction?
  if Duel.SelectEffectYesNo(tp,c,96) then
		c:RemoveCounter(tp,COUNTER_SPELL,1,REASON_EFFECT)
		return true
	else return false end
end
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
-- Set S/T on destruction
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return (r&REASON_EFFECT+REASON_BATTLE)~=0
end
function s.setfilter(c)
	return c:IsType(TYPE_TRAP+TYPE_SPELL) and c:IsSSetable() and aux.IsCodeListed(c,id)
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SEARCH,nil,1,0,0)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SSet(tp,g)
		--Duel.ConfirmCards(1-tp,g)
    g:GetFirst():SetStatus(STATUS_SET_TURN,false)
	end
end
