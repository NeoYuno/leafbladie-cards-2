--Exodia the Protector
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
	--Xyz materials
	Xyz.AddProcedure(c, nil, 1, 2, s.ovfilter, aux.Stringid(id, 0), 3, s.xyzop)
    --Cannot be target
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
    --Cannot remove
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0, 1)
	c:RegisterEffect(e2)
	--Imperial Iron Wall check
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(30459350)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(0,1)
	c:RegisterEffect(e3)
	--Return
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.retcon)
	e4:SetCost(s.retcost)
	e4:SetTarget(s.rettg)
	e4:SetOperation(s.retop)
	c:RegisterEffect(e4, false, REGISTER_FLAG_DETACH_XMAT)
end
--Xyz materials
s.listed_series={0xde, 0x40}
function s.cfilter(c)
	return c:IsSetCard(0xde) or c:IsSetCard(0x40) and c:IsDiscardable()
end
function s.ovfilter(c, tp, lc)
	return c:IsFaceup() and c:IsSetCard(0x40, lc, SUMMON_TYPE_XYZ, tp)
end
function s.xyzop(e, tp, chk, mc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter, tp, LOCATION_HAND, 0, 1, nil) end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DISCARD)
	local tc=Duel.GetMatchingGroup(s.cfilter, tp, LOCATION_HAND, 0, nil):SelectUnselect(Group.CreateGroup(), tp, false, Xyz.ProcCancellable)
	if tc then
		Duel.SendtoGrave(tc, REASON_DISCARD+REASON_COST)
		return true
	else return false end
end
--
function s.retcon(e, tp, eg, ep, ev, re, r, rp)
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsSetCard, 1, nil, 0x40)
end
function s.retcost(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp, 1, REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp, 1, 1, REASON_COST)
end
function s.rettg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return Duel.IsExistingMatchingCard(nil, 0, LOCATION_REMOVED, LOCATION_REMOVED, 1, nil) end
	local g=Duel.GetMatchingGroup(nil, 0, LOCATION_REMOVED, LOCATION_REMOVED, nil)
	Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, g, #g, 0, 0)
end
function s.retop(e, tp, eg, ep, ev, re, r, rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(nil, 0, LOCATION_REMOVED, LOCATION_REMOVED, nil)
	if #g>0 and Duel.SendtoGrave(g, REASON_EFFECT+REASON_RETURN)~=0 then
		local ct=g:GetCount()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetRange(LOCATION_MZONE)
		e1:SetValue(ct*100)
		c:RegisterEffect(e1)
	end
end