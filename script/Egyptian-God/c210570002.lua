--Obligatory Summon
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_RA}
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.PayLPCost(tp,Duel.GetLP(tp)//2)
end
--The monster you choose on field
function s.filter(c,e,tp)
	return c:IsFaceup() and c:IsLevelAbove(5)
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp,c)
end
--The monster you special summon from the deck with the initial effect
function s.spfilter(c,e,tp,tc)
	return c:GetOriginalRace()==tc:GetOriginalRace() and c:GetOriginalAttribute()==tc:GetOriginalAttribute() 
        and c:GetOriginalLevel()==tc:GetOriginalLevel() and not c:IsCode(tc:GetCode())
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
--The monster you special summon with the additional effect
function s.spfilter2(c,e,tp,fg)
	return (c:IsMonster() and c:IsRace(RACE_DIVINE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
        and not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,c:GetCode()),tp,LOCATION_ONFIELD,0,1,nil))
        or (not fg and c:IsCode(CARD_RA) and c:IsCanBeSpecialSummoned(e,0,tp,true,false))    
end
--Ra monsters' filter
function s.chkfilter(c)
    return c:IsFaceup() and c:IsCode(CARD_RA,10000080,10000090)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    local fg=Duel.IsExistingMatchingCard(s.chkfilter,tp,LOCATION_MZONE,0,1,nil)
    --Choose a level 5 or higher monster
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil,e,tp):GetFirst()
    --Set it's original type as label for summon restriction
    e:SetLabel(tc:GetOriginalRace())
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    --Special summon a monster with same type, attribute and level but different name
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp,tc):GetFirst()
    if sc and Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)>0 and sc:IsRace(RACE_DIVINE) 
    and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp,fg) 
    and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
        if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
        --Special summon an additional monster, if you do not have a Ra monster, you can special summon a "Winged Dragon of Ra"
        local spg=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp,fg)
        if #spg>0 then Duel.SpecialSummon(spg,0,tp,tp,true,false,POS_FACEUP) end
        --If you special summon Ra, change its stats
        if spg:GetFirst():IsCode(CARD_RA) then
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_SET_ATTACK)
            e1:SetValue(4000)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            spg:GetFirst():RegisterEffect(e1)
            local e2=e1:Clone()
            e2:SetCode(EFFECT_SET_DEFENSE)
            spg:GetFirst():RegisterEffect(e2)
        end
        --Divine beasts you currently control cannot send themselves to gy by their own effects
        local dg=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsRace,RACE_DIVINE),tp,LOCATION_MZONE,0,nil)
        for dc in aux.Next(dg) do
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_CANNOT_TO_GRAVE)
            e1:SetRange(LOCATION_MZONE)
            e1:SetValue(s.efilter)
            dc:RegisterEffect(e1)
        end
    end
    --You cannot special summon monsters with the same type as the previously set label for the rest of the turn
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	Duel.RegisterEffect(e1,tp)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:GetRace()==e:GetLabel()
end
function s.efilter(e,re,rp,c)
	return re:GetOwner()==c
end