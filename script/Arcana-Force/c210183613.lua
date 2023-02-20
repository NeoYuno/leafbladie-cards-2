--Reverse Reborn
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCountLimit(1,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Destroy
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
    --Coin Effect
    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.eftg)
	e3:SetOperation(s.efop)
	c:RegisterEffect(e3)
end
s.toss_coin=true
s.listed_names={CARD_LIGHT_BARRIER}
s.listed_series={SET_ARCANA_FORCE}
--[Special Summon]
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_ARCANA_FORCE) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
function s.eqlimit(e,c)
	return e:GetLabelObject()==c
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		if Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)==0 then return end
		Duel.Equip(tp,c,tc)
		--Add Equip limit
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(s.eqlimit)
		e1:SetLabelObject(tc)
		c:RegisterEffect(e1)
		--coin
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetRange(LOCATION_SZONE)
		e2:SetCode(EVENT_ADJUST)
		e2:SetOperation(s.coinop)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
	end
end
--[Destroy]
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetFirstCardTarget()
	if c:IsReason(REASON_DESTROY) and tc and tc:IsLocation(LOCATION_MZONE) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
function s.coinop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetFirstCardTarget()
	if not tc then return end
	if Arcana.GetCoinResult(tc)==COIN_HEADS then
		Arcana.SetCoinResult(tc,COIN_TAILS)
	end
end
--[Coin Effect]
function s.eftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end
function s.efop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local sel
	if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_LIGHT_BARRIER),tp,LOCATION_FZONE,0,1,nil) then
		local op=Duel.SelectOption(tp,aux.GetCoinEffectHintString(COIN_HEADS),aux.GetCoinEffectHintString(COIN_TAILS))
		if op==0 then
			sel=COIN_HEADS
		elseif op==1 then
			sel=COIN_TAILS
		else
			return
		end
	else
		sel=Duel.TossCoin(tp,1)
	end
	if sel==COIN_HEADS then
        Duel.SendtoHand(c,nil,REASON_EFFECT)
	elseif sel==COIN_TAILS then
        Duel.Destroy(c,REASON_EFFECT)
    end
end