--Brotherhood of the Fire Fist - Rhino
--Modified for "Flamvell Kindling"
local s,id=GetID()
function s.initial_effect(c)
	--attack up
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetCondition(s.atkcon)
	e1:SetCost(s.atkcost)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
end
s.listed_series={0x79,0x7c}
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return (Duel.GetAttacker():IsControler(tp) and Duel.GetAttacker():IsSetCard(0x79))
		or (Duel.GetAttackTarget() and Duel.GetAttackTarget():IsControler(tp) and Duel.GetAttackTarget():IsSetCard(0x79))
end
function s.filter1(c)
	return c:IsFaceup() and c:IsSetCard(0x7c) and c:IsAbleToGraveAsCost()
end
function s.filter2(c)
	return c:IsSetCard(0x79) and c:GetBaseAttack()>0 and c:IsAbleToGraveAsCost()
end
function s.costfilter(c,tp)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsMonster() and c:IsDefenseBelow(200) and c:IsAbleToGraveAsCost()
end
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local b1=e:GetHandler():GetFlagEffect(id)==0 and Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_ONFIELD,0,1,nil)
        and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_HAND,0,1,nil)
    local b2=Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_DECK,0,1,nil,tp) and Duel.IsPlayerAffectedByEffect(tp,210632003)
	if chk==0 then return b1 or b2 end
    if b1 and b2 then
        if Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
            s.op(e,tp,eg,ep,ev,re,r,rp)
        else
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
            local g1=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_ONFIELD,0,1,1,nil)
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
            local g2=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_HAND,0,1,1,nil)
            e:SetLabel(g2:GetFirst():GetBaseAttack())
            g1:Merge(g2)
            Duel.SendtoGrave(g1,REASON_COST)
            e:GetHandler():RegisterFlagEffect(id,RESET_PHASE+PHASE_DAMAGE_CAL,0,1)
        end
    elseif b1 and not b2 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
        local g1=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_ONFIELD,0,1,1,nil)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
        local g2=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_HAND,0,1,1,nil)
        e:SetLabel(g2:GetFirst():GetBaseAttack())
        g1:Merge(g2)
        Duel.SendtoGrave(g1,REASON_COST)
        e:GetHandler():RegisterFlagEffect(id,RESET_PHASE+PHASE_DAMAGE_CAL,0,1)
    else
        s.op(e,tp,eg,ep,ev,re,r,rp)
    end
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
    local fg=Group.CreateGroup()
	for i,pe in ipairs({Duel.IsPlayerAffectedByEffect(tp,210632003)}) do
		fg:AddCard(pe:GetHandler())
	end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g1=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_ONFIELD,0,1,1,nil)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g1=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_ONFIELD,0,1,1,nil)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g2=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
    if g2:GetFirst() then
        local fc=nil
        if #fg==1 then
            fc=fg:GetFirst()
        else
            fc=fg:Select(tp,1,1,nil)
        end
        Duel.Hint(HINT_CARD,0,fc:GetCode())
        fc:RegisterFlagEffect(210632003,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
    end
    g1:Merge(g2)
    Duel.SendtoGrave(g1,REASON_COST)
    e:GetHandler():RegisterFlagEffect(id,RESET_PHASE+PHASE_DAMAGE_CAL,0,1)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=Duel.GetAttacker()
	if c:IsControler(1-tp) then c=Duel.GetAttackTarget() end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE_CAL)
	e1:SetValue(e:GetLabel())
	c:RegisterEffect(e1)
end