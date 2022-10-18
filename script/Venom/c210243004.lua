--Venom Burn Serpant
local s,id=GetID()
function s.initial_effect(c)
    --fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,aux.FilterBoolFunctionEx(Card.IsRace,RACE_REPTILE),2)
	--fusrace
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_CHANGE_RACE)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e0:SetTarget(s.racetg)
	e0:SetValue(s.raceval)
	e0:SetOperation(s.racecon)
	c:RegisterEffect(e0)
    --Burn
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.damcon)
    e1:SetTarget(s.damtg)
	e1:SetOperation(s.damop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(s.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	--Place counter
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_COUNTER)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
end
s.counter_list={COUNTER_VENOM}
--fusrace
function s.racetg(e,c)
	return c:GetCounter(COUNTER_VENOM)>0
end
function s.raceval(e,c,rp)
	if rp==e:GetHandlerPlayer() then
		return RACE_REPTILE
	else return c:GetRace() end
end
function s.racecon(scard,sumtype,tp)
	return (sumtype&MATERIAL_FUSION)~=0
end
function s.valcheck(e,c)
	local g=c:GetMaterial()
	local ct=0
	for tc in aux.Next(g) do
		if tc:GetCounter(COUNTER_VENOM)>0 then
			ct=tc:GetCounter(COUNTER_VENOM)*1
		end
	end
	e:GetLabelObject():SetLabel(ct)
end
--Burn
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=e:GetLabel()
	if chk==0 then return ct>0 end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*700)
    Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,e:GetHandler(),1,0,ct*700)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	local ct=e:GetLabel()
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	if ct>0 and Duel.Damage(p,ct*700,REASON_EFFECT)~=0 then
        if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(ct*700)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END,2)
        c:RegisterEffect(e1)
    end
end
--Place counter
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsCanAddCounter(COUNTER_VENOM,1) end
	if chk==0 then return Duel.IsExistingTarget(Card.IsCanAddCounter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,COUNTER_VENOM,1) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,Card.IsCanAddCounter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,COUNTER_VENOM,1)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		tc:AddCounter(COUNTER_VENOM,1)
	end
end