--Suit of Sword X
local s,id=GetID()
function s.initial_effect(c)
	--Coin Effect
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
    --Draw
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.drcon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
end
s.toss_coin=true
s.listed_names={CARD_LIGHT_BARRIER}
s.listed_series={SET_ARCANA_FORCE}
--[Coin Effect]
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,0,1,nil) or
		Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_MZONE)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local sel
	if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_LIGHT_BARRIER),tp,LOCATION_FZONE,0,1,nil) then
		local self=Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_MZONE,1,nil)
		local oppo=Duel.IsExistingMatchingCard(nil,tp,LOCATION_MZONE,0,1,nil)
		local op=Duel.SelectEffect(tp,{self,aux.GetCoinEffectHintString(COIN_HEADS)},{oppo,aux.GetCoinEffectHintString(COIN_TAILS)})
		if op==1 then
			sel=COIN_HEADS
		elseif op==2 then
			sel=COIN_TAILS
		else
			return
		end
	else
		sel=Duel.TossCoin(tp,1)
	end
	if sel==COIN_HEADS then
		local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_MZONE,nil)
		if #g>0 then
			Duel.Destroy(g,REASON_EFFECT)
		end
	elseif sel==COIN_TAILS then
		local g2=Duel.GetMatchingGroup(nil,tp,LOCATION_MZONE,0,nil)
		if #g2>0 then
			Duel.Destroy(g2,REASON_EFFECT)
        end
	end
end
--[Draw]
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_ARCANA_FORCE),tp,LOCATION_MZONE,0,1,nil)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
    Duel.BreakEffect()
    Duel.Recover(tp,1000,REASON_EFFECT)
end