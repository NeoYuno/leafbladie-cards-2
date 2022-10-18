--A Normal Fusion
local s,id=GetID()
function s.initial_effect(c)
    --Fusion Summon any Fusion Monster
	local e1=Fusion.CreateSummonEff(c,nil,aux.FilterBoolFunction(Card.IsType,TYPE_NORMAL),s.fextra,s.extraop)
    e1:SetDescription(aux.Stringid(id,0))
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
	if not GhostBelleTable then GhostBelleTable={} end
	table.insert(GhostBelleTable,e1)
    --Fusion Summon a non-Effect Fusion Monster
	local e2=Fusion.CreateSummonEff(c,aux.FilterBoolFunction(s.ffilter),nil,s.fextra2,nil,nil,s.stage2)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e2)
	if not AshBlossomTable then AshBlossomTable={} end
	table.insert(AshBlossomTable,e2)
end
--Fusion Summon any Fusion Monster
function s.exfilter(c)
    return c:IsType(TYPE_NORMAL) and c:IsAbleToRemove()
end
function s.fextra(e,tp,mg)
	local exg=Duel.GetMatchingGroup(Fusion.IsMonsterFilter(s.exfilter),tp,LOCATION_GRAVE,0,nil)
	if not Duel.IsPlayerAffectedByEffect(tp,69832741) then return exg end
end
function s.extraop(e,tc,tp,sg)
	local g1=sg:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
	Duel.Remove(g1,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
	sg:Sub(g1)
end
--Fusion Summon a non-Effect Fusion Monster
function s.ffilter(c)
	return c:IsType(TYPE_MONSTER) and not c:IsType(TYPE_EFFECT)
end
function s.fextra2(e,tp,mg)
	return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToGrave),tp,LOCATION_DECK,0,nil)
end
function s.matfilter(c)
    return c:IsPreviousLocation(LOCATION_DECK) and c:IsType(TYPE_EFFECT)
end
function s.stage2(e,tc,tp,mg,chk)
    if chk==1 then
        local g=tc:GetMaterial()
        local g2=g:Filter(s.matfilter,nil)
        if #g2>=2 then
            for sc in g2:Iter() do
                --Cannot special summon monsters with the same name
                local e1=Effect.CreateEffect(e:GetHandler())
                e1:SetType(EFFECT_TYPE_FIELD)
                e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
                e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
                e1:SetTargetRange(1,0)
                e1:SetTarget(s.sumlimit)
                e1:SetLabel(sc:GetCode())
                e1:SetReset(RESET_PHASE+PHASE_END)
                Duel.RegisterEffect(e1,tp)
                local e2=e1:Clone()
                e2:SetCode(EFFECT_CANNOT_ACTIVATE)
                e2:SetValue(s.aclimit)
                Duel.RegisterEffect(e2,tp)
            end
        end
	end
end
function s.sumlimit(e,c)
	return c:IsType(TYPE_EFFECT) and c:IsCode(e:GetLabel())
end
function s.aclimit(e,re,tp)
	return re:GetHandler():IsCode(e:GetLabel()) and re:IsActiveType(TYPE_MONSTER)
end