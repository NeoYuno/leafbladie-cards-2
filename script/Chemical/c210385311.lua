-- Alchemic Bonding
local s, id = GetID()
local CARD_LEGENDARY_CHEMIST = 210385305
function s.initial_effect(c)
  -- activate
  local e1 = Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetTarget(s.target)
  e1:SetCode(EVENT_FREE_CHAIN)
  c:RegisterEffect(e1)

  -- Special Summon
  local e2=Effect.CreateEffect(c)
  e2:SetDescription(aux.Stringid(id,0)) --Special Summon Dinosaur from Deck.
  e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
  e2:SetType(EFFECT_TYPE_QUICK_O)
  e2:SetCode(EVENT_FREE_CHAIN)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCountLimit(1)
  e2:SetCost(s.spcost)
  e2:SetTarget(s.sptg)
  e2:SetOperation(s.spop)
  c:RegisterEffect(e2)

  -- Copy Bonding card
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
  e3:SetCode(EVENT_DESTROYED)
  e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
  e3:SetCondition(s.copycon)
  e3:SetCost(s.copycost)
  e3:SetTarget(s.copytg)
  e3:SetOperation(s.copyop)
  c:RegisterEffect(e3)
end
s.listed_names = {CARD_LEGENDARY_CHEMIST}
s.listed_series = {0x100}

-- Destroy during 2nd Standby Phase.
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	c:SetTurnCounter(0)
	--destroy
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(s.descon)
	e1:SetOperation(s.desop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,2)
	c:RegisterEffect(e1)
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return tp==Duel.GetTurnPlayer()
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetTurnCounter()
	ct=ct+1
	c:SetTurnCounter(ct)
	if ct==2 then
		Duel.Destroy(c,REASON_RULE)
	end
end

-- Special Summon
function s.cfilter(c,e,tp)
  return (c:IsCode(CARD_LEGENDARY_CHEMIST) or c:IsRace(RACE_DINOSAUR)) and (c:IsControler(tp) or c:IsFaceup())
		and (c:IsInMainMZone(tp) or Duel.GetLocationCount(tp,LOCATION_MZONE)>0)
    and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetAttribute())
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.cfilter,1,true,nil,nil,e,tp) end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.SelectReleaseGroupCost(tp,s.cfilter,1,1,true,nil,nil,e,tp)
	Duel.Release(g,REASON_COST)
  e:SetLabel(g:GetFirst():GetAttribute())
end
function s.spfilter(c,e,tp,att)
  return c:IsAttribute(ATTRIBUTE_EARTH+ATTRIBUTE_WATER+ATTRIBUTE_FIRE+ATTRIBUTE_WIND)
    and c:IsRace(RACE_DINOSAUR)
    and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
    and (not att or not c:IsAttribute(att))
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
  -- Continuous Trap
  if not e:GetHandler():IsRelateToEffect(e) then return end

  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
  if Duel.GetLocationCount(tp,LOCATION_MZONE) <=0 then return end
  local att=e:GetLabel()
  local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,att)
  if #sg>0 then
    Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
  end
end

-- Copy Bonding card
function s.copycon(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  return c:IsPreviousLocation(LOCATION_SZONE) and c:IsReason(REASON_EFFECT)
end

function s.cfilter2(c)
  return c:IsRace(RACE_DINOSAUR) and c:IsAbleToRemoveAsCost()
end
function s.copycost(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_GRAVE,0,3,nil) end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
  local sg=Duel.SelectMatchingCard(tp,s.cfilter2,tp,LOCATION_GRAVE,0,3,3,nil)
  Duel.Remove(sg,POS_FACEUP,REASON_COST)
end

function s.copyfilter(c)
  return (c:IsFaceup() or not c:IsLocation(LOCATION_REMOVED)) and c:IsSetCard(0x100)
    and (c:GetType() == TYPE_SPELL or c:GetType() == TYPE_TRAP) and c:IsAbleToDeck()
    and c:CheckActivateEffect(false,true,false)~=nil
end
function s.copytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.copyfilter(chkc) end
  if chk==0 then return Duel.IsExistingTarget(s.copyfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
  local tg=Duel.SelectTarget(tp,s.copyfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
  Duel.SetOperationInfo(0,CATEGORY_TODECK,tg,1,tp,tg:GetFirst():GetLocation())
end

function s.copyop(e,tp,eg,ep,ev,re,r,rp)
  local tc=Duel.GetFirstTarget()
  if not (tc and tc:IsRelateToEffect(e)) then return end
  local te,ceg,cep,cev,cre,cr,crp=tc:CheckActivateEffect(false,true,true)
  if not te then return end
  local tg=te:GetTarget()
  local op=te:GetOperation()
  if tg then tg(te,tp,Group.CreateGroup(),PLAYER_NONE,0,e,REASON_EFFECT,PLAYER_NONE,1) end
  Duel.BreakEffect()
  tc:CreateEffectRelation(te)
  Duel.BreakEffect()
  local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
  for etc in aux.Next(g) do
    etc:CreateEffectRelation(te)
  end
  if op then op(te,tp,Group.CreateGroup(),PLAYER_NONE,0,e,REASON_EFFECT,PLAYER_NONE,1) end
  tc:ReleaseEffectRelation(te)
  for etc in aux.Next(g) do
    etc:ReleaseEffectRelation(te)
  end
  Duel.BreakEffect()
  Duel.SendtoDeck(te:GetHandler(),nil,2,REASON_EFFECT)
end
