--Gun Cannon Fusion
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Fusion.CreateSummonEff{handler=c,fusfilter=s.ffilter,extraop=s.extraop,stage2=s.stage2,matfilter=s.matfil,extrafil=s.fextra,extratg=s.extratg}
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_DESTROY)
	e1:SetCountLimit(1,id)
	c:RegisterEffect(e1)
	--Add itself from the GY
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_COIN+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.toss_coin=true
s.listed_names={3113667}
function s.ffilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_MACHINE)
end
function s.matfil(c,e,tp,chk)
	return c:IsDestructable(e) and not c:IsImmuneToEffect(e)
end
function s.fcheck(tp,sg,fc)
    local g=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=#g
end
function s.fextra(e,tp,mg)
    local g=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
	if #g>0 then
		local sg=Duel.GetMatchingGroup(s.exfilter,tp,LOCATION_DECK,0,nil)
		if #sg>0 then
			return sg,s.fcheck
		end
	end
	return nil
end
function s.exfilter(c)
	return c.toss_coin
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_HAND+LOCATION_ONFIELD)
end
function s.extraop(e,tc,tp,sg)
	local res=Duel.Destroy(sg,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)==#sg
	sg:Clear()
	return res
end
function s.stage2(e,tc,tp,sg,chk)
    local c=e:GetHandler()
	if chk==1 then
		--Cannot be negated
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3308)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_CANNOT_DISEFFECT)
		e2:SetRange(LOCATION_MZONE)
		e2:SetValue(s.efilter)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
        --Cannot special summon
        local e3=Effect.CreateEffect(c)
        e3:SetDescription(aux.Stringid(id,0))
        e3:SetType(EFFECT_TYPE_FIELD)
        e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
        e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
        e3:SetTargetRange(1,0)
        e3:SetTarget(s.splimit)
        e3:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e3,tp)
	end
end
function s.efilter(e,ct)
	local te=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT)
	return te:GetHandler()==e:GetHandler()
end
function s.splimit(e,c)
	return not (c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_DARK))
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	Duel.PayLPCost(tp,1000)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,2)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local c1,c2=Duel.TossCoin(tp,2)
	local ct=c1+c2
	if c:IsRelateToEffect(e) and c:IsAbleToHand() then
		if c1+c2<2 and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,3113667),tp,LOCATION_FZONE,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			local ct=0
			local res={Duel.GetCoinResult()}
			for i=1,ev do
				if res[i]==1 then
					ct=ct+1
				end
			end
			Duel.Damage(1-tp,1000,REASON_EFFECT)
			Duel.BreakEffect()
			Duel.SendtoHand(c,nil,REASON_EFFECT)
		else
			Duel.Damage(1-tp,ct*500,REASON_EFFECT)
			if ct==2 then
				Duel.BreakEffect()
				Duel.SendtoHand(c,nil,REASON_EFFECT)
			end
		end
	end
end