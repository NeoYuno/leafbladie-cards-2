-- Shaman with Eyes of Blue
local s,id=GetID()
function s.initial_effect(c)
  --Search
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0))
  e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
  e1:SetType(EFFECT_TYPE_QUICK_O)
  e1:SetRange(LOCATION_MZONE)
  e1:SetCode(EVENT_BECOME_TARGET)
  e1:SetCountLimit(1,id)
  e1:SetCondition(s.thcon)
  e1:SetTarget(s.thtg)
  e1:SetOperation(s.thop)
  c:RegisterEffect(e1)
  --Draw
  local e2=Effect.CreateEffect(c)
  e2:SetDescription(aux.Stringid(id,1))
  e2:SetCategory(CATEGORY_DRAW)
  e2:SetType(EFFECT_TYPE_QUICK_O)
  e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
  e2:SetRange(LOCATION_HAND)
  e2:SetCode(EVENT_FREE_CHAIN)
  e2:SetCountLimit(1,id)
  e2:SetCost(s.drawcost)
  e2:SetTarget(s.drawtg)
  e2:SetOperation(s.drawop)
  c:RegisterEffect(e2)
end
s.listed_names={CARD_BLUEEYES_W_DRAGON, 23995346}
s.listed_series={0xdd}

-- Only if self is targeted.
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsContains(e:GetHandler())
end
-- filter for adding Blue-Eyes S/T.
function s.thfilter(c)
	return (c:ListsCode(CARD_BLUEEYES_W_DRAGON) or c:ListsCode(23995346))
    and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- check if a Blue-Eyes S/T is in deck.
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
  Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- select and add a Blue-Eyes S/T to hand.
function s.thop(e,tp,eg,ep,ev,re,r,rp)
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

-- filter for sending Blue-Eyes monster from hand or field to draw.
function s.togravefilter(c,tp)
	return (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsType(TYPE_MONSTER) and c:IsSetCard(0xdd) and c:IsAbleToGrave()
end
-- discard self as cost for draw effect.
function s.drawcost(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return e:GetHandler():IsDiscardable() end
  Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- check if a card to send exists
function s.drawtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2)
    and Duel.IsExistingMatchingCard(s.togravefilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,e:GetHandler()) end
  Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND+LOCATION_ONFIELD)
  Duel.SetTargetPlayer(tp)
  Duel.SetTargetParam(2)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- send the monster and draw the cards
function s.drawop(e,tp,eg,ep,ev,re,r,rp)
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
  local tg = Duel.SelectMatchingCard(tp,s.togravefilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil)
  local tc = tg:GetFirst()
  if tc and Duel.SendtoGrave(tc,REASON_EFFECT) ~= 0 and tc:IsLocation(LOCATION_GRAVE) then
  	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
  	Duel.Draw(p,d,REASON_EFFECT)
  end
end
