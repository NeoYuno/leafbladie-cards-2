-- Puella Magi Witch - Chandeloro
local s, id = GetID()
local CARD_MAMI_TOMOE=210633304
local COUNTER_RIBBON=0x1901
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

  -- Place Ribbon Counter
  local e4=Effect.CreateEffect(c)
  e4:SetCategory(CATEGORY_COUNTER)
  e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e4:SetCode(EVENT_SPSUMMON_SUCCESS)
  e4:SetProperty(EFFECT_FLAG_DELAY)
  e4:SetRange(LOCATION_MZONE)
  e4:SetCondition(aux.zptcon(s.rbcfilter))
  e4:SetTarget(s.rbctg)
  e4:SetOperation(s.rbcop)
  c:RegisterEffect(e4)

  -- Ribbon Counter cont effect
  local e5 = Effect.CreateEffect(c)
  e5:SetType(EFFECT_TYPE_FIELD)
  e5:SetCode(EFFECT_CANNOT_ATTACK)
  e5:SetRange(LOCATION_MZONE)
  e5:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
  e5:SetTarget(s.rbccon)
  c:RegisterEffect(e5)
  local e7=e5:Clone()
  e7:SetCode(EFFECT_CANNOT_TRIGGER)
  c:RegisterEffect(e7)

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
s.listed_names={CARD_MAMI_TOMOE}
s.listed_series={0xf72}
s.counter_place_list={COUNTER_SPELL}

-- Filter for Witch Tribute
function s.sprfilter(c)
	return c:IsCode(CARD_MAMI_TOMOE) and c:GetCounter(COUNTER_SPELL) == 0
end

-- Place Ribbon Counter.
function s.rbcfilter(c)
  return not c:IsSetCard(0xf72) and c:IsFaceup() and c:IsCanAddCounter(COUNTER_RIBBON,1)
end
function s.rbctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=aux.zptgroup(eg,s.rbcfilter,e:GetHandler(),tp)
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,g,1,0,0)
end
function s.rbcop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  --Zone points to group (only for summoned monsters), excluding PM.
	local g=aux.zptgroup(eg,s.rbcfilter,c,tp)
	for tc in aux.Next(g) do
    if tc:IsCanAddCounter(COUNTER_RIBBON,1) then tc:AddCounter(COUNTER_RIBBON,1) end
	end
end

-- Ribbon Counter cont effect
function s.rbccon(e,c)
	return c:GetCounter(COUNTER_RIBBON)>0
end

-- GY effect: Special Summon.
function s.sscost(e,tp,eg,ep,ev,re,r,rp,chk)
  local c=e:GetHandler()
  if chk==0 then return c:IsAbleToDeckOrExtraAsCost() end
  Duel.SendtoDeck(c,tp,SEQ_DECKSHUFFLE,REASON_COST)
end
function s.ssfilter(c,e,tp)
  return c:IsCode(CARD_MAMI_TOMOE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
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
    if #g>0 and Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)>0 and g:GetFirst():IsCanAddCounter(COUNTER_SPELL,3) then
      g:GetFirst():AddCounter(COUNTER_SPELL,3)
    end
end
