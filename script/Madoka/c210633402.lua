-- Puella Magi Irregularity
local s, id = GetID()
local COUNTER_GRIEF=0x1900
local CARD_HOMURA_AKEMI=210633302
function s.initial_effect(c)
  Xyz.AddProcedure(c,nil,7,2)
  Pendulum.AddProcedure(c,false) --allow Pend Summon in scale.
  c:EnableReviveLimit()
  c:EnableCounterPermit(COUNTER_SPELL,LOCATION_MZONE)
  --counter limit
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetCode(EFFECT_COUNTER_LIMIT|COUNTER_SPELL)
  e1:SetValue(2)
  c:RegisterEffect(e1)
  --Place Grief counters
  local e2=Effect.CreateEffect(c)
  e2:SetDescription(aux.Stringid(id,0)) --Place Grief counter.
  e2:SetCategory(CATEGORY_COUNTER)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetCode(EVENT_FREE_CHAIN)
  e2:SetRange(LOCATION_PZONE)
  e2:SetCost(s.grfcost)
  e2:SetOperation(s.grfop)
  c:RegisterEffect(e2)
  --Pendulum to hand from ED or GY
  local e3=Effect.CreateEffect(c)
  e3:SetDescription(aux.Stringid(id,3)) --Recover Pendulum Monster.
  e3:SetCategory(CATEGORY_TOHAND+CATEGORY_DESTROY)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetCode(EVENT_FREE_CHAIN)
  e3:SetRange(LOCATION_PZONE)
  e3:SetTarget(s.pthtg)
  e3:SetOperation(s.pthop)
  c:RegisterEffect(e3)
  --atk/def gain
  local e4=Effect.CreateEffect(c)
  e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
  e4:SetType(EFFECT_TYPE_SINGLE)
  e4:SetCode(EFFECT_UPDATE_ATTACK)
  e4:SetValue(s.aduv)
  e4:SetRange(LOCATION_MZONE)
  c:RegisterEffect(e4)
  local e5=e4:Clone()
  e5:SetCode(EFFECT_UPDATE_DEFENSE)
  c:RegisterEffect(e5)
  -- Monster negate
  local e6=Effect.CreateEffect(c)
  e6:SetDescription(1116) -- Negate activation
  e6:SetCategory(CATEGORY_NEGATE)
  e6:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
  e6:SetType(EFFECT_TYPE_QUICK_O)
  e6:SetCode(EVENT_CHAINING)
  e6:SetCountLimit(1,id)
  e6:SetRange(LOCATION_MZONE)
  e6:SetCondition(s.negcon)
  e6:SetCost(s.negcost)
  e6:SetTarget(s.negtg)
  e6:SetOperation(s.negop)
  c:RegisterEffect(e6,false,REGISTER_FLAG_DETACH_XMAT)
  -- Set/Attach from Deck
  local e7=Effect.CreateEffect(c)
  e7:SetCategory(CATEGORY_SEARCH)
  e7:SetType(EFFECT_TYPE_IGNITION)
  e7:SetCode(EVENT_FREE_CHAIN)
  e7:SetCountLimit(1)
  e7:SetRange(LOCATION_MZONE)
  e7:SetCost(s.setcost)
  e7:SetTarget(s.settg)
  e7:SetOperation(s.setop)
  c:RegisterEffect(e7)
end
s.counter_place_list={COUNTER_GRIEF}
-- Madoka Kaname, Homura Akemi
s.listed_names={210633301,CARD_HOMURA_AKEMI}
s.listed_series={0xf72}
-- Place Grief counters
function s.grffilter(c,cnt)
  return c:IsCode(210633301) and c:IsFaceup() and c:IsCanAddCounter(COUNTER_GRIEF,cnt)
end
function s.grfcost(e,tp,eg,ep,ev,re,r,rp,chk)
  -- Check if 1 counter is possible.
  if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,COUNTER_SPELL,1,REASON_COST)
    and Duel.IsExistingMatchingCard(s.grffilter,tp,LOCATION_PZONE,0,1,nil,1) end

  local cnt=1
  -- Check if 2 counters are possible.
  if Duel.IsCanRemoveCounter(tp,1,0,COUNTER_SPELL,2,REASON_COST)
    and Duel.IsExistingMatchingCard(s.grffilter,tp,LOCATION_PZONE,0,1,nil,2) then
    -- "Remove 1 Counter" or "Remove 2 Counters"
    cnt=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2)) + 1
  end
  -- Remove the counters
  Duel.Hint(HINT_SELECTMSG,tp,10)
  Duel.RemoveCounter(tp,1,0,COUNTER_SPELL,cnt,REASON_COST)
  e:SetLabel(cnt)
end
-- Add Grief counters
function s.grfop(e,tp,eg,ep,ev,re,r,rp)
  local cnt=e:GetLabel()
  local sg=Duel.SelectMatchingCard(tp,s.grffilter,tp,LOCATION_PZONE,0,1,1,nil,cnt)
  if #sg > 0 then
    sg:GetFirst():AddCounter(COUNTER_GRIEF,cnt)
  end
end
-- Pendulum to Hand from ED/GY
function s.pthfilter(c)
  return c:IsSetCard(0xf72) and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
    and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
end
function s.pthtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk == 0 then return e:GetHandler():IsDestructable()
    and Duel.IsExistingMatchingCard(s.pthfilter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil) end
end
function s.pthop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  if Duel.Destroy(c,REASON_EFFECT) then
    local g=Duel.SelectMatchingCard(tp,s.pthfilter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,1,nil)
    if #g > 0 then
      Duel.SendtoHand(g,tp,REASON_EFFECT)
    end
  end
end
-- Attack/def Increase Value
function s.aduv(e,c)
	return 300*c:GetCounter(COUNTER_SPELL)
end
-- Monster negate
function s.negcon(e,tp,eg,ep,ev,re,r,rp,chk)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
	local ct=Duel.GetOperatedGroup():GetFirst()
	e:SetLabelObject(ct)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
  -- If Homura was detached
	if re:GetHandler():IsRelateToEffect(re) and e:GetLabelObject():IsCode(CARD_HOMURA_AKEMI) then
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,1,0,0)
	end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and e:GetLabelObject():IsCode(CARD_HOMURA_AKEMI) then
		Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
	end
end
-- Set/Attach from Deck
function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsCanRemoveCounter(tp,LOCATION_ONFIELD,0,COUNTER_SPELL,2,REASON_COST) end
  Duel.RemoveCounter(tp,LOCATION_ONFIELD,0,COUNTER_SPELL,2,REASON_COST)
end
function s.setfilter(c)
  return aux.IsCodeListed(c,CARD_HOMURA_AKEMI) and
    ((c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()) or c:IsType(TYPE_MONSTER))
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return e:GetHandler():IsType(TYPE_XYZ)
    and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
  local c=e:GetHandler()
  local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
  local tc=g:GetFirst()

  -- If it's S/T, set it.
  if tc:IsType(TYPE_SPELL+TYPE_TRAP) and tc:IsSSetable() then
    Duel.SSet(tp,tc)
    --tc:SetStatus(STATUS_SET_TURN,false)
  -- Otherwise, attach if possible. If not possible, remains in deck.
  elseif tc:IsType(TYPE_MONSTER) and c:IsRelateToEffect(e) then
    Duel.Overlay(c,tc)
  end
end
