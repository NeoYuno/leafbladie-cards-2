-- Temmie the Underground Shopkeeper
local s, id = GetID()
function s.initial_effect(c)
  	c:SetUniqueOnField(1,0,id)
  --activate cost
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_ACTIVATE_COST)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetTarget(s.actarget)
	e1:SetCost(s.costchk)
	e1:SetOperation(s.costop)
	c:RegisterEffect(e1)
  --cannot be target
local e2=Effect.CreateEffect(c)
e2:SetType(EFFECT_TYPE_SINGLE)
e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
e2:SetRange(LOCATION_MZONE)
e2:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
e2:SetCondition(s.tgcon)
e2:SetValue(aux.imval1)
c:RegisterEffect(e2)
local e3=e2:Clone()
e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
e3:SetValue(aux.tgoval)
c:RegisterEffect(e3)
end
--Part of "the Underground" archetype
s.listed_series={0xf4a}
function s.actarget(e,te,tp)
	return te:GetHandler():IsLocation(LOCATION_ALL)
end
function s.costchk(e,te_or_c,tp)
	local ct=#{Duel.GetPlayerEffect(tp,id)}
	return Duel.CheckLPCost(tp,ct*500)
end
function s.costop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	Duel.PayLPCost(tp,500)
end
function s.tgcon(e)
  local c=e:GetHandler()
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,0xf4a),c:GetControler(),LOCATION_MZONE,0,1,c)
end
