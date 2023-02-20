--The Hierophant's Wand
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
    --Search
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
    --Can be activated from the hand
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e3:SetCondition(s.handcon)
	c:RegisterEffect(e3)
end
s.toss_coin=true
s.listed_names={CARD_LIGHT_BARRIER}
s.listed_series={SET_ARCANA_FORCE}
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--indestructable
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetTargetRange(LOCATION_ONFIELD,0)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetValue(s.indval)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
    local sel
	if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_LIGHT_BARRIER),tp,LOCATION_FZONE,0,1,nil) then
        Duel.BreakEffect()
		local self=Duel.IsPlayerCanDraw(tp,1)
		local oppo=Duel.IsPlayerCanDraw(1-tp,1)
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
		Duel.Draw(tp,1,REASON_EFFECT)
	elseif sel==COIN_TAILS then
		Duel.Draw(1-tp,1,REASON_EFFECT)
	end
end
function s.indval(e,re,tp)
	return e:GetOwnerPlayer()~=re:GetOwnerPlayer()
end
--[Search]
function s.thfilter(c)
	return c:IsSetCard(SET_ARCANA_FORCE) and c:IsMonster() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
--[Can be activated from the hand]
function s.cfilter(c)
	return c:IsFacedown() or not c:IsSetCard(SET_ARCANA_FORCE)
end
function s.handcon(e)
	return not Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end