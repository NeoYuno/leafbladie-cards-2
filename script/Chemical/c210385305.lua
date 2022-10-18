-- Legendary Chemist
-- by MasterQuestMaster
local s, id = GetID()
local CARD_CHEMICAL_LAB = 210385308
local CARD_LITMUS_SWORDSMAN = 72566043
local CARD_LITMUS_RITUAL = 8955148
function s.initial_effect(c)
  -- Substitute for Bonding
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetCode(id)
  e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
  e1:SetValue(s.repval)
  c:RegisterEffect(e1)

  -- Add Chemical Lab
  local e2=Effect.CreateEffect(c)
  e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetRange(LOCATION_HAND)
  e2:SetCountLimit(1,id)
  e2:SetCost(s.thcost)
  e2:SetTarget(s.thtg)
  e2:SetOperation(s.thop)
  c:RegisterEffect(e2)

  -- Add this from GY and Litmus from Deck.
  local e3=Effect.CreateEffect(c)
  e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DESTROY)
  e3:SetType(EFFECT_TYPE_QUICK_O)
  e3:SetCode(EVENT_FREE_CHAIN)
  e3:SetRange(LOCATION_GRAVE)
  e3:SetCountLimit(1,id)
  e3:SetTarget(s.gythtg)
  e3:SetOperation(s.gythop)
  c:RegisterEffect(e3)

  -- Set Continuous Trap from Deck
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
  e4:SetCode(EVENT_RELEASE)
  e4:SetProperty(EFFECT_FLAG_DELAY)
  e4:SetCountLimit(1,id)
  e4:SetTarget(s.settg)
  e4:SetOperation(s.setop)
  c:RegisterEffect(e4)
end
s.listed_names = {CARD_CHEMICAL_LAB, CARD_LITMUS_SWORDSMAN, CARD_LITMUS_RITUAL}
s.listed_series = {0x100} -- Bonding

function s.repval(e,c)
  return c:IsLocation(LOCATION_HAND+LOCATION_GRAVE+LOCATION_MZONE)
end

-- Discard to add Laboratory
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
function s.thfilter(c)
	return c:IsCode(CARD_CHEMICAL_LAB) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

-- Add this from GY and Litmus from Deck.
function s.gythtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return e:GetHandler():IsAbleToHand()
		and Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_HAND+LOCATION_ONFIELD)
  Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function s.litmusfil(c,code)
  return c:IsCode(code) and c:IsAbleToHand()
end
function s.gythop(e,tp,eg,ep,ev,re,r,rp)
  -- Destroy a card you control
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
  local desg=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil)

  -- Add this card to your hand
  local c=e:GetHandler()
  if #desg > 0 and Duel.Destroy(desg,REASON_EFFECT)~=0 and c:IsRelateToEffect(e)
  and Duel.SendtoHand(c,nil,REASON_EFFECT)~0 and c:IsLocation(LOCATION_HAND) then
    Duel.ConfirmCards(1-tp,c)
    -- Add Litmus Swordsman and Ritual
    if (Duel.IsExistingMatchingCard(s.litmusfil,tp,LOCATION_DECK,0,1,nil,CARD_LITMUS_SWORDSMAN)
        or Duel.IsExistingMatchingCard(s.litmusfil,tp,LOCATION_DECK,0,1,nil,CARD_LITMUS_RITUAL))
      and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then -- Add Litmus cards?

      Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
      local sg1=Duel.SelectMatchingCard(tp,s.litmusfil,tp,LOCATION_DECK,0,0,1,nil,CARD_LITMUS_SWORDSMAN)
      local sg2=Duel.SelectMatchingCard(tp,s.litmusfil,tp,LOCATION_DECK,0,0,1,nil,CARD_LITMUS_RITUAL)
      sg1:Merge(sg2)

      if #sg1 > 0 then
        Duel.SendtoHand(sg1,tp,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,sg1)
      end
    end
  end
end

-- Set Continuous Trap from Deck
function s.setfilter(c)
	return c:GetType()==TYPE_TRAP+TYPE_CONTINUOUS and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local tc=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if tc then
		Duel.SSet(tp,tc)
		local e0=Effect.CreateEffect(tc)
		e0:SetType(EFFECT_TYPE_SINGLE)
		e0:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
		e0:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e0:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e0)
	end
end
