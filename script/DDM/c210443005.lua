--Swift Strike Ninja
local s,id=GetID()
function s.initial_effect(c)
    --Dice
	local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DICE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
    --Negate
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.discon)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
	e2:SetLabelObject(e1)
    local e3=e2:Clone()
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e3)
    local e4=e2:Clone()
    e4:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
    c:RegisterEffect(e4)
    --Remove
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_REMOVE)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
    e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,id+100)
    e5:SetCost(s.rmcost)
	e5:SetTarget(s.rmtg)
	e5:SetOperation(s.rmop)
	c:RegisterEffect(e5)
end
s.roll_dice=true
s.listed_names={210443010}
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE,nil,LOCATION_REASON_COUNT)>0 end
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	local ct=Duel.TossDice(tp,1)
    if ct==6 then ct=5 end
    local zone=Duel.SelectDisableField(tp,ct,0,LOCATION_MZONE,0)
	Duel.Hint(HINT_ZONE,tp,zone)
    e:SetLabel(zone)
	c:RegisterFlagEffect(id,RESET_PHASE+PHASE_END,0,2)
end
function s.disfilter(c,tp,zone)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and aux.IsZone(c,zone,tp)
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local zone=e:GetLabelObject():GetLabel()
	return eg:IsExists(s.disfilter,1,nil,tp,zone) and e:GetHandler():GetFlagEffect(id)>0
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local zone=e:GetLabelObject():GetLabel()
    local g=eg:Filter(s.disfilter,nil,tp,zone)
    Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,#g,1-tp,LOCATION_MZONE)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local zone=e:GetLabelObject():GetLabel()
    local g=eg:Filter(s.disfilter,nil,tp,zone)
    for tc in aux.Next(g) do
        if c:GetFlagEffect(id+1+tc:GetSequence())==0 then
            c:RegisterFlagEffect(id+1+tc:GetSequence(),RESET_PHASE+PHASE_END,0,2)
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_DISABLE)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            tc:RegisterEffect(e1,true)
            local e2=Effect.CreateEffect(c)
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetCode(EFFECT_DISABLE_EFFECT)
            e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            tc:RegisterEffect(e2,true)
        else
            return
        end
    end
end
function s.filter1(c)
    return c:IsType(TYPE_TRAP) and c:IsAbleToRemoveAsCost()
end
function s.filter2(c)
    return c.roll_dice and c:IsType(TYPE_TRAP) and c:IsAbleToGraveAsCost()
end
function s.fieldcond(c)
	return c:IsFaceup() and c:IsCode(210443010)
end
function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local fc=Duel.IsExistingMatchingCard(s.fieldcond,tp,LOCATION_FZONE,LOCATION_FZONE,1,nil)
	local gv=Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_GRAVE,0,2,nil)
	local dk=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_DECK,0,2,nil)
	if chk==0 then return gv or (fc and dk) end
	if gv and fc and dk then
		if Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
			local g=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_DECK,0,2,2,nil)
			Duel.SendtoGrave(g,REASON_COST)
		else
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
			local g=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_GRAVE,0,2,2,nil)
			Duel.Remove(g,POS_FACEUP,REASON_COST)
		end
	elseif fc and dk and not gv then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_DECK,0,2,2,nil)
		Duel.SendtoGrave(g,REASON_COST)
	elseif gv and not fc or not dk then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,Cs.filter1,tp,LOCATION_GRAVE,0,2,2,nil)
		Duel.Remove(g,POS_FACEUP,REASON_COST)
	end
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsAbleToRemove() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetLabelObject(tc)
		e1:SetCountLimit(1)
		e1:SetCondition(s.retcon)
		e1:SetOperation(s.retop)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():GetFlagEffect(id)~=0
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ReturnToField(e:GetLabelObject())
end