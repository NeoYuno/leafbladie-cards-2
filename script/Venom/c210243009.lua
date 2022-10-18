--Venom Bog
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
    --Cannot activate
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
    e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(1,1)
    e2:SetCondition(s.condition)
	e2:SetValue(s.aclimit)
	c:RegisterEffect(e2)
    --Destroy and set
	local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_SZONE)
    e3:SetCountLimit(1)
    e3:SetTarget(s.destg)
    e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
s.listed_names={54306223}
s.counter_list={COUNTER_VENOM}
function s.filter(c,tp)
    local tp=c:GetControler()
	return c:IsCode(54306223) and c:GetActivateEffect() and c:GetActivateEffect():IsActivatable(tp,true,true)
end
function s.thfilter(c)
	return c:IsSetCard(0x50) and c:IsMonster() and c:IsAbleToHand()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g1=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
	local g2=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	local b1=#g1>0
	local b2=#g2>0 and Duel.IsEnvironment(54306223)
	if (b1 or b2) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		local op=aux.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)})
		if op==1 then 
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
			local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
			local sg=g:Select(tp,1,1,nil):GetFirst()
			aux.PlayFieldSpell(sg,e,tp,eg,ep,ev,re,r,rp)
		else
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
			local sg=g:Select(tp,1,1,nil):GetFirst()
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,sg)
		end
    end
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    local tp=e:GetHandlerPlayer()
    return Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsCode,54306223),tp,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
function s.aclimit(e,re,tp)
	local tc=re:GetHandler()
	return tc:IsFaceup() and tc:IsLocation(LOCATION_MZONE) and tc:GetCounter(COUNTER_VENOM)>0 and re:IsActiveType(TYPE_MONSTER) and not tc:IsRace(RACE_REPTILE)
end
function s.desfilter(c,tp)
	if not (c:IsFaceup() and c:IsDestructable() and (c:IsControler(tp) or (c:IsControler(1-tp) and c:GetCounter(COUNTER_VENOM)>0))) then return false end
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if ft==0 and c:IsLocation(LOCATION_SZONE) and c:GetSequence()<5 then
		return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil,true)
	else
		return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil,false)
	end
end
function s.setfilter(c,ignore)
	return c:IsCode(16067089,93217231,80678380,210243010) and c:IsType(TYPE_TRAP) and c:IsSSetable(ignore)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.desfilter(chkc,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil,false)
		if #g>0 then
			Duel.SSet(tp,g:GetFirst())
            local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
			e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			g:GetFirst():RegisterEffect(e1)
		end
	end
end