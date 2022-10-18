--Supreme Queen Dragun
local s,id=GetID()
function s.initial_effect(c)
	--Xyz summon
	Xyz.AddProcedure(c,nil,8,2)
	c:EnableReviveLimit()
    --Special summon
    local e0=Effect.CreateEffect(c)
    e0:SetDescription(aux.Stringid(id,0))
    e0:SetType(EFFECT_TYPE_FIELD)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e0:SetCode(EFFECT_SPSUMMON_PROC)
    e0:SetRange(LOCATION_EXTRA)
    e0:SetCountLimit(1, id)
    e0:SetCondition(s.spcon)
    e0:SetOperation(s.spop)
    e0:SetValue(SUMMON_TYPE_XYZ+1)
    c:RegisterEffect(e0)
	--Indes
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_DRAGON))
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetValue(s.indval)
	c:RegisterEffect(e2)
	--Detach
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.tg)
	e3:SetOperation(s.op)
	c:RegisterEffect(e3)
end
function s.filter1(c)
    return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER) and c:HasLevel() and not c:IsLevel(8) and c:IsCanBeXyzMaterial() and not (c:IsHasEffect(EFFECT_CANNOT_BE_XYZ_MATERIAL) or c:IsHasEffect(EFFECT_XYZ_MAT_RESTRICTION))
end
function s.filter2(c)
    return c:IsFaceup() and c:IsLevel(8) and c:IsCanBeXyzMaterial() and not (c:IsHasEffect(EFFECT_CANNOT_BE_XYZ_MATERIAL) or c:IsHasEffect(EFFECT_XYZ_MAT_RESTRICTION))
end
function s.spcon(e,c,sc)
    if c==nil then return true end
    local tp=c:GetControler()
    local rg1=Duel.GetMatchingGroup(s.filter1,tp,LOCATION_MZONE,0,nil)
    local rg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_MZONE,0,nil)
    return aux.SelectUnselectGroup(rg1,e,tp,1,1,nil,0,c) 
	    and aux.SelectUnselectGroup(rg2,e,tp,1,1,nil,0,c)
        and Duel.GetLocationCountFromEx(tp,tp,c,sc)>-2
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
    local rg1=Duel.GetMatchingGroup(s.filter1,tp,LOCATION_MZONE,0,nil)
    local rg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_MZONE,0,nil)
    local g1=aux.SelectUnselectGroup(rg1,e,tp,1,1,nil,1,tp,HINTMSG_XMATERIAL)
    if #g1>0 then
        if Duel.GetLocationCountFromEx(tp,tp,c,sc)<=-2 then return false end
        local g2=aux.SelectUnselectGroup(rg2,e,tp,1,1,nil,1,tp,HINTMSG_XMATERIAL)
        g1:Merge(g2)
		c:SetMaterial(g1)
        Duel.Overlay(c,g1)
    end
end
function s.indval(e,re,tp)
	return e:GetHandlerPlayer()==1-tp
end
function s.thfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsAbleToHand()
end
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.rescon(sg,e,tp,mg)
	return sg:FilterCount(Card.IsRace,nil,RACE_DRAGON)<=1 and sg:FilterCount(Card.IsRace,nil,RACE_SPELLCASTER)<=1
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=c:GetOverlayGroup()
	local rc=0
	if Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) then rc=rc | RACE_DRAGON end
	if Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) then rc=rc | RACE_SPELLCASTER end
	if Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) then rc=rc | RACE_DRAGON+RACE_SPELLCASTER end
	if chk==0 then return rc>0 and g:IsExists(Card.IsRace,1,nil,rc) end
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local g=c:GetOverlayGroup()
	local rc=0
	if Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) then rc=rc | RACE_DRAGON end
	if Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) then rc=rc | RACE_SPELLCASTER end
	if Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) then rc=rc | RACE_DRAGON+RACE_SPELLCASTER end
	if rc==0 then return end
	local sg=aux.SelectUnselectGroup(g:Filter(Card.IsRace,nil,rc),e,tp,1,2,s.rescon,1,tp,HINTMSG_XMATERIAL)
	Duel.SendtoGrave(sg,REASON_EFFECT)
	Duel.RaiseSingleEvent(c,EVENT_DETACH_MATERIAL,e,0,0,0,0)
	local og=Duel.GetOperatedGroup()
	Duel.BreakEffect()
	if #og==1 and og:GetFirst():IsRace(RACE_DRAGON) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
	if #og==1 and og:GetFirst():IsRace(RACE_SPELLCASTER) then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		local tc=g:GetFirst()
		if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
		end
		Duel.SpecialSummonComplete()
	end
	if #og==2 and og:FilterCount(Card.IsRace,nil,RACE_DRAGON)==1 and og:FilterCount(Card.IsRace,nil,RACE_SPELLCASTER)==1 then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
