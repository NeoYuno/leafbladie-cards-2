--Freya, Lady of the Aesir
local s,id=GetID()
function s.initial_effect(c)
	--link summon
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x42),3,3)
    --Banish and summon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
    --Must attack
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCode(EFFECT_MUST_ATTACK)
    e2:SetCondition(s.macon)
	c:RegisterEffect(e2)
    --Double damage
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e3:SetCode(EFFECT_CHANGE_DAMAGE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetTargetRange(0,1)
    e3:SetCondition(s.ddcon)
    e3:SetValue(s.val)
    c:RegisterEffect(e3)
    --Special summon
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1,id)
	e4:SetCondition(s.spcon2)
	e4:SetTarget(s.sptg2)
	e4:SetOperation(s.spop2)
	c:RegisterEffect(e4)
end
s.listed_series={0x42,0x4b}
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.remcheck1(sg,e,tp,mg)
	return sg:GetClassCount(Card.GetLocation)==#sg and sg:GetSum(Card.GetLevel)==10
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,sg)
end
function s.remcheck2(sg,e,tp,mg)
	return sg:GetSum(Card.GetLevel)==10 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,sg)
end
function s.filter(c)
    return c:IsSetCard(0x42) and c:IsType(TYPE_MONSTER) and c:HasLevel() and c:IsAbleToRemove()
end
function s.spfilter(c,e,tp)
    return c:IsSetCard(0x4b) and c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local fg=Group.CreateGroup()
	for i,pe in ipairs({Duel.IsPlayerAffectedByEffect(tp,210458409)}) do
		fg:AddCard(pe:GetHandler())
	end
	if chk==0 then
		local g1=Duel.GetMatchingGroup(s.filter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,nil)
		local g2=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
		return (aux.SelectUnselectGroup(g1,e,tp,3,3,s.remcheck1,0)
		    or (#fg>0 and aux.SelectUnselectGroup(g2,e,tp,3,3,s.remcheck2,0)))
            and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,3,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local fg=Group.CreateGroup()
	for i,pe in ipairs({Duel.IsPlayerAffectedByEffect(tp,210458409)}) do
		fg:AddCard(pe:GetHandler())
	end
	local g1=Duel.GetMatchingGroup(s.filter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,nil)
	local g2=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
	local rg=nil
	if #fg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		rg=aux.SelectUnselectGroup(g2,e,tp,3,3,s.remcheck2,1,tp,HINTMSG_REMOVE)
		fg:GetFirst():RegisterFlagEffect(210458409,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
	else
		rg=aux.SelectUnselectGroup(g1,e,tp,3,3,s.remcheck1,1,tp,HINTMSG_REMOVE)
	end
	if #rg==3 and Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)>0 then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
		Duel.SpecialSummon(sg,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)
		sg:GetFirst():CompleteProcedure()
	end
end
function s.confilter(c)
    return c:IsSetCard(0x4b) and c:IsType(TYPE_SYNCHRO) and c:IsFaceup()
end
function s.macon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local g=c:GetLinkedGroup()
	return g:IsExists(s.confilter,1,nil)
end
function s.ddcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    local g=c:GetLinkedGroup()
	return g:IsExists(s.confilter,2,nil) and g:GetClassCount(Card.GetCode)>=2
end
function s.val(e,re,val,r,rp,rc)
	return val*2
end
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    local g=c:GetLinkedGroup()
	return g:IsExists(s.confilter,3,nil) and g:GetClassCount(Card.GetCode)==3
end
function s.spfilter2(c,e,tp)
	return c:IsSetCard(0x42) and not c:IsCode(id) and (c:IsCanBeSpecialSummoned(e,0,tp,true,false,POS_FACEUP_DEFENSE)
        or c:IsCanBeSpecialSummoned(e,0,tp,true,false,POS_FACEUP_DEFENSE,1-tp))
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetMatchingGroup(s.spfilter2,tp,LOCATION_HAND+LOCATION_DECK,0,nil,e,tp)
		return (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 or Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0) 
            and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
			and g:GetClassCount(Card.GetCode)>=2
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND+LOCATION_DECK)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	local g=Duel.GetMatchingGroup(s.spfilter2,tp,LOCATION_HAND+LOCATION_DECK,0,nil,e,tp)
	if #g>=2 and g:GetClassCount(Card.GetCode)>=2 then
		local sg=aux.SelectUnselectGroup(g,e,tp,2,2,aux.dncheck,1,tp,HINTMSG_SPSUMMON)
        for tc in aux.Next(sg) do
            local s1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
            local s2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
            local op=0
            Duel.Hint(HINT_SELECTMSG,tp,0)
            if s1 and s2 then op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
            elseif s1 then op=Duel.SelectOption(tp,aux.Stringid(id,1))
            elseif s2 then op=Duel.SelectOption(tp,aux.Stringid(id,2))+1
            else return end
            if op==0 then Duel.SpecialSummonStep(tc,0,tp,tp,true,false,POS_FACEUP_DEFENSE)
            else Duel.SpecialSummonStep(tc,0,tp,1-tp,true,false,POS_FACEUP_DEFENSE) end
            --Cannot be used as link material
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetDescription(3312)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
            e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
            e1:SetValue(1)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e1,true)
        end
        Duel.SpecialSummonComplete()
	end
end