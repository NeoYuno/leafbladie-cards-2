--Puella Magi - Mami Tomoe
--updated by MasterQuest
local s,id=GetID()
local COUNTER_RIBBON=0x1901
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
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(1160)
	e3:SetType(EFFECT_TYPE_ACTIVATE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetTarget(s.patg)
	e3:SetOperation(s.paop)
	c:RegisterEffect(e3)
	--negate attack
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:SetRange(LOCATION_PZONE)
	e4:SetCost(s.nacos)
	e4:SetCondition(s.nacon)
	e4:SetTarget(s.nat)
	e4:SetOperation(s.nao)
	c:RegisterEffect(e4)
	--destroy self in PZone
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	--special summoned by pendulum summon
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetCondition(s.psccon)
	e5:SetTarget(s.psct)
	e5:SetOperation(s.psco)
	c:RegisterEffect(e5)
	--atk/def gain
	local e7=Effect.CreateEffect(c)
	e7:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetCode(EFFECT_UPDATE_ATTACK)
	e7:SetValue(s.aduv)
	e7:SetRange(LOCATION_MZONE)
	c:RegisterEffect(e7)
	local e8=e7:Clone()
	e8:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e8)
	--place ribbon counters
	local e9=Effect.CreateEffect(c)
	e9:SetCategory(CATEGORY_COUNTER)
	e9:SetType(EFFECT_TYPE_QUICK_O)
	e9:SetCode(EVENT_FREE_CHAIN)
	e9:SetRange(LOCATION_MZONE)
	e9:SetCountLimit(1)
	e9:SetCost(s.rbccost)
	e9:SetTarget(s.rbctg)
	e9:SetOperation(s.rbcop)
	c:RegisterEffect(e9)
	-- Ribbon Counter cont effect
	local e10 = Effect.CreateEffect(c)
	e10:SetCategory(CATEGORY_DEFCHANGE)
	e10:SetType(EFFECT_TYPE_FIELD)
	e10:SetCode(EFFECT_UPDATE_DEFENSE)
	e10:SetRange(LOCATION_MZONE)
	e10:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e10:SetTarget(s.defcon)
	e10:SetValue(s.defval)
	c:RegisterEffect(e10)
	local e11 = Effect.CreateEffect(c)
	e11:SetCategory(CATEGORY_POSITION)
	e11:SetType(EFFECT_TYPE_FIELD)
	e11:SetCode(EFFECT_SET_POSITION)
	e11:SetRange(LOCATION_MZONE)
	e11:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e11:SetTarget(s.defcon)
	e11:SetValue(POS_FACEUP_DEFENSE)
	c:RegisterEffect(e11)
	-- Set S/T on destruction
	local e6=Effect.CreateEffect(c)
	e6:SetCategory(CATEGORY_SEARCH)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetProperty(EFFECT_FLAG_DELAY)
	e6:SetCode(EVENT_DESTROYED)
	e6:SetCondition(s.setcon)
	e6:SetTarget(s.settg)
	e6:SetOperation(s.setop)
	c:RegisterEffect(e6)
end
s.counter_place_list={COUNTER_SPELL, COUNTER_RIBBON}
s.listed_names={id}
-- Spell Counter Limit
function s.CounterValue(e)
	local c=e:GetHandler()
	if c:IsLocation(LOCATION_MZONE) then
		return 3
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
-- negate attack
function s.nacos(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,COUNTER_SPELL,1,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,COUNTER_SPELL,1,REASON_COST)
end
function s.nacon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker() and Duel.GetAttacker():IsControler(1-tp)
end
function s.nat(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetCard(Duel.GetAttacker())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,Duel.GetAttacker(),1,0,0)
end
function s.nao(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetAttacker()
	if c:IsRelateToEffect(e) then
		Duel.NegateAttack()
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
-- Pendulum Summoned (Place Spell Counter)
function s.psccon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_PENDULUM)
end
function s.psct(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,COUNTER_SPELL)
end
function s.psco(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		c:AddCounter(COUNTER_SPELL,2,true)
	end
end
-- ATK/DEF Value
function s.aduv(e,c)
	return 300*c:GetCounter(COUNTER_SPELL)
end
-- Place Ribbon Counters
function s.rbccost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(aux.FilterFaceupFunction(Card.IsCanAddCounter,COUNTER_RIBBON,1),tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if chk==0 then return c:IsCanRemoveCounter(tp,COUNTER_SPELL,1,REASON_COST) and #g>0 end
	local counter_max = 3
	for i=1,math.min(3,#g) do
		if c:IsCanRemoveCounter(tp,COUNTER_SPELL,i,REASON_COST) then counter_max=i end
	end
	-- 10 = Remove counters
	Duel.Hint(HINT_SELECTMSG,tp,10)
	local cnt=Duel.AnnounceLevel(tp,1,counter_max)
	c:RemoveCounter(tp,COUNTER_SPELL,cnt,REASON_COST)
	e:SetLabel(cnt)
end
function s.rbcfilter(c)
	-- Can place on any monster, but they don't do anything to Link Monsters.
	return c:IsFaceup() and c:IsCanAddCounter(COUNTER_RIBBON,1)
end
function s.rbctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rbcfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	local g=Duel.GetMatchingGroup(s.rbcfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local l=e:GetLabel()
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,l,0,0)
end
function s.rbcop(e,tp,eg,ep,ev,re,r,rp)
	local l=e:GetLabel()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local sg=Duel.SelectMatchingCard(tp,s.rbcfilter,tp,LOCATION_MZONE,LOCATION_MZONE,l,l,nil)
	local tc=sg:GetFirst()
	while tc do
		tc:AddCounter(COUNTER_RIBBON,1)
		local e1=Effect.CreateEffect(e:GetHandler())
		-- e1:SetType(EFFECT_TYPE_SINGLE)
		-- e1:SetCode(EFFECT_SET_DEFENSE_FINAL)
		-- e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE) --since it's not part of the monster.
		-- e1:SetCondition(s.defcon2)
		-- e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		-- e1:SetValue(0)
		-- tc:RegisterEffect(e1)
		-- local e2=e1:Clone()
		-- e2:SetCode(EFFECT_SET_POSITION)
		-- e2:SetValue(POS_FACEUP_DEFENSE)
		-- tc:RegisterEffect(e2)
		tc=sg:GetNext()
	end
end
-- function s.deffilter(c)
-- 	local mamiImpostor = 0
-- 	return c:IsCode(id) and c:IsOriginalCode(mamiImpostor) and c:IsFaceup() and not c:IsDisabled()
-- end
-- function s.defcon2(e)
-- 	local tp=e:GetHandlerPlayer()
-- 	return e:GetHandler():GetCounter(COUNTER_RIBBON) > 0 and Duel.IsExistingMatchingCard(s.deffilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
-- end
function s.defcon(e,c)
	return c:GetCounter(COUNTER_RIBBON)>0
end
function s.defval(e,c)
	local rec=c:GetBaseDefense()
	if rec<0 then rec=0 end
	return rec*-1 -- lose DEF equal to base DEF.
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
		--g:GetFirst():SetStatus(STATUS_SET_TURN,false)
	end
end
