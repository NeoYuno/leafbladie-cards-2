--Brotherhood of the Fire Fist - Ram
--Modified for "Flamvell Kindling"
local s,id=GetID()
function s.initial_effect(c)
	--When normal summoned, set 1 "Fire Formation" spell/trap from deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(62694833,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.setcost)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)
	--If special summoned by effect of a "Fire Fist" monster, set 1 "Fire Formation" spell/trap from deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(62694833,0))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.setcon2)
	e2:SetTarget(s.settg2)
	e2:SetOperation(s.setop2)
	c:RegisterEffect(e2)
end
s.listed_series={0x7c,0x79}

function s.costfilter(c,tp)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsMonster() and c:IsDefenseBelow(200) and c:IsAbleToGraveAsCost()
end
function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local b1=Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil)
    local b2=Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_DECK,0,1,nil,tp) and Duel.IsPlayerAffectedByEffect(tp,210632003)
	if chk==0 then return b1 or b2 end
    if b1 and b2 then
        if Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
            s.op(e,tp,eg,ep,ev,re,r,rp)
        else
            Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
        end
    elseif b1 and not b2 then
        Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
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
    Duel.SendtoGrave(tc,REASON_COST)
end
function s.setfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x7c) and c:IsType(TYPE_SPELL+TYPE_TRAP)
		and Duel.IsExistingMatchingCard(s.setfilter2,tp,LOCATION_DECK,0,1,nil,c)
end
function s.setfilter2(c,tc)
	return c:IsSetCard(0x7c) and c:IsType(TYPE_SPELL+TYPE_TRAP) and not c:IsCode(tc:GetCode()) and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsOnField() and s.setfilter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.setfilter,tp,LOCATION_ONFIELD,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.setfilter,tp,LOCATION_ONFIELD,0,1,1,nil,tp)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not (tc:IsRelateToEffect(e) and tc:IsFaceup()) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter2,tp,LOCATION_DECK,0,1,1,nil,tc)
	if #g>0 then
		Duel.SSet(tp,g:GetFirst())
	end
end
function s.setcon2(e,tp,eg,ep,ev,re,r,rp)
	return re and re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsSetCard(0x79)
end
function s.setfilter3(c,tp)
	return c:IsSetCard(0x7c) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
		and not Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,c:GetCode())
end
function s.settg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter3,tp,LOCATION_DECK,0,1,nil,tp) end
end
function s.setop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter3,tp,LOCATION_DECK,0,1,1,nil,tp)
	if #g>0 then
		Duel.SSet(tp,g:GetFirst())
	end
end