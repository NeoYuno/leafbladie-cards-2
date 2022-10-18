-- Kyoko's Sacrifice
local s, id = GetID()
local CARD_KYOKO_SAKURA=210633305
Duel.LoadScript("madoka-utility.lua")
function s.initial_effect(c)
  -- activate
  local e1 = Effect.CreateEffect(c)
  e1:SetCategory(CATEGORY_DESTROY)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
  e1:SetTarget(s.target)
  e1:SetOperation(s.activate)
  c:RegisterEffect(e1)

  aux.ActInSetTurnIfSetBy(s,c,s.setbyfilter)
end
s.listed_names={CARD_KYOKO_SAKURA}
s.listed_series={0xf72}

-- Activatable if set by this card
function s.setbyfilter(c)
  return c:IsCode(CARD_KYOKO_SAKURA)
end

function s.pmfilter(c)
  return c:IsFaceup() and c:IsSetCard(0xf72) and c:IsType(TYPE_PENDULUM)
    and Duel.IsExistingTarget(aux.TRUE,0,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.pmfilter,tp,LOCATION_MZONE,0,1,nil) end
  -- Target your PM monster
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g1=Duel.SelectTarget(tp,s.pmfilter,tp,LOCATION_MZONE,0,1,1,nil)
  -- If Kyoko, you can destroy up to 2 cards.
  local maxdes = 1
  if g1:GetFirst():IsCode(CARD_KYOKO_SAKURA) then maxdes=2 end
  -- Target the other cards to destroy
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g2=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,maxdes,true,g1:GetFirst())
	g1:Merge(g2)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,#g1,0,0)
end
function s.activate(e, tp, eg, ep, ev, re, r, rp)
  local tg = Duel.GetTargetCards(e)
  Duel.Destroy(tg,REASON_EFFECT)
end
