-- Puella Magi Witch - Ophelia
local s, id = GetID()
local CARD_KYOKO_SAKURA=210633305
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

  -- Set ATK/DEF 0.
  local e4 = Effect.CreateEffect(c)
  e4:SetCategory(CATEGORY_DEFCHANGE)
  e4:SetType(EFFECT_TYPE_FIELD)
  e4:SetCode(EFFECT_SET_DEFENSE_FINAL)
  e4:SetRange(LOCATION_MZONE)
  e4:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
  e4:SetTarget(s.defcon)
  e4:SetValue(0)
  c:RegisterEffect(e4)
  local e5=e4:Clone()
  e5:SetCategory(CATEGORY_ATKCHANGE)
  e5:SetCode(EFFECT_SET_ATTACK_FINAL)
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
s.listed_names={CARD_KYOKO_SAKURA}
s.listed_series={0xf72}
s.counter_place_list={COUNTER_SPELL}

-- Filter for Witch Tribute
function s.sprfilter(c)
	return c:IsCode(CARD_KYOKO_SAKURA) and c:GetCounter(COUNTER_SPELL) == 0
end

-- ATK/DEF Condition
function s.defcon(e,c)
	return e:GetHandler():GetLinkedGroup():IsContains(c) and not c:IsSetCard(0xf72)
end

-- GY effect: Special Summon.
function s.sscost(e,tp,eg,ep,ev,re,r,rp,chk)
  local c=e:GetHandler()
  if chk==0 then return c:IsAbleToDeckOrExtraAsCost() end
  Duel.SendtoDeck(c,tp,SEQ_DECKSHUFFLE,REASON_COST)
end
function s.ssfilter(c,e,tp)
  return c:IsCode(CARD_KYOKO_SAKURA) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
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
