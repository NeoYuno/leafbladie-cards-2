--Eilift Gullmani
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
    e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={0xf8a}

function s.xyzfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xf8a) and c:IsType(TYPE_XYZ)
end
function s.mfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xf8a)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_MZONE,0,1,nil) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_MZONE,0,nil)
	if #g==0 then return end
	local ct=#g
	for tc in g:Iter() do
		--ATK/DEF boost
		local atk=Effect.CreateEffect(e:GetHandler())
		atk:SetType(EFFECT_TYPE_SINGLE)
		atk:SetCode(EFFECT_UPDATE_ATTACK)
		atk:SetValue(ct*400)
		atk:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(atk)
		local def=atk:Clone()
		def:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(def)
		--Extra +1000 if Special Summoned this turn
		if tc:IsStatus(STATUS_SPSUMMON_TURN) then
			local atk2=atk:Clone()
			atk2:SetValue(1000)
			tc:RegisterEffect(atk2)
			local def2=def:Clone()
			def2:SetValue(1000)
			tc:RegisterEffect(def2)
		end
	end
	--Indestructible (battle/effect)
	local ind=Effect.CreateEffect(e:GetHandler())
	ind:SetType(EFFECT_TYPE_FIELD)
	ind:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	ind:SetTargetRange(LOCATION_MZONE,0)
	ind:SetTarget(s.mytg)
	ind:SetValue(1)
	ind:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(ind,tp)
	local ind2=ind:Clone()
	ind2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	Duel.RegisterEffect(ind2,tp)
end

function s.mytg(e,c)
	return c:IsSetCard(0xf8a)
end
