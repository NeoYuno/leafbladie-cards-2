-- Puella Magi Witch - Oktavia
local s, id = GetID()
local CARD_SAYAKA_MIKI=210633303
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

  -- burn damage
  local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
  e4:SetCondition(s.regcon)
	e4:SetOperation(s.regop)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_CHAIN_SOLVED)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(s.damcon)
	e5:SetOperation(s.damop)
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
s.listed_names={CARD_SAYAKA_MIKI}
s.listed_series={0xf72}
s.counter_place_list={COUNTER_SPELL}

-- Filter for Witch Tribute
function s.sprfilter(c)
	return c:IsCode(CARD_SAYAKA_MIKI) and c:GetCounter(COUNTER_SPELL) == 0
end

-- Burn Damage Register on activation
function s.regcon(e, tp, eg, ep, ev, re, r, rp)
  local rc=re:GetHandler()
  return e:GetHandler():GetLinkedGroup():IsContains(rc) and not rc:IsSetCard(0xf72)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_CHAIN,0,1)
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetFlagEffect(id)~=0
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	Duel.Damage(re:GetHandlerPlayer(),re:GetHandler():GetAttack(),REASON_EFFECT)
end

-- GY effect: Special Summon.
function s.sscost(e,tp,eg,ep,ev,re,r,rp,chk)
  local c=e:GetHandler()
  if chk==0 then return c:IsAbleToDeckOrExtraAsCost() end
  Duel.SendtoDeck(c,tp,SEQ_DECKSHUFFLE,REASON_COST)
end
function s.ssfilter(c,e,tp)
  return c:IsCode(CARD_SAYAKA_MIKI) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
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
