--Mighty Magician
local s,id=GetID()
function s.initial_effect(c)
    --Dice
	local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DICE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
    --Can attack directly
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(s.atcost)
	e2:SetOperation(s.atop)
	c:RegisterEffect(e2)
end
s.roll_dice=true
s.listed_names={210443010}
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	local d=Duel.TossDice(tp,1)
    local ct=0
    local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_MZONE,LOCATION_MZONE,nil,TYPE_MONSTER)
    for tc in aux.Next(g) do
        while ct<d do
            local tc=g:Select(tp,1,1,nil):GetFirst()
            if tc:IsControler(tp) then
                i=0
                p1=LOCATION_MZONE
                p2=0
            else
                i=16
                p2=LOCATION_MZONE
                p1=0
            end
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
            Duel.MoveSequence(tc,math.log(Duel.SelectDisableField(tp,1,p1,p2,0),2)-i)
            g:RemoveCard(tc)
            ct=ct+1
            if ct<d and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
                return end
        end
    end
end
function s.filter1(c)
    return c:IsType(TYPE_SPELL) and c:IsAbleToRemoveAsCost()
end
function s.filter2(c)
    return c.roll_dice and c:IsType(TYPE_SPELL) and c:IsAbleToGraveAsCost()
end
function s.fieldcond(c)
	return c:IsFaceup() and c:IsCode(210443010)
end
function s.atcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local fc=Duel.IsExistingMatchingCard(s.fieldcond,tp,LOCATION_FZONE,LOCATION_FZONE,1,nil)
	local gv=Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_GRAVE,0,2,nil)
	local dk=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_DECK,0,2,nil)
	if chk==0 then return gv or (fc and dk) end
	if gv and fc and dk then
		if Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
			local g=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_DECK,0,2,2,nil)
			Duel.SendtoGrave(g,REASON_COST)
		else
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
			local g=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_GRAVE,0,2,2,nil)
			Duel.Remove(g,POS_FACEUP,REASON_COST)
		end
	elseif fc and dk and not gv then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_DECK,0,2,2,nil)
		Duel.SendtoGrave(g,REASON_COST)
	elseif gv and not fc or not dk then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_GRAVE,0,2,2,nil)
		Duel.Remove(g,POS_FACEUP,REASON_COST)
	end
end
function s.atop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(3205)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end