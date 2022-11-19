-- Blue-Eyes Shining Nova Dragon
local s, id = GetID()
function s.initial_effect(c)
  c:EnableReviveLimit()
  --cannot special summon
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
  e1:SetCode(EFFECT_SPSUMMON_CONDITION)
  c:RegisterEffect(e1)
  --special summon
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD)
  e2:SetCode(EFFECT_SPSUMMON_PROC)
  e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
  e2:SetRange(LOCATION_HAND)
  e2:SetCondition(s.spcon)
  e2:SetOperation(s.spop)
  c:RegisterEffect(e2)
end
s.listed_names = {CARD_BLUEEYES_W_DRAGON}

-- Special Summon
-- Filter Blue-Eyes
function s.tdfilter(c)
  return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xdd) and c:IsAbleToDeckOrExtraAsCost()
end
-- Check if enough cards exist and an MZONE space would be free.
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE,0,nil) 
		or Group.CreateGroup()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	return (#g>0 and ft>0)
end
-- Shuffle the targets back.
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE,0,nil)
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
  local dg=Duel.GetOperatedGroup()
  local ct=dg:FilterCount(Card.GetPreviousCodeOnField,nil,CARD_BLUEEYES_W_DRAGON)
  local atk=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK)
  if ct>=1 then
    -- atk for each dragon in your GY
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(atk*1000)
    e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE&~RESET_TOFIELD)
    c:RegisterEffect(e1)
  end
  if ct>=2 then
      --cannot target
      local e2=Effect.CreateEffect(c)
      e2:SetType(EFFECT_TYPE_SINGLE)
      e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
      e2:SetRange(LOCATION_MZONE)
      e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
      e2:SetValue(aux.tgoval)
      e2:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE&~RESET_TOFIELD)
      c:RegisterEffect(e2)
      --indestructible
      local e3=Effect.CreateEffect(c)
      e3:SetType(EFFECT_TYPE_SINGLE)
      e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
      e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
      e3:SetRange(LOCATION_MZONE)
      e3:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE&~RESET_TOFIELD)
      e3:SetValue(s.indval)
      c:RegisterEffect(e3)
    end
  if ct==3 then
      -- Tribute to send all cards from field to GY
      local e4=Effect.CreateEffect(c)
      e4:SetDescription(aux.Stringid(id,0))
      e4:SetCategory(CATEGORY_TOGRAVE)
      e4:SetType(EFFECT_TYPE_QUICK_O)
      e4:SetCode(EVENT_FREE_CHAIN)
      e4:SetRange(LOCATION_MZONE)
      e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
      e4:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE&~RESET_TOFIELD)
      e4:SetCost(s.gycost)
      e4:SetTarget(s.gytg)
      e4:SetOperation(s.gyop)
      c:RegisterEffect(e4)
  end
end
-- Check if opponent (for indestructible effect)
function s.indval(e,re,tp)
	return tp~=e:GetHandlerPlayer()
end

-- Send to GY effect (3 mat)
function s.gycost(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return e:GetHandler():IsReleasable() end
	Duel.Release(e:GetHandler(),REASON_COST)
end
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,#g,0,0)
end
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	Duel.SendtoGrave(g,REASON_EFFECT)
end
