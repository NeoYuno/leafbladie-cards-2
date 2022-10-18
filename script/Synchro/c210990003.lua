--Galaxy-Eyes Photon Ener-Dragon
local s,id=GetID()
function s.initial_effect(c)
	--synchro summon
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)
	c:EnableReviveLimit()
    --Banish
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCondition(s.rmcon)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
    --Increase ATK
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
    --Special summon
	local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.spcon)
    e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
s.listed_names={93717133}
s.listed_series={0x107b,0x55}
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function s.filter(c)
    return c:IsType(TYPE_XYZ) and c:GetOverlayCount()>0
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local mcount=0
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_MZONE,LOCATION_MZONE,c)
    if g:IsExists(s.filter,1,nil) then
        for oc in aux.Next(g) do
            mcount=oc:GetOverlayCount()
        end
    end
	if #g>0 and Duel.Remove(g,POS_FACEUP,REASON_EFFECT+REASON_TEMPORARY)>0 then
        local og=Duel.GetOperatedGroup()
		for tc in aux.Next(og) do
			tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE,0,2)
		end
        og:KeepAlive()
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e1:SetCode(EVENT_PHASE+PHASE_BATTLE)
        e1:SetReset(RESET_PHASE+PHASE_BATTLE)
        e1:SetLabelObject(og)
        e1:SetCountLimit(1)
        e1:SetOperation(s.retop)
        Duel.RegisterEffect(e1,tp)
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_UPDATE_ATTACK)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
        e2:SetValue(mcount*1000)
        c:RegisterEffect(e2)
    end
end
function s.retfilter(c)
	return c:GetFlagEffect(id)~=0
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local sg=g:Filter(s.retfilter,nil)
	g:DeleteGroup()
	for tc in aux.Next(sg) do
		Duel.ReturnToField(tc)
	end
end

function s.atkfilter(c)
    return c:IsMonster() and (c:IsSetCard(0x7b) or c:IsSetCard(0x55))
end
function s.atkval(e,c)
	local LOCATION_GRAVE_MZONE=LOCATION_GRAVE+LOCATION_MZONE
	return Duel.GetMatchingGroupCount(s.atkfilter,e:GetHandlerPlayer(),LOCATION_GRAVE_MZONE,LOCATION_GRAVE_MZONE,nil)*500
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp~=tp and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost() end
	if Duel.Remove(c,POS_FACEUP,REASON_COST+REASON_TEMPORARY)~=0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetLabelObject(c)
		e1:SetCountLimit(1)
		e1:SetOperation(s.retop2)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.retop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.ReturnToField(e:GetLabelObject())
end
function s.spfilter(c,e,tp)
	return c:IsCode(93717133) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
        --Unaffected by other cards' effects
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3100)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetValue(s.efilter)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		g:GetFirst():RegisterEffect(e1)
	end
end
function s.efilter(e,te)
	return te:GetOwner()~=e:GetHandler()
end