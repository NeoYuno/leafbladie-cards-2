--ガーディアン・ロッド
--Guardian Rod
--scripted by pyrQ
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
	e1:SetCost(aux.RemainFieldCost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--change name
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_CHANGE_CODE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetValue(95515060)
	c:RegisterEffect(e2)
end
s.listed_series={0x52}
s.listed_names={95515060}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()~=PHASE_DAMAGE or not Duel.IsDamageCalculated()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() and c:IsSetCard(0x52) end
	if chk==0 then return e:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsExistingTarget(aux.FilterFaceupFunction(Card.IsSetCard,0x52),tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectTarget(tp,aux.FilterFaceupFunction(Card.IsSetCard,0x52),tp,LOCATION_MZONE,0,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CARDTYPE)
	local opt1=Duel.SelectOption(tp,70,71,72)
	local opt2=0
	local typ=0
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CARDTYPE)
	if opt1==0 then
		typ=typ|(TYPE_MONSTER&0x7)
		opt2=Duel.SelectOption(tp,71,72)
	elseif opt1==1 then
		typ=typ|(TYPE_SPELL&0x7)
		opt2=Duel.SelectOption(tp,70,72)
	elseif opt1==2 then
		typ=typ|(TYPE_TRAP&0x7)
		opt2=Duel.SelectOption(tp,70,71)
	end
	if (opt1==1 or opt1==2) and opt2==0 then
		typ=typ|(TYPE_MONSTER&0x7)
	elseif (opt1==0 and opt2==0) or (opt1==2 and opt2==1) then
		typ=typ|(TYPE_SPELL&0x7)
	elseif (opt1==0 or opt1==1) and opt2==1 then
		typ=typ|(TYPE_TRAP&0x7)
	end
	e:SetLabel(typ)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsLocation(LOCATION_SZONE) or not c:IsRelateToEffect(e) or c:IsStatus(STATUS_LEAVE_CONFIRMED) then return end
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.Equip(tp,c,tc)
		local typ=e:GetLabel()
		--increase DEF
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_EQUIP)
		e1:SetCode(EFFECT_UPDATE_DEFENSE)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		--Equip limit
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_EQUIP_LIMIT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetValue(1)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
		--unaffected by X and Y
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_EQUIP)
		e3:SetCode(EFFECT_IMMUNE_EFFECT)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		e3:SetValue(s.efilter)
		e3:SetLabel(typ)
		c:RegisterEffect(e3)
		if typ&TYPE_MONSTER~=0 then
			tc:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(21377582,3))
		end
		if typ&TYPE_SPELL~=0 then
			tc:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(21377582,4))
		end
		if typ&TYPE_TRAP~=0 then
			tc:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(21377582,5))
		end
		--cannot be effect target
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_FIELD)
		e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
		e4:SetRange(LOCATION_SZONE)
		e4:SetTargetRange(LOCATION_MZONE,0)
		e4:SetTarget(s.tgtg)
		e4:SetValue(aux.tgoval)
		c:RegisterEffect(e4)
		--cannot be attack target
		local e5=e4:Clone()
		e5:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
		e5:SetTargetRange(0,LOCATION_MZONE)
		e5:SetValue(s.tgtg)
		c:RegisterEffect(e5)
	else
		c:CancelToGrave(false)
	end
end
function s.efilter(e,te)
	return te:IsActiveType(e:GetLabel()) and te:GetOwner()~=e:GetOwner() and te:GetHandlerPlayer()==1-e:GetHandlerPlayer()
end
function s.tgtg(e,c)
	return c~=e:GetHandler():GetEquipTarget()
end
function s.atlimit(e,c)
	local g=Duel.GetMatchingGroup(s.atfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)
	return c:IsFaceup() and c:IsSetCard(0x131) and not g:GetMaxGroup(Card.GetLevel):IsContains(c)
end