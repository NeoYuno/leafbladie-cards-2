-- Critias, the Blue-Eyes Knight
local s, id = GetID()
function s.initial_effect(c)
  --link summon
  Link.AddProcedure(c,nil,2,2,s.lcheck)
  c:EnableReviveLimit()

  -- Add Fang of Critias and Normal Trap
  local e1=Effect.CreateEffect(c)
  e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
  e1:SetCode(EVENT_SPSUMMON_SUCCESS)
  e1:SetProperty(EFFECT_FLAG_DELAY)
  e1:SetCountLimit(1,id)
  e1:SetCondition(s.thcon)
  e1:SetCost(s.thcost)
  e1:SetTarget(s.thtg)
  e1:SetOperation(s.thop)
  c:RegisterEffect(e1)

  --Set trap from GY
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
  e2:SetCode(EVENT_ATTACK_ANNOUNCE)
  e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
  e2:SetRange(LOCATION_MZONE)
  e2:SetCountLimit(1)
  e2:SetCondition(s.setcon)
  e2:SetTarget(s.settg)
  e2:SetOperation(s.setop)
  c:RegisterEffect(e2)
end
s.listed_names={CARD_BLUEEYES_W_DRAGON, 11082056}
-- including at least 1 Blue-Eyes White Dragon.
function s.lcheck(g,lc,tp)
	return g:IsExists(Card.IsCode,1,nil,CARD_BLUEEYES_W_DRAGON)
end

-- Add Trap/Critias on Summon
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- Discard 1 card as cost
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- Fang of Critias / Normal Trap card
function s.thfilter(c, tp)
  -- Filter2 is called for follow-up card.
	return c:IsCode(11082056) and c:IsAbleToHand()
    and Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
end
function s.thfilter2(c)
  return c:GetType()==TYPE_TRAP and c:IsAbleToHand()
end
-- Check existing cards in deck/GY
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,tp) end
  Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- Add the cards to hand (first Fang, then Trap)
function s.thop(e,tp,eg,ep,ev,re,r,rp)
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
  local g1=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,tp)
  if #g1 > 0 then
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g2=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter2),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
		g1:Merge(g2)
    Duel.SendtoHand(g1,nil,REASON_EFFECT)
    Duel.ConfirmCards(1-tp,g1)
  end
end

-- Set Trap from GY on attack announce
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  -- Sequence > 4 = card is in Extra Monster Zone.
  return (Duel.GetAttacker()==c or Duel.GetAttackTarget()==c) and c:GetSequence()>4
end
-- Filter traps that can be set
function s.setfilter(c)
  return c:IsType(TYPE_TRAP) and c:IsSSetable()
end
-- Target a Trap in your GY
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc) end
	local ct=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) and not e:GetHandler():IsLocation(LOCATION_SZONE) then ct=ct-1 end
	if chk==0 then return ct>0 and Duel.IsExistingTarget(s.setfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectTarget(tp,s.setfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- Set the trap to your field.
function s.setop(e,tp,eg,ep,ev,re,r,rp)
  local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsSSetable() then
		Duel.SSet(tp,tc)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
