--Resurrection Scroll
local s,id=GetID()
function s.initial_effect(c)
	--Special summon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DICE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.roll_dice=true
function s.filter1(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.filter2(c,e,tp)
	return c.roll_dice and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	local d=Duel.TossDice(tp,1)
	if d==1 then
        local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.filter1),tp,0,LOCATION_GRAVE,nil,e,tp)
        if #g==0 then return end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sg=g:Select(tp,1,1,nil):GetFirst()
        local spos=0
        if sg:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK) then spos=spos+POS_FACEUP_ATTACK end
        if sg:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE) then spos=spos+POS_FACEDOWN_DEFENSE end
        if spos~=0 and Duel.SpecialSummon(sg,0,tp,tp,false,false,spos)~=0 then
            if sg:IsFacedown() then
                Duel.ConfirmCards(1-tp,sg)
            end
        end
	elseif d==6 then
        local ft=math.min(Duel.GetLocationCount(tp,LOCATION_MZONE),2)
        if ft==0 then return end
        if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
        ft=math.min(ft,aux.CheckSummonGate(tp) or ft)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter2),tp,LOCATION_GRAVE,0,1,ft,nil,e,tp)
        for tc in aux.Next(g) do
            local spos=0
            if tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK) then spos=spos+POS_FACEUP_ATTACK end
            if tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE) then spos=spos+POS_FACEDOWN_DEFENSE end
            Duel.SpecialSummonStep(tc,0,tp,tp,false,false,spos)
            if tc:IsFacedown() then
                Duel.ConfirmCards(1-tp,tc)
            end
        end
        Duel.SpecialSummonComplete()
	else
        local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.filter2),tp,LOCATION_GRAVE,0,nil,e,tp)
        if #g==0 then return end
        Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sg=g:Select(tp,1,1,nil):GetFirst()
        local spos=0
        if sg:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK) then spos=spos+POS_FACEUP_ATTACK end
        if sg:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE) then spos=spos+POS_FACEDOWN_DEFENSE end
        if spos~=0 and Duel.SpecialSummon(sg,0,tp,tp,false,false,spos)~=0 then
            if sg:IsFacedown() then
                Duel.ConfirmCards(1-tp,sg)
            end
        end
	end
end
