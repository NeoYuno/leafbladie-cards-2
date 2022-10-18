-- Puella Magi Witch - Gretchen
local s, id = GetID()
local CARD_PM_MADOKA=210633306
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

  -- Destroy and burn
  local e4=Effect.CreateEffect(c)
  e4:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
  e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e4:SetCode(EVENT_PHASE+PHASE_BATTLE)
  e4:SetRange(LOCATION_MZONE)
  e4:SetCountLimit(1)
  e4:SetTarget(s.destg)
  e4:SetOperation(s.desop)
  c:RegisterEffect(e4)

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

  -- Gain additional attack
  local e7=Effect.CreateEffect(c)
  e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
  e7:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
  e7:SetRange(LOCATION_MZONE)
  e7:SetCountLimit(1)
  e7:SetCondition(s.atkcon)
  e7:SetTarget(s.atktg)
  e7:SetOperation(s.atkop)
  c:RegisterEffect(e7)
end
s.listed_names={CARD_PM_MADOKA}
s.listed_series={0xf72}
s.counter_place_list={COUNTER_SPELL}

-- Filter for Witch Tribute
function s.sprfilter(c)
	return c:IsCode(CARD_PM_MADOKA) and c:GetCounter(COUNTER_SPELL) == 0
end

-- Destroy, then burn
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  local g=e:GetHandler():GetLinkedGroup():Filter(Card.IsType,nil,TYPE_MONSTER)
  Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  local g=c:GetLinkedGroup():Filter(Card.IsType,nil,TYPE_MONSTER)
  if c:IsRelateToEffect(e) and #g>0 and Duel.Destroy(g, REASON_EFFECT)>0 then
    Duel.BreakEffect()
    local og=Duel.GetOperatedGroup()
    local p1g=og:Filter(Card.IsPreviousControler,nil,tp)
    local p1dmg=p1g:GetSum(Card.GetBaseAttack)
    if p1dmg > 0 then
      Duel.Damage(tp,p1dmg,REASON_EFFECT)
    end
    local p2g=og:Filter(Card.IsPreviousControler,nil,1-tp)
    local p2dmg=p2g:GetSum(Card.GetBaseAttack)
    if p2dmg > 0 then
      Duel.Damage(1-tp,p2dmg,REASON_EFFECT)
    end
  end
end

-- GY effect: Special Summon.
function s.sscost(e,tp,eg,ep,ev,re,r,rp,chk)
  local c=e:GetHandler()
  if chk==0 then return c:IsAbleToDeckOrExtraAsCost() end
  Duel.SendtoDeck(c,tp,SEQ_DECKSHUFFLE,REASON_COST)
end
function s.ssfilter(c,e,tp)
  return c:IsCode(CARD_PM_MADOKA) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
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
    if #g>0 and Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)>0 and g:GetFirst():IsCanAddCounter(COUNTER_SPELL,1) then
      g:GetFirst():AddCounter(COUNTER_SPELL,1)
    end
end

-- Gain additional attack
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
  return Duel.IsTurnPlayer(tp)
end

function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return e:GetHandler():GetLinkedGroupCount() > 0 end
end

function s.atkop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  if not c:IsRelateToEffect(e) or not c:IsFaceup() then return end

  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetCode(EFFECT_EXTRA_ATTACK)
  e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
  e1:SetValue(c:GetLinkedGroupCount())
  e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
  c:RegisterEffect(e1)
end
