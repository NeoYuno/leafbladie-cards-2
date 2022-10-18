--Red-Eyes Metalmorph
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(aux.RemainFieldCost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
    --Equip
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_EQUIP)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_BATTLE_DESTROYING)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCondition(s.eqcon)
    e2:SetTarget(s.eqtg)
    e2:SetOperation(s.eqop)
    c:RegisterEffect(e2)
end
s.listed_series={0x3b}
function s.filter(c)
	return c:IsSetCard(0x3b) and c:IsFaceup()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return s.filter(chkc) and chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsStatus(STATUS_LEAVE_CONFIRMED) then return end
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.Equip(tp,c,tc)
		--Equip limit
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(s.eqlimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
        c:CancelToGrave()
        --Atk/def
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetValue(300)
		c:RegisterEffect(e2)
        local e3=e2:Clone()
        e3:SetCode(EFFECT_UPDATE_DEFENSE)
        c:RegisterEffect(e3)
        --Indestructable by effects
        local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_EQUIP)
		e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD)
		e4:SetValue(1)
		c:RegisterEffect(e4,true)
    end
end
function s.eqlimit(e,c)
	return c:IsSetCard(0x3b)
end
--
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=eg:GetFirst()
	local bc=ec:GetBattleTarget()
	return e:GetHandler():GetEquipTarget()==eg:GetFirst() and ec:IsControler(tp)
		and bc:IsLocation(LOCATION_GRAVE) and bc:IsReason(REASON_BATTLE)
end
function s.eqfilter(c)
	return c:IsType(TYPE_MONSTER)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ec=e:GetHandler():GetEquipTarget()
	if chkc then return chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and s.eqfilter(chkc) and chkc~=ec end
	if chk==0 then return Duel.IsExistingTarget(s.eqfilter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,aux.NecroValleyFilter(s.eqfilter),tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,1,ec)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		if ec then
			Duel.Equip(tp,tc,ec)
			--Atk
			local e1=Effect.CreateEffect(tc)
			e1:SetType(EFFECT_TYPE_EQUIP)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(tc:GetBaseAttack()//2)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			--Equip limit
			local e2=Effect.CreateEffect(tc)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_EQUIP_LIMIT)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetValue(s.eqlimit2)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			e2:SetLabelObject(ec)
			tc:RegisterEffect(e2)
		else Duel.SendtoGrave(tc,REASON_RULE)
		end
	end
end
function s.eqlimit2(e,c)
	return c==e:GetLabelObject()
end