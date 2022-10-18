-- Connect
local s, id = GetID()
local CARD_HOMURA_AKEMI = 210633302
local CARD_SAYAKA_MIKI = 210633303
local CARD_MAMI_TOMOE = 210633304
local CARD_KYOKO_SAKURA = 210633305
local CARD_PM_MADOKA = 210633306
local CARD_NAGISA_MOMOE = 210633401
Duel.LoadScript("madoka-utility.lua")
function s.initial_effect(c)
  -- activate
  local e1 = Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
  e1:SetCost(s.cost)
  e1:SetTarget(s.target)
  e1:SetOperation(s.operation)
  c:RegisterEffect(e1)

  aux.ActInSetTurnIfSetBy(s,c,s.setbyfilter)
end
s.listed_series={0xf72}
s.listed_names={CARD_HOMURA_AKEMI,CARD_SAYAKA_MIKI,CARD_MAMI_TOMOE,CARD_KYOKO_SAKURA,CARD_PM_MADOKA,CARD_NAGISA_MOMOE}

-- Activatable if set by this card
function s.setbyfilter(c)
  return c:IsSetCard(0xf72)
end

-- can only remove from the specified cards, not any PM cards.
function s.costfil(c,tp)
  return c:IsCode(CARD_HOMURA_AKEMI,CARD_SAYAKA_MIKI,CARD_MAMI_TOMOE,CARD_KYOKO_SAKURA,CARD_PM_MADOKA,CARD_NAGISA_MOMOE)
    and c:IsCanRemoveCounter(tp,COUNTER_SPELL,1,REASON_COST)
end

function s.cost(e, tp, eg, ep, ev, re, r, rp, chk)
  if chk == 0 then return Duel.IsExistingMatchingCard(s.costfil,tp,LOCATION_ONFIELD,0,1,nil,tp) end
  Duel.Hint(HINT_SELECTMSG,tp,10)
  local g = Duel.SelectMatchingCard(tp,s.costfil,tp,LOCATION_ONFIELD,0,1,1,nil,tp)

  -- Remove counter and save for later code check
  if #g > 0 then
    local rc=g:GetFirst()
    rc:RemoveCounter(tp,COUNTER_SPELL,1,REASON_COST)
    e:SetLabel(rc:GetCode())
  end
end

function s.target(e, tp, eg, ep, ev, re, r, rp, chk)
  if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,e) end

  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
  local tg = Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,e)
  local pmc = e:GetLabel()
  if pmc == CARD_PM_MADOKA or pmc == CARD_MAMI_TOMOE then
    Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,tg,1,0,1000)
  elseif pmc == CARD_HOMURA_AKEMI then
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,tg,1,0,0)
  end
end

function s.operation(e, tp, eg, ep, ev, re, r, rp)
  local c=e:GetHandler()
  local pmc = e:GetLabel()
  local tc = Duel.GetFirstTarget()

  -- Effect to grant to the card (code based on PM card name)
  local e1 = Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)

  if tc and tc:IsRelateToEffect(e) then
    if pmc == CARD_PM_MADOKA then
      e1:SetCode(EFFECT_UPDATE_ATTACK)
      e1:SetValue(-1000)
      tc:RegisterEffect(e1)
    elseif pmc == CARD_MAMI_TOMOE then
      e1:SetCode(EFFECT_UPDATE_ATTACK)
      e1:SetValue(1000)
      tc:RegisterEffect(e1)
    elseif pmc == CARD_KYOKO_SAKURA then
      -- effects cannot be negated
      e1:SetDescription(3308)
      e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
      e1:SetCode(EFFECT_CANNOT_DISABLE)
      tc:RegisterEffect(e1)
      -- activations and effect resolutions cannot be negated
      local e2=Effect.CreateEffect(c)
  		e2:SetType(EFFECT_TYPE_FIELD)
  		e2:SetCode(EFFECT_CANNOT_INACTIVATE)
  		e2:SetRange(LOCATION_MZONE)
  		e2:SetTargetRange(1,0)
  		e2:SetValue(s.efilter)
  		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
  		tc:RegisterEffect(e2)
  		local e3=e2:Clone()
  		e3:SetCode(EFFECT_CANNOT_DISEFFECT)
  		tc:RegisterEffect(e3)
    elseif pmc == CARD_HOMURA_AKEMI then
      --Banish until End Phase.
      if Duel.Remove(tc,POS_FACEUP,REASON_EFFECT+REASON_TEMPORARY) ~= 0 then
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e2:SetCode(EVENT_PHASE+PHASE_END)
        e2:SetReset(RESET_PHASE+PHASE_END)
        e2:SetLabelObject(tc)
        e2:SetCountLimit(1)
        e2:SetOperation(s.retop)
        Duel.RegisterEffect(e2,tp)
      end
    elseif pmc == CARD_SAYAKA_MIKI then
      e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
      e1:SetValue(1)
      tc:RegisterEffect(e1)
    elseif pmc == CARD_NAGISA_MOMOE then
      e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
      e1:SetValue(1)
      tc:RegisterEffect(e1)
    end
  end
end

-- Filter für CANNOT_DISEFFECT
function s.efilter(e,ct)
	local te=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT)
	return te:GetHandler()==e:GetHandler()
end

-- Return from Banish functions
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ReturnToField(e:GetLabelObject())
end
