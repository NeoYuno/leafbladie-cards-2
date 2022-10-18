--Servant of Exodia
local s,id=GetID()
function s.initial_effect(c)
	--Special summon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
    e1:SetCountLimit(1, id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
    --Lv change
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1, id+100)
	e2:SetCost(s.lvcost)
	e2:SetOperation(s.lvop)
	c:RegisterEffect(e2)
end
s.listed_series={0xde, 0x40}
function s.filter(c)
    return c:IsRace(RACE_SPELLCASTER) or c:IsSetCard(0xde) and c:IsAbleToDeckOrExtraAsCost()
end
function s.spcost(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter , tp, LOCATION_HAND+LOCATION_GRAVE, 0, 1, e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp, s.filter, tp, LOCATION_HAND+LOCATION_GRAVE, 0, 1, 1, e:GetHandler())
	Duel.SendtoDeck(g, nil, 2, REASON_COST)
end
function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return Duel.GetLocationCount(tp, LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e, 0, tp, false, false) end
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, e:GetHandler(), 1, 0, 0)
end
function s.spop(e, tp, eg, ep, ev, re, r, rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP)~=0 then
		--Banish it if it leaves the field
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3300)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1)
	end
end
--Lv change
function s.cfilter(c)
	return c:IsSetCard(0xde) or c:IsSetCard(0x40) and not c:IsPublic()
end
function s.lvcost(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter, tp, LOCATION_HAND, 0, 1, nil) end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp, s.cfilter, tp, LOCATION_HAND, 0, 1, 2, nil)
	Duel.ConfirmCards(1-tp, g)
	Duel.ShuffleHand(tp)
	e:SetLabel(#g)
end
function s.lvop(e, tp, eg, ep, ev, re, r, rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	local ct=e:GetLabel()
	local sel=nil
	if c:GetLevel()==1 then
		sel=Duel.SelectOption(tp, aux.Stringid(id, 0))
	else
		sel=Duel.SelectOption(tp, aux.Stringid(id, 0), aux.Stringid(id, 1))
	end
	if sel==1 then
		ct=ct*-1
	end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetValue(ct)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end