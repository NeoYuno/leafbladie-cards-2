-- Apprentice with Eyes of Blue
local s, id = GetID()
function s.initial_effect(c)
  -- on normal summon, add a Blue-Eyes monster.
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id, 0))
  e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
  e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
  e1:SetCode(EVENT_SUMMON_SUCCESS)
  e1:SetTarget(s.thtg)
  e1:SetOperation(s.thop)
  c:RegisterEffect(e1)

  -- hand eff to buff atk
  local e2=Effect.CreateEffect(c)
  e2:SetDescription(aux.Stringid(id, 1))
  e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_TODECK)
  e2:SetType(EFFECT_TYPE_QUICK_O)
  e2:SetRange(LOCATION_HAND)
  e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
  e2:SetCode(EVENT_FREE_CHAIN)
  e2:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP+0x1c0)
  e2:SetCountLimit(1,id)
  e2:SetCost(s.atkcost)
  e2:SetTarget(s.atktg)
  e2:SetOperation(s.atkop)
  c:RegisterEffect(e2)
end

s.listed_series = {0xdd}

-- filter Blue-Eyes monster
function s.thfilter(c)
  return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xdd) and c:IsAbleToHand()
end

-- select Blue-Eyes monster from deck
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
  Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

-- add Blue-Eyes monster from deck to hand
function s.thop(e,tp,eg,ep,ev,re,r,rp)
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
  local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
  if #g > 0 then
    Duel.SendtoHand(g,nil,REASON_EFFECT)
    Duel.ConfirmCards(1-tp,g)
  end
end

-- can only use in Dmg Step if dmg was not calculated yet
function s.atkcond(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()~=PHASE_DAMAGE or not Duel.IsDamageCalculated()
end
-- reveal self as cost for atk effect
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return not e:GetHandler():IsPublic() end
end
-- filter Effect monster
function s.atkfilter(c)
  return c:IsFaceup() and c:IsType(TYPE_EFFECT)
end
-- filter Blue-Eyes monster for shuffle
function s.gyfilter(c)
  return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xdd) and c:IsAbleToDeck()
end
-- target monster on field and Blue-Eyes in GY
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chkc then return false end
  if chk==0 then return Duel.IsExistingTarget(s.atkfilter,tp,LOCATION_MZONE,0,1,nil)
    and Duel.IsExistingTarget(s.gyfilter,tp,LOCATION_GRAVE,0,1,nil) end
  -- select monster on field
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
  local fieldtg=Duel.SelectTarget(tp,s.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
  e:SetLabelObject(fieldtg:GetFirst())
  -- select Blue-Eyes monster in GY
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
  local gytg=Duel.SelectTarget(tp,s.gyfilter,tp,LOCATION_GRAVE,0,1,1,nil)
  Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,fieldtg,1,0,0)
  Duel.SetOperationInfo(0,CATEGORY_TODECK,gytg,1,0,0)
end

function s.atkop(e,tp,eg,ep,ev,re,r,rp)
  -- check if gy target is first, and if so, swap the targets so field target is first
  local fieldtc,gytc=Duel.GetFirstTarget()
	if fieldtc~=e:GetLabelObject() then fieldtc,gytc=gytc,fieldtc end

  -- if both targets are still valid
	if fieldtc:IsControler(tp) and fieldtc:IsRelateToEffect(e) and fieldtc:IsFaceup()
  and gytc:IsRelateToEffect(e) then
    -- add half the orig. atk of the gy target to the field target.
    local atk=gytc:GetBaseAttack()
    local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk/2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		fieldtc:RegisterEffect(e1)
    -- then shuffle gy target into the deck.
    Duel.BreakEffect()
    Duel.SendtoDeck(gytc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
