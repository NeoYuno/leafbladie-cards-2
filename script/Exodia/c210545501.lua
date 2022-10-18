--Ritual of the Ultimate Forbidden Lord
local WIN_REASON_RUFL=0x23
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={id,13893596}
s.listed_series={0x40}
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_MONSTER)
    if chk==0 then return #g>0 end
    Duel.SendtoDeck(g,tp,2,REASON_COST)
end
function s.tgfilter(c)
	return c:IsSetCard(0x40) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
function s.spfilter(c,e,tp)
    return c:IsCode(13893596) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.rescon(sg,e,tp,mg)
	return sg:GetClassCount(Card.GetLocation)==#sg
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil)
	if chk==0 then return aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0)
        and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,2,tp,LOCATION_HAND+LOCATION_DECK)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_HAND+LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil)
    local rg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_TOGRAVE)
    if Duel.SendtoGrave(rg,REASON_EFFECT)>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
        if Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)>0 then
		    --Unaffected by opponent's card effects
			local e1=Effect.CreateEffect(tc)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_IMMUNE_EFFECT)
			e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
			e1:SetRange(LOCATION_MZONE)
			e1:SetValue(s.efilter)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			--Cannot be destroyed by battle once per turn
			local e2=Effect.CreateEffect(tc)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
			e2:SetRange(LOCATION_MZONE)
			e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
			e2:SetCountLimit(1)
			e2:SetValue(s.valcon)
			tc:RegisterEffect(e2)
			--Redirect to deck
			local e3=Effect.CreateEffect(tc)
			e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e3:SetCode(EVENT_TO_GRAVE)
			e3:SetRange(LOCATION_MZONE)
			e3:SetCondition(s.retcon)
			e3:SetOperation(s.retop)
			tc:RegisterEffect(e3)
			--Win
			local e4=Effect.CreateEffect(tc)
			e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e4:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_DELAY)
			e4:SetCode(EVENT_TO_GRAVE)
			e4:SetRange(LOCATION_MZONE)
			e4:SetOperation(s.winop)
			tc:RegisterEffect(e4)
			local e5=e4:Clone()
			e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
			e5:SetCode(EVENT_SPSUMMON_SUCCESS)
			tc:RegisterEffect(e5)
        end
    end
end
function s.efilter(e,re)
	return e:GetOwnerPlayer()==1-re:GetOwnerPlayer()
end
function s.valcon(e,re,r,rp)
	return (r&REASON_BATTLE)~=0
end
function s.cfilter(c)
	return c:IsSetCard(0x40) and c:IsMonster()
end
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil)
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	for tc in aux.Next(eg) do
		if not (re and re:GetHandler()==e:GetHandler()) then
			Duel.SendtoDeck(tc,nil,2,REASON_EFFECT+REASON_REDIRECT)
		end
	end
end

function s.filter(c)
	return c:IsSetCard(0x40) and c:IsMonster()
end
function s.winop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_GRAVE,0,nil)
	if g:GetClassCount(Card.GetCode)==5 then
		Duel.Win(tp,WIN_REASON_RUFL)
	end
end
