--Puella Magi - Sayaka Miki
--updated by MasterQuest
local s,id=GetID()
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
	--special summon
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_PZONE)
	e4:SetCost(s.sscost)
	e4:SetTarget(s.sstg)
	e4:SetOperation(s.ssop)
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
	--add up to 3 counters to other Puella Magi
	local e9=Effect.CreateEffect(c)
	e9:SetCategory(CATEGORY_COUNTER)
	e9:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e9:SetType(EFFECT_TYPE_IGNITION)
	e9:SetRange(LOCATION_MZONE)
	e9:SetCountLimit(2)
	e9:SetCost(s.addsccost)
	e9:SetTarget(s.addsctg)
	e9:SetOperation(s.addscop)
	c:RegisterEffect(e9)
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
s.counter_place_list={COUNTER_SPELL}
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
-- Special Summon from hand or GY
function s.sscost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,COUNTER_SPELL,1,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,COUNTER_SPELL,1,REASON_COST)
end
function s.sstfilter(c,e,tp)
	return c:IsType(TYPE_PENDULUM) and c:IsSetCard(0xf72) and c:IsCanBeSpecialSummoned(e,72,tp,false,false) and not c:IsCode(id)
end
function s.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.sstfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function s.ssop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.sstfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 and Duel.SpecialSummon(g,72,tp,tp,false,false,POS_FACEUP) then
		-- Place up to 3 Spell Counters.
		local tc=g:GetFirst()
		local counter = 0
		for i=1,3 do
			if tc:IsCanAddCounter(COUNTER_SPELL, i) then counter=i end
		end
		if counter > 1 then
			counter=Duel.AnnounceLevel(tp,1,counter)
			tc:AddCounter(COUNTER_SPELL,counter)
		elseif counter > 0 then
			tc:AddCounter(COUNTER_SPELL,1)
		end
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
		c:AddCounter(COUNTER_SPELL,1,true)
	end
end
-- Atk/Def Increase Value
function s.aduv(e,c)
	return 300*c:GetCounter(COUNTER_SPELL)
end
-- Add up to 3 spell counters to other Puella Magi
function s.addscfilter(c,e)
	return not c:IsCode(id) and c:IsSetCard(0xf72) and c:IsCanAddCounter(COUNTER_SPELL,1)
		and (not e or c:IsCanBeEffectTarget(e))
end
function s.addsccost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanRemoveCounter(tp,COUNTER_SPELL,1,REASON_COST) end
	c:RemoveCounter(tp,COUNTER_SPELL,1,REASON_COST)
end
function s.addsctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(s.addscfilter,tp,LOCATION_MZONE+LOCATION_PZONE,LOCATION_MZONE+LOCATION_PZONE,1,nil,e) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COUNTER)
	local g=Duel.SelectTarget(tp,s.addscfilter,tp,LOCATION_MZONE+LOCATION_PZONE,LOCATION_MZONE+LOCATION_PZONE,1,1,nil,e)
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,g,1,0,0)
end
function s.gfilter(c,e)
	return c:IsFaceup() and c:IsRelateToEffect(e)
end
function s.addscop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end

	-- Place up to 3 Spell Counters.
	local counter = 0
	for i=1,3 do
		if tc:IsCanAddCounter(COUNTER_SPELL, i) then counter=i end
	end
	if counter > 1 then
		counter=Duel.AnnounceLevel(tp,1,counter)
		tc:AddCounter(COUNTER_SPELL,counter)
	elseif counter > 0 then
		-- no selection necessary
		tc:AddCounter(COUNTER_SPELL,1)
	end
end
-- Set S/T on destruction
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return (r&REASON_EFFECT+REASON_BATTLE)~=0
end
function s.setfilter(c)
	return c:IsType(TYPE_TRAP+TYPE_SPELL) and c:IsSSetable() and c:ListsCode(id)
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
		Duel.ConfirmCards(1-tp,g)
		--g:GetFirst():SetStatus(STATUS_SET_TURN,false)
	end
end
