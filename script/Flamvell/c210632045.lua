--Ancient Warriors - Ambitious Cao De
--Modified for "Flamvell Kindling"
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(33545259,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Prevent effect target
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetCondition(s.condition)
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	--Prevent destruction by effects
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.condition)
	e3:SetValue(aux.indoval)
	c:RegisterEffect(e3)
	--Special Summon the destroyed monster
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(33545259,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLE_DESTROYING)
	e4:SetCountLimit(1,{id,1})
	e4:SetCondition(aux.bdogcon)
	e4:SetTarget(s.target)
	e4:SetOperation(s.operation)
	c:RegisterEffect(e4)
end
s.listed_series={0x137}
function s.spcfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:GetPreviousControler()==1-tp and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.spcfilter,1,nil,tp)
end
function s.costfilter(c,tp)
	return c:IsAbleToGraveAsCost() and Duel.GetMZoneCount(tp,c)>0
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,c,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,1,c,tp)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.costfilter(c,tp)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsMonster() and c:IsDefenseBelow(200) and c:IsAbleToGraveAsCost()
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local b1=Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,e:GetHandler(),tp)
    local b2=Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_DECK,0,1,nil,tp) and Duel.IsPlayerAffectedByEffect(tp,210632003)
	if chk==0 then return b1 or b2 end
    if b1 and b2 then
        if Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
            s.op(e,tp,eg,ep,ev,re,r,rp)
        else
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
            local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,1,e:GetHandler(),tp)
            Duel.SendtoGrave(g,REASON_COST)
        end
    elseif b1 and not b2 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
        local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,1,e:GetHandler(),tp)
        Duel.SendtoGrave(g,REASON_COST)
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
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
function s.condition(e)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,0x137),e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler())
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetHandler():GetBattleTarget()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and bc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	Duel.SetTargetCard(bc)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,bc,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
