--One-Eyed Infernity Resonator
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1)
    e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
    --Special Summon Restrictions
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(1,0)
	e2:SetTarget(s.splimit)
	c:RegisterEffect(e2)
    --Place on top of deck
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_HAND+LOCATION_MZONE)
    e3:SetCountLimit(1,id)
    e3:SetCost(s.cost)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
end
s.listed_names={id}
s.listed_series={0xb,0x57}
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	local ct=Duel.DiscardHand(tp,Card.IsDiscardable,1,2,REASON_COST+REASON_DISCARD)
    e:SetLabel(ct)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==0
        and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsNegatable),tp,0,LOCATION_MZONE,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local g=Duel.SelectMatchingCard(tp,aux.FaceupFilter(Card.IsNegatable),tp,0,LOCATION_MZONE,1,e:GetLabel(),nil)
        if #g>0 then
            for tc in aux.Next(g) do
                local e1=Effect.CreateEffect(c)
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetCode(EFFECT_SET_ATTACK_FINAL)
                e1:SetValue(0)
                e1:SetReset(RESET_EVENT+RESETS_STANDARD)
                tc:RegisterEffect(e1)
            end
        else
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_SET_ATTACK_FINAL)
            e1:SetValue(0)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            g:GetFirst():RegisterEffect(e1)
        end
    end
end

function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not (c:IsRace(RACE_DRAGON+RACE_FIEND) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_SYNCHRO)) and c:IsLocation(LOCATION_EXTRA)
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() end
	Duel.SendtoGrave(c,REASON_COST)
end
function s.filter(c)
	return (c:IsSetCard(0xb) or c:IsSetCard(0x57)) and not c:IsCode(id)
end
function s.drfilter(c)
    return c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc:IsLocation(LOCATION_DECK) then
		Duel.ShuffleDeck(tp)
		Duel.MoveSequence(tc,0)
		Duel.ConfirmDecktop(tp,1)
    else
        Duel.SendtoDeck(tc,nil,0,REASON_EFFECT)
	end
    local g=Duel.GetMatchingGroup(s.drfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
    local ct=g:GetClassCount(Card.GetCode)
	local t={}
	for i=1,ct do t[i]=i end
    if ct>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		if ct==1 then
			Duel.BreakEffect()
			Duel.Draw(tp,ct,REASON_EFFECT)
		else
			Duel.Hint(HINTMSG_NUMBER,tp,HINT_NUMBER)
			local ac=Duel.AnnounceNumber(tp,table.unpack(t))
			Duel.BreakEffect()
			Duel.Draw(tp,ac,REASON_EFFECT)
		end
    end
end