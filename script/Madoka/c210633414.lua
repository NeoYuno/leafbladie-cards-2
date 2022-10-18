-- Nagisa's Resolve
local s, id = GetID()
local CARD_NAGISA_MOMOE=210633401
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
  -- activate
  local e1 = Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetCode(EVENT_FREE_CHAIN)
  c:RegisterEffect(e1)

  --500 Boost to Puella Magi
  local e2=Effect.CreateEffect(c)
  e2:SetCategory(CATEGORY_ATKCHANGE)
  e2:SetType(EFFECT_TYPE_FIELD)
  e2:SetCode(EFFECT_UPDATE_ATTACK)
  e2:SetRange(LOCATION_SZONE)
  e2:SetTargetRange(LOCATION_MZONE,0)
  e2:SetTarget(aux.TargetBoolFunction(s.pmfilter))
  e2:SetValue(500)
  c:RegisterEffect(e2)

  -- Boost Nagisa for lower LP.
  local e3=Effect.CreateEffect(c)
  e3:SetCategory(CATEGORY_ATKCHANGE)
  e3:SetType(EFFECT_TYPE_FIELD)
  e3:SetCode(EFFECT_UPDATE_ATTACK)
  e3:SetRange(LOCATION_SZONE)
  e3:SetTargetRange(LOCATION_MZONE,0)
  e3:SetCondition(s.atkcon)
  e3:SetTarget(aux.TargetBoolFunction(Card.IsCode,CARD_NAGISA_MOMOE))
  e3:SetValue(s.atkval)
  c:RegisterEffect(e3)

  -- Negate attack, Special Nagisa
  local e4=Effect.CreateEffect(c)
  e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
  e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
  e4:SetCode(EVENT_ATTACK_ANNOUNCE)
  e4:SetRange(LOCATION_SZONE)
  e4:SetCountLimit(1,id,EFFECT_COUNT_CODE_DUEL)
  e4:SetCondition(s.negcon)
  e4:SetCost(s.negcost)
  e4:SetTarget(s.negtg)
  e4:SetOperation(s.negop)
  c:RegisterEffect(e4)

end
s.listed_names={CARD_NAGISA_MOMOE}
s.listed_series={0xf72}

function s.pmfilter(c)
  return c:IsSetCard(0xf72) and c:IsType(TYPE_PENDULUM)
end

-- Boost ATK equal to difference in LP
function s.atkcon(e)
  local tp=e:GetHandlerPlayer()
	return Duel.GetLP(tp) < Duel.GetLP(1-tp)
end
function s.atkval(e,c)
  local tp=e:GetHandlerPlayer()
  return Duel.GetLP(1-tp) - Duel.GetLP(tp)
end

-- Negate attack, Special Nagisa
function s.negcon(e, tp, eg, ep, ev, re, r, rp)
  local at=Duel.GetAttacker()
  return at:GetControler()~=tp and Duel.GetAttackTarget()==nil
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
  local lp = Duel.GetLP(tp)
	if chk==0 then return lp > 100 end
	Duel.PayLPCost(tp,lp-100)
end
function s.ssfilter(c,e,tp)
  return c:IsCode(CARD_NAGISA_MOMOE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
    and ((c:IsFaceup() and Duel.GetLocationCountFromEx(tp) > 0) or (Duel.GetLocationCount(tp,LOCATION_MZONE) > 0 and not c:IsLocation(LOCATION_EXTRA)))
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
  local at=Duel.GetAttacker()
	if chk==0 then return at:IsOnField() and at:GetAttack()>=Duel.GetLP(tp)
    and Duel.IsExistingMatchingCard(s.ssfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp) end
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
  if not e:GetHandler():IsRelateToEffect(e) then return end
  if Duel.NegateAttack() then
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.ssfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,e,tp)
    if #g>0 then
      Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
    end
  end
end
