--Worm Fusion
local s,id=GetID()
function s.initial_effect(c)
	local e1=Fusion.CreateSummonEff(c,aux.FilterBoolFunction(Card.IsRace,RACE_REPTILE),nil,s.fextra)
    e1:SetCountLimit(1,id)
	c:RegisterEffect(e1)
	if not AshBlossomTable then AshBlossomTable={} end
	table.insert(AshBlossomTable,e1)
    --Set
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_PHASE+PHASE_END)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.setcon)
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.settg)
    e2:SetOperation(s.setop)
    c:RegisterEffect(e2)
end
s.listed_names={90075978}
s.listed_series={0x3e}
function s.filter(c)
    return c:IsOnField() and c:IsSetCard(0x3e) and c:IsRace(RACE_REPTILE) and c:HasLevel()
end
function s.fcheck(tp,sg,fc)
    local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil)
    local ct=g:GetSum(Card.GetLevel)
    if sg:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then
        return sg:IsExists(s.filter,1,nil) and sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=ct
    end
    return true
end
function s.fextra(e,tp,mg)
	if mg:IsExists(s.filter,1,nil) then
		local eg=Duel.GetMatchingGroup(s.exfilter,tp,LOCATION_DECK,0,nil)
		if eg and #eg>0 then
			return eg,s.fcheck
		end
	end
	return nil
end
function s.exfilter(c)
	return c:IsMonster() and c:IsSetCard(0x3e) and c:IsRace(RACE_REPTILE) and c:IsAbleToGrave()
end

function s.cfilter(c)
	return c:IsType(TYPE_MONSTER) and not c:IsRace(RACE_REPTILE)
end
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,1,nil,TYPE_MONSTER) and not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil) 
end
function s.setfilter(c)
	return c:IsCode(90075978) and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SSet(tp,g:GetFirst())
	end
end