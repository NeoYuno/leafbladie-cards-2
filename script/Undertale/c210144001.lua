--Frisk the Human
local COUNTER_LV=0x1950
local s,id=GetID()
function s.initial_effect(c)
    c:EnableCounterPermit(COUNTER_LV)
	c:SetCounterLimit(COUNTER_LV,19)
	--Special summon itself from GY
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
    --Cannot be Tributed
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UNRELEASABLE_SUM)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	c:RegisterEffect(e3)
    --Special Summon limit
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(1,0)
	e4:SetTarget(s.splimit)
	c:RegisterEffect(e4)
    --Immune
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
    e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetCode(EFFECT_IMMUNE_EFFECT)
    e5:SetRange(LOCATION_MZONE)
	e5:SetValue(s.immval)
	c:RegisterEffect(e5)
    --Self attack
    local e6=Effect.CreateEffect(c)
    e6:SetType(EFFECT_TYPE_FIELD)
    e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e6:SetCode(EFFECT_SELF_ATTACK)
    e6:SetRange(LOCATION_MZONE)
    e6:SetTargetRange(1,0)
    c:RegisterEffect(e6)
    --Counter
    local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e7:SetProperty(EFFECT_FLAG_DELAY)
	e7:SetCode(EVENT_BATTLE_DESTROYING)
	e7:SetOperation(s.ctop)
	c:RegisterEffect(e7)
    --Atk up
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_SINGLE)
	e8:SetCode(EFFECT_UPDATE_ATTACK)
	e8:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e8:SetRange(LOCATION_MZONE)
	e8:SetValue(s.atkval)
	c:RegisterEffect(e8)
    --Special Summon Chara
	local e9=Effect.CreateEffect(c)
	e9:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e9:SetType(EFFECT_TYPE_IGNITION)
	e9:SetRange(LOCATION_MZONE)
	e9:SetCondition(s.spcon)
	e9:SetTarget(s.sptg)
	e9:SetOperation(s.spop)
	c:RegisterEffect(e9)
    --Change itself to defense position
	local e10=Effect.CreateEffect(c)
	e10:SetCategory(CATEGORY_POSITION)
	e10:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e10:SetCode(EVENT_PHASE+PHASE_END)
	e10:SetRange(LOCATION_MZONE)
	e10:SetCountLimit(1)
	e10:SetCondition(s.poscon)
	e10:SetOperation(s.posop)
	c:RegisterEffect(e10)
end
s.counter_place_list={COUNTER_LV}
s.listed_names={210144025}
s.listed_series={0x0f4a}
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
    end
end

function s.splimit(e,c,tp,sumtp,sumpos)
	return not (c:IsSetCard(0x0f4a) or c:IsCode(210144025))
end

function s.immval(e,te)
	return te:IsActiveType(TYPE_MONSTER) and e:GetHandlerPlayer()~=te:GetHandlerPlayer()and te:IsActivated()
end

function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetCounter(COUNTER_LV)==19 or not (c:IsFaceup() and c:IsLocation(LOCATION_MZONE)) then return end
	if c:IsCanAddCounter(COUNTER_LV,9) then
		local t={}
		for i=1,9 do t[i]=i end
		Duel.Hint(HINT_CARD,tp,id)
	    Duel.Hint(HINTMSG_NUMBER,tp,HINT_NUMBER)
		local ct=Duel.AnnounceNumber(tp,table.unpack(t))
		c:AddCounter(COUNTER_LV,ct)
	elseif c:IsCanAddCounter(COUNTER_LV,8) then
		local t={}
	    for i=1,8 do t[i]=i end
		Duel.Hint(HINT_CARD,tp,id)
	    Duel.Hint(HINTMSG_NUMBER,tp,HINT_NUMBER)
		local ct=Duel.AnnounceNumber(tp,table.unpack(t))
		c:AddCounter(COUNTER_LV,ct)
	elseif c:IsCanAddCounter(COUNTER_LV,7) then
		local t={}
	    for i=1,7 do t[i]=i end
		Duel.Hint(HINT_CARD,tp,id)
	    Duel.Hint(HINTMSG_NUMBER,tp,HINT_NUMBER)
		local ct=Duel.AnnounceNumber(tp,table.unpack(t))
		c:AddCounter(COUNTER_LV,ct)
	elseif c:IsCanAddCounter(COUNTER_LV,6) then
		local t={}
	    for i=1,6 do t[i]=i end
		Duel.Hint(HINT_CARD,tp,id)
	    Duel.Hint(HINTMSG_NUMBER,tp,HINT_NUMBER)
		local ct=Duel.AnnounceNumber(tp,table.unpack(t))
		c:AddCounter(COUNTER_LV,ct)
	elseif c:IsCanAddCounter(COUNTER_LV,5) then
		local t={}
	    for i=1,5 do t[i]=i end
		Duel.Hint(HINT_CARD,tp,id)
	    Duel.Hint(HINTMSG_NUMBER,tp,HINT_NUMBER)
		local ct=Duel.AnnounceNumber(tp,table.unpack(t))
		c:AddCounter(COUNTER_LV,ct)
	elseif c:IsCanAddCounter(COUNTER_LV,4) then
		local t={}
	    for i=1,4 do t[i]=i end
		Duel.Hint(HINT_CARD,tp,id)
	    Duel.Hint(HINTMSG_NUMBER,tp,HINT_NUMBER)
		local ct=Duel.AnnounceNumber(tp,table.unpack(t))
		c:AddCounter(COUNTER_LV,ct)
	elseif c:IsCanAddCounter(COUNTER_LV,3) then
		local t={}
	    for i=1,3 do t[i]=i end
		Duel.Hint(HINT_CARD,tp,id)
	    Duel.Hint(HINTMSG_NUMBER,tp,HINT_NUMBER)
		local ct=Duel.AnnounceNumber(tp,table.unpack(t))
		c:AddCounter(COUNTER_LV,ct)
	elseif c:IsCanAddCounter(COUNTER_LV,2) then
		local t={}
	    for i=1,2 do t[i]=i end
		Duel.Hint(HINT_CARD,tp,id)
	    Duel.Hint(HINTMSG_NUMBER,tp,HINT_NUMBER)
		local ct=Duel.AnnounceNumber(tp,table.unpack(t))
		c:AddCounter(COUNTER_LV,ct)
	elseif c:IsCanAddCounter(COUNTER_LV,1) then
		Duel.Hint(HINT_CARD,tp,id)
		c:AddCounter(COUNTER_LV,1)
	end
end

function s.atkval(e,c)
	return c:GetCounter(COUNTER_LV)*200
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetCounter(COUNTER_LV)==19
end
function s.spfilter(c,e,tp)
	return c:IsCode(210144025) and c:IsCanBeSpecialSummoned(e,0,tp,false,true)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemove()
        and Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
    end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,c,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if not Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,true,POS_FACEUP)
        g:GetFirst():CompleteProcedure()
	end
end

function s.poscon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsAttackPos() and Duel.GetTurnPlayer()==tp
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsAttackPos() then
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
end