-- Nagisa's Surprise
local s, id = GetID()
local CARD_NAGISA_MOMOE = 210633401
local CARD_WITCH_CHARLOTTE = 210633404
Duel.LoadScript("madoka-utility.lua")
function s.initial_effect(c)
  -- activate
  local e1 = Effect.CreateEffect(c)
  e1:SetCategory(CATEGORY_NEGATE+CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetCode(EVENT_CHAINING)
  e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
  e1:SetCondition(s.negcon)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
  c:RegisterEffect(e1)

  aux.ActInSetTurnIfSetBy(s,c,s.setbyfilter)
end
s.listed_names={CARD_NAGISA_MOMOE, CARD_WITCH_CHARLOTTE}
s.listed_series={0xf72}

-- Activatable if set by this card
function s.setbyfilter(c)
  return c:IsCode(CARD_NAGISA_MOMOE)
end

-- Negate
function s.pmfilter(c)
  return c:IsFaceup() and c:IsSetCard(0xf72)
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
  if not Duel.IsExistingMatchingCard(s.pmfilter,tp,LOCATION_MZONE,0,1,nil) then return false end
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and Duel.IsChainNegatable(ev)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function s.ssfilter(c,e,tp)
  return c:IsCode(CARD_WITCH_CHARLOTTE) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.desfilter(c)
	return not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
  Debug.Message(Duel.IsExistingMatchingCard(s.ssfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp))
  Debug.Message(Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsCode,CARD_NAGISA_MOMOE),tp,LOCATION_ONFIELD,0,1,nil))
  Debug.Message(msg)
  -- Negate successful, control Nagisa, can Special Charlotte, and can destroy 1 card.
	if Duel.NegateActivation(ev) and Duel.IsExistingMatchingCard(s.ssfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
  and Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsCode,CARD_NAGISA_MOMOE),tp,LOCATION_ONFIELD,0,1,nil)
  and Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_ONFIELD,1,nil)
  and Duel.GetLocationCountFromEx(tp) > 0 then
    Duel.BreakEffect()
    -- Ask to summon Charlotte
    if Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
      Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
      local sg=Duel.SelectMatchingCard(tp,s.ssfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
      local tc=sg:GetFirst()
      -- Summon Charlotte and negate its effects.
      if tc and Duel.SpecialSummonStep(tc,0,tp,tp,true,false,POS_FACEUP) then
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_DISABLE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e1,true)
        local e2=Effect.CreateEffect(e:GetHandler())
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_DISABLE_EFFECT)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e2,true)
        Duel.SpecialSummonComplete()
        -- Destroy 1 opponent's card.
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
        local desg=Duel.SelectMatchingCard(tp,s.desfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
        Duel.Destroy(desg,REASON_EFFECT)
      end
    end
	end
end
