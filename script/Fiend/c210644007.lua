--Master of Darkness - Zorc Inferno
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    --Change dice result
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
    e1:SetCode(EVENT_CHAINING)
    e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
    e1:SetCondition(s.dicecon)
    e1:SetCost(s.dicecost)
    e1:SetTarget(s.dicetg)
    e1:SetOperation(s.diceop)
    c:RegisterEffect(e1)
    --Dice effect
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_DESTROY+CATEGORY_DICE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
s.roll_dice=true

--Change dice result
function s.dicecon(e,tp,eg,ep,ev,re,r,rp)
    local ex,eg,et,cp,ct=Duel.GetOperationInfo(ev,CATEGORY_DICE)
	if ex then
		e:SetLabelObject(re)
		return true
	else return false end
end
function s.dicecost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
function s.dicetg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetChainLimit(s.chlimit)
end
function s.chlimit(e,ep,tp)
	return tp==ep
end
function s.diceop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_TOSS_DICE_NEGATE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.dicecon2)
	e1:SetOperation(s.diceop2)
	e1:SetLabelObject(e:GetLabelObject())
	e1:SetReset(RESET_CHAIN)
	Duel.RegisterEffect(e1,tp)
end
function s.dicecon2(e,tp,eg,ep,ev,re,r,rp)
	return re==e:GetLabelObject()
end
function s.diceop2(e,tp,eg,ep,ev,re,r,rp)
	local res={Duel.GetDiceResult()}
	local ct=ev
	for i=1, ct do
		res[i]=1
	end
	Duel.SetDiceResult(table.unpack(res))
end
--Dice effect
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	if chk==0 then return #g~=0 end
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	Duel.SetChainLimit(s.chlimit)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local d=Duel.TossDice(tp,1)
	if d==1 then
		local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
		if #g==0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local sg=g:Select(tp,1,1,nil)
		Duel.HintSelection(sg)
		Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
	elseif d==6 then
		if e:GetHandler():IsRelateToEffect(e) then
            Duel.Destroy(e:GetHandler(),REASON_EFFECT)
        end
	else
		local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
		if #g==0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local sg=g:Select(tp,1,1,nil)
		Duel.HintSelection(sg)
		Duel.Destroy(sg,REASON_EFFECT)
	end
end
