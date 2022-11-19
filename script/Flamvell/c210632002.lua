--Neo Flamvell Archer
local s,id=GetID()
function s.initial_effect(c)
	--Banish
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.rmcost)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
    --ATK up
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_REMOVE)
	e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.atkcon)
    e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
function s.filter(c,tp)
	return not c:IsType(TYPE_TOKEN) and c:IsControler(1-tp)
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter,1,nil,tp)
end
function s.costfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsDiscardable()
end
function s.costfilter2(c,tp)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsMonster() and c:IsDefenseBelow(200) and c:IsAbleToGraveAsCost()
end
function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local b1=Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,e:GetHandler())
    local b2=Duel.IsExistingMatchingCard(s.costfilter2,tp,LOCATION_DECK,0,1,nil,tp) and Duel.IsPlayerAffectedByEffect(tp,210632003)
	if chk==0 then return b1 or b2 end
    if b1 and b2 then
        if Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
            s.op(e,tp,eg,ep,ev,re,r,rp)
        else
            Duel.DiscardHand(tp,s.costfilter,1,1,REASON_COST+REASON_DISCARD,e:GetHandler())
        end
    elseif b1 and not b2 then
        Duel.DiscardHand(tp,s.costfilter,1,1,REASON_COST+REASON_DISCARD,e:GetHandler())
    else
        s.op(e,tp,eg,ep,ev,re,r,rp)
    end
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
    local fg=Group.CreateGroup()
	for i,pe in ipairs({Duel.IsPlayerAffectedByEffect(tp,210632003)}) do
		fg:AddCard(pe:GetHandler())
	end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local tc=Duel.SelectMatchingCard(tp,s.costfilter2,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
    if tc then
        local fc=nil
        if #fg==1 then
            fc=fg:GetFirst()
        else
            fc=fg:Select(tp,1,1,nil)
        end
        Duel.Hint(HINT_CARD,0,fc:GetCode())
        fc:RegisterFlagEffect(210632003,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
    end
    Duel.SendtoGrave(tc,REASON_COST)
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_HAND,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_HAND)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.IsChainDisablable(0) then
		local g=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,0,LOCATION_HAND,nil)
		if #g>0 and Duel.SelectYesNo(1-tp,aux.Stringid(id,0)) then
			Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)
			local sg=g:Select(1-tp,1,1,nil)
			Duel.SendtoGrave(sg,REASON_EFFECT)
			Duel.ShuffleHand(1-tp)
			Duel.NegateEffect(0)
			return
		end
	end
	local hg=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if Duel.IsPlayerAffectedByEffect(1-tp,30459350) or #hg==0 then return end
	Duel.ConfirmCards(tp,hg)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=hg:Select(tp,1,1,nil)
	local tc=g:GetFirst()
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	Duel.ShuffleHand(1-tp)
	local c=e:GetHandler()
	local fid=c:GetFieldID()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetLabel(fid)
	e1:SetLabelObject(tc)
	e1:SetCondition(s.retcon)
	e1:SetOperation(s.retop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
end
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(id)==e:GetLabel() then
		return true
	else
		e:Reset()
		return false
	end
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	Duel.SendtoHand(tc,nil,REASON_EFFECT)
end

function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsAttribute,ATTRIBUTE_FIRE),tp,LOCATION_MZONE,0,1,nil) end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsAttribute,ATTRIBUTE_FIRE),tp,LOCATION_MZONE,0,nil)
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(800)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end