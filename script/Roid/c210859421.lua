--Poweroid Fusion
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Fusion.CreateSummonEff(c,aux.FilterBoolFunction(Card.IsSetCard,0x16),nil,s.fextra,nil,nil,s.stage2,nil,nil,nil,nil,nil,nil,nil,s.extratg)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
end
s.listed_series={0x16}
function s.fcheck(tp,sg,fc)
    if fc:IsCode(5368615) then
        return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)<=2
	elseif fc:IsCode(98927491) then
		return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)<=2
	elseif fc:IsCode(36256625) then
		return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)<=3
	elseif fc:IsCode(3897065) then
		return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)<=4
	elseif fc:IsCode(32752319) then
		return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)<=2
	elseif fc:IsCode(81003500) then
		return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)<=2
	elseif fc:IsCode(511002246) then
		return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)<=3
	elseif fc:IsCode(511002244) then
		return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)<=3
	elseif fc:IsCode(511002245) then
		return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)<=3
	else
        return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)==0
    end
end
function s.fextra(e,tp,mg)
	local eg=Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToGrave),tp,LOCATION_DECK+LOCATION_EXTRA,0,nil)
    if eg and #eg>0 then
        return eg,s.fcheck
	end
	return nil
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,0,tp,LOCATION_DECK+LOCATION_EXTRA)
end
function s.stage2(e,tc,tp,mg,chk)
	local c=e:GetHandler()
	if chk==1 then
		if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(aux.Stringid(id,0))
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
			e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
			e1:SetTargetRange(1,0)
			e1:SetTarget(s.splimit)
			e1:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e1,tp)
		end
	end
end
function s.splimit(e,c)
	return not c:IsRace(RACE_MACHINE)
end