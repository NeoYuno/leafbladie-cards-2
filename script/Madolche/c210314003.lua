--Madolche Necklafoutis
--Madolche Chowlotte
local s,id=GetID()
function s.initial_effect(c)
	--to deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(s.retcon)
	e1:SetTarget(s.rettg)
	e1:SetOperation(s.retop)
	c:RegisterEffect(e1)
    --Specia Summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_HAND)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_END_PHASE)
    e2:SetCountLimit(1,id)
    e2:SetCondition(s.spcon)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
    --Activate 1 "Madolche Chateau"
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.accon)
	e3:SetOperation(s.acop)
	c:RegisterEffect(e3)
end
s.listed_names={14001430}
s.listed_series={0x71}
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY) and e:GetHandler():GetReasonPlayer()~=tp
		and e:GetHandler():IsPreviousControler(tp)
end
function s.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		Duel.SendtoDeck(e:GetHandler(),nil,2,REASON_EFFECT)
	end
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(Card.IsMonster,tp,LOCATION_GRAVE,0,1,nil)
end
function s.cfilter(c)
	return c:IsSetCard(0x71) and not c:IsPublic()
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,3,e:GetHandler())
	Duel.ConfirmCards(1-tp,g)
	Duel.ShuffleHand(tp)
    e:SetLabel(#g)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) and Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)>0
          and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) 
          and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
        local tg=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,e:GetLabel(),nil)
        Duel.HintSelection(tg:GetFirst())
        Duel.SendtoDeck(tg,nil,2,REASON_EFFECT)
	end
end

function s.fieldfilter(c,tp)
	return c:IsCode(14001430) and c:GetActivateEffect() and c:GetActivateEffect():IsActivatable(tp,true,true)
end
function s.thfilter(c)
    return c:IsSetCard(0x71) and c:IsRace(RACE_SPELLCASTER+RACE_BEAST) and c:IsAbleToHand()
end
function s.accon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.fieldfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,tp)
        or (Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,14001430),tp,LOCATION_FZONE,0,1,nil)
        and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil))
end
function s.acop(e,tp,eg,ep,ev,re,r,rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
	local g1=Duel.GetMatchingGroup(s.fieldfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,nil,tp)
	local g2=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
	local b1=#g1>0
	local b2=#g2>0 and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,14001430),tp,LOCATION_FZONE,0,1,nil)
	if b1 or b2 then
		local op=Duel.SelectEffect(tp,{b1,aux.Stringid(id,4)},{b2,aux.Stringid(id,2)})
		if op==1 then 
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
			local g=Duel.GetMatchingGroup(s.fieldfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,nil,tp)
			local sg=g:Select(tp,1,1,nil):GetFirst()
			Duel.ActivateFieldSpell(sg,e,tp,eg,ep,ev,re,r,rp)
		else
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
			local sg=g:Select(tp,1,1,nil):GetFirst()
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,sg)
		end
    end
end