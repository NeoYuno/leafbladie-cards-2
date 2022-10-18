-- Sayaka's Grief
local s, id = GetID()
local CARD_SAYAKA_MIKI = 210633303
Duel.LoadScript("madoka-utility.lua")
function s.initial_effect(c)
  -- activate
  local e1 = Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetCode(EVENT_FREE_CHAIN)
  c:RegisterEffect(e1)

  -- Attack all monsters once each
  local e2=Effect.CreateEffect(c)
	e2:SetCode(EFFECT_ATTACK_ALL)
	e2:SetType(EFFECT_TYPE_FIELD)
  e2:SetRange(LOCATION_SZONE)
  e2:SetTargetRange(LOCATION_MZONE,0)
  e2:SetTarget(aux.TargetBoolFunction(Card.IsCode,CARD_SAYAKA_MIKI))
	e2:SetValue(1)
	c:RegisterEffect(e2)

  --destroy replace
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTarget(s.destg)
	e2:SetValue(s.value)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)

  --atk
  local e3=Effect.CreateEffect(c)
  e3:SetCategory(CATEGORY_ATKCHANGE)
  e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e3:SetRange(LOCATION_SZONE)
  e3:SetCode(EVENT_DAMAGE_STEP_END)
  e3:SetCondition(s.atkcon)
  e3:SetOperation(s.atkop)
  c:RegisterEffect(e3)

  aux.ActInSetTurnIfSetBy(s,c,s.setbyfilter)
end
s.listed_names={CARD_SAYAKA_MIKI}
s.listed_series={0xf72}

-- Activatable if set by this card
function s.setbyfilter(c)
  return c:IsCode(CARD_SAYAKA_MIKI)
end

-- Destroy Replace
function s.dfilter(c,tp)
	return c:IsControler(tp) and c:IsReason(REASON_BATTLE) and c:IsSetCard(0xf72) and c:IsType(TYPE_PENDULUM)
    and c:IsCanRemoveCounter(tp,COUNTER_SPELL,1,REASON_EFFECT+REASON_REPLACE)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.dfilter,1,nil,tp) end
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
function s.value(e,c)
	return s.dfilter(c,e:GetHandlerPlayer())
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
  local tc=Duel.GetAttackTarget()
  if not tc or tc:IsControler(1-tp) then tc=Duel.GetAttacker() end
	tc:RemoveCounter(tp,COUNTER_SPELL,1,REASON_EFFECT+REASON_REPLACE)
end

-- atk
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	if not d:IsControler(1-tp) then return end
	e:SetLabelObject(d)
	return a and d and a:IsFaceup() and a:IsSetCard(0xf72) and a:IsType(TYPE_PENDULUM)
    and a:IsRelateToBattle() and d:IsFaceup() and d:IsRelateToBattle()
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)

  if not e:GetHandler():IsRelateToEffect(e) then return end
  local ac=Duel.GetAttacker()
  local dc=Duel.GetAttackTarget()
  if ac:IsControler(1-tp) then ac,dc=dc,ac end

	if ac:IsFaceup() and ac:IsRelateToBattle() and dc:IsFaceup() and dc:IsRelateToBattle() then
    -- reduce opp's ATK by your ATK
    local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(ac:GetAttack() * (-1))
		dc:RegisterEffect(e1)

    -- second attack
    if ac:CanChainAttack(2,true) then
      Duel.ChainAttack(dc)
    end
	end
end
