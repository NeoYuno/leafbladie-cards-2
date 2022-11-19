-- Liquid Oxygeddon
-- by MasterQuestMaster
local s, id = GetID()
local CARD_OXYGEDDON = 58071123
function s.initial_effect(c)
  -- Name change
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
  e1:SetCode(EFFECT_CHANGE_CODE)
  e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
  e1:SetValue(CARD_OXYGEDDON)
  c:RegisterEffect(e1)

  --Double Atk
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE)
  e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
  e2:SetRange(LOCATION_MZONE)
  e2:SetCode(EFFECT_SET_ATTACK_FINAL)
  e2:SetCondition(s.atkcon)
  e2:SetValue(s.atkval)
  c:RegisterEffect(e2)

  --Destroy Fire/Pyro monster, then Add Bonding S/T
  local e3=Effect.CreateEffect(c)
  e3:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE+CATEGORY_SEARCH+CATEGORY_TOHAND)
  e3:SetType(EFFECT_TYPE_QUICK_O)
  e3:SetCode(EVENT_FREE_CHAIN)
  e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
  e3:SetRange(LOCATION_HAND)
  e3:SetCountLimit(1,id)
  e3:SetCost(s.descost)
  e3:SetTarget(s.destg)
  e3:SetOperation(s.desop)
  c:RegisterEffect(e3)
end
s.listed_names={CARD_OXYGEDDON}
s.listed_series={0x100} --Bonding

-- Double Atk
function s.atkcon(e)
	local ph=Duel.GetCurrentPhase()
	local bc=e:GetHandler():GetBattleTarget()
	return (ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL)
    and bc and (bc:IsAttribute(ATTRIBUTE_FIRE) or bc:IsRace(RACE_PYRO))
end
function s.atkval(e,c)
	return e:GetHandler():GetAttack()*2
end

function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
  Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
function s.desfilter(c)
  return c:IsRace(RACE_PYRO+RACE_DINOSAUR) or c:IsAttribute(ATTRIBUTE_FIRE)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.desfilter(chkc) end
  local desg=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
  local tc=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,800)
end
function s.thfilter1(c)
  return c:IsSetCard(0x100) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
function s.thfilter2(c,class)
  return class.listed_names and c:IsCode(table.unpack(class.listed_names))
      and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
  -- Destroy Fire/Pyro, then burn.
  local tc=Duel.GetFirstTarget()

  if not tc:IsRelateToEffect(e) or Duel.Destroy(tc,REASON_EFFECT)==0 then return end
    Duel.Damage(1-tp,800,REASON_EFFECT,true)
    Duel.Damage(tp,800,REASON_EFFECT,true)
    Duel.RDComplete()

  -- Add Bonding and listed monster to hand.
  if Duel.IsExistingMatchingCard(s.thfilter1,tp,LOCATION_DECK,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
    Duel.BreakEffect()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local sg = Duel.SelectMatchingCard(tp,s.thfilter1,tp,LOCATION_DECK,0,1,1,nil)
    if #sg > 0 and Duel.SendtoHand(sg,tp,REASON_EFFECT)~=0 then
      local thc=sg:GetFirst()
      Duel.ConfirmCards(1-tp, thc)
      local class=Duel.GetMetatable(thc:GetCode())
      if class==nil or class.listed_names==nil then return end
      -- Add a listed monster to hand
      if Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK,0,1,nil,class)
      and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then -- Add a monster to your hand?
        Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG, tp, 506) -- Select a card to add to your hand.
        sg = Duel.SelectMatchingCard(tp,s.thfilter2,tp,LOCATION_DECK,0,1,1,nil,class)
        if #sg > 0 then
          Duel.SendtoHand(sg,tp,REASON_EFFECT)
          Duel.ConfirmCards(1-tp, sg)
        end
      end
    end
  end
end
