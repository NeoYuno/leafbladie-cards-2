--Red-Eyes Scapegoat
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_TOKEN+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={210852443}
s.listed_series={0x3b}
function s.tdfilter(c)
	return c:IsSetCard(0x3b) and c:HasLevel() and c:IsAbleToDeck()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE,0,1,nil)
        and (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 or Duel.IsPlayerAffectedByEffect(tp,69832741)) 
		and Duel.IsPlayerCanSpecialSummonMonster(tp,210852443,0x3b,TYPES_TOKEN,0,0,1,RACE_BEAST,ATTRIBUTE_DARK) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
    Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
    if ft<=0 or not Duel.IsPlayerCanSpecialSummonMonster(tp,210852443,0x3b,TYPES_TOKEN,0,0,1,RACE_BEAST,ATTRIBUTE_DARK) then return end
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE,0,nil)
	if #g==0 then return end
	local rg=aux.SelectUnselectGroup(g,e,tp,1,4,aux.dpcheck(Card.GetLevel),1,tp,HINTMSG_TODECK)
	local rc=Duel.SendtoDeck(rg,nil,2,REASON_EFFECT)
	if rc>0 then
		for i=1,rc do
            local token=Duel.CreateToken(tp,210852442+i)
            Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetDescription(aux.Stringid(id,0))
            e1:SetType(EFFECT_TYPE_FIELD)
            e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
            e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
            e1:SetTargetRange(1,0)
            e1:SetTarget(s.splimit)
            e1:SetReset(RESET_PHASE+PHASE_END)
            Duel.RegisterEffect(e1,tp)
            --lizard check
            aux.addTempLizardCheck(e:GetHandler(),tp,s.lizfilter)
        end
        Duel.SpecialSummonComplete()
    end
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0x3b) and c:IsLocation(LOCATION_EXTRA)
end
function s.lizfilter(e,c)
	return not c:IsOriginalSetCard(0x3b)
end