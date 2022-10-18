--Blood Necrofear
local s,id=GetID()
function s.initial_effect(c)
	--cannot be normal summoned/set
	c:EnableUnsummonable()
	--must be special summoned by a card effect
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(s.splimit)
	c:RegisterEffect(e1)
    --Spsummon
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_HAND)
    e2:SetCountLimit(1, id)
    e2:SetCost(s.spcost)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
    --Activate dark sanctuary from deck
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id, 1))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1, id+100)
	e3:SetCondition(s.actcon)
	e3:SetOperation(s.actop)
	c:RegisterEffect(e3)
end
--must be special summoned by a card effect
function s.splimit(e, se, sp, st)
	return se:IsHasType(EFFECT_TYPE_ACTIONS)
end
--Spsummon
function s.costfilter(c)
    return c:IsRace(RACE_FIEND) and not c:IsCode(id) and c:IsAbleToGraveAsCost()
end
function s.spcost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter, tp, LOCATION_DECK, 0, 3, nil) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp, s.costfilter, tp, LOCATION_DECK, 0, 3, 3, nil)
    if Duel.SendtoGrave(g, REASON_COST)~=0 and g:IsExists(Card.IsType, (2 or 3), nil, TYPE_EFFECT) then
		--cannot special summon from gy
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1, 0)
		e1:SetTarget(s.splimit2)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1, tp)
		--cannot activate monsters effects from gy
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetCode(EFFECT_CANNOT_ACTIVATE)
		e2:SetTargetRange(1, 0)
		e2:SetValue(s.actlimit)
		e2:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e2, tp)
	end
end
--cannot special summon from gy
function s.splimit2(e, c)
	return c:IsLocation(LOCATION_GRAVE)
end
--cannot activate monsters effects from gy
function s.actlimit(e, re, tp)
    local loc=re:GetActivateLocation()
    return loc==LOCATION_GRAVE and re:IsActiveType(TYPE_MONSTER)
end
function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp, LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e, 0, tp, false, false, POS_FACEUP) end
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end
function s.spop(e, tp, eg, ep, ev, re, r, rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP)
end
--Activate dark sanctuary from deck
function s.fieldfilter(c,tp)
	return c:IsCode(CARD_DARK_SANCTUARY) and c:GetActivateEffect() and c:GetActivateEffect():IsActivatable(tp,true,true)
end
function s.actcon(e, tp, eg, ep, ev, re, r, rp)
	return Duel.IsExistingMatchingCard(s.fieldfilter, tp, LOCATION_DECK, 0, 1, nil, tp)
end
function s.actop(e, tp, eg, ep, ev, re, r, rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp, s.fieldfilter, tp, LOCATION_DECK, 0, 1, 1, nil, tp):GetFirst()
	if aux.PlayFieldSpell(tc, e, tp, eg, ep, ev, re, r, rp) then
		--face-up spells/traps cannot be targeted
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetRange(LOCATION_FZONE)
		e1:SetTargetRange(LOCATION_ONFIELD,LOCATION_ONFIELD)
		e1:SetTarget(aux.TargetBoolFunction(Card.IsType, TYPE_SPELL+TYPE_TRAP))
		e1:SetCondition(s.condition)
		e1:SetValue(1)
		e1:SetLabelObject(e:GetHandler())
		tc:RegisterEffect(e1)
	end
end
function s.condition(e)
	local blood=e:GetLabelObject()
	return blood:GetLocation()==LOCATION_GRAVE
end
