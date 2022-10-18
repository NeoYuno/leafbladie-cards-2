--Magician Dragon
local s,id=GetID()
function s.initial_effect(c)
	--Destroy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCost(s.descost)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
    --Dice
	local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DICE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
s.roll_dice=true
s.listed_names={210443010}
function s.filter1(c)
    return c:IsType(TYPE_SPELL) and c:IsAbleToRemoveAsCost()
end
function s.filter2(c)
    return c.roll_dice and c:IsType(TYPE_SPELL) and c:IsAbleToGraveAsCost()
end
function s.fieldcond(c)
	return c:IsFaceup() and c:IsCode(210443010)
end
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
    local fc=Duel.IsExistingMatchingCard(s.fieldcond,tp,LOCATION_FZONE,LOCATION_FZONE,1,nil)
	local gv=Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_GRAVE,0,3,nil)
	local dk=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_DECK,0,3,nil)
	if chk==0 then return gv or (fc and dk) end
	if gv and fc and dk then
		if Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
			local g=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_DECK,0,3,3,nil)
			Duel.SendtoGrave(g,REASON_COST)
		else
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
			local g=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_GRAVE,0,3,3,nil)
			Duel.Remove(g,POS_FACEUP,REASON_COST)
		end
	elseif fc and dk and not gv then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_DECK,0,3,3,nil)
		Duel.SendtoGrave(g,REASON_COST)
	elseif gv and not fc or not dk then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_GRAVE,0,3,3,nil)
		Duel.Remove(g,POS_FACEUP,REASON_COST)
	end
end
function s.desfilter(c,cg)
	return cg:IsContains(c)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    local cg=e:GetHandler():GetColumnGroup(1,1)
	if chk==0 then return Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler(),cg) end
	local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler(),cg)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local cg=c:GetColumnGroup(1,1)
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c,cg)
		if #g>0 then
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	local d=Duel.TossDice(tp,1)
	if d==1 then
        if c:IsFaceup() and c:IsRelateToEffect(e) then
            local e1=Effect.CreateEffect(c)
            e1:SetDescription(3008)
            e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
            e1:SetValue(1)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
            c:RegisterEffect(e1)
            local e2=e1:Clone()
            e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
            c:RegisterEffect(e2)
        end
	elseif d==6 and c:IsFaceup() and c:IsRelateToEffect(e) then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
        e1:SetRange(LOCATION_MZONE)
        e1:SetTargetRange(0,LOCATION_MZONE)
        e1:SetValue(s.atlimit)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
        c:RegisterEffect(e1)
	else
        if c:IsFaceup() and c:IsRelateToEffect(e) then
            local og=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
            local mg,mdef=og:GetMaxGroup(Card.GetDefense)
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_UPDATE_DEFENSE)
            e1:SetValue(mdef)
            c:RegisterEffect(e1)
            if c:IsAttackPos() and c:IsCanChangePosition() and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
                if c:IsRelateToEffect(e) and c:IsFaceup() then
                    Duel.BreakEffect()
                    Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
                end
            end
        end
	end
end
function s.atlimit(e,c)
	return c~=e:GetHandler()
end