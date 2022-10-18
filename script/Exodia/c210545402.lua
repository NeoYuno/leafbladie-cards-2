--Nekroz of Exodia
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Cannot special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.ritlimit)
	c:RegisterEffect(e1)
    --Set
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1, id)
    e2:SetCost(s.setcost)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
    --ATK up
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetCode(EFFECT_UPDATE_ATTACK)
    e3:SetRange(LOCATION_MZONE)
    e3:SetValue(s.val)
    c:RegisterEffect(e3)
    --Indes
    local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e4:SetValue(1)
	c:RegisterEffect(e4)
    --Immune
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_SINGLE)
    e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e5:SetCode(EFFECT_IMMUNE_EFFECT)
    e5:SetRange(LOCATION_MZONE)
    e5:SetValue(s.efilter)
    c:RegisterEffect(e5)
end
s.listed_names={id}
s.listed_series={0xde, 0x40}
--Set
function s.setcost(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	Duel.SendtoGrave(e:GetHandler(), REASON_DISCARD+REASON_COST)
end
function s.setfilter(c, e, tp)
	if not (c:IsSetCard(0xde) or c:IsSetCard(0x40)) then return end
	if c:IsType(TYPE_MONSTER) and not c:IsCode(id) then 
		return Duel.GetLocationCount(tp, LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e, 0, tp, false, false, POS_FACEDOWN_DEFENSE)
	elseif c:IsType(TYPE_SPELL+TYPE_TRAP) then 
		return (c:IsType(TYPE_FIELD) or Duel.GetLocationCount(tp, LOCATION_SZONE)>0) and c:IsSSetable()
	end
	return false
end
function s.settg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.setfilter(chkc, e, tp) end
	if chk==0 then return Duel.IsExistingTarget(s.setfilter, tp, LOCATION_GRAVE, 0, 1, nil, e, tp) end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SET)
	local g=Duel.SelectTarget(tp, s.setfilter, tp, LOCATION_GRAVE, 0, 1, 1, nil, e, tp)
	local tc=g:GetFirst()
	if tc:IsType(TYPE_MONSTER) then
		Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, g, 1, tp, LOCATION_GRAVE)
	elseif tc:IsType(TYPE_SPELL+TYPE_TRAP) then
		Duel.SetOperationInfo(0, CATEGORY_LEAVE_GRAVE, g, 1, tp, LOCATION_GRAVE)
	end
end
function s.setop(e, tp, eg, ep, ev, re, r, rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	if tc:IsType(TYPE_MONSTER) then
        aux.ToHandOrElse(tc, tp, function(c)
            return Duel.GetLocationCount(tp, LOCATION_MZONE)>0
        end,
        function(c)
            Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEDOWN_DEFENSE)
		end,
        aux.Stringid(id, 0))
	elseif tc:IsType(TYPE_SPELL+TYPE_TRAP) then
		if tc:IsType(TYPE_FIELD) then
			local fc=Duel.GetFieldCard(tp, LOCATION_SZONE, 5)
			if fc then
				Duel.SendtoGrave(fc, REASON_RULE)
				Duel.BreakEffect()
			end
		end
        aux.ToHandOrElse(tc, tp, function(c)
            return Duel.GetLocationCount(tp, LOCATION_SZONE)>0
        end,
        function(c)
			Duel.SSet(tp, tc)
        end,
        aux.Stringid(id, 0))
    end
end
--ATK up
function s.val(e, c)
    return Duel.GetMatchingGroupCount(Card.IsSetCard, c:GetControler(), LOCATION_GRAVE, 0, nil, 0x40)*500
end
--Immune
function s.efilter(e, te)
    return te:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end