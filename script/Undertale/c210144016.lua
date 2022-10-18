-- Mettaton the Underground Killer Robot
local s, id = GetID()
function s.initial_effect(c)
  c:SetUniqueOnField(1,0,aux.FilterBoolFunction(Card.IsSetCard,0xf4b),LOCATION_MZONE)
  --indes
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e2)
  --Half Target or player
 local e3=Effect.CreateEffect(c)
 e3:SetType(EFFECT_TYPE_QUICK_O)
 e3:SetCategory(CATEGORY_ATKCHANGE)
 e3:SetCode(EVENT_FREE_CHAIN)
 e3:SetProperty(EFFECT_FLAG_INITIAL)
 e3:SetRange(LOCATION_MZONE)
 e3:SetCountLimit(1)
 e3:SetCondition(s.hafcon)
 e3:SetOperation(s.hafop)
 c:RegisterEffect(e3)
 --Return itself to hand
 local e4=Effect.CreateEffect(c)
 e4:SetCategory(CATEGORY_TOHAND)
 e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_QUICK_O)
 e4:SetCode(EVENT_FREE_CHAIN)
 e4:SetProperty(EFFECT_TYPE_SINGLE)
 e4:SetRange(LOCATION_MZONE)
 e4:SetCountLimit(1)
 e4:SetTarget(s.thtg)
 e4:SetOperation(s.thop)
 c:RegisterEffect(e4)
end
function s.hafcon(e,tp,eg,ep,ev,re,r,rp)
	return (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE)
end
function s.hafop(e,tp,eg,ep,ev,re,r,rp)
  if Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) then
   Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
   local g=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
   local tc=g:GetFirst()
	 if tc then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(tc:GetAttack()/2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
  end
 else
  Duel.SetLP(1-tp,Duel.GetLP(1-tp)/2)
 end
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0xf4b) and c:IsAttackAbove(2800) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.selchk(tp)
	return Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsCode,210144001),tp,LOCATION_MZONE,0,1,nil)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local loc=LOCATION_HAND
	if Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsCode,210144001),tp,LOCATION_MZONE,0,1,nil) then loc=loc+LOCATION_DECK end
	if not c:IsFaceup() or not c:IsRelateToEffect(e) then return end
	if Duel.SendtoHand(c,nil,REASON_EFFECT)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,loc,0,1,nil,e,tp) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,loc,0,1,1,nil,e,tp)
		if #g>0 then 
			Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
		end
	end
end
