--Red-Eyes Black Flame Swordsman
local s,id=GetID()
function s.initial_effect(c)
	--ATK up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(s.val)
	c:RegisterEffect(e1)
    --Equip
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCode(EVENT_EQUIP)
	e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetCondition(s.eqcon)
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)
    aux.AddEREquipLimit(c,nil,s.eqval,aux.EquipByEffectAndLimitRegister,e2)
    --ATK down
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_DESTROY+CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.atktg)
	e3:SetOperation(s.atkop)
	c:RegisterEffect(e3)
end
s.listed_series={0x3b}
function s.val(e,c)
	return c:GetEquipCount()*600
end
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
    return #eg==1 and eg:GetFirst():IsControler(tp)
end
function s.eqval(ec,c,tp)
	return ec:IsControler(tp) and ec:IsSetCard(0x3b) 
end
function s.eqfilter(c)
	return c:IsSetCard(0x3b) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.eqfilter(chkc) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsFaceup() and c:IsRelateToEffect(e) and tc and tc:IsRelateToEffect(e) then
		aux.EquipByEffectAndLimitRegister(c,e,tp,tc)
	end
end
function s.desfilter(c,ec)
	return c:GetEquipTarget()==ec and c:IsDestructable()
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler())
        and Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,e:GetHandler())
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil,e:GetHandler())
    if #g<=0 or not Duel.Destroy(g,REASON_EFFECT) then return end
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(600)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end