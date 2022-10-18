-- Mystic with Eyes of Blue
local s, id = GetID()
function s.initial_effect(c)
  -- 2k atk on target.
  local e1 = Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id, 0))
  e1:SetCategory(CATEGORY_ATKCHANGE)
  e1:SetType(EFFECT_TYPE_QUICK_O)
  e1:SetRange(LOCATION_MZONE)
  e1:SetCode(EVENT_BECOME_TARGET)
  e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
  e1:SetCountLimit(1,id)
  e1:SetCondition(s.atkcon)
  e1:SetTarget(s.atktg)
  e1:SetOperation(s.atkop)
  c:RegisterEffect(e1)

  -- Special Summon with equal level
  local e2=Effect.CreateEffect(c)
  e2:SetDescription(aux.Stringid(id,1))
  e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
  e2:SetRange(LOCATION_HAND+LOCATION_GRAVE)
  e2:SetCountLimit(1,id)
  e2:SetTarget(s.sstg)
  e2:SetOperation(s.ssop)
  c:RegisterEffect(e2)
end

s.listed_series={0xdd}

-- Only if self is targeted.
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsContains(e:GetHandler())
end
-- filter face-up Blue-Eyes card.
function s.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xdd)
end
-- target a Blue-Eyes card you control.
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.atkfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.atkfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- give target 2k atk until eot.
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
  local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(2000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end

-- filter Blue-Eyes monster for shuffle.
function s.todeckfilter(c)
  return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xdd) and (c:IsAbleToDeckAsCost() or c:IsAbleToExtraAsCost())
end

-- filter effect monster with a level
function s.tgfilter(c)
  return c:IsFaceup() and c:IsType(TYPE_EFFECT) and c:HasLevel()
end

-- target effect monster and check if card can be summoned.
function s.sstg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  local c=e:GetHandler()
  if chkc then return false end
  if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE) > 0
    and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
    and Duel.IsExistingMatchingCard(s.todeckfilter,tp,LOCATION_GRAVE,0,1,nil)
    and Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,0,1,nil) end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
  local g1=Duel.SelectTarget(tp,s.todeckfilter,tp,LOCATION_GRAVE,0,1,1,nil)
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g2=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil)
  e:SetLabelObject(g1:GetFirst())
  Duel.SetOperationInfo(0,CATEGORY_TODECK,g1,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end

-- Special Summon, set level, bottom deck on leave
function s.ssop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
	local tc=e:GetLabelObject()
	local g=Duel.GetTargetCards(e)
	local dc=g:GetFirst()
	if dc==tc then dc=g:GetNext() end
  if Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and c:IsRelateToEffect(e) 
	  and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 and dc:IsFaceup() then
    -- increase lvl
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
		e1:SetValue(dc:GetLevel())
		c:RegisterEffect(e1)
    -- bottom deck on leave only if lvl changed.
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
    e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e2:SetReset(RESET_EVENT+RESETS_REDIRECT)
    e2:SetValue(LOCATION_DECKBOT)
    c:RegisterEffect(e2)
	end
end
