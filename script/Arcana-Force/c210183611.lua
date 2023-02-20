--Sowing the Fool
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Cannot activate effects or Special Summon from the GY
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,1)
	e2:SetCondition(s.limcon)
	local e3=e2:Clone()
	e2:SetValue(function(_,re) return re:GetActivateLocation()==LOCATION_GRAVE end)
	c:RegisterEffect(e2)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetTarget(function(_,c) return c:IsLocation(LOCATION_GRAVE) end)
	c:RegisterEffect(e3)
    --Mill
    local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TOGRAVE)
	e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,id)
	e4:SetTarget(s.tgtg)
	e4:SetOperation(s.tgop)
	c:RegisterEffect(e4)
end
s.toss_coin=true
s.listed_names={CARD_LIGHT_BARRIER}
s.listed_series={SET_ARCANA_FORCE}
--[Cannot activate effects or Special Summon from the GY]
function s.limcon(e)
	return Duel.IsExistingMatchingCard(Card.IsCode,e:GetHandlerPlayer(),LOCATION_FZONE,LOCATION_FZONE,1,nil,CARD_LIGHT_BARRIER)
end
--[Mill]
function s.filter(c)
    return c:IsSetCard(SET_ARCANA_FORCE) and c:IsFaceup() and c:HasLevel()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) 
        and (Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 or Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>0) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    local ct=tc:GetLevel()
    local sel
	if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_LIGHT_BARRIER),tp,LOCATION_FZONE,0,1,nil) then
        local self=Duel.IsPlayerCanDiscardDeck(tp,ct)
        local oppo=Duel.IsPlayerCanDiscardDeck(1-tp,ct)
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
        Duel.DiscardDeck(tp,ct,REASON_EFFECT)
    elseif sel==COIN_TAILS then
        Duel.DiscardDeck(1-tp,ct,REASON_EFFECT)
    end
end