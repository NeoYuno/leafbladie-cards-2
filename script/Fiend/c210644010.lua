--Darker Ruler Ha Des
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Link.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsRace, RACE_FIEND), 2)
    --Actlimit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0, 1)
	e1:SetValue(1)
	e1:SetCondition(s.actcon)
	c:RegisterEffect(e1)
    --Activate 1 of 3 effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(s.cost)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
--actlimit
function s.actfilter(c, tp)
	return c and c:IsFaceup() and c:IsRace(RACE_FIEND) and c:IsControler(tp)
end
function s.actcon(e)
	local tp=e:GetHandlerPlayer()
	return s.actfilter(Duel.GetAttacker(), tp) or s.actfilter(Duel.GetAttackTarget(), tp)
end
--Activate 1 of 3 effects
function s.cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk==0 then return Duel.CheckLPCost(tp, 1000) end
    Duel.PayLPCost(tp, 1000)
end
function s.target(e, tp, eg, ep, ev, re, r, rp, chk)
	local b1=Duel.GetFlagEffect(tp,id)==0
	local b2=Duel.GetFlagEffect(tp,id+1)==0
	local b3=Duel.GetFlagEffect(tp,id+2)==0
	if chk==0 then return b1 or b2 or b3 end
end
function s.operation(e, tp, eg, ep, ev, re, r, rp)
	local c=e:GetHandler()
	local b1=Duel.GetFlagEffect(tp,id)==0
	local b2=Duel.GetFlagEffect(tp,id+1)==0
	local b3=Duel.GetFlagEffect(tp,id+2)==0
	local dtab={}
	if b1 then
		table.insert(dtab, aux.Stringid(id, 1))
	end
	if b2 then
		table.insert(dtab, aux.Stringid(id, 2))
	end
	if b3 then
		table.insert(dtab, aux.Stringid(id, 3))
	end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_RESOLVEEFFECT)
	local op=Duel.SelectOption(tp, table.unpack(dtab))+1
	if not (b1 and b2) then op=3 end
	if not (b1 and b3) then op=2 end
	if (b1 and b3 and not b2 and op==2) then op=3 end
	if (b2 and b3 and not b1) then op=op+1 end
	if op==1 then
		--Negate the effects of other monsters on the field, except Fiend monsters
		Duel.RegisterFlagEffect(tp, id, RESET_PHASE+PHASE_END, 0, 2)
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_DISABLE)
        e1:SetRange(LOCATION_MZONE)
        e1:SetTargetRange(LOCATION_MZONE, LOCATION_MZONE)
        e1:SetTarget(aux.NOT(aux.TargetBoolFunction(Card.IsRace, RACE_FIEND)))
		e1:SetReset(RESET_PHASE+PHASE_END, 2)
        c:RegisterEffect(e1)
    elseif op==2 then
        --Monsters that are banished, as well as monsters in the GY, cannot activate their effects, except Fiend monsters
		Duel.RegisterFlagEffect(tp, id+1, RESET_PHASE+PHASE_END, 0, 2)
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_FIELD)
        e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e2:SetCode(EFFECT_CANNOT_ACTIVATE)
        e2:SetRange(LOCATION_MZONE)
        e2:SetTargetRange(1, 1)
        e2:SetTarget(aux.NOT(aux.TargetBoolFunction(Card.IsRace, RACE_FIEND)))
        e2:SetValue(s.aclimit)
		e2:SetReset(RESET_PHASE+PHASE_END, 2)
        c:RegisterEffect(e2)
	elseif op==3 then
        --Effects of monsters in the hand cannot be activated, except Fiend monsters
		Duel.RegisterFlagEffect(tp, id+2, RESET_PHASE+PHASE_END, 0, 2)
        local e3=Effect.CreateEffect(c)
        e3:SetType(EFFECT_TYPE_FIELD)
        e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e3:SetCode(EFFECT_CANNOT_ACTIVATE)
        e3:SetRange(LOCATION_MZONE)
        e3:SetTargetRange(1, 1)
        e3:SetTarget(aux.NOT(aux.TargetBoolFunction(Card.IsRace, RACE_FIEND)))
        e3:SetValue(s.aclimit2)
		e3:SetReset(RESET_PHASE+PHASE_END, 2)
        c:RegisterEffect(e3)
	end
end
--Monsters that are banished, as well as monsters in the GY, cannot activate their effects, except Fiend monsters
function s.aclimit(e, re, tp)
    local loc=re:GetActivateLocation()
    return (loc==LOCATION_GRAVE or loc==LOCATION_REMOVED) and re:IsActiveType(TYPE_MONSTER)
end
--Effects of monsters in the hand cannot be activated, except Fiend monsters
function s.aclimit2(e, re, tp)
    local loc=re:GetActivateLocation()
    return loc==LOCATION_HAND and re:IsActiveType(TYPE_MONSTER)
end
