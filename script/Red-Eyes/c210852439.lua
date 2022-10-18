--Red-Eyes Shield & Sword
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_series={0x3b}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()~=PHASE_DAMAGE or not Duel.IsDamageCalculated()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	e:SetLabel(1)
end
function s.adfilter(c)
    return c:IsFaceup() and not c:IsSetCard(0x3b)
end
function s.eqfilter(c,e)
    return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsSetCard(0x3b) and c:IsCanBeEffectTarget(e)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		if e:GetLabel()==0 then
			return false
		elseif e:GetLabel()==1 then
			return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() and s.eqfilter(chkc,e)
		else return false end
	end
	local b1=Duel.IsExistingMatchingCard(s.adfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
	local b2=Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_MZONE,0,1,nil,e)
	if chk==0 then return b1 or b2 end
	local opt=0
	if b1 and b2 then
		opt=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))
	elseif b1 then
		opt=Duel.SelectOption(tp,aux.Stringid(id,0))
	else
		opt=Duel.SelectOption(tp,aux.Stringid(id,1))+1
	end
	Duel.SetTargetParam(opt)
	if opt==1 or opt==2 then
		if e:GetLabel()==1 then
			aux.RemainFieldCost(e,tp,eg,ep,ev,re,r,rp,1)
		end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		local g=Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_MZONE,0,1,1,nil,e)
		e:SetLabelObject(g:GetFirst())
		Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
	end
	e:SetLabel(0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local opt=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	if opt==0 or opt==2 then
		local g=Duel.GetMatchingGroup(s.adfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
        local tc=g:GetFirst()
        for tc in aux.Next(g) do
            local atk=tc:GetAttack()
            local def=tc:GetDefense()
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_SET_ATTACK_FINAL)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            e1:SetValue(def)
            tc:RegisterEffect(e1)
            local e2=Effect.CreateEffect(c)
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
            e2:SetReset(RESET_EVENT+RESETS_STANDARD)
            e2:SetValue(atk)
            tc:RegisterEffect(e2)
        end
	end
	if opt==1 or opt==2 then
		local tc=e:GetLabelObject()
		if not c:IsLocation(LOCATION_SZONE) or not c:IsRelateToEffect(e) or c:IsStatus(STATUS_LEAVE_CONFIRMED) then return end
		if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
			Duel.Equip(tp,c,tc)
			--ATK Change
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_EQUIP)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetValue(tc:GetBaseAttack()+tc:GetBaseDefense())
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			c:RegisterEffect(e1)
            local e2=e1:Clone()
            e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
            c:RegisterEffect(e2)
			--Equip limit
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_EQUIP_LIMIT)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetValue(s.eqlimit)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			c:RegisterEffect(e3)
		else
			c:CancelToGrave(false)
		end
	end
end
function s.eqlimit(e,c)
	return c:GetControler()==e:GetOwnerPlayer()
end
