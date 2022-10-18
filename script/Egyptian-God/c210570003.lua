--Hyper GOD Energy
local s,id=GetID()
local COUNTER_DIVINE=0x1903
function s.initial_effect(c)
    c:SetUniqueOnField(1,0,id)
    --Search on activation
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
    --Cannot be used as material for a summon, nor be tributed
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsOriginalRace,RACE_DIVINE))
	e2:SetValue(1)
	c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
    c:RegisterEffect(e3)
    local e4=e2:Clone()
    e4:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
    c:RegisterEffect(e4)
    local e5=e2:Clone()
    e5:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
    c:RegisterEffect(e5)
    local e6=e2:Clone()
    e6:SetCode(EFFECT_UNRELEASABLE_SUM)
    c:RegisterEffect(e6)
    local e7=e2:Clone()
    e7:SetCode(EFFECT_UNRELEASABLE_NONSUM)
    c:RegisterEffect(e7)
    local e8=e2:Clone()
    e8:SetCode(EFFECT_UNRELEASABLE_EFFECT)
    c:RegisterEffect(e8)
    --Place DIVINE Counters
	local e9=Effect.CreateEffect(c)
	e9:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e9:SetProperty(EFFECT_FLAG_DELAY)
	e9:SetRange(LOCATION_SZONE)
	e9:SetCode(EVENT_SUMMON_SUCCESS)
	e9:SetCondition(s.ctcon)
	e9:SetOperation(s.ctop)
	c:RegisterEffect(e9)
	local e10=e9:Clone()
	e10:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e10)
    --Search (ignition)
    local e11=Effect.CreateEffect(c)
    e11:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
    e11:SetType(EFFECT_TYPE_IGNITION)
    e11:SetRange(LOCATION_SZONE)
    e11:SetCost(s.thcost)
    e11:SetTarget(s.thtg)
    e11:SetOperation(s.thop)
    c:RegisterEffect(e11)
    --register names
	aux.GlobalCheck(s,function()
		s.card_list={}
		s.card_list[0]={}
		s.card_list[1]={}
		aux.AddValuesReset(function()
			s.card_list[0]={}
			s.card_list[1]={}
		end)
	end)
end
s.listed_names={10000020,10000000,CARD_RA,id}
s.counter_list={COUNTER_DIVINE}
--Search on activation
function s.filter(c)
	return c:IsCode(210570001,210570002,210651801,210651802,210651803,79387392,7373632,5253985,39913299,269012,59094601,79339613) 
		and not c:IsCode(id) and c:IsAbleToHand()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end
--Place DIVINE Counters
function s.ctfilter(c,tp)
	return c:IsFaceup() and c:IsOriginalRace(RACE_DIVINE)
end
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.ctfilter,1,nil,tp)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(COUNTER_DIVINE,eg:FilterCount(s.ctfilter,nil))
end
--Search (ignition)
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,COUNTER_DIVINE,1,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,COUNTER_DIVINE,1,REASON_COST)
end
function s.chkfilter(c,tp)
    return c:IsFaceup() and c:IsCode(10000020,10000000,CARD_RA) and not table.includes(s.card_list[tp],c:GetCode())
        and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,c)
end
function s.thfilter(c,tc)
    return c:ListsCode(tc:GetCode()) and not c:IsCode(id) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.chkfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
    local tc=Duel.SelectMatchingCard(tp,s.chkfilter,tp,LOCATION_MZONE,0,1,1,nil,tp):GetFirst()
    table.insert(s.card_list[tp],tc:GetCode())
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local sc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,tc):GetFirst()
    if sc then
        Duel.SendtoHand(sc,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,sc)
    end
end

if not table.includes then
	--binary search
	function table.includes(t,val)
		if #t<1 then return false end
		if #t==1 then return t[1]==val end --saves sorting for efficiency
		table.sort(t)
		local left=1
		local right=#t
		while left<=right do
			local middle=(left+right)//2
			if t[middle]==val then return true
			elseif t[middle]<val then left=middle+1
			else right=middle-1 end
		end
		return false
	end
end