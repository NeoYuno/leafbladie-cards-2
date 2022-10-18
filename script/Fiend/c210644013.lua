--Mask of Gilfer
Duel.LoadScript("c420.lua")
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c)
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_ADD_SETCODE)
	e0:SetRange(LOCATION_HAND+LOCATION_DECK+LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED)
    e0:SetValue(0x583)
    c:RegisterEffect(e0)
	--Increase ATK
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(s.value)
	c:RegisterEffect(e1)
    --Gain LP
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id, 0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_PAY_LPCOST)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1)
	e2:SetCondition(s.reccon)
    e2:SetOperation(s.recop)
	c:RegisterEffect(e2)
	--Effect activate cost
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id, 1))
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_ACTIVATE_COST)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(1, 1)
	e3:SetCondition(s.accon)
	e3:SetTarget(s.actarget)
	e3:SetCost(s.costchk)
	e3:SetOperation(s.costop)
	c:RegisterEffect(e3)
	--accumulate
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(id)
	e4:SetRange(LOCATION_SZONE)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetTargetRange(1,1)
	c:RegisterEffect(e4)
	--Search
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id, 2))
	e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetCondition(s.thcon)
	e5:SetCost(s.thcost)
	e5:SetTarget(s.thtg)
	e5:SetOperation(s.thop)
	c:RegisterEffect(e5)
end
--Increase ATK
function s.value(e,c)
	local ec=e:GetHandler():GetEquipTarget()
	if ec:IsRace(RACE_FIEND) then
		return 500
	else
		return -500
	end
end
--Gain LP
function s.reccon(e, tp, eg, ep, ev, re, r, rp)
    local c=e:GetHandler():GetEquipTarget()
    return ep==tp and c:IsRace(RACE_FIEND) and re:GetHandler()==c
end
function s.recop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Recover(tp, ev, REASON_EFFECT)
end
--Effect activate cost
function s.accon(e)
    return not e:GetHandler():GetEquipTarget():IsRace(RACE_FIEND)
end
function s.actarget(e, te, tp)
	return te:GetHandler()==e:GetHandler():GetEquipTarget()
end
function s.costchk(e, te_or_c, tp)
	local ct=#{Duel.GetPlayerEffect(tp, id)}
	local atk=e:GetHandler():GetEquipTarget():GetBaseAttack()
	return Duel.CheckLPCost(tp, ct*atk)
end
function s.costop(e, tp, eg, ep, ev, re, r, rp)
	local atk=e:GetHandler():GetEquipTarget():GetBaseAttack()
	Duel.Hint(HINT_CARD, 0, id)
	Duel.PayLPCost(tp, atk)
end
--Search
function s.thcon(e, tp, eg, ep, ev, re, r, rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
function s.tgfilter(c)
	return c:IsRace(RACE_FIEND) and c:IsNonEffectMonster() and c:IsAbleToGraveAsCost()
end
function s.thfilter(c, chval)
	return c:IsRace(RACE_FIEND) and (c:GetAttack()==chval or c:GetDefense()==chval) and c:IsAbleToHand()
end
function s.thcost(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return Duel.CheckLPCost(tp, 500) and Duel.IsExistingMatchingCard(s.tgfilter, tp, LOCATION_DECK, 0, 1, nil) end
	local sg=Duel.SelectMatchingCard(tp, s.tgfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
	local tc=sg:GetFirst()
	local atk=tc:GetAttack()
	local def=tc:GetDefense()
	local chval=0
	Duel.PayLPCost(tp, 500)
	Duel.SendtoGrave(tc, REASON_COST)
	Duel.Hint(HINT_SELECTMSG, tp, aux.Stringid(id, 3))
	local sel=Duel.SelectOption(tp, aux.Stringid(id, 4), aux.Stringid(id, 5))
	if sel==0 then chval=atk
	else chval=def end
	e:SetLabel(chval)
end
function s.thtg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end
function s.thop(e, tp, eg, ep, ev, re, r, rp)
	local chval=e:GetLabel()
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp, s.thfilter, tp, LOCATION_DECK, 0, 1, 1, nil, chval)
	if #g>0 then
		Duel.SendtoHand(g, nil, REASON_EFFECT)
		Duel.ConfirmCards(1-tp, g)
	end
end