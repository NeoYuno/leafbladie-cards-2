--Ultimate Madoka
--updated by MasterQuest
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--special summon limit
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(s.scon)
	c:RegisterEffect(e1)
	--immune to other card effects
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.immuneval)
	c:RegisterEffect(e2)
	--place Spell Counters during EP.
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_COUNTER)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetTarget(s.psctg)
	e3:SetOperation(s.pscop)
	e3:SetCountLimit(1)
	c:RegisterEffect(e3)
	--Place Puella Magi in Pendulum Zones.
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e4:SetTarget(s.tpztg)
	e4:SetOperation(s.tpzop)
	c:RegisterEffect(e4)
	--Send cards to GY
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_TOGRAVE)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetCondition(s.sendcon)
	e5:SetTarget(s.sendtg)
	e5:SetOperation(s.sendop)
	c:RegisterEffect(e5)
end
s.counter_place_list={COUNTER_SPELL}
s.listed_series={0xf72} -- Puella Magi
s.listed_names={210633301} 	-- Madoka Kaname
-- Summoning Condition
function s.scon(e,se,sp,st)
	return se and se:GetHandler():IsCode(210633301)
end
-- Immune Condition
function s.immuneval(e,te)
	-- "Other cards"
	return te:GetOwner()~=e:GetOwner()
end
-- Place Spell Counters
function s.pscfilter(c)
	return c:IsCanAddCounter(COUNTER_SPELL,1)
end
function s.psctg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingMatchingCard(s.pscfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0)
end
function s.pscop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.pscfilter,tp,LOCATION_ONFIELD,0,nil)
	for tc in aux.Next(g) do
		tc:AddCounter(COUNTER_SPELL,1)
	end
end
-- Place Puella Magi in Pendulum Scales.
function s.tpzfilter(c)
	return c:IsType(TYPE_PENDULUM) and c:IsSetCard(0xf72) and not c:IsForbidden()
		and (c:IsFaceup() or not c:IsLocation(LOCATION_EXTRA))
end
function s.tpztg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tpzfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil)
		and (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)) end
end
function s.tpzop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tpzfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,nil)
	local ct=0
	-- Check for free Scales.
	if Duel.CheckLocation(tp,LOCATION_PZONE,0) then ct=ct+1 end
	if Duel.CheckLocation(tp,LOCATION_PZONE,1) then ct=ct+1 end
	if ct>0 and #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		-- Select up to 2/free scales/available targets.
		local sg=g:Select(tp,1,ct,nil)
		local sc=sg:GetFirst()
		while sc do
			Duel.MoveToField(sc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
			sc=sg:GetNext()
		end
	end
end
-- Send cards to GY
function s.linkfil(c)
	return c:IsSetCard(0xf72) and c:IsFaceup() and c:IsType(TYPE_PENDULUM)
end
function s.sendcon(e,tp,eg,ep,ev,re,r,rp)
	local lg = e:GetHandler():GetLinkedGroup():Filter(s.linkfil,nil)
	return #lg > 0
end
function s.sendtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,0,0,0)
end
function s.sendop(e,tp,eg,ep,ev,re,r,rp)
	local lg = e:GetHandler():GetLinkedGroup():Filter(s.linkfil,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local og = Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,#lg,nil)
	Duel.SendtoGrave(og,REASON_EFFECT)
end
