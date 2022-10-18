--Harpie's Pet Dragon Master
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
    --Fusion materials
	Fusion.AddProcMix(c, true, true, CARD_HARPIE_LADY, s.ffilter)
	Fusion.AddContactProc(c, s.contactfil, s.contactop, s.splimit, nil, nil, nil, false)
    --ATK up
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_ATKCHANGE)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_ATTACK_ANNOUNCE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCondition(s.atkcon)
    e1:SetOperation(s.atkop)
    c:RegisterEffect(e1)
    --Change pos
	local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.postg)
	e2:SetOperation(s.posop)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_HARPIE_LADY}
s.listed_series={0x64}
--Fusion materials
function s.ffilter(c, fc, sumtype, tp)
	return c:IsRace(RACE_DRAGON, fc, sumtype, tp) and (c:IsLevelBelow(7) or c:IsRankBelow(7))
end
function s.splimit(e, se, sp, st)
	return (st&SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION or e:GetHandler():GetLocation()~=LOCATION_EXTRA
end
function s.contactfil(tp)
	return Duel.GetReleaseGroup(tp)
end
function s.contactop(g)
	Duel.Release(g, REASON_COST+REASON_MATERIAL)
end
--ATK up
function s.filter(c)
    return c:IsFaceup() and c:IsSetCard(0x64) and c:IsType(TYPE_MONSTER)
end
function s.atkcon(e, tp, eg, ep, ev, re, r, rp)
    return (e:GetHandler()==Duel.GetAttacker() and Duel.GetAttackTarget()~=nil) or e:GetHandler()==Duel.GetAttackTarget()
end
function s.atkop(e, tp, eg, ep, ev, re, r, rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        local atk=Duel.GetMatchingGroupCount(s.filter, tp, LOCATION_MZONE+LOCATION_GRAVE, LOCATION_MZONE+LOCATION_GRAVE, nil)
        local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk*500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
    end
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetTargetRange(LOCATION_MZONE, 0)
	e2:SetTarget(s.ftarget)
	e2:SetLabel(c:GetFieldID())
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2, tp)
end
function s.ftarget(e, c)
	return e:GetLabel()~=c:GetFieldID()
end
--Change pos
function s.posfilter(c)
	return c:IsSetCard(0x64) and c:IsFaceup() and c:IsAttackPos()
end
function s.postg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.posfilter, tp, LOCATION_MZONE, 0, 1, nil) end
	Duel.SetOperationInfo(0, CATEGORY_POSITION, nil, 1, 0, 0)
end
function s.posop(e, tp, eg, ep, ev, re, r, rp, chk)
    local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_POSCHANGE)
	local g=Duel.SelectMatchingCard(tp, s.posfilter, tp, LOCATION_MZONE, 0, 1, 1, nil)
	local tc=g:GetFirst()
	if tc and Duel.ChangePosition(tc, POS_FACEUP_DEFENSE) then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
        e1:SetValue(1)
        e1:SetTargetRange(LOCATION_ONFIELD, 0)
        e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard, 0x64))
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1, tp)
        local e2=e1:Clone()
        e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
        Duel.RegisterEffect(e2, tp)
	end
end