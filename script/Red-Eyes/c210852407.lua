--Red-Eyes Panther Warrior
local s,id=GetID()
function s.initial_effect(c)
	--Search
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
    --Attack cost
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_ATTACK_COST)
	e3:SetCost(s.atcost)
	e3:SetOperation(s.atop)
	c:RegisterEffect(e3)
    --Act qp/trap in hand
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_HAND,0)
	e4:SetCondition(s.handcon)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(id)
	c:RegisterEffect(e5)
	--Activate cost
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetCode(EFFECT_ACTIVATE_COST)
	e6:SetRange(LOCATION_MZONE)
	e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e6:SetTargetRange(1,0)
	e6:SetCost(s.costchk)
	e6:SetTarget(s.costtg)
	e6:SetOperation(s.costop)
	c:RegisterEffect(e6)
end
s.listed_names={id,210852436}
s.listed_series={0x3b}
function s.thfilter(c)
	return c:IsCode(210852436) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.filter(c)
    return c:IsSetCard(0x3b) and c:IsType(TYPE_MONSTER) and not c:IsCode(id)
end
function s.atcost(e,c,tp)
	return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil)
end
function s.atop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsAttackCostPaid()~=1 and e:GetHandler():IsLocation(LOCATION_MZONE) then
		local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
		local sg=aux.SelectUnselectGroup(g,e,tp,0,1,nil,1,tp,HINTMSG_TOGRAVE,function() return Duel.IsAttackCostPaid()==0 end,nil)
		if #sg==1 then
			Duel.SendtoGrave(sg,REASON_COST)
			Duel.AttackCostPaid()
		else
			Duel.AttackCostPaid(1)
		end
	end
end
function s.costfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x3b) and c:IsAbleToGrave()
end
function s.handcon(e)
    local ph=Duel.GetCurrentPhase()
	return Duel.IsExistingMatchingCard(s.costfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,e:GetHandler())
        and ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
function s.costtg(e,te,tp)
	local tc=te:GetHandler()
	return tc:IsLocation(LOCATION_HAND) and tc:GetEffectCount(id)>0
		and tc:GetEffectCount(EFFECT_TRAP_ACT_IN_HAND)<=tc:GetEffectCount(id) and tc:IsType(TYPE_TRAP)
end
function s.costchk(e,te_or_c,tp)
	return Duel.IsExistingMatchingCard(s.costfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,e:GetHandler())
end
function s.costop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.GetMatchingGroup(s.costfilter,tp,LOCATION_ONFIELD,0,e:GetHandler())
    local sg=g:Select(tp,1,1,e:GetHandler())
    if #sg==1 then
        Duel.SendtoGrave(sg,REASON_EFFECT)
    end
end