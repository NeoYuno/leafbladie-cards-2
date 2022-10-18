--Rogue of Endymion
--Modified for "Flamvell Kindling"
local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(COUNTER_SPELL)
	--add counter
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44640691,0))
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.cttg)
	e1:SetOperation(s.ctop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	--set
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(44640691,1))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCost(s.setcost)
	e3:SetTarget(s.settg)
	e3:SetOperation(s.setop)
	c:RegisterEffect(e3)
end
s.counter_place_list={COUNTER_SPELL}
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,COUNTER_SPELL)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		c:AddCounter(COUNTER_SPELL,1)
	end
end
function s.cfilter(c)
	return c:IsDiscardable() and c:IsRace(RACE_SPELLCASTER)
end
function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanRemoveCounter(tp,COUNTER_SPELL,1,REASON_COST) and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) end
	c:RemoveCounter(tp,COUNTER_SPELL,1,REASON_COST)
	Duel.DiscardHand(tp,s.cfilter,1,1,REASON_DISCARD+REASON_COST,nil)
end
function s.costfilter(c,tp)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsMonster() and c:IsDefenseBelow(200) and c:IsAbleToGraveAsCost()
end
function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local b1=c:IsCanRemoveCounter(tp,COUNTER_SPELL,1,REASON_COST) and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil)
    local b2=Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_DECK,0,1,nil,tp) and Duel.IsPlayerAffectedByEffect(tp,210632003)
	if chk==0 then return b1 or b2 end
    if b1 and b2 then
        if Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
            s.op(e,tp,eg,ep,ev,re,r,rp)
        else
            e:GetHandler():RemoveCounter(tp,COUNTER_SPELL,1,REASON_COST)
            Duel.DiscardHand(tp,s.cfilter,1,1,REASON_DISCARD+REASON_COST,nil)
        end
    elseif b1 and not b2 then
        e:GetHandler():RemoveCounter(tp,COUNTER_SPELL,1,REASON_COST)
        Duel.DiscardHand(tp,s.cfilter,1,1,REASON_DISCARD+REASON_COST,nil)
    else
        s.op(e,tp,eg,ep,ev,re,r,rp)
    end
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
    local fg=Group.CreateGroup()
	for i,pe in ipairs({Duel.IsPlayerAffectedByEffect(tp,210632003)}) do
		fg:AddCard(pe:GetHandler())
	end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local tc=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
    if tc then
        local fc=nil
        if #fg==1 then
            fc=fg:GetFirst()
        else
            fc=fg:Select(tp,1,1,nil)
        end
        Duel.Hint(HINT_CARD,0,fc:GetCode())
        fc:RegisterFlagEffect(210632003,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
    end
    e:GetHandler():RemoveCounter(tp,COUNTER_SPELL,1,REASON_COST)
    Duel.SendtoGrave(tc,REASON_COST)
end
function s.setfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsType(TYPE_CONTINUOUS) and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SSet(tp,g)
		local tc=g:GetFirst()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESET_EVENT+RESETS_CANNOT_ACT+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_CANNOT_ACTIVATE)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e2:SetDescription(aux.Stringid(44640691,2))
		e2:SetTargetRange(1,0)
		e2:SetValue(s.aclimit)
		e2:SetLabel(tc:GetCode())
		e2:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e2,tp)
	end
end
function s.aclimit(e,re,tp)
	return re:GetHandler():IsCode(e:GetLabel()) and not re:GetHandler():IsImmuneToEffect(e)
end
