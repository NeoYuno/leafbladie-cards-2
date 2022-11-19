--Venom Fusion
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Fusion.CreateSummonEff(c,s.ffilter,Fusion.OnFieldMat,s.fextra)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetCondition(s.condition)
	c:RegisterEffect(e1)
    --To hand
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_series={0x50}
s.listed_names={54306223,210243005}
s.counter_list={COUNTER_VENOM}
function s.ffilter(c)
	return c:IsSetCard(0x50) or c:IsCode(210243005)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,54306223),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
function s.checkextra(tp,sg,fc)
	return sg:IsExists(aux.AND(aux.FilterBoolFunction(Card.IsRace,RACE_REPTILE),aux.FilterBoolFunction(Card.IsControler,tp)),1,nil)
end
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsFaceup),tp,0,LOCATION_ONFIELD,nil),s.checkextra
end
function s.filter(c)
	return c:GetCounter(COUNTER_VENOM)>0
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) and e:GetHandler():IsAbleToHand() end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local ct=tc:GetCounter(COUNTER_VENOM)
	if ct>0 and tc:RemoveCounter(tp,COUNTER_VENOM,ct,REASON_EFFECT) then
		Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
	end
end