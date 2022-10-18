--ゲーム・オブ・フェート
--Game of Fate
--scripted by pyrQ
--updated by MQM
local s,id=GetID()
function s.initial_effect(c)
	--Activate and search
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--draw/gain LP/Special Summon Tokens
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(4334811,1))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,id)
	e3:SetCost(s.choosecost)
	e3:SetTarget(s.choosetg)
	e3:SetOperation(s.chooseop)
	c:RegisterEffect(e3)
end
function s.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xf75) and c:IsAbleToHand()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if #g>0 and Duel.SelectEffectYesNo(tp,e:GetHandler()) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end
function s.cfilter(c,tp)
	return c:IsSetCard(0xf75) and c:IsAbleToDeckAsCost()
end
function s.spcheck(sg,e,tp)
    return sg:GetClassCount(Card.GetCode)==#sg
end
function s.choosecost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return aux.SelectUnselectGroup(g,e,tp,2,2,s.spcheck,0) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local tg=aux.SelectUnselectGroup(g,e,tp,2,2,s.spcheck,1,tp,HINTMSG_TODECK)
	Duel.SendtoDeck(tg,nil,2,REASON_COST)
end
function s.choosetg(e,tp,eg,ep,ev,re,r,rp,chk)
	local slifer=Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_ONFIELD,0,1,nil,10000020)
	local ra=Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_ONFIELD,0,1,nil,10000010)
	local draweff=((Duel.IsPlayerCanDraw(tp,1) and not slifer) or (Duel.IsPlayerCanDraw(tp,2) and slifer))
	local tokeneff=(not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0,TYPES_TOKEN,1100,600,4,RACE_FAIRY,ATTRIBUTE_LIGHT,POS_FACEUP))
	if chk==0 then return true end
	local op=0
	local opt=0
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)
	if draweff and tokeneff then
		op=Duel.SelectOption(tp,1108,1119,1122)
		opt=op
	elseif draweff and not tokeneff then
		op=Duel.SelectOption(tp,1108,1119)
		opt=op
	elseif tokeneff and not draweff then
		op=Duel.SelectOption(tp,1119,1122)
		if op==0 then opt=1
		elseif op==1 then opt=2 end
	else
		op=Duel.SelectOption(tp,lp)
		opt=1
	end
	e:SetLabel(opt)
	--opt 0 draw
	--opt 1 lp
	--opt 2 token
	local ct=0
	if opt==0 then
		ct=1
		if slifer then ct=2 end
		e:SetCategory(CATEGORY_DRAW)
		Duel.SetTargetPlayer(tp)
		Duel.SetTargetParam(ct)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
	elseif opt==1 then
		ct=2000
		if ra then ct=4000 end
		e:SetCategory(CATEGORY_RECOVER)
		Duel.SetTargetPlayer(tp)
		Duel.SetTargetParam(ct)
		Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,ct)
	elseif opt==2 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
		Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,0)
	end
end
function s.chooseop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local slifer=Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_ONFIELD,0,1,nil,10000020)
	local ra=Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_ONFIELD,0,1,nil,10000010)
	local opt=e:GetLabel()
	local ct=0
	if opt==0 then
		ct=1
		if slifer then ct=2 end
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		Duel.Draw(p,ct,REASON_EFFECT)
	elseif opt==1 then
		ct=2000
		if ra then ct=4000 end
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		Duel.Recover(p,ct,REASON_EFFECT)
	elseif opt==2 then
		if not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
			and Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0,TYPES_TOKEN,1100,600,4,RACE_FAIRY,ATTRIBUTE_LIGHT,POS_FACEUP) then
			for i=1,2 do
				local token=Duel.CreateToken(tp,id+1)
				if Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP) then
					local e1=Effect.CreateEffect(e:GetHandler())
					e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
					e1:SetCode(EVENT_LEAVE_FIELD)
					e1:SetOperation(s.damop)
					e1:SetLabel(tp)
					token:RegisterEffect(e1,true)
				end
			end
			Duel.SpecialSummonComplete()
		end
	end
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsReason(REASON_RELEASE) and re:GetHandler():IsCode(10000000) then
		Duel.Damage(1-e:GetLabel(),2000,REASON_EFFECT)
	end
	e:Reset()
end
