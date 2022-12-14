--Brotherhood of the Fire Fist - Buffalo
--Modified for "Flamvell Kindling"
local s,id=GetID()
function s.initial_effect(c)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(92572371,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
s.listed_series={0x79,0x7c}
function s.cfilter(c)
	return (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and (c:IsSetCard(0x79) or c:IsSetCard(0x7c)) and c:IsAbleToGraveAsCost()
end
function s.mzfilter(c)
	return c:IsLocation(LOCATION_MZONE) and c:GetSequence()<5
end
function s.costfilter(c,tp)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsMonster() and c:IsDefenseBelow(200) and c:IsAbleToGraveAsCost()
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local ct=-ft+1
	local sg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,nil)
	local nc=#sg>=2 and (ft>0 or (ct<3 and sg:IsExists(s.mzfilter,ct,nil)))
    local b1=(Duel.IsPlayerAffectedByEffect(tp,CARD_FIRE_FIST_EAGLE) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0) or nc
    local b2=Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_DECK,0,1,nil,tp) and Duel.IsPlayerAffectedByEffect(tp,210632003)
	if chk==0 then return b1 or b2 end
    if b1 and b2 then
        if Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
            s.op(e,tp,eg,ep,ev,re,r,rp)
        else
            if nc and not (Duel.IsPlayerAffectedByEffect(tp,CARD_FIRE_FIST_EAGLE) and Duel.SelectYesNo(tp,aux.Stringid(CARD_FIRE_FIST_EAGLE,0))) then
                local g=nil
                if ft<=0 then
                    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
                    g=sg:FilterSelect(tp,s.mzfilter,ct,ct,nil)
                    if ct<2 then
                        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
                        local g1=sg:Select(tp,2-ct,2-ct,g)
                        g:Merge(g1)
                    end
                else
                    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
                    g=sg:Select(tp,2,2,nil)
                end
                Duel.SendtoGrave(g,REASON_COST)
            end
        end
    elseif b1 and not b2 then
        if nc and not (Duel.IsPlayerAffectedByEffect(tp,CARD_FIRE_FIST_EAGLE) and Duel.SelectYesNo(tp,aux.Stringid(CARD_FIRE_FIST_EAGLE,0))) then
            local g=nil
            if ft<=0 then
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
                g=sg:FilterSelect(tp,s.mzfilter,ct,ct,nil)
                if ct<2 then
                    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
                    local g1=sg:Select(tp,2-ct,2-ct,g)
                    g:Merge(g1)
                end
            else
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
                g=sg:Select(tp,2,2,nil)
            end
            Duel.SendtoGrave(g,REASON_COST)
        end
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
	if e:GetHandler():IsRelateToEffect(e) then
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
