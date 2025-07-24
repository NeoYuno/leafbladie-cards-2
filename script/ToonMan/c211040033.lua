--Magnet Fusion
local s,id=GetID()
function s.initial_effect(c)
	local e1=Fusion.CreateSummonEff(c,aux.FilterBoolFunction(Card.IsRace,RACE_ROCK),nil,s.fextra,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,s.extratg)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
end

function s.fcheck(tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=1
end
function s.fextra(e,tp,mg)
	local eg=Duel.GetMatchingGroup(s.exfilter,tp,LOCATION_DECK,0,nil)
	if eg and #eg>0 then
		return eg,s.fcheck
	end
end
function s.exfilter(c)
	return c:IsMonster() and c:IsSetCard(0xe9) and c:IsAbleToGrave()
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end 