--Red-Eyes Claw Shield
local s,id=GetID()
function s.initial_effect(c)
	--Equip and take control
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP+CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
    --Replace target
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_BE_BATTLE_TARGET)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
    e2:SetCondition(s.cbcon)
	e2:SetTarget(s.cbtg)
	e2:SetOperation(s.cbop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(s.cecon)
	e3:SetTarget(s.cetg)
	e3:SetOperation(s.ceop)
	c:RegisterEffect(e3)
end
s.listed_series={0x3b}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsBattlePhase()
end
function s.eqfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x3b) and c:IsType(TYPE_MONSTER)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_MZONE,0,1,nil) 
		and Duel.IsExistingTarget(aux.FaceupFilter(Card.IsControlerCanBeChanged,nil),tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g1=Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g2=Duel.SelectTarget(tp,aux.FaceupFilter(Card.IsControlerCanBeChanged,nil),tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g1,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_CONTROL,g2,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	local ex1,tg1=Duel.GetOperationInfo(0,CATEGORY_EQUIP)
	local ex2,tg2=Duel.GetOperationInfo(0,CATEGORY_CONTROL)
	if tg1:GetFirst() and tg1:GetFirst():IsRelateToEffect(e) then
        Duel.Equip(tp,c,tg1:GetFirst())
		--Equip limit
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(s.eqlimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
        c:CancelToGrave()
    end
    local tct=1
	if Duel.GetTurnPlayer()~=tp then tct=2
	elseif Duel.GetCurrentPhase()==PHASE_END then tct=3 end
    if tg2:GetFirst() and tg2:GetFirst():IsRelateToEffect(e) then
        Duel.GetControl(tg2:GetFirst(),tp,PHASE_END,tct)
    end
end
function s.eqlimit(e,c)
	return c:GetControler()==e:GetHandlerPlayer()
end
--
function s.cbcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetFlagEffect(tp,id)==0
end
function s.cbfilter(c,e)
	return c:IsCanBeEffectTarget(e)
end
function s.cbtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.cbfilter(chkc,e) end
	local ag=Duel.GetAttacker():GetAttackableTarget()
	local at=Duel.GetAttackTarget()
	ag:RemoveCard(at)
	if chk==0 then return Duel.GetAttacker():IsControler(1-tp) and at:IsControler(tp) and ag:IsExists(s.cbfilter,1,e:GetHandler(),e) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=ag:FilterSelect(tp,s.cbfilter,1,1,e:GetHandler(),e)
	Duel.SetTargetCard(g)
    Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end
function s.cbop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and not Duel.GetAttacker():IsImmuneToEffect(e) then
		Duel.ChangeAttackTarget(tc)
	end
end
function s.cecon(e,tp,eg,ep,ev,re,r,rp)
	if e==re or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or #g~=1 then return false end
	local tc=g:GetFirst()
	e:SetLabelObject(tc)
	return tc:IsLocation(LOCATION_MZONE) and Duel.GetFlagEffect(tp,id)==0
end
function s.cefilter(c,ct,oc)
	return oc~=c and Duel.CheckChainTarget(ct,c)
end
function s.cetg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.cefilter(chkc,ev,e:GetHandler()) end
	if chk==0 then return Duel.IsExistingTarget(s.cefilter,tp,LOCATION_MZONE,0,1,e:GetLabelObject(),ev,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.cefilter,tp,LOCATION_MZONE,0,1,1,e:GetLabelObject(),ev,e:GetHandler())
    Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end
function s.ceop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.ChangeTargetCard(ev,Group.FromCards(tc))
	end
end