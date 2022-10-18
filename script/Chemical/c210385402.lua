--Oil Spil Fusion
local s,id=GetID()
function s.initial_effect(c)
	local e1=Fusion.CreateSummonEff(c,s.filter,nil,s.fextra)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
	AshBlossomTable=AshBlossomTable or {}
	table.insert(AshBlossomTable,e1)
end
s.listed_names={210385308}
function s.filter(c)
    return c:IsType(TYPE_FUSION) and c:IsRace(RACE_PYRO) and c:IsAttribute(ATTRIBUTE_WATER)
end
function s.fcheck(tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=1
end
function s.fextra(e,tp,mg)
	if Duel.IsEnvironment(210385308) then
		local eg=Duel.GetMatchingGroup(s.exfilter,tp,LOCATION_DECK,0,nil)
		if eg and #eg>0 then
			return eg,s.fcheck
		end
	end
	return nil
end
function s.exfilter(c)
	return c:IsMonster() and c:IsAbleToGrave()
end