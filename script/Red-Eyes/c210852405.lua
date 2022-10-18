--Red-Eyes Rocket Warrior
local s,id=GetID()
function s.initial_effect(c)
	--Equip
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)
    --ATK boost
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(500)
    e2:SetCondition(s.con)
	c:RegisterEffect(e2)
    --Indestrcutable
    local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
    --Reduce atk
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_BATTLED)
    e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(s.racon)
	e4:SetOperation(s.raop)
	c:RegisterEffect(e4)
    --Special Summon
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetCountLimit(1,id)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCondition(s.spcon)
	e5:SetTarget(s.sptg)
	e5:SetOperation(s.spop)
	c:RegisterEffect(e5)
	--clock lizard
	local e6=aux.createContinuousLizardCheck(c,LOCATION_SZONE,nil,0,0xff)
	e6:SetCondition(s.effcon)
	c:RegisterEffect(e6)
end
s.listed_series={0x3b}
function s.eqfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x3b)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.eqfilter(chkc) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local tc=Duel.GetFirstTarget()
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsFacedown() or not tc:IsRelateToEffect(e) then
		Duel.SendtoGrave(c,REASON_RULE)
		return
	end
	Duel.Equip(tp,c,tc,true)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(s.eqlimit)
	c:RegisterEffect(e1)
end
function s.eqlimit(e,c)
	return c:IsSetCard(0x3b)
end
function s.con(e)
	local ph=Duel.GetCurrentPhase()
	local tp=Duel.GetTurnPlayer()
	return tp==e:GetHandler():GetControler() and ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
function s.racon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local ec=c:GetEquipTarget()
	return ec==Duel.GetAttacker() and Duel.GetAttackTarget()
end
function s.raop(e,tp,eg,ep,ev,re,r,rp)
	local d=Duel.GetAttackTarget()
	if not d:IsRelateToBattle() or d:IsFacedown() then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetValue(0)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	d:RegisterEffect(e1)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetEquipTarget()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
function s.effcon(e)
	return e:GetHandler():GetEquipTarget()
end
