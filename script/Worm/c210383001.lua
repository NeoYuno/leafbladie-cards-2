--Worm Alpha Zeta
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Link.AddProcedure(c,s.matfilter,1,1)
	--Search
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
    --Change Battle Pos
    local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMING_MAIN_END)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.postg)
	e2:SetOperation(s.posop)
	c:RegisterEffect(e2)
end
s.listed_series={0x3e}
--filter for the link material
function s.matfilter(c,scard,sumtype,tp)
	return not c:IsLinkMonster() and c:IsRace(RACE_REPTILE,scard,sumtype,tp)
end
--filter for the search
function s.thfilter(c)
	return c:IsSetCard(0x3e) and c:IsAbleToHand() and ((c:IsMonster() and c:IsRace(RACE_REPTILE)) or c:IsType(TYPE_SPELL+TYPE_TRAP))
end
--filter for the additional summon "cost" effect
function s.tgfilter(c)
    return c:IsRace(RACE_REPTILE) and c:IsAbleToGrave() and (c:IsFaceup() or c:IsLocation(LOCATION_HAND))
end
--filter for the summonable reptiles in hand
function s.stfilter(c,ft)
    return c:IsRace(RACE_REPTILE) and c:CanSummonOrSet(true,nil) and ((c:IsLevelBelow(4) and ft>0) or c:IsLevelAbove(5) and ft>-1)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if Duel.SendtoHand(tc,nil,REASON_EFFECT)==0 then return end
	local tgg=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
	local stg=Duel.GetMatchingGroup(s.stfilter,tp,LOCATION_HAND,0,nil,ft)
	if #tgg==2 and not stg:FilterCount(Card.IsLevelBelow,nil,4)==0 then return end
	if #tgg==2 and stg:FilterCount(Card.IsLevelBelow,nil,4)==1 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.SendtoGrave(c,REASON_EFFECT)
		s.sumop(e,tp,eg,ep,ev,re,r,rp)
	elseif #tgg>2 and stg:FilterCount(Card.IsLevelAbove,nil,5)==#stg and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)<=1 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		tgg:RemoveCard(c)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local sg=tgg:Select(tp,1,1,nil)
		Duel.SendtoGrave(sg,REASON_EFFECT)
		s.sumop(e,tp,eg,ep,ev,re,r,rp)
	elseif #tgg>2 and #stg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local sg=tgg:Select(tp,1,1,nil)
		Duel.SendtoGrave(sg,REASON_EFFECT)
		s.sumop(e,tp,eg,ep,ev,re,r,rp)
	end
end
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.stfilter,tp,LOCATION_HAND,0,1,1,nil,ft):GetFirst()
	if sc then
		Duel.BreakEffect()
		Duel.SummonOrSet(tp,sc,true,nil)
	end
end

function s.posfilter(c)
	return c:IsRace(RACE_REPTILE) and c:IsCanChangePosition()
end
function s.confilter(c)
    return c:IsFaceup() and c:IsRace(RACE_REPTILE) and c:IsSetCard(0x3e)
end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.posfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,0,0)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACK)
	local tc=Duel.SelectMatchingCard(tp,s.posfilter,tp,LOCATION_MZONE,0,1,1,nil)
	if tc and Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)>0 then
        local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_REPTILE))
		e1:SetCondition(s.econ)
		e1:SetValue(s.efilter)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.econ(e)
	return Duel.IsExistingMatchingCard(s.confilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
function s.efilter(e,re)
	return re:GetOwnerPlayer()~=e:GetHandlerPlayer()
end