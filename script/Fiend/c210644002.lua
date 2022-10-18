--Hellpoemer
local s,id=GetID()
function s.initial_effect(c)
    --Spsummon
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetRange(LOCATION_GRAVE)
    e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0, TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
    e1:SetCountLimit(1, id)
    e1:SetCondition(s.spcon)
    e1:SetCost(s.spcost)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
    --Negate
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id, 1))
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_SPECIAL_SUMMON)
    e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1, id+100)
	e2:SetCondition(s.negcon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
end
--Spsummon
function s.spcon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetTurnPlayer()~=tp and Duel.GetCurrentPhase()==PHASE_MAIN1
end
function s.costfilter(c, tp)
    return c:IsRace(RACE_FIEND) and c:IsAbleToRemoveAsCost()
end
function s.spcost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter, tp, LOCATION_GRAVE, 0, 1, e:GetHandler(), tp) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp, s.costfilter, tp, LOCATION_GRAVE, 0, 1, 1, e:GetHandler(), tp)
    Duel.Remove(g, POS_FACEUP, REASON_COST)
end
function s.spfilter(c, e, tp, atk)
    return c:IsRace(RACE_FIEND) and c:IsLevelAbove(5) and atk and c:GetAttack()<=atk and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end
function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
    local _,atk=Duel.GetMatchingGroup(Card.IsFaceup, tp, 0, LOCATION_MZONE, nil):GetMaxGroup(Card.GetAttack)
    if chk==0 then return Duel.GetLocationCount(tp, LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter, tp, LOCATION_HAND+LOCATION_DECK, 0, 1, nil, e, tp, atk) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_HAND+LOCATION_DECK, atk)
end
function s.spop(e, tp, eg, ep, ev, re, r, rp)
    --Opponent can negate this effect by discarding 1 card
	local g=Duel.GetFieldGroup(1-tp, LOCATION_HAND, 0)
	if #g>0 and Duel.SelectYesNo(1-tp, aux.Stringid(id, 2)) then
        if #g==0 then return end
        local sg=g:RandomSelect(1-tp, 1)
		Duel.SendtoGrave(sg, REASON_DISCARD+REASON_EFFECT)
		if Duel.IsChainDisablable(0) then
			Duel.NegateEffect(0)
			return
		end
	end
    if Duel.SkipPhase(1-tp, PHASE_MAIN1, RESET_PHASE+PHASE_MAIN1, 1)~=0 then
        Duel.BreakEffect()
        local _,atk=Duel.GetMatchingGroup(Card.IsFaceup, tp, 0, LOCATION_MZONE, nil):GetMaxGroup(Card.GetAttack)
        if Duel.GetLocationCount(tp, LOCATION_MZONE)<=0 then return end
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
        local g=Duel.SelectMatchingCard(tp, s.spfilter, tp, LOCATION_HAND+LOCATION_DECK, 0, 1, 1, nil, e, tp, atk)
        local tc=g:GetFirst()
        if tc and Duel.SpecialSummonStep(tc, 0, tp, tp, false, false, POS_FACEUP_ATTACK) then
            --Must attack
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_FIELD)
            e1:SetCode(EFFECT_MUST_ATTACK)
            e1:SetRange(LOCATION_MZONE)
            e1:SetTargetRange(0, LOCATION_MZONE)
            tc:RegisterEffect(e1)
            local e2=e1:Clone()
            e2:SetCode(EFFECT_MUST_ATTACK_MONSTER)
            e2:SetValue(s.atklimit)
            tc:RegisterEffect(e2)
        end
        Duel.SpecialSummonComplete()
    end
end
function s.atklimit(e, c)
	return c==e:GetHandler()
end
--Negate
function s.negfilter(c, tp)
	return c:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and c:IsRace(RACE_FIEND) and c:IsControler(tp)
end
function s.spfilter2(c, e, tp)
    return c:IsRace(RACE_FIEND) and c:IsLevelAbove(5) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false, e, tp)
end
function s.negcon(e, tp, eg, ep, ev, re, r, rp)
	if not (rp==1-tp and re:IsHasProperty(EFFECT_FLAG_CARD_TARGET)) then return false end
	local g=Duel.GetChainInfo(ev, CHAININFO_TARGET_CARDS)
	return g and g:IsExists(s.negfilter, 1, nil, tp) and Duel.IsChainNegatable(ev)
end
function s.negtg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return Duel.GetLocationCount(tp, LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter2, tp, LOCATION_HAND+LOCATION_DECK, 0, 1, nil, e, tp) end
	Duel.SetOperationInfo(0, CATEGORY_NEGATE, eg, 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_HAND+LOCATION_DECK)
end
function s.negop(e, tp, eg, ep, ev, re, r, rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		if Duel.GetLocationCount(tp, LOCATION_MZONE)<=0 then return end
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
        local g=Duel.SelectMatchingCard(tp, s.spfilter2, tp, LOCATION_HAND+LOCATION_DECK, 0, 1, 1, nil, e, tp)
        local tc=g:GetFirst()
        if tc and Duel.SpecialSummonStep(tc, 0, tp, tp, false, false, POS_FACEUP) then
            --Negate effects
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_DISABLE)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e1)
            local e2=Effect.CreateEffect(e:GetHandler())
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetCode(EFFECT_DISABLE_EFFECT)
            e2:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e2)
            --Immune
            local e3=Effect.CreateEffect(e:GetHandler())
            e3:SetType(EFFECT_TYPE_SINGLE)
            e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
            e3:SetRange(LOCATION_MZONE)
            e3:SetCode(EFFECT_IMMUNE_EFFECT)
            e3:SetValue(1)
            tc:RegisterEffect(e3)
        end
        Duel.SpecialSummonComplete()
    end
end
