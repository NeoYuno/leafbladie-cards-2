--Infinity Chaotic Heart
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon itself
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
    --Cannot be destroyed by battle
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
    --Special Summon limit
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(1,0)
	e3:SetTarget(s.splimit)
	c:RegisterEffect(e3)
    --Grant effect
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_BE_MATERIAL)
	e4:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e4:SetCondition(s.efcon)
	e4:SetOperation(s.efop)
	c:RegisterEffect(e4)
end
s.listed_names={id}
s.listed_series={0x0f7c}

function s.spconfilter(c)
	return not (c:IsSetCard(0x0f7c) and c:IsFaceup())
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(s.spconfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,4) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,1,tp,tp,false,false,POS_FACEUP,4)
        local e1=Effect.CreateEffect(c)
        e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
        e1:SetDescription(3001)
        e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
        e1:SetRange(LOCATION_MZONE)
        e1:SetReset(RESET_PHASE+PHASE_END)
        e1:SetValue(1)
        c:RegisterEffect(e1)
	end
end

function s.splimit(e,c,tp,sumtp,sumpos)
	return not c:IsSetCard(0x0f7c)
end

function s.efcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return r==REASON_XYZ and c:GetReasonCard():IsCode(211040040)
end
function s.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
    -- Detach 1 material; opponent's monsters lose 500 ATK/DEF
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCost(s.cost)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsHasCardTarget() or e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
    e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(function(c) return c:IsFaceup() end,tp,0,LOCATION_MZONE,nil)
    for tc in g:Iter() do
        local atk=Effect.CreateEffect(e:GetHandler())
        atk:SetType(EFFECT_TYPE_SINGLE)
        atk:SetCode(EFFECT_UPDATE_ATTACK)
        atk:SetValue(-500)
        atk:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(atk)
        local def=Effect.CreateEffect(e:GetHandler())
        def:SetType(EFFECT_TYPE_SINGLE)
        def:SetCode(EFFECT_UPDATE_DEFENSE)
        def:SetValue(-500)
        def:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(def)
    end
end
