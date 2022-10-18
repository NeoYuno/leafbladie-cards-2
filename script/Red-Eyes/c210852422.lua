--Gilti-Gearfried the Red-Eyes Iron Knight
local Gearfried={210852422,22091647,4722253,69488544,57046845,210852415,423705,85651167,49161188}
local Giltia={77406972,210852412,51828629}
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,s.ffilter,aux.FilterBoolFunctionEx(Card.IsRace,RACE_WARRIOR))
    --Double attack
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.tncon)
	e1:SetOperation(s.tnop)
	c:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(s.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
    --Disable spsummon
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_SPSUMMON)
	e3:SetCondition(s.dscon)
	e3:SetCost(s.dscost)
	e3:SetTarget(s.dstg)
	e3:SetOperation(s.dsop)
	c:RegisterEffect(e3)
    --ATK Boost
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e4:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e4:SetCondition(s.atkcon)
	e4:SetOperation(s.atkop)
	c:RegisterEffect(e4)
end
s.material_setcode={0x3b}
function s.ffilter(c,fc,sumtype,tp)
	return c:IsSetCard(0x3b,fc,sumtype,tp) and c:IsRace(RACE_WARRIOR,fc,sumtype,tp)
end
function s.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsCode,1,nil,table.unpack(Gearfried)) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
function s.tncon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) and e:GetLabel()==1
end
function s.tnop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(3201)
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EXTRA_ATTACK)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
end
function s.dscon(e,tp,eg,ep,ev,re,r,rp)
	return tp~=ep and Duel.GetCurrentChain()==0 
        and e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) and e:GetHandler():GetMaterial():IsExists(Card.IsCode,1,nil,table.unpack(Giltia))
end
function s.dscost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost() end
	if Duel.Remove(c,POS_FACEUP,REASON_COST+REASON_TEMPORARY)~=0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetLabelObject(c)
		e1:SetCountLimit(1)
		e1:SetOperation(s.retop)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.dstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,#eg,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,#eg,0,0)
end
function s.dsop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateSummon(eg)
	Duel.Destroy(eg,REASON_EFFECT)
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ReturnToField(e:GetLabelObject())
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and bc and bc:IsFaceup() and bc:IsRelateToBattle()
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local value=c:GetDefense()
	if value<0 then value=0 end
	if c:IsRelateToEffect(e) and c:IsFaceup() and value>0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(value/2)
		c:RegisterEffect(e1)
	end
end