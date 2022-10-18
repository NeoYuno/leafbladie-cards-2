--Giltia the Red-Eyes Magical Knight
local s,id=GetID()
function s.initial_effect(c)
	--Normal summon with no tribute
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--Banish itself temporarily
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(s.rmcon)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
    --Banish itself and an opponent's monster
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_REMOVE)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetCode(EVENT_SUMMON_SUCCESS)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
    e3:SetTarget(s.target)
    e3:SetOperation(s.operation)
    c:RegisterEffect(e3)
    local e4=e3:Clone()
    e4:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e4)
end
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_NORMAL+1
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetHandler(),1,0,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		if Duel.Remove(c,0,REASON_EFFECT+REASON_TEMPORARY)==0 then return end
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetLabelObject(c)
		e1:SetOperation(s.retop)
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ReturnToField(e:GetLabelObject())
end
function s.filter(c,e,tp)
	return c:IsSummonPlayer(1-tp) and c:IsLocation(LOCATION_MZONE) and c:IsLevelAbove(5) and c:IsCanBeEffectTarget(e)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return eg and eg:IsExists(s.filter,1,nil,e,tp) and e:GetHandler():IsAbleToRemove() end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=eg:FilterSelect(tp,s.filter,1,1,nil,e,tp)
	Duel.SetTargetCard(g)
    g:AddCard(e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,2,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or not tc:IsRelateToEffect(e) then return end
	local g=Group.FromCards(c,tc)
	if Duel.Remove(g,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		local og=Duel.GetOperatedGroup()
		local oc=og:GetFirst()
		for oc in aux.Next(og) do
			if oc:IsControler(tp) then
				oc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,1)
			else
				oc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_OPPO_TURN,0,1)
			end
		end
		og:KeepAlive()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN)
		e1:SetCountLimit(1)
		e1:SetLabelObject(og)
		e1:SetCondition(s.retcon2)
		e1:SetOperation(s.retop2)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.retfilter(c)
	return c:GetFlagEffect(id)~=0
end
function s.retcon2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end
function s.retop2(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local sg=g:Filter(s.retfilter,nil)
	if #sg>1 and sg:GetClassCount(Card.GetPreviousControler)==1 then
		local ft=Duel.GetLocationCount(sg:GetFirst():GetPreviousControler(),LOCATION_MZONE)
		if ft==1 then
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
			local tc=sg:Select(tp,1,1,nil):GetFirst()
			Duel.ReturnToField(tc)
			sg:RemoveCard(tc)
		end
	end
	local tc=sg:GetFirst()
	for tc in aux.Next(sg) do
		Duel.ReturnToField(tc)
	end
end
