--Dangerous Portal Machine Type-777
local s,id=GetID()
function s.initial_effect(c)
    --Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
    --Destroy and Special Summon
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_SZONE)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.destg)
    e1:SetOperation(s.desop)
    c:RegisterEffect(e1)
end
s.listed_names={211040008}
s.listed_series={0x0f7a}
function s.desfilter(c,e)
    return (c:IsSetCard(0x0f7a) or c:IsCode(67048711)) and c:IsDestructable()
end
function s.sphandfilter(c,e,tp)
    return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.spexfilter(c,e,tp)
    return c:IsCode(211040008) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SPECIAL,tp,false,false)
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    local dg=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c,e)
    if chk==0 then
        return #dg>0 and (
            Duel.IsExistingMatchingCard(s.sphandfilter,tp,LOCATION_HAND,0,1,nil,e,tp) or
            Duel.IsExistingMatchingCard(s.spexfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
        )
    end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,0,LOCATION_ONFIELD)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_EXTRA)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local dg=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c,e)
    if #dg>0 then
        Duel.HintSelection(dg)
        if Duel.Destroy(dg,REASON_EFFECT)>0 then
            Duel.BreakEffect()
            local g=Group.CreateGroup()
            local g1=Duel.GetMatchingGroup(s.sphandfilter,tp,LOCATION_HAND,0,nil,e,tp)
            local g2=Duel.GetMatchingGroup(s.spexfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
            g:Merge(g1)
            g:Merge(g2)
            if #g==0 then return end
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
            local sg=g:Select(tp,1,1,nil)
            local sc=sg:GetFirst()
            if sc then
                if sc:IsLocation(LOCATION_EXTRA) then
                    Duel.SpecialSummon(sc,SUMMON_TYPE_SPECIAL,tp,tp,false,false,POS_FACEUP)
                else
                    Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
                end
            end
        end
    end
end