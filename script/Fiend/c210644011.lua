--Masquerade (Custom)
Duel.LoadScript("c420.lua")
local s,id=GetID()
function s.initial_effect(c)
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
	e1:SetCountLimit(1, id+EFFECT_COUNT_CODE_OATH)
    e1:SetTarget(s.target)
    c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1 = s.thtg(e,tp,eg,ep,ev,re,r,rp,0)
	local b2 = s.cltg1(e,tp,eg,ep,ev,re,r,rp,0)
	local b3 = s.cltg2(e,tp,eg,ep,ev,re,r,rp,0)
	if chk==0 then return b1 or b2 or b3 end
	local ops={}
	local opval={}
	local off=1
	if b1 then
		ops[off]=aux.Stringid(id,0)
		opval[off-1]=1
		off=off+1
	end
	if b2 then
		ops[off]=aux.Stringid(id,1)
		opval[off-1]=2
		off=off+1
	end
	if b3 then
		ops[off]=aux.Stringid(id,2)
		opval[off-1]=3
		off=off+1
	end
	local op=Duel.SelectOption(tp,table.unpack(ops))
	local sel=opval[op]
	if sel==1 then
        e:SetCategory(CATEGORY_TOHAND)
		e:SetOperation(s.thop)
	elseif sel==2 then
        e:SetCategory(CATEGORY_CONTROL)
		e:SetOperation(s.clop1)
	elseif sel==3 then
		e:SetCategory(CATEGORY_CONTROL)
		e:SetOperation(s.clop2)
		s.clop2(e,tp,eg,ep,ev,re,r,rp,1)
	else
		e:SetCategory(0)
		e:SetOperation(nil)
	end
end
function s.thfilter(c)
	return c:IsMask() and c:IsType(TYPE_SPELL+TYPE_TRAP) and not c:IsCode(id) and c:IsAbleToHand()
end
function s.thtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter, tp, LOCATION_DECK, 0, 1, nil) end
	Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end
function s.thop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp, s.thfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
	if #g>0 then
		Duel.SendtoHand(g, nil, REASON_EFFECT)
		Duel.ConfirmCards(1-tp, g)
	end
end
function s.clfilter1(c)
    return c:GetEquipGroup():IsExists(Card.IsMask, 1, nil) and c:IsControlerCanBeChanged()
end
function s.cltg1(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.clfilter1, tp, 0, LOCATION_MZONE, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_CONTROL, nil, 1, 0, 0)
end
function s.clop1(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_CONTROL)
	local g=Duel.SelectMatchingCard(tp, s.clfilter1, tp, 0, LOCATION_MZONE, 1, 1, nil)
	local tc=g:GetFirst()
	if tc and not tc:IsImmuneToEffect(e) and Duel.GetControl(tc, tp) then
		local c=e:GetOwner()
		local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_CONTROL)
		e1:SetValue(tc:GetOwner())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetCondition(s.retcon1)
		tc:RegisterEffect(e1)
	end
end
function s.retcon1(e)
	local c=e:GetHandler()
	return not c:GetEquipGroup():IsExists(Card.IsMask, 1, nil)
end
function s.columnfilter(c)
    return c:IsMask() and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsFaceup()
end
function s.clfilter2(c)
    return c:GetColumnGroup():IsExists(s.columnfilter,1,nil,tp) and c:IsControlerCanBeChanged()
end
function s.cltg2(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.clfilter2, tp, 0, LOCATION_MZONE, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_CONTROL, nil, 1, 0, 0)
end
function s.clop2(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_CONTROL)
	local g=Duel.SelectMatchingCard(tp, s.clfilter2, tp, 0, LOCATION_MZONE, 1, 1, nil)
	local tc=g:GetFirst()
	if tc and not tc:IsImmuneToEffect(e) and Duel.GetControl(tc, tp) then
		local c=e:GetOwner()
		local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_CONTROL)
		e1:SetValue(tc:GetOwner())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetCondition(s.retcon2)
		tc:RegisterEffect(e1)
	end
end
function s.retcon2(e)
	local c=e:GetHandler()
	return not c:GetColumnGroup():IsExists(Card.IsMask, 1, nil)
end
