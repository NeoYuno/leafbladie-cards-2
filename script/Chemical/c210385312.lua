-- Chemical Breakdown
local s, id = GetID()
function s.initial_effect(c)
  -- activate
  local e1 = Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetCost(s.cost)
  e1:SetTarget(s.target)
  e1:SetOperation(s.operation)
  c:RegisterEffect(e1)

  -- Destroy the monsters
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
  e2:SetCode(EVENT_LEAVE_FIELD)
  e2:SetOperation(s.desop)
  c:RegisterEffect(e2)

  -- Avoid Battle Damage
  local e3=Effect.CreateEffect(c)
  e3:SetDescription(aux.Stringid(id,0))
  e3:SetType(EFFECT_TYPE_QUICK_O)
  e3:SetCode(EVENT_FREE_CHAIN)
  e3:SetRange(LOCATION_GRAVE)
  e3:SetCost(aux.bfgcost)
  e3:SetOperation(s.gyop)
  c:RegisterEffect(e3)
end
-- Special Summon
function s.cfilter(c)
  return c:IsType(TYPE_NORMAL) and c:IsLevelAbove(5) and c:IsAbleToDeckAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil) end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
  local sg=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
  if sg:GetFirst():IsLocation(LOCATION_HAND) then
    Duel.ConfirmCards(1-tp,g)
  end
  Duel.SendtoDeck(sg,tp,SEQ_DECKSHUFFLE,REASON_COST)
end
function s.filter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_EARTH+ATTRIBUTE_WATER+ATTRIBUTE_FIRE+ATTRIBUTE_WIND)
    and c:IsLevelBelow(5) and c:IsRace(RACE_DINOSAUR)
    and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
    and (c:IsFaceup() or not c:IsLocation(LOCATION_REMOVED))
end
function s.rescon(sg,e,tp,mg)
  -- different attributes, different locations
  return sg:GetClassCount(Card.GetAttribute)==#sg and sg:GetClassCount(Card.GetLocation)==#sg
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
  local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e,tp)
	if chk==0 then return aux.SelectUnselectGroup(g,e,tp,1,1,s.rescon,0) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,0,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
  -- dont forget NecroValleyFilter
  -- Continuous Trap
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
  -- monster zone count
  local ft=math.min(Duel.GetLocationCount(tp,LOCATION_MZONE),4)
  if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	local tg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.filter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e,tp)
	if ft<=0 or #tg==0 then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
  -- select monsters with different attributes from different locations.
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
  local sg=aux.SelectUnselectGroup(tg,e,tp,1,ft,s.rescon,1,tp,HINTMSG_SPSUMMON,s.rescon)
	--local tc=g:GetFirst()
	for tc in aux.Next(sg) do
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		c:SetCardTarget(tc)
	end
	Duel.SpecialSummonComplete()
end
function s.desfilter(c,rc)
	return rc:IsHasCardTarget(c)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e:GetHandler())
	Duel.Destroy(g,REASON_EFFECT)
end

-- Avoid Battle Damage
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  --avoid battle damage
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD)
  e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
  e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
  e2:SetReset(RESET_PHASE+PHASE_END)
  e2:SetTargetRange(1,0)
  e2:SetCondition(s.bdcon)
  Duel.RegisterEffect(e2,tp)
end
function s.bdcon(e)
  return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_MZONE,0)>0
end
