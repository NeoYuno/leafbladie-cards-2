--Slot 777 Dragon
local s,id=GetID()
function s.initial_effect(c)
	Fusion.AddProcMix(c,true,true,s.matfilter1,s.matfilter2)
	c:EnableReviveLimit()
	--Destroy
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.descon)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
    --Coin
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_COIN+CATEGORY_DESTROY+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetHintTiming(TIMING_BATTLE_PHASE,TIMINGS_CHECK_MONSTER)
	e2:SetCondition(s.coincon)
	e2:SetOperation(s.coinop)
	c:RegisterEffect(e2)
end
s.toss_coin=true
s.listed_series={0x0f7a}

function s.matfilter1(c,fc,sumtype,tp)
	return c:IsSetCard(0x0f7a,fc,sumtype,tp)
end
function s.matfilter2(c,fc,sumtype,tp)
	return c:IsAttribute(ATTRIBUTE_DARK,fc,sumtype,tp)
		and c:IsRace(RACE_MACHINE,fc,sumtype,tp)
		and (c:IsLevel(6) or c:IsLevel(7))
end

function s.desfilter(c)
	return c:IsSetCard(0x0f7a) and c:IsSpellTrap() or c:IsCode(67048711)
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.desfilter,1,nil)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,0,LOCATION_ONFIELD)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
        Duel.HintSelection(g)
        Duel.Destroy(g,REASON_EFFECT)
    end
end

function s.coincon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsBattlePhase()
end
function s.coinop(e,tp,eg,ep,ev,re,r,rp)
	local heads=0
	for i=1,3 do
		if Duel.TossCoin(tp,1)==1 then heads=heads+1 end
	end
	if heads>=2 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		local g=Duel.SelectMatchingCard(tp,Card.IsSpellTrap,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
		if #g>0 then
            Duel.BreakEffect()
            Duel.HintSelection(g)
            Duel.Destroy(g,REASON_EFFECT)
        end
	end
	if heads==3 then
		local opt=0
		if Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			opt=Duel.SelectOption(tp,
				aux.Stringid(id,2),
				aux.Stringid(id,3),
				aux.Stringid(id,4)
			)
		end
		if opt==0 then
			if Duel.Destroy(e:GetHandler(),REASON_EFFECT)~=0 then
				local g=Duel.GetMatchingGroup(Card.IsMonster,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
				Duel.Destroy(g,REASON_EFFECT)
			end
		elseif opt==1 then
			if Duel.Destroy(e:GetHandler(),REASON_EFFECT)~=0 then
				local g=Duel.GetMatchingGroup(Card.IsSpellTrap,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
				Duel.Destroy(g,REASON_EFFECT)
			end
		elseif opt==2 then
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end