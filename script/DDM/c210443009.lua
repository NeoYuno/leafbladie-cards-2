--Diamond Cleaver
local s,id=GetID()
function s.initial_effect(c)
	local e0=aux.AddEquipProcedure(c,nil,s.filter)
    e0:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    --Atk up
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(s.atkcon)
	e1:SetCost(s.atkcost)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_TOSS_DICE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetLabelObject(e1)
	e2:SetOperation(s.regop)
	c:RegisterEffect(e2)
    local e3=e2:Clone()
	e3:SetCode(EVENT_PHASE_START+PHASE_END)
	e3:SetOperation(s.clearop)
	c:RegisterEffect(e3)
    --Draw
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_DICE+CATEGORY_DRAW)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EVENT_BATTLE_DESTROYING)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(s.drcon)
	e4:SetTarget(s.drtg)
	e4:SetOperation(s.drop)
	c:RegisterEffect(e4)
end
s.roll_dice=true
function s.filter(c)
	return c.roll_dice
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
    local ct=e:GetLabel()
	return ct>0 and e:GetHandler():GetFlagEffect(id)<ct
end
function s.filter1(c)
    return c:IsType(TYPE_SPELL) and c:IsAbleToRemoveAsCost()
end
function s.filter2(c)
    return c.roll_dice and c:IsType(TYPE_SPELL) and c:IsAbleToGraveAsCost()
end
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local b1=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_DECK,0,2,nil)
    local b2=Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_GRAVE,0,2,nil)
	if chk==0 then return (b1 and Duel.IsEnvironment(210443010)) or b2 end
    if b1 and Duel.IsEnvironment(210443010) then
        if b2 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
            local g=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_DECK,0,2,2,nil)
            if #g>0 then
                Duel.SendtoGrave(g,REASON_COST)
            end
        elseif not b2 then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
            local g=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_DECK,0,2,2,nil)
            if #g>0 then
                Duel.SendtoGrave(g,REASON_COST)
            end
        end
    else
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
        local g=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_GRAVE,0,2,2,nil)
        if #g>0 then
            Duel.Remove(g,POS_FACEUP,REASON_COST)
        end
    end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	if ec and ec:IsFaceup() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		ec:RegisterEffect(e1)
	end
    c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local ec=c:GetEquipTarget()
	if re:GetHandler()==ec then
		local val=ev
		e:GetLabelObject():SetLabel(val)
	end
end
function s.clearop(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():SetLabel(0)
end
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=eg:GetFirst()
	local bc=ec:GetBattleTarget()
	return e:GetHandler():GetEquipTarget()==eg:GetFirst() and ec:IsControler(tp) and bc:IsReason(REASON_BATTLE)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,0)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local dc=Duel.TossDice(tp,1)
	if Duel.Draw(tp,dc+1,REASON_EFFECT) then
        local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_HAND,0,nil)
        if #g==0 then return end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
        local sg=g:Select(tp,dc,dc,nil)
        Duel.SendtoDeck(sg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
        local ct=Duel.GetOperatedGroup():FilterCount(Card.IsLocation,nil,LOCATION_DECK)
        if ct>0 then
            Duel.SortDeckbottom(tp,tp,ct)
        end
    end
end