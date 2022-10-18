-- Madoka's Wish
local s, id = GetID()
local CARD_MADOKA_KANAME = 210633301
local CARD_PM_MADOKA = 210633306
local CARD_ULTIMATE_MADOKA = 210633308
local COUNTER_GRIEF=0x1900
Duel.LoadScript("madoka-utility.lua")
function s.initial_effect(c)
  -- activate
  local e1 = Effect.CreateEffect(c)
  e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetCode(EVENT_BATTLE_DESTROYED)
  e1:SetCondition(s.condition)
  e1:SetTarget(s.target)
  e1:SetOperation(s.activate)
  c:RegisterEffect(e1)

  aux.ActInSetTurnIfSetBy(s,c,s.setbyfilter)
end
s.listed_series={0xf72}
s.listed_names={CARD_PM_MADOKA, CARD_MADOKA_KANAME}

-- Activatable if set by this card
function s.setbyfilter(c)
  return c:IsCode(CARD_PM_MADOKA)
end

function s.cfilter(c,tp)
	return c:IsSetCard(0xf72) and c:IsType(TYPE_PENDULUM) and c:IsPreviousControler(tp)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- Filter for destroy from hand/field/extra
function s.desfilter(c,deckg)
  return c:IsSetCard(0xf72) and c:IsType(TYPE_PENDULUM) and c:IsDestructable()
    and (c:IsFaceup() or c:IsLocation(LOCATION_HAND)) and (not deckg or not deckg:IsExists(Card.IsCode,1,nil,c:GetCode()))
end
-- Filter for destroy from Deck
function s.deckdesfil(c)
  return c:IsSetCard(0xf72) and c:IsType(TYPE_MONSTER) and c:IsDestructable() and c:IsLocation(LOCATION_DECK)
end
-- Filter for Summoning Ultimate Madoka
function s.ssfilter(c,e,tp)
  return c:IsCode(CARD_ULTIMATE_MADOKA) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.target(e, tp, eg, ep, ev, re, r, rp, chk)
  --local canDes = s.CanDestroyPuellaMagi(tp)

  local loc=LOCATION_HAND+LOCATION_MZONE+LOCATION_EXTRA
  if Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_PZONE,0,1,nil,CARD_MADOKA_KANAME) then
    loc=loc+LOCATION_DECK
  end

  local g=Duel.GetMatchingGroup(aux.OR(s.desfilter,s.deckdesfil),tp,loc,0,nil)
  if chk==0 then return Duel.IsExistingMatchingCard(s.ssfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
    and Duel.GetLocationCountFromEx(tp) > 0 and aux.SelectUnselectGroup(g,e,tp,5,5,s.rescon,0) end

  Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_EXTRA)
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.activate(e, tp, eg, ep, ev, re, r, rp)

  --if not s.CanDestroyPuellaMagi(tp) then return end

  local loc=LOCATION_HAND+LOCATION_MZONE+LOCATION_EXTRA
  if Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_PZONE,0,1,nil,CARD_MADOKA_KANAME) then
    loc=loc+LOCATION_DECK
  end

  local g=Duel.GetMatchingGroup(aux.OR(s.desfilter,s.deckdesfil),tp,loc,0,nil)
  if aux.SelectUnselectGroup(g,e,tp,5,5,s.rescon,0) then
    local desg=aux.SelectUnselectGroup(g,e,tp,5,5,s.rescon,1,tp,HINTMSG_DESTROY,s.rescon)
    if #desg > 0 and Duel.Destroy(desg,REASON_EFFECT) and Duel.IsExistingMatchingCard(s.ssfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
    and Duel.GetLocationCountFromEx(tp) > 0 then
      Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
      local sg = Duel.SelectMatchingCard(tp,s.ssfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
      if #sg > 0 then
        Duel.SpecialSummon(sg,0,tp,tp,true,false,POS_FACEUP)
        sg:GetFirst():CompleteProcedure()
      end
    end
  end
end

function s.rescon(sg,e,tp,mg)
  local gcnt = Duel.GetCounter(tp,1,0,COUNTER_GRIEF)
  -- different names and only up to (2 * grief) from Deck
  	return sg:GetClassCount(Card.GetCode)==#sg and sg:FilterCount(s.deckdesfil, nil) <= (gcnt * 2)
end
