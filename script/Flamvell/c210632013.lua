--Red Mirror
--Modified for "Flamvell Kindling"
local s,id=GetID()
function s.initial_effect(c)
	--to hand
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--to hand
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker():GetControler()~=tp
end
function s.costfilter(c,tp)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsMonster() and c:IsDefenseBelow(200) and c:IsAbleToGraveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    local b1=e:GetHandler():IsAbleToGraveAsCost()
    local b2=Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_DECK,0,1,nil,tp) and Duel.IsPlayerAffectedByEffect(tp,210632003)
	if chk==0 then return b1 or b2 end
    if b1 and b2 then
        if Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
            s.op(e,tp,eg,ep,ev,re,r,rp)
        else
            Duel.SendtoGrave(e:GetHandler(),REASON_COST)
        end
    elseif b1 and not b2 then
        Duel.SendtoGrave(e:GetHandler(),REASON_COST)
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
    local tc=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
    if tc then
        local fc=nil
        if #fg==1 then
            fc=fg:GetFirst()
        else
            fc=fg:Select(tp,1,1,nil)
        end
        Duel.Hint(HINT_CARD,0,fc:GetCode())
        fc:RegisterFlagEffect(210632003,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
    end
    Duel.SendtoGrave(tc,REASON_COST)
end
function s.filter(c)
	return c:IsRace(RACE_FIEND) and c:IsAttribute(ATTRIBUTE_FIRE) and not c:IsCode(id) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
function s.cfilter(c,tp)
	return c:IsSummonType(SUMMON_TYPE_SYNCHRO) and c:IsSummonPlayer(tp)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp) and aux.exccon(e)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
