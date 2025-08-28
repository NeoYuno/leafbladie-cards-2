--Pressure Of The Mythisch
local s,id=GetID()
function s.initial_effect(c)
	--Activate: indestructible by battle this turn
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(s.actop)
	c:RegisterEffect(e1)
	--ATK/DEF decrease (continuous)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetValue(s.val)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	--Mythisch Xyz summoned: its effects cannot be negated
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,{id,0})
	e4:SetCondition(s.efcon)
	e4:SetOperation(s.efop)
	c:RegisterEffect(e4)
	--If destroyed → attach to Mythisch Xyz
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCountLimit(1,{id,1})
	e5:SetCondition(s.xyzcon)
	e5:SetTarget(s.xyztg)
	e5:SetOperation(s.xyzop)
	c:RegisterEffect(e5)
	--If detached → Set itself
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_TO_GRAVE)
	e6:SetProperty(EFFECT_FLAG_DELAY)
	e6:SetCountLimit(1,{id,2})
    e6:SetCondition(s.setcon)
	e6:SetTarget(s.settg)
	e6:SetOperation(s.setop)
	c:RegisterEffect(e6)
end
s.listed_series={0xf8a}
--(1) Activation protection
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(function(e,c) return c:IsSetCard(0xf8a) end)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end

--(2) ATK/DEF decrease
function s.ctfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xf8a)
end
function s.val(e,c)
	return -100*Duel.GetMatchingGroupCount(s.ctfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,nil)
end

--(3) Prevent negation on newly summoned Mythisch Xyz
function s.efcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(function(c,tp) return c:IsSummonPlayer(tp) and c:IsSetCard(0xf8a) and c:IsType(TYPE_XYZ) end,1,nil,tp)
end
function s.efop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(function(c,tp) return c:IsSummonPlayer(tp) and c:IsSetCard(0xf8a) and c:IsType(TYPE_XYZ) end,nil,tp)
	for tc in g:Iter() do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end

--(4) Attach if destroyed
function s.xyzcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_SZONE)
end
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(function(c) return c:IsFaceup() and c:IsSetCard(0xf8a) and c:IsType(TYPE_XYZ) end,tp,LOCATION_MZONE,0,1,nil) end
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local tc=Duel.SelectMatchingCard(tp,function(c) return c:IsFaceup() and c:IsSetCard(0xf8a) and c:IsType(TYPE_XYZ) end,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	if tc then
		Duel.Overlay(tc,Group.FromCards(c))
	end
end

function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:GetPreviousLocation()&LOCATION_OVERLAY)~=0 and re:GetHandler():IsSetCard(0xf8a)
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SSet(tp,c)
	end
end
