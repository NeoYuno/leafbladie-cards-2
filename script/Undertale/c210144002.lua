-- Aibou the Puppeteer
local COUNTER_LV=0x1950
local s, id = GetID()
function s.initial_effect(c)
  --Counters
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCondition(s.discon)
	e1:SetCost(s.discost)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
  --Add this banished card to hand
 local e2=Effect.CreateEffect(c)
 e2:SetDescription(aux.Stringid(id,1))
 e2:SetCategory(CATEGORY_TOHAND)
 e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
 e2:SetCode(EVENT_PHASE+PHASE_END)
 e2:SetRange(LOCATION_REMOVED)
 e2:SetCountLimit(1)
 e2:SetTarget(s.thtg)
 e2:SetOperation(s.thop)
 c:RegisterEffect(e2)
end
s.counter_place_list={COUNTER_LV}
s.listed_names={210144001} --Frisk
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local phase=Duel.GetCurrentPhase()
	if phase~=PHASE_DAMAGE or Duel.IsDamageCalculated() then return false end
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	return d~=nil and d:IsFaceup() and (a:GetControler()==tp and a:IsCode(210144001) and a:IsRelateToBattle()) and a:GetCounter(COUNTER_LV)<19
end
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp,chk)
	local at=Duel.GetAttacker()
	if at:GetCounter(COUNTER_LV)==19 or not (at:IsFaceup() and at:IsLocation(LOCATION_MZONE)) then return end
	if at:IsCanAddCounter(COUNTER_LV,9) then
		at:AddCounter(COUNTER_LV,9)
	elseif at:IsCanAddCounter(COUNTER_LV,8) then
		at:AddCounter(COUNTER_LV,8)
	elseif at:IsCanAddCounter(COUNTER_LV,7) then
		at:AddCounter(COUNTER_LV,7)
	elseif at:IsCanAddCounter(COUNTER_LV,6) then
		at:AddCounter(COUNTER_LV,6)
	elseif at:IsCanAddCounter(COUNTER_LV,5) then
		at:AddCounter(COUNTER_LV,5)
	elseif at:IsCanAddCounter(COUNTER_LV,4) then
		at:AddCounter(COUNTER_LV,4)
	elseif at:IsCanAddCounter(COUNTER_LV,3) then
		at:AddCounter(COUNTER_LV,3)
	elseif at:IsCanAddCounter(COUNTER_LV,2) then
		at:AddCounter(COUNTER_LV,2)
	elseif at:IsCanAddCounter(COUNTER_LV,1) then
		at:AddCounter(COUNTER_LV,1)
	end
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
  if e:GetHandler():IsFacedown() then return end
	if chk==0 then return c:IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsAbleToHand() then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
