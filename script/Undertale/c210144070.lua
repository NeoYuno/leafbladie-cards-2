--Undyne's Spear
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c)
	--Change ATK
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(s.value)
	c:RegisterEffect(e1)
    --Change Battle Position
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_SET_POSITION)
    e2:SetCondition(s.condition)
	e2:SetValue(POS_FACEUP_DEFENSE)
	c:RegisterEffect(e2)
    --Negate
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_DISABLE)
    e3:SetCondition(s.condition)
	c:RegisterEffect(e3)
    --Re-add
    local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_GRAVE)
    e4:SetCountLimit(1,id)
	e4:SetCondition(s.thcon)
	e4:SetCost(s.thcost)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
    --effect gain
	local e5=Effect.CreateEffect(c)
    e5:SetCategory(CATEGORY_EQUIP)
	e5:SetType(EFFECT_TYPE_QUICK_O)
    e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetRange(LOCATION_MZONE)
    e5:SetCountLimit(1,{id,1})
    e5:SetTarget(s.eqtg)
	e5:SetOperation(s.eqop)
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e6:SetRange(LOCATION_SZONE)
	e6:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e6:SetTarget(s.eftg)
	e6:SetLabelObject(e5)
	c:RegisterEffect(e6)
end
s.listed_series={0x0f4a,0x0f4e}
function s.value(e,c)
	local ec=e:GetHandler():GetEquipTarget()
	if ec:IsSetCard(0xf4a) then
		return 1000
	else
		return 0
	end
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
    local ec=e:GetHandler():GetEquipTarget()
    return not ec:IsSetCard(0x0f4a)
end

function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,0x0f4e),tp,LOCATION_MZONE,0,1,nil)
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
        Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end

function s.eftg(e,c)
	return e:GetHandler():GetEquipTarget()==c and c:IsSetCard(0x0f4e)
end
function s.filter(c,tp)
	return c:IsFaceup() and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,c,tp)
end
function s.eqfilter(c,tc,tp)
	return c:IsSetCard(0x0f4a) and c:IsType(TYPE_EQUIP) and c:CheckEquipTarget(tc) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler(),tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,e:GetHandler(),tp)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
    local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		local g=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,tc,tp)
		if #g>0 and Duel.Equip(tp,g:GetFirst(),tc) then
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_PIERCE)
            e1:SetValue(DOUBLE_DAMAGE)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            c:RegisterEffect(e1)
		end
	end
end