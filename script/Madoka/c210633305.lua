--Puella Magi - Kyoko Sakura
--updated by MasterQuest
local s,id=GetID()
local TOKEN_PUELLA_MAGI = 210633300
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
	e3:SetDescription(1160) -- "Place in Pendulum Zone"
	e3:SetType(EFFECT_TYPE_ACTIVATE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetTarget(s.patg)
	e3:SetOperation(s.paop)
	c:RegisterEffect(e3)
	--can't respond to NS/SS.
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_PZONE)
	e4:SetCost(s.limcost)
	e4:SetOperation(s.limop)
	c:RegisterEffect(e4)
	--destroy self in PZone
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
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
	e5:SetTarget(s.psctg)
	e5:SetOperation(s.pscop)
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
	--special summon tokens
	local e9=Effect.CreateEffect(c)
	e9:SetDescription(aux.Stringid(id,2))
	e9:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e9:SetType(EFFECT_TYPE_IGNITION)
	e9:SetRange(LOCATION_MZONE)
	e9:SetCountLimit(1)
	e9:SetCost(s.sstcost)
	e9:SetTarget(s.ssttg)
	e9:SetOperation(s.sstop)
	c:RegisterEffect(e9)
	--set S/T on destruction
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
-- Cannot activate effects Normal/Special Summon
function s.limcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,COUNTER_SPELL,1,REASON_COST) and Duel.GetFlagEffect(tp,id)==0 end
	e:GetHandler():RemoveCounter(tp,COUNTER_SPELL,1,REASON_COST)
end
function s.limop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end

	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetOperation(s.actop1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	Duel.RegisterEffect(e2,tp)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_END)
	e3:SetOperation(s.actop2)
	e3:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e3,tp)
	-- Prevent the effect from being activated again, since it wouldn't do anything.
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end
s.actfilter=aux.FilterFaceupFunction(Card.IsSetCard,0xf72)
function s.actop1(e,tp,eg,ep,ev,re,r,rp)
	if eg and eg:IsExists(s.actfilter,1,nil) then
	    Duel.SetChainLimitTillChainEnd(s.chainlm)
	end
end
function s.actop2(e,tp,eg,ep,ev,re,r,rp)
	local _,g=Duel.CheckEvent(EVENT_SPSUMMON_SUCCESS,true)
	if g and g:IsExists(s.actfilter,1,nil) and Duel.CheckEvent(EVENT_SPSUMMON_SUCCESS) then
    Duel.SetChainLimitTillChainEnd(s.chainlm)
	end
end
function s.chainlm(re,rp,tp)
	return tp==rp
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
-- Pendulum Summoned (Add Counter)
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
-- ATK/DEF Value
function s.aduv(e,c)
	return 300*c:GetCounter(COUNTER_SPELL)
end
-- Summon Puella Magi Tokens
function s.sstcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanRemoveCounter(tp,COUNTER_SPELL,1,REASON_COST) end
	local counter_max
	for i=1,2 do
		if c:IsCanRemoveCounter(tp,COUNTER_SPELL,i,REASON_COST) and (i==1 or not Duel.IsPlayerAffectedByEffect(tp,59822133))
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>=i then
			counter_max=i
		end
	end
	Duel.Hint(HINT_SELECTMSG,tp,10)
	local l=Duel.AnnounceLevel(tp,1,counter_max)
	c:RemoveCounter(tp,COUNTER_SPELL,l,REASON_COST)
	e:SetLabel(l)
end
function s.ssttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_PUELLA_MAGI,0xf72,0x4011,2100,2000,8,RACE_SPELLCASTER,ATTRIBUTE_FIRE) end
	local l=e:GetLabel()
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,l,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,l,tp,0)
end
function s.sstop(e,tp,eg,ep,ev,re,r,rp)
	local l=e:GetLabel()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 or not Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_PUELLA_MAGI,0xf72,0x4011,2100,2000,8,RACE_SPELLCASTER,ATTRIBUTE_FIRE) then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then
		l=1
	else
		l=math.min(l,ft)
	end
	for i=1,l do
		local token=Duel.CreateToken(tp,TOKEN_PUELLA_MAGI)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		token:RegisterEffect(e1,true)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e2:SetValue(s.synlimit)
		e2:SetReset(RESET_EVENT+0xff0000)
		token:RegisterEffect(e2,true)
	end
	Duel.SpecialSummonComplete()
end
function s.synlimit(e,c)
	if not c then return false end
	return not c:IsSetCard(0xf72)
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
	end
end
