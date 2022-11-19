-- Bonding Chemical Laboratory
-- by MasterQuestMaster
local s, id = GetID()
local CARD_LEGENDARY_CHEMIST = 210385305
function s.initial_effect(c)
  -- activate
  local e1 = Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetCode(EVENT_FREE_CHAIN)
  c:RegisterEffect(e1)

  --cannot disable
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD)
  e2:SetCode(EFFECT_CANNOT_DISABLE)
  e2:SetRange(LOCATION_FZONE)
  e2:SetTargetRange(LOCATION_ONFIELD+LOCATION_GRAVE,0)
  e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
  e2:SetTarget(aux.TargetBoolFunction(s.tgfilter)) -- restrict to bonding.
  c:RegisterEffect(e2)
  --inactivatable
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_FIELD)
  e3:SetCode(EFFECT_CANNOT_INACTIVATE)
  e3:SetRange(LOCATION_FZONE)
  e3:SetValue(s.effectfilter)
  c:RegisterEffect(e3)
  local e4=e3:Clone()
  e4:SetCode(EFFECT_CANNOT_DISEFFECT)
  c:RegisterEffect(e4)

  --Turn into Fire Pyro
  local e5=Effect.CreateEffect(c)
  e5:SetDescription(aux.Stringid(id,0)) -- Become FIRE Pyro
  e5:SetType(EFFECT_TYPE_IGNITION)
  e5:SetRange(LOCATION_FZONE)
  e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
  e5:SetCountLimit(1)
  e5:SetTarget(s.firetg)
  e5:SetOperation(s.fireop)
  c:RegisterEffect(e5)

  --Add Chemist or monster
  local e6=Effect.CreateEffect(c)
  e6:SetDescription(aux.Stringid(id,1)) -- Send Bonding card to add/send monster.
  e6:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_DECKDES+CATEGORY_TOGRAVE)
  e6:SetType(EFFECT_TYPE_IGNITION)
  e6:SetRange(LOCATION_FZONE)
  e6:SetCountLimit(1,id)
  e6:SetCost(s.thcost)
  e6:SetTarget(s.thtg)
  e6:SetOperation(s.thop)
  c:RegisterEffect(e6)

  -- Boost ATK
  local e7=Effect.CreateEffect(c)
  e7:SetCategory(CATEGORY_ATKCHANGE)
  e7:SetType(EFFECT_TYPE_QUICK_O)
  e7:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
  e7:SetRange(LOCATION_FZONE)
  e7:SetCountLimit(1)
  e7:SetCondition(s.atkcon)
  e7:SetCost(s.atkcost)
  e7:SetOperation(s.atkop)
  c:RegisterEffect(e7)
end
s.listed_series={0x100}
s.listed_names={id, CARD_LEGENDARY_CHEMIST}

function s.tgfilter(c)
  return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSetCard(0x100)
end

function s.effectfilter(e,ct)
	local p=e:GetHandler():GetControler()
	local te,tp=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
	return p==tp and te:IsActiveType(TYPE_SPELL+TYPE_TRAP) and te:GetHandler():IsSetCard(0x100)
end

-- Become Fire Pyro
function s.firefil(c)
  return c:IsFaceup() and not (c:IsRace(RACE_PYRO) and c:IsAttribute(ATTRIBUTE_FIRE))
end
function s.firetg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chkc then return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) end
  if chk == 0 then return Duel.IsExistingTarget(s.firefil,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
  local tg=Duel.SelectTarget(tp,s.firefil,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
function s.fireop(e,tp,eg,ep,ev,re,r,rp)
  local tc=Duel.GetFirstTarget()
  if tc:IsFaceup() and tc:IsRelateToEffect(e) then
    local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetValue(ATTRIBUTE_FIRE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EFFECT_CHANGE_RACE)
    e2:SetValue(RACE_PYRO)
    tc:RegisterEffect(e2)
  end
end

-- Add Chemist or monster
function s.thfilter(c,class)
  return (c:IsCode(CARD_LEGENDARY_CHEMIST) or (class.listed_names and c:IsCode(table.unpack(class.listed_names))))
    and (c:IsAbleToHand() or c:IsAbleToGrave())
end
function s.costfil(c,tp)
  return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSetCard(0x100) and not c:IsCode(id) and c:IsAbleToGraveAsCost()
    and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,c)
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
  e:SetLabel(1)
  if chk==0 then return true end
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
  -- check cost
  if chk==0 then
    if e:GetLabel()~=1 then return false end
    e:SetLabel(0)
    return Duel.IsExistingMatchingCard(s.costfil,tp,LOCATION_DECK,0,1,nil,tp)
  end
  -- Pay cost and sending card to GY.
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
  local g=Duel.SelectMatchingCard(tp,s.costfil,tp,LOCATION_DECK,0,1,1,nil,tp)
  Duel.SendtoGrave(g,REASON_COST)
  -- Save sent card for listing check
  e:SetLabelObject(g:GetFirst())
  Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
  Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
  local gyc=e:GetLabelObject()
  local class=Duel.GetMetatable(gyc:GetCode())
  if class==nil or class.listed_names==nil then return end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
  local sg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,class)
  if #sg > 0 then
    aux.ToHandOrElse(sg,tp)
  end
end

-- Boost ATK
function s.atkcfilter(c)
  return c:IsRace(RACE_DINOSAUR) and c:IsAbleToGraveAsCost()
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttacker()
	local bc=Duel.GetAttackTarget()
	if not bc then return false end
	if bc:IsControler(1-tp) then bc=tc end
	e:SetLabelObject(bc)
	return bc:IsFaceup() and bc:IsRace(RACE_DINOSAUR) and Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL
end
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(s.atkcfilter,tp,LOCATION_DECK,0,1,nil) end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
  local g=Duel.SelectMatchingCard(tp,s.atkcfilter,tp,LOCATION_DECK,0,1,1,nil)
  Duel.SendtoGrave(g,REASON_COST)
  e:SetLabel(g:GetFirst():GetBaseAttack())
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local tc=e:GetLabelObject()
  local atk=e:GetLabel()
  if tc:IsRelateToBattle() and tc:IsFaceup() and tc:IsControler(tp) then
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(atk / 2)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    tc:RegisterEffect(e1)
  end
end
