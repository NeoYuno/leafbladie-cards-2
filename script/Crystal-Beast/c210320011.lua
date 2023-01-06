--Crystal Amber Stomp
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
    --Apply effect
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(TIMING_MAIN_END)
	e2:SetCondition(s.macon)
	e2:SetCost(aux.bfgcost)
	e2:SetOperation(s.maop)
	c:RegisterEffect(e2)
end
s.listed_series={0x1034}
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x1034)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.ftarget)
	e1:SetLabel(g:GetFirst():GetFieldID())
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local atk=0
		local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil)
		local bc=g:GetFirst()
		for bc in aux.Next(g) do
			local catk=bc:GetBaseAttack()
			if catk<0 then catk=0 end
			atk=atk+catk
		end
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		tc:RegisterEffect(e1)
	end
end
function s.amberfilter(c)
	return c:IsFaceup() and c:IsCode(69937550,18847598)
end
function s.ftarget(e,c)
	return e:GetLabel()~=c:GetFieldID()
end
function s.macon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==1-tp and Duel.IsExistingMatchingCard(s.amberfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.maop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    --Must attack
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_MUST_ATTACK)
    e1:SetRange(0x3ff)
    e1:SetTargetRange(0,LOCATION_MZONE)
    e1:SetReset(RESET_PHASE+PHASE_END)
    c:RegisterEffect(e1)
	--Limit attack target
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetRange(0x3ff)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetValue(s.atlimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	c:RegisterEffect(e2)
end
function s.atkval(tp)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,0,nil)
	local _,val=g:GetMaxGroup(Card.GetAttack)
	return val
end
function s.atlimit(e,c)
	return c:IsFaceup() and c:GetAttack()<s.atkval(e:GetHandlerPlayer())
end