--Harpie Lady Sisters - Ecstasy
local s,id=GetID()
local CARD_ELEGANT_EGOTIST=90219263
function s.initial_effect(c)
    c:EnableReviveLimit()
    --Link materials
	Link.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsAttribute, ATTRIBUTE_WIND), 2)
    --Special summon
    local e0=Effect.CreateEffect(c)
    e0:SetDescription(aux.Stringid(id, 0))
    e0:SetType(EFFECT_TYPE_FIELD)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e0:SetCode(EFFECT_SPSUMMON_PROC)
    e0:SetRange(LOCATION_EXTRA)
    e0:SetCountLimit(1, id)
    e0:SetCondition(s.spcon)
    e0:SetOperation(s.spop)
    e0:SetValue(SUMMON_TYPE_LINK+1)
    c:RegisterEffect(e0)
    --Change atk
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EFFECT_SET_BASE_ATTACK)
    e1:SetCondition(s.atkcon)
    e1:SetValue(1950)
    c:RegisterEffect(e1)
    --Change name
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_CHANGE_CODE)
	e2:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e2:SetValue(CARD_HARPIE_LADY_SISTERS)
	c:RegisterEffect(e2)
    --Negate
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_NEGATE)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
    e3:SetCode(EVENT_CHAINING)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(3)
    e3:SetCondition(s.discon)
    e3:SetCost(s.discost)
    e3:SetTarget(s.distg)
    e3:SetOperation(s.disop)
    c:RegisterEffect(e3)
end
s.listed_names={CARD_HARPIE_LADY, CARD_HARPIE_LADY_SISTERS, CARD_ELEGANT_EGOTIST}
s.listed_series={0x64}
function s.dcfilter(c)
    return c:IsCode(CARD_ELEGANT_EGOTIST) and c:IsDiscardable(d)
end
function s.lkfilter(c)
    return c:GetOriginalCode()==CARD_HARPIE_LADY and c:IsFaceup()
end
function s.spcon(e, c, sc)
    if c==nil then return true end
    local tp=c:GetControler()
    local rg1=Duel.GetMatchingGroup(s.dcfilter, tp, LOCATION_HAND, 0, nil)
    local rg2=Duel.GetMatchingGroup(s.lkfilter, tp, LOCATION_MZONE, 0, nil)
    return aux.SelectUnselectGroup(rg1, e, tp, 1, 1, nil, 0, c) and aux.SelectUnselectGroup(rg2, e, tp, 1, 1, nil, 0, c)
        and Duel.GetLocationCountFromEx(tp, tp, c, sc)>-1
end
function s.spop(e, tp, eg, ep, ev, re, r, rp, c)
    local rg1=Duel.GetMatchingGroup(s.dcfilter, tp, LOCATION_HAND, 0, nil)
    local rg2=Duel.GetMatchingGroup(s.lkfilter, tp, LOCATION_MZONE, 0, nil)
    local g1=aux.SelectUnselectGroup(rg1, e, tp, 1, 1, nil , 1, tp, HINTMSG_DISCARD, false)
    if Duel.SendtoGrave(g1, REASON_DISCARD+REASON_COST)~=0 then
        if Duel.GetLocationCountFromEx(tp, tp, c, sc)<=-1 then return false end
        local g2=aux.SelectUnselectGroup(rg2, e, tp, 1, 1, nil , 1, tp, HINTMSG_TOGRAVE, false)
        Duel.BreakEffect()
        Duel.SendtoGrave(g2, REASON_MATERIAL+REASON_LINK)
    end
end
--Change atk
function s.atkcon(e)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK+1)
end
--Negate
function s.tgfilter(c, tp)
	return c:IsFaceup() and c:IsLocation(LOCATION_ONFIELD) and c:IsControler(tp) and c:IsSetCard(0x64)
end
function s.discon(e, tp, eg, ep, ev, re, r, rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local tg=Duel.GetChainInfo(ev, CHAININFO_TARGET_CARDS)
	return tg and tg:IsExists(s.tgfilter, 1, nil, tp) and Duel.IsChainNegatable(ev)
		and aux.exccon(e, tp, eg, ep, ev, re, r, rp)
end
function s.filter(c)
	return (c:IsFaceup() and c:IsSetCard(0x64) and c:IsType(TYPE_MONSTER)) or (c:IsFaceup() and c:IsSetCard(0x64) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsStatus(STATUS_EFFECT_ENABLED))
end
function s.discost(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter, tp, LOCATION_ONFIELD, 0, 1, e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_RTOHAND)
	local g=Duel.SelectMatchingCard(tp, s.filter, tp, LOCATION_ONFIELD, 0, 1, 1, e:GetHandler())
	Duel.SendtoHand(g, nil, REASON_COST)
end
function s.distg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0, CATEGORY_NEGATE, eg, 1, 0, 0)
end
function s.disop(e, tp, eg, ep, ev, re, r, rp)
    if Duel.NegateActivation(ev) and Duel.SelectYesNo(tp, aux.Stringid(id, 1)) then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
        local g=Duel.SelectMatchingCard(tp, aux.TRUE, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, 1, nil)
        if #g>0 then
            Duel.HintSelection(g)
            Duel.Destroy(g, REASON_EFFECT)
        end
    end
end
