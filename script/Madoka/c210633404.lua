-- Puella Magi Witch - Charlotte
local s, id = GetID()
local CARD_NAGISA_MOMOE = 210633401
Duel.LoadScript("witch-utility.lua")
function s.initial_effect(c)
  c:EnableReviveLimit()
  --cannot link material
  local e0=Effect.CreateEffect(c)
  e0:SetType(EFFECT_TYPE_SINGLE)
  e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
  e0:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
  e0:SetValue(1)
  c:RegisterEffect(e0)
  -- Witch Summon (to either field, by tributing a monster you control)
  local e1,e2,e3 = aux.AddWitchProcedure(c,s.sprfilter,aux.Stringid(id,0),aux.Stringid(id,1))

  -- Cannot activate S/T.
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_FIELD)
  e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
  e4:SetCode(EFFECT_CANNOT_ACTIVATE)
  e4:SetRange(LOCATION_MZONE)
  e4:SetTargetRange(1,0)
  e4:SetValue(s.aclimit)
  c:RegisterEffect(e4)

  -- Negate own effect
  local e5=Effect.CreateEffect(c)
  e5:SetCategory(CATEGORY_DISABLE)
  e5:SetType(EFFECT_TYPE_IGNITION)
  e5:SetCode(EVENT_FREE_CHAIN)
  e5:SetRange(LOCATION_MZONE)
  e5:SetCondition(s.negcon)
  e5:SetCost(s.negcost)
  e5:SetOperation(s.negop)
  c:RegisterEffect(e5)

  -- GY effect: Special Summon
  local e6=Effect.CreateEffect(c)
  e6:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_COUNTER)
  e6:SetType(EFFECT_TYPE_IGNITION)
  e6:SetCode(EVENT_FREE_CHAIN)
  e6:SetRange(LOCATION_GRAVE)
  e6:SetCountLimit(1,id)
  e6:SetCost(s.sscost)
  e6:SetTarget(s.sstg)
  e6:SetOperation(s.ssop)
  c:RegisterEffect(e6)
end
s.listed_names={CARD_NAGISA_MOMOE}
s.counter_place_list={COUNTER_SPELL}

-- Filter for Witch Tribute
function s.sprfilter(c)
	return c:IsCode(CARD_NAGISA_MOMOE) and c:GetCounter(COUNTER_SPELL) == 0
end
-- Spell/Trap activate filter
function s.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
-- Negate own effect
function s.negcon(e)
  return not e:GetHandler():IsDisabled()
end
function s.negfilter(c,e)
  return e:GetHandler():GetLinkedGroup():IsContains(c) and c:IsReleasable()
end
function s.negcost(e, tp, eg, ep, ev, re, r, rp, chk)
  if chk==0 then return Duel.IsExistingMatchingCard(s.negfilter,tp,LOCATION_MZONE,0,1,nil,e) end
  local sg=Duel.SelectMatchingCard(tp,s.negfilter,tp,LOCATION_MZONE,0,1,1,nil,e)
  Duel.Release(sg,REASON_COST)
end
function s.negop(e, tp, eg, ep, ev, re, r, rp)
  local c=e:GetHandler()
  if c:IsFaceup() and not c:IsDisabled() and c:IsRelateToEffect(e) then
    Duel.NegateRelatedChain(c,RESET_TURN_SET)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e2)
  end
end

-- GY effect: Special Summon.
function s.sscost(e,tp,eg,ep,ev,re,r,rp,chk)
  local c=e:GetHandler()
  if chk==0 then return c:IsAbleToDeckOrExtraAsCost() end
  Duel.SendtoDeck(c,tp,SEQ_DECKSHUFFLE,REASON_COST)
end
function s.ssfilter(c,e,tp)
  return c:IsCode(CARD_NAGISA_MOMOE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
    and ((c:IsFaceup() and Duel.GetLocationCountFromEx(tp) > 0)
    or (Duel.GetLocationCount(tp,LOCATION_MZONE) > 0 and not c:IsLocation(LOCATION_EXTRA)))
end
function s.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then
    return Duel.IsExistingMatchingCard(s.ssfilter,tp,LOCATION_HAND+LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil,e,tp)
  end
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_EXTRA+LOCATION_GRAVE)
end
function s.ssop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.ssfilter),tp,LOCATION_HAND+LOCATION_EXTRA+LOCATION_GRAVE,0,1,1,nil,e,tp)
    if #g>0 and Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)>0 and g:GetFirst():IsCanAddCounter(COUNTER_SPELL,2) then
      g:GetFirst():AddCounter(COUNTER_SPELL,2)
    end
end
