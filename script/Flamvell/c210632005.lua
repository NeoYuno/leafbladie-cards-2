--Flamvell Burial Grounds
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Adjust
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EVENT_ADJUST)
	e2:SetRange(LOCATION_FZONE)
    e2:SetCondition(s.adjustcon)
	e2:SetOperation(s.adjustop)
	c:RegisterEffect(e2)
    --Remove
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e3:SetTargetRange(0,0xff)
    e3:SetCondition(s.condition)
	e3:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e3)
    --Negate
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_CHAIN_SOLVING)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCondition(s.negcon)
	e4:SetOperation(s.negop)
	c:RegisterEffect(e4)
end
s.listed_series={0x2c}
function s.adjustcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,0x2c),tp,LOCATION_MZONE,0,1,nil)
end
function s.adjustop(e,tp,eg,ep,ev,re,r,rp)
	local sg=Group.CreateGroup()
    local ct=Duel.GetMatchingGroupCount(nil,tp,0,LOCATION_GRAVE,nil)
    local num=3
    if ct>num then
        local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,nil)
        Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_REMOVE)
        local dg=g:Select(1-tp,ct-num,ct-num,nil)
        sg:Merge(dg)
    end
	if #sg>0 then
		Duel.Remove(sg,POS_FACEUP,REASON_RULE)
		Duel.Readjust()
	end
end

function s.condition(e)
    local tp=e:GetHandlerPlayer()
    return Duel.GetMatchingGroupCount(nil,tp,0,LOCATION_GRAVE,nil)>2
        and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,0x2c),tp,LOCATION_MZONE,0,1,nil)
end

function s.filter(c)
    return c:IsFaceup() and c:IsSetCard(0x2c) and c:IsType(TYPE_SYNCHRO)
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainDisablable(ev)
        and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil)
		and e:GetHandler():GetFlagEffect(id)==0
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		Duel.Hint(HINT_CARD,0,id)
		Duel.NegateEffect(ev)
	end
end