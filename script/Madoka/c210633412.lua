-- Mami's Tiro Duet
local s, id = GetID()
local CARD_MAMI_TOMOE = 210633304
Duel.LoadScript("madoka-utility.lua")
function s.initial_effect(c)
  -- activate
  local e1 = Effect.CreateEffect(c)
  e1:SetCategory(CATEGORY_ATKCHANGE)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
  e1:SetHintTiming(TIMING_DAMAGE_STEP)
  e1:SetTarget(s.target)
  e1:SetOperation(s.operation)
  c:RegisterEffect(e1)

  aux.ActInSetTurnIfSetBy(s,c,s.setbyfilter)
end
s.listed_series={0xf72}
s.listed_names={CARD_MAMI_TOMOE}

-- Activatable if set by this card
function s.setbyfilter(c)
  return c:IsCode(CARD_MAMI_TOMOE)
end

-- "can be effect target" is only used when IsExistingTarget is not used.
function s.filter(c,e)
	return c:IsSetCard(0xf72) and c:IsType(TYPE_PENDULUM) and c:IsCanBeEffectTarget(e) and c:IsFaceup()
end

function s.target(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
  if chkc then return false end
  local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil,e)
  if chk==0 then return aux.SelectUnselectGroup(g,e,tp,2,2,aux.dncheck,0) end
  -- let player select 2 with different names
  local tg=aux.SelectUnselectGroup(g,e,tp,2,2,aux.dncheck,1,tp,HINTMSG_TARGET)
  Duel.SetTargetCard(tg)
  Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,tg,#tg,0,0)
    -- search for mami for additional effect
  local mami=tg:Filter(Card.IsCode,1,nil,CARD_MAMI_TOMOE)
  if #mami > 0 then
    e:SetLabelObject(mami:GetFirst())
    -- Include the opponent's card in the ATK change info
    local og = Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
    og:Merge(tg)
    Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,og,#og,0,0)
  end
end

function s.operation(e, tp, eg, ep, ev, re, r, rp)
  local tg = Duel.GetTargetCards(e)
  if #tg < 2 then return end
  for tc in aux.Next(tg) do
    if not tc:IsRelateToEffect(e) or not tc:IsFaceup() then return end
  end

  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATKDEF)
  local sg=tg:Select(tp,1,1,nil)
  if #sg > 0 then
    local c_to = sg:GetFirst()
    tg:RemoveCard(c_to)
    local c_from = tg:GetFirst()

    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(c_from:GetAttack() / 2)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    c_to:RegisterEffect(e1)

    local mami=e:GetLabelObject()
    if mami then
      Duel.BreakEffect()
      local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
      local atk = mami:GetAttack() * -1
    	if #g>0 and atk~=0 then
    	   g:ForEach(s.atkop,e:GetHandler(),atk)
      end
    end
  end
end

function s.atkop(tc,c,atk)
  local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(atk)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc:RegisterEffect(e1)
end

-- Check set cards to see if this card was set by card
function s.gblop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(Card.IsCode,nil,id)
	for ec in aux.Next(g) do
		if re and re:GetOwner() and re:GetOwner():IsCode(CARD_MAMI_TOMOE) then
      -- Activate the turn it is set.
      local e0=Effect.CreateEffect(ec)
      e0:SetType(EFFECT_TYPE_SINGLE)
      e0:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
      e0:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
      e0:SetReset(RESET_EVENT+RESETS_STANDARD)
      ec:RegisterEffect(e0)
		end
	end
end
