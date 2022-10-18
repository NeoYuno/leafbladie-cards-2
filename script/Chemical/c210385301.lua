-- Plasma Carboneddon
-- by MasterQuestMaster
local s, id = GetID()
local CARD_CARBONEDDON = 15981690
function s.initial_effect(c)
  -- Name change
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
  e1:SetCode(EFFECT_CHANGE_CODE)
  e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
  e1:SetValue(CARD_CARBONEDDON)
  c:RegisterEffect(e1)

  -- Banish battle opponent
  local e2=Effect.CreateEffect(c)
  e2:SetCategory(CATEGORY_REMOVE)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
  e2:SetCode(EVENT_BATTLE_START)
  e2:SetRange(LOCATION_MZONE)
  e2:SetCountLimit(1)
  e2:SetCondition(s.rmcon)
  e2:SetTarget(s.rmtg)
  e2:SetOperation(s.rmop)
  c:RegisterEffect(e2)

  -- Add Bonding S/T
  local e3=Effect.CreateEffect(c)
  e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_DECKDES+CATEGORY_TOGRAVE)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
  e3:SetProperty(EFFECT_FLAG_DELAY)
  e3:SetCode(EVENT_TO_GRAVE)
  e3:SetCountLimit(1,id)
  e3:SetTarget(s.thtg)
  e3:SetOperation(s.thop)
  c:RegisterEffect(e3)
end
s.listed_names = {CARD_CARBONEDDON}
s.listed_series = {0x100} --Bonding

-- Banish battle opponent
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
  -- get opponent's monster
	local tc=Duel.GetAttacker()
	if tc==e:GetHandler() then tc=Duel.GetAttackTarget() end
	if not (tc and tc:IsFaceup()) then return false end
	return tc:IsControler(1-tp) and not tc:IsAttribute(ATTRIBUTE_LIGHT) and not tc:IsRace(RACE_THUNDER)
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
  local tc=Duel.GetAttacker()
  if tc==e:GetHandler() then tc=Duel.GetAttackTarget() end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,tc,1,0,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttacker()
	if tc==e:GetHandler() then tc=Duel.GetAttackTarget() end
	if tc and tc:IsRelateToBattle() then
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end

function s.thfilter(c)
  return c:IsSetCard(0x100) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
function s.tgyfilter(c,thc)
  return aux.IsCodeListed(thc,c:GetCode()) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
  Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
  local tc = Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
  if tc and Duel.SendtoHand(tc,tp,REASON_EFFECT)~=0 then
    Duel.ConfirmCards(1-tp,tc)
    -- Send a listed monster to GY
    if Duel.IsExistingMatchingCard(s.tgyfilter,tp,LOCATION_DECK,0,1,nil,tc)
    and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then -- Send a monster from your Deck to the GY?
      Duel.BreakEffect()
      Duel.Hint(HINT_SELECTMSG, tp, 504) -- Select a card to send to the GY.
      local sg = Duel.SelectMatchingCard(tp,s.tgyfilter,tp,LOCATION_DECK,0,1,1,nil,tc)
      if #sg > 0 then
        Duel.SendtoGrave(sg,REASON_EFFECT)
      end
    end
  end
end
