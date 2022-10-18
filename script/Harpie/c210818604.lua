--Training Harpie Girl
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    --Link material
    Link.AddProcedure(c, s.matfilter, 1, 1)
    --Special summon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
    e1:SetRange(LOCATION_MZONE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1, id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
    --ATK up
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
s.listed_series={0x64}
--Link material
function s.matfilter(c, lc, stype, tp)
    return c:IsSetCard(0x64, lc, stype, tp) and not c:IsType(TYPE_LINK, lc, stype, tp) and c:IsRace(RACE_WINGEDBEAST)
end
--Special summon
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x64) and c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end
function s.filter(c, e, tp)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and Duel.IsExistingMatchingCard(s.spfilter, tp, LOCATION_DECK, 0, 1, c, e, tp)
end
function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return Duel.GetLocationCount(tp, LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.filter, tp, LOCATION_SZONE, 0, 1, nil, e, tp) end
	Duel.SetOperationInfo(0, CATEGORY_DESTROY, nil, 1, tp, LOCATION_SZONE)
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_DECK)
end
function s.spop(e, tp, eg, ep, ev, re, r, rp)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp, s.filter, tp, LOCATION_SZONE, 0, 1, 1, nil, e, tp)
	if #g==0 then return end
	if Duel.Destroy(g, REASON_EFFECT)~=0 and Duel.GetLocationCount(tp, LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
		local g2=Duel.SelectMatchingCard(tp, s.spfilter, tp, LOCATION_DECK, 0, 1, 1, nil, e, tp)
		if #g2>0 then
			Duel.SpecialSummon(g2 , 0, tp, tp, false, false, POS_FACEUP)
		end
	end
end
--ATK up
function s.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x64) and c:IsType(TYPE_MONSTER)
end
function s.atktg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.atkfilter(chkc) end
	if chk==0 then return e:GetHandler():IsAbleToExtra()
		and Duel.IsExistingTarget(s.atkfilter, tp, LOCATION_MZONE, 0, 1, nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp, s.atkfilter, tp, LOCATION_MZONE, 0, 1, 1, nil)
	Duel.SetOperationInfo(0, CATEGORY_ATKCHANGE, g, 1, 0, 0)
	Duel.SetOperationInfo(0, CATEGORY_TODECK, e:GetHandler(), 1, 0, LOCATION_GRAVE)
end
function s.atkop(e, tp, eg, ep, ev, re, r, rp)
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SendtoDeck(c, nil, 0, REASON_EFFECT) and c:IsLocation(LOCATION_EXTRA) then
		if tc:IsRelateToEffect(e) then
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_UPDATE_ATTACK)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            e1:SetValue(500)
            tc:RegisterEffect(e1)
        end
	end
end
