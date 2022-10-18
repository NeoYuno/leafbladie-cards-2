--Harpie's Aero Nail
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c, nil, aux.FilterBoolFunction(Card.IsCode, CARD_HARPIE_LADY, CARD_HARPIE_LADY_SISTERS))
	--ATK up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(300)
	c:RegisterEffect(e1)
    --Double damage
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e2:SetCondition(s.damcon)
	e2:SetValue(aux.ChangeBattleDamage(1, DOUBLE_DAMAGE))
	c:RegisterEffect(e2)
    --Equip
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_EQUIP)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1, id)
	e3:SetCondition(s.eqcon)
	e3:SetTarget(s.eqtg)
	e3:SetOperation(s.eqop)
	c:RegisterEffect(e3)
end
s.listed_names={CARD_HARPIE_LADY, CARD_HARPIE_LADY_SISTERS}
s.listed_series={0x64}
--Double damage
function s.damcon(e)
	return e:GetHandler():GetEquipTarget():GetBattleTarget()~=nil
end
--Equip
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP) and c:IsReason(REASON_DESTROY) and c:CheckUniqueOnField(tp)
end
function s.eqfilter(c)
	return c:IsFaceup() and c:IsCode(CARD_HARPIE_LADY) or c:IsCode(CARD_HARPIE_LADY_SISTERS)
end
function s.spfilter(c, e, tp)
    return c:IsSetCard(0x64) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end
function s.eqtg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.eqfilter(chkc) end
	if chk==0 then return e:GetHandler():IsRelateToEffect(e) and Duel.GetLocationCount(tp, LOCATION_SZONE)>0
		and Duel.IsExistingTarget(s.eqfilter, tp, LOCATION_MZONE, 0, 1, nil) end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_EQUIP)
	Duel.SelectTarget(tp, s.eqfilter, tp, LOCATION_MZONE, 0, 1, 1, nil)
	Duel.SetOperationInfo(0, CATEGORY_EQUIP, e:GetHandler(), 1, 0, 0)
	Duel.SetOperationInfo(0, CATEGORY_LEAVE_GRAVE, e:GetHandler(), 1, 0, 0)
end
function s.eqop(e, tp, eg, ep, ev, re, r, rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc and tc:IsRelateToEffect(e) and tc:IsFaceup() and c:CheckUniqueOnField(tp) then
		if Duel.Equip(tp, c, tc) then
            local g=Duel.GetMatchingGroup(s.spfilter, tp, LOCATION_HAND+LOCATION_GRAVE, 0, nil, e, tp)
			if #g>0 and Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
				Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
				local sg=g:Select(tp, 1, 1, nil)
				if #sg>0 then
					Duel.SpecialSummon(sg, 0, tp, tp, false, false, POS_FACEUP)
				end
			end
        end
	end
end