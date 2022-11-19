--Undyne the Underground Heroine
local COUNTER_LV=0x1950
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon itself
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Change DEF
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(s.defcon)
	e2:SetOperation(s.defop)
	c:RegisterEffect(e2)
	--Float
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetOperation(s.op)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
	local e5=e3:Clone()
	e5:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e5)
    --Counter
	local e6=Effect.CreateEffect(c)
	e6:SetCategory(CATEGORY_COUNTER)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e6:SetCode(EVENT_BE_BATTLE_TARGET)
    e6:SetCondition(s.ctcon)
	e6:SetTarget(s.cttg)
	e6:SetOperation(s.ctop)
	c:RegisterEffect(e6)
    --Destroy replace
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e7:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_NO_TURN_RESET)
    e7:SetCode(EFFECT_DESTROY_REPLACE)
	e7:SetRange(LOCATION_MZONE)
	e7:SetTarget(s.reptg)
	c:RegisterEffect(e7)
end
s.counter_place_list={COUNTER_LV}
s.listed_names={210144001,210144023}
s.listed_series={0x0f4a,0x0f4e}
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local at=Duel.GetAttackTarget()
    e:SetLabelObject(at)
	return at:IsFaceup() and at:IsControler(tp) and at:IsSetCard(0x0f4a) and not at:IsSetCard(0x0f4e)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
    if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,210144001),tp,LOCATION_MZONE,0,1,nil) then
        Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetLabelObject(),1,tp,LOCATION_HAND)
    else
        Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetLabelObject(),1,tp,LOCATION_DECK)
    end
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    local at=e:GetLabelObject()
	if not c:IsRelateToEffect(e) then return end
	if Duel.SpecialSummon(c,1,tp,tp,false,false,POS_FACEUP_DEFENSE)>0 then
        if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,210144001),tp,LOCATION_MZONE,0,1,nil) then
            Duel.SendtoHand(at,nil,REASON_EFFECT)
        else
            Duel.SendtoDeck(at,nil,2,REASON_EFFECT)
        end
    end
end

function s.defcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL+1)
end
function s.defop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_COPY_INHERIT)
	e1:SetCode(EFFECT_SET_DEFENSE)
	e1:SetValue(0)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
end

function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	e1:SetReset(RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_DEFENSE) and c:IsReason(REASON_BATTLE)
end
function s.filter(c,e,tp)
	return c:IsCode(210144023) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end

function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetAttacker():IsCode(210144001)
end
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local at=Duel.GetAttacker()
	if chk==0 then return at and at:IsFaceup() and at:IsRelateToBattle() end
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local at=Duel.GetAttacker()
	if at:GetCounter(COUNTER_LV)==19 or not (at:IsFaceup() and at:IsLocation(LOCATION_MZONE)) then return end
	if at:IsCanAddCounter(COUNTER_LV,7) then
		Duel.Hint(HINT_CARD,tp,id)
		at:AddCounter(COUNTER_LV,7)
	elseif at:IsCanAddCounter(COUNTER_LV,6) then
		Duel.Hint(HINT_CARD,tp,id)
		at:AddCounter(COUNTER_LV,6)
	elseif at:IsCanAddCounter(COUNTER_LV,5) then
		Duel.Hint(HINT_CARD,tp,id)
		at:AddCounter(COUNTER_LV,5)
	elseif at:IsCanAddCounter(COUNTER_LV,4) then
		Duel.Hint(HINT_CARD,tp,id)
		at:AddCounter(COUNTER_LV,4)
	elseif at:IsCanAddCounter(COUNTER_LV,3) then
		Duel.Hint(HINT_CARD,tp,id)
		at:AddCounter(COUNTER_LV,3)
	elseif at:IsCanAddCounter(COUNTER_LV,2) then
		Duel.Hint(HINT_CARD,tp,id)
		at:AddCounter(COUNTER_LV,2)
	elseif at:IsCanAddCounter(COUNTER_LV,1) then
		Duel.Hint(HINT_CARD,tp,id)
		at:AddCounter(COUNTER_LV,1)
    end
end

function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsReason(REASON_REPLACE) and (c:IsReason(REASON_EFFECT) or c:IsReason(REASON_BATTLE))
		and c:GetDefense()>=500 end
	if Duel.SelectEffectYesNo(tp,c,96) then
        local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_DEFENSE)
		e1:SetValue(-500)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
		return true
	else return false end
end