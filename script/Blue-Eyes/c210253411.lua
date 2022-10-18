-- Radiance with Eyes of Blue
local s, id = GetID()
function s.initial_effect(c)
  --activate
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetCode(EVENT_FREE_CHAIN)
  c:RegisterEffect(e1)

  -- draw
  local e1 = Effect.CreateEffect(c)
  e1:SetCategory(CATEGORY_DRAW)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
  e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
  e1:SetCode(EVENT_TO_GRAVE)
  e1:SetCondition(s.drawcon)
  e1:SetTarget(s.drawtg)
  e1:SetOperation(s.drawop)
  c:RegisterEffect(e1)

  -- When Normal Summon Blue-Eyes
  local e2 = Effect.CreateEffect(c)
  e2:SetDescription(aux.Stringid(id, 3))
  e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_DESTROY)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
  e2:SetCode(EVENT_SUMMON_SUCCESS)
  e2:SetProperty(EFFECT_FLAG_DELAY)
  e2:SetCountLimit(1, id)
  e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.condition)
  e2:SetTarget(s.target)
  e2:SetOperation(s.operation)
  c:RegisterEffect(e2)
  -- When Special Summon Blue-Eyes
  local e3 = e2:Clone()
  e3:SetCode(EVENT_SPSUMMON_SUCCESS)
  c:RegisterEffect(e3)
end
s.listed_names={CARD_BLUEEYES_W_DRAGON}
s.listed_series={0xdd}

-- Draw Effect on Destruction
function s.drawcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsReason(REASON_EFFECT)
    and rp==1-tp and c:IsPreviousControler(tp)
end
function s.bewdfilter(c)
	return c:IsCode(CARD_BLUEEYES_W_DRAGON) and (c:IsFaceup() or not c:IsOnField())
end
function s.drawtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then
		local g=Duel.GetMatchingGroup(s.bewdfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
		e:SetLabel(#g)
		return #g>0 and Duel.IsPlayerCanDraw(tp,#g)
	end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(e:GetLabel())
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,e:GetLabel())
end
function s.drawop(e,tp,eg,ep,ev,re,r,rp)
  local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local g=Duel.GetMatchingGroup(s.bewdfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	Duel.Draw(p,#g,REASON_EFFECT)
end

-- Special Summon Blue-Eyes or add Light Tuner
-- Check for Summon of a Blue-Eyes monster.
function s.condition(e,tp,eg,ep,ev,re,r,rp)
  local tc=eg:GetFirst()
  return tc:IsFaceup() and tc:IsSetCard(0xdd)
end
-- Filter for adding Light Tuner
function s.addfilter(c)
  return c:IsLevel(1) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsType(TYPE_TUNER) and c:IsAbleToHand()
end
function s.setfilter(c,ignore)
	return (aux.IsCodeListed(c,CARD_BLUEEYES_W_DRAGON) or aux.IsCodeListed(c,23995346)) 
  and c:IsType(TYPE_SPELL+TYPE_TRAP) and not c:IsCode(id) and c:IsSSetable(ignore)
end
-- Choose option
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local badd=Duel.IsExistingMatchingCard(s.addfilter,tp,LOCATION_DECK,0,1,nil)
  local bset=Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil)
  local bdes=Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil)
	if chk==0 then return badd or bset or bdes end

	local op=0
	if badd and bset and bdes then
			op=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))
	elseif badd and bset then
		  op=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
  elseif badd and bdes then
		  op=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,2))
  elseif bset and bdes then
      op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
  elseif badd then
      op=Duel.SelectOption(tp,aux.Stringid(id,0))
  elseif bset then
      op=Duel.SelectOption(tp,aux.Stringid(id,1))
  else
      op=Duel.SelectOption(tp,aux.Stringid(id,2))+1
	end
	e:SetLabel(op)
	if op==0 then
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	end
  if op==2 then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_ONFIELD)
	end
end
-- Execute effect based on selection
function s.operation(e,tp,eg,ep,ev,re,r,rp)
  local op=e:GetLabel()
	if op==0 then
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
  	local g=Duel.SelectMatchingCard(tp,s.addfilter,tp,LOCATION_DECK,0,1,1,nil)
  	if #g>0 then
  		Duel.SendtoHand(g,nil,REASON_EFFECT)
  		Duel.ConfirmCards(1-tp,g)
  	end
	end
  if op==1 then
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil,false)
		if #g>0 then
			Duel.SSet(tp,g:GetFirst())
		end
	end
  if op==2 then
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil,false)
		if #g>0 then
			Duel.Destroy(g:GetFirst(),REASON_EFFECT)
    end
  end
end
