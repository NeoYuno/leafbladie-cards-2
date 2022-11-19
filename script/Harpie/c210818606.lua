--Harpie Fortification
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1, id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
    --Double atk
    local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.atkcon)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_HARPIE_LADY,CARD_HARPIE_LADY_SISTERS}
s.listed_series={0x64}
--Activate
function s.filter(c,tp)
	return c:IsFaceup() and (c:IsCode(CARD_HARPIE_LADY) or c:IsCode(CARD_HARPIE_LADY_SISTERS))
        and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,c,tp)
end
function s.eqfilter(c,tc,tp)
	return c:IsType(TYPE_EQUIP) and c:CheckEquipTarget(tc) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc,tp) end
	local ft=0
	if e:GetHandler():IsLocation(LOCATION_HAND) then ft=1 end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>ft
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil,tp)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	local g=Duel.GetMatchingGroup(s.eqfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,tc,tp)
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and #g>0 and ft>0 then
        if tc:IsCode(CARD_HARPIE_LADY_SISTERS) then
            local sg=aux.SelectUnselectGroup(g,e,tp,1,math.min(ft,3),false,1,tp,HINTMSG_EQUIP)
            local sc=sg:GetFirst()
            for sc in aux.Next(sg) do
                Duel.Equip(tp,sc,tc)
            end
        else 
            local sg=aux.SelectUnselectGroup(g,e,tp,1,1,false,1,tp,HINTMSG_EQUIP)
            local sc=sg:GetFirst()
            for sc in aux.Next(sg) do
                Duel.Equip(tp,sc,tc)
            end
        end
    end
end
--Double atk
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD) and (rp~=tp or (rp==tp and re:GetHandler():IsSetCard(0x64))) and c:IsPreviousControler(tp)
		and r&REASON_EFFECT==REASON_EFFECT
end
function s.cfilter(c,e)
	return c:IsFaceup() and c:IsSetCard(0x64) and not c:IsImmuneToEffect(e)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil,e)
	local c=e:GetHandler()
	local tc=sg:GetFirst()
	for tc in aux.Next(sg) do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		e1:SetValue(tc:GetAttack()*2)
		tc:RegisterEffect(e1)
    end
end
