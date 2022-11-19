--King's Court
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Cannot target
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetValue(1)
	e2:SetCondition(s.indcon)
	c:RegisterEffect(e2)
	--Indes
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e3)
    --Immune
    local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_IMMUNE_EFFECT)
    e4:SetRange(LOCATION_FZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetTarget(s.etarget)
	e4:SetValue(s.efilter)
    c:RegisterEffect(e4)
	--Change cost
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(id)
	e5:SetRange(LOCATION_FZONE)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetTargetRange(1,0)
	e5:SetCondition(s.condition)
	c:RegisterEffect(e5)
end
s.listed_names={210100007,210100008,210100009}
function s.filter(c)
    return c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_LIGHT)
end
function s.indcon(e)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(s.filter),0,LOCATION_MZONE,0,1,nil)
end
function s.etarget(e,c)
    local g=c:GetMaterial()
	return c:IsFaceup() and (c:IsCode(210100007,210100008,210100009) or (c:IsSummonType(SUMMON_TYPE_TRIBUTE) and g:FilterCount(s.filter,nil)==3 and g:GetClassCount(Card.GetCode)==3))
end
function s.efilter(e,re)
	if not re:IsActivated() or e:GetOwnerPlayer()==re:GetOwnerPlayer() then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return true end
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	return not g
end
function s.condition(e)
	return e:GetHandler():GetFlagEffect(id)==0
end