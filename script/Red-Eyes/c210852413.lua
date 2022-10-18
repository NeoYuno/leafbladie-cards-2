--Red-Eyes Jinzo
local s,id=GetID()
function s.initial_effect(c)
	--Immune
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x3b))
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)
    --Equip
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
	e2:SetCondition(s.eqcon)
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)
	aux.AddEREquipLimit(c,s.eqcon,s.eqval,s.equipop,e2)
    --Destroy
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
	aux.DoubleSnareValidity(c,LOCATION_MZONE)
    --Special summon
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e4:SetCode(EVENT_TO_GRAVE)
    e4:SetCountLimit(1,id)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
s.listed_series={0x3b}
function s.efilter(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer() and te:IsActiveType(TYPE_TRAP)
end
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetHandler():GetEquipGroup():Filter(s.eqconfilter,nil)
	return #g==0
end
function s.eqconfilter(c)
	return c:GetFlagEffect(id)==0 
end
function s.eqval(ec,c,tp)
	return ec:IsControler(tp) and ec:IsSetCard(0x3b) and ec:IsType(TYPE_MONSTER)
end
function s.eqfilter(c)
	return c:IsSetCard(0x3b) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_GRAVE,0,1,nil,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_GRAVE)
end
function s.equipop(c,e,tp,tc)
	if not aux.EquipByEffectAndLimitRegister(c,e,tp,tc,nil,true) then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OWNER_RELATE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(500)
	tc:RegisterEffect(e1)
    --Change type
    local e2=Effect.CreateEffect(e:GetHandler())
    e2:SetCode(EFFECT_CHANGE_TYPE)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e2:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
    e2:SetValue(TYPE_TRAP)
    tc:RegisterEffect(e2)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.eqfilter),tp,LOCATION_GRAVE,0,1,1,nil,e:GetHandler())
	local tc=g:GetFirst()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		s.equipop(c,e,tp,tc)
        local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DIRECT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	else
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,TYPE_SPELL+TYPE_TRAP) end
	local dg=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,TYPE_SPELL+TYPE_TRAP)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,#dg,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,#dg*300)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local dg=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,TYPE_SPELL+TYPE_TRAP)
    Duel.ConfirmCards(tp,dg)
    local sg=dg:Filter(Card.IsType,nil,TYPE_TRAP)
	local ct=Duel.Destroy(sg,REASON_EFFECT)
	Duel.Damage(1-tp,ct*300,REASON_EFFECT)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x3b) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
        local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetOwnerPlayer(tp)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCondition(s.descon)
		e1:SetOperation(s.desop2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		e1:SetCountLimit(1)
		g:GetFirst():RegisterEffect(e1)
	end
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end
function s.desop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end