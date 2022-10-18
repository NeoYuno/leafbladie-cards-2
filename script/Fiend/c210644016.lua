--Mask of the Doomed
Duel.LoadScript("c420.lua")
local s,id=GetID()
function s.initial_effect(c)
	c:SetUniqueOnField(1, 0, id)
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_ADD_SETCODE)
	e0:SetRange(LOCATION_HAND+LOCATION_DECK+LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED)
    e0:SetValue(0x583)
    c:RegisterEffect(e0)
	--Activate
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)
    --Negate
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1)
	e2:SetCondition(s.discon)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
	aux.DoubleSnareValidity(c, LOCATION_SZONE)
	--Activate cost
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetRange(LOCATION_SZONE)
	e3:SetOperation(s.costop)
	c:RegisterEffect(e3)
	--Act in hand
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e4:SetCondition(s.actcon)
	c:RegisterEffect(e4)
	--Spsummon
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id, 0))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetCountLimit(1, id)
	e5:SetCondition(s.spcon)
	e5:SetCost(s.spcost)
	e5:SetTarget(s.sptg)
	e5:SetOperation(s.spop)
	c:RegisterEffect(e5)
end
--Negate
function s.discon(e, tp, eg, ep, ev, re, r, rp)
	if rp==tp or not re:IsActiveType(TYPE_SPELL+TYPE_TRAP) then return false end
	local c=e:GetHandler()
	local rc=re:GetHandler()
	local p,loc,seq=Duel.GetChainInfo(ev, CHAININFO_TRIGGERING_CONTROLER, CHAININFO_TRIGGERING_LOCATION, CHAININFO_TRIGGERING_SEQUENCE)
	if (loc&LOCATION_SZONE==0 or rc:IsControler(1-p)) then
		if rc:IsLocation(LOCATION_SZONE) and rc:IsControler(p) then
			seq=rc:GetSequence()
			loc=LOCATION_SZONE
		else
			seq=rc:GetPreviousSequence()
			loc=rc:GetPreviousLocation()
		end
	end
	return loc&LOCATION_SZONE==LOCATION_SZONE and rc:GetColumnGroup():IsContains(c)
end
function s.disop(e, tp, eg, ep, ev, re, r, rp)
	Duel.NegateEffect(ev)
end
--Activate cost
function s.costop(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp then return end
	local c=e:GetHandler()
	if not re:GetHandler():GetColumnGroup():IsContains(c) and re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and re:GetActivateLocation()==LOCATION_SZONE then
	Duel.PayLPCost(1-tp, 500)
	end
end
--Act in hand
function s.actfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_FIEND) and c:IsLevelAbove(8)
end
function s.actcon(e)
	return Duel.IsExistingMatchingCard(s.actfilter, e:GetHandlerPlayer(), LOCATION_MZONE, 0, 1, nil)
end
--Spsummon
function s.spcon(e, tp, eg, ep, ev, re, r, rp)
	for _,te in ipairs({Duel.GetPlayerEffect(tp, EFFECT_LPCOST_CHANGE)}) do
		local val=te:GetValue()
		if val(te, e, tp, 100)~=100 then return false end
	end
	return true
end
function s.spcost(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return Duel.CheckLPCost(tp, 100) end
	local lp=Duel.GetLP(tp)
	local m=math.floor(math.min(lp, Duel.GetLP(tp))/100)
	local t={}
	for i=1,m do
		t[i]=i*100
	end
	local ac=Duel.AnnounceNumber(tp, table.unpack(t))
	Duel.PayLPCost(tp, ac)
	e:SetLabel(ac)
end
function s.spfilter(c, e, tp, val)
    return c:IsRace(RACE_FIEND) and c:IsNonEffectMonster() and (c:GetAttack()==val or c:GetDefense()==val) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end
function s.thfilter(c)
	return (c:IsRitualSpell() or (c:IsMask() and c:IsType(TYPE_SPELL+TYPE_TRAP))) and c:IsAbleToHand()
end
function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk==0 then return Duel.GetLocationCount(tp, LOCATION_MZONE)>0 end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
function s.spop(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetLocationCount(tp, LOCATION_MZONE)<=0 then return end
	local val=e:GetLabel()
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g1=Duel.SelectMatchingCard(tp, s.spfilter, tp, LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE, 0, 1, 1, nil, e, tp, val)
    if #g1>0 and Duel.SpecialSummon(g1, 0, tp, tp, false, false, POS_FACEUP)~=0 and Duel.SelectYesNo(tp, aux.Stringid(id, 1)) then
		local g2=Duel.GetMatchingGroup(s.thfilter, tp, LOCATION_DECK, 0, nil)
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
		local sg=g2:Select(tp, 1, 1, nil)
		Duel.SendtoHand(sg, tp, REASON_EFFECT)
		Duel.ConfirmCards(1-tp, sg)
    end
end
