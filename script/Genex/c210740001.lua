--Genex Ally Hexagram
local s,id=GetID()
function s.initial_effect(c)
	--Synchro Summon
	c:EnableReviveLimit()
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)
	--Attribute change
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ADD_ATTRIBUTE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.attval)
	c:RegisterEffect(e1)
	--Unaffected by activated effect
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x2))
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetValue(s.unaval)
	c:RegisterEffect(e2)
	--ATK up
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x2))
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetValue(s.atkval)
	c:RegisterEffect(e3)
	--Attribute chnage 2
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id)
	e4:SetCost(s.atchcost)
	e4:SetTarget(s.atchtg)
	e4:SetOperation(s.atchop)
	c:RegisterEffect(e4)
end
s.listed_series={0x2}
--Attribute change
function s.attfilter(c)
    return c:IsSetCard(0x2) and c:IsMonster()
end
function s.attval(e,c)
	local att=0
	local g=Duel.GetMatchingGroup(s.attfilter,e:GetHandlerPlayer(),LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	for tc in aux.Next(g) do
		att=att|tc:GetAttribute()
	end
	return att
end
--Unaffected by activated effects
function s.unaval(e,te)
	local tc=te:GetOwner()
	local att=0
	local g=Duel.GetMatchingGroup(s.attfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)
	for tc in aux.Next(g) do
		att=att|tc:GetAttribute()
	end
	return tc:GetAttribute()&att>0 and te:GetOwnerPlayer()~=e:GetHandlerPlayer() and te:IsActiveType(TYPE_MONSTER) and te:IsActivated()
end
--ATK up
function s.atkval(e,c)
	local g=Duel.GetMatchingGroup(Card.IsType,e:GetHandlerPlayer(),LOCATION_MZONE+LOCATION_GRAVE,0,nil,TYPE_MONSTER)
	return g:GetClassCount(Card.GetAttribute)*300
end
--Attribute chnage 2
function s.spfilter(c,e,tp,att)
	return c:IsSetCard(0x2) and c:IsAttribute(att) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.atchcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
function s.atchtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chkc then return chkc:GetLocation()==LOCATION_MZONE and chkc:IsControler(tp) end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,c)
end
function s.atchop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local att=0
	if not tc:IsFaceup() or not tc:IsRelateToEffect(e) then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ADD_ATTRIBUTE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.attval2)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	if not tc:RegisterEffect(e1) then return end
	for gc in aux.Next(Duel.GetMatchingGroup(Card.IsMonster,tp,LOCATION_MZONE,0,nil)) do
		att=att|gc:GetAttribute()|tc:GetAttribute()
	end
	if att>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp,att)
	    and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp,att)
		if #g<=0 then return end
		Duel.BreakEffect()
		Duel.SpecialSummon(g:GetFirst(),0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.attval2(e,c)
	local att=0
	local g=Duel.GetMatchingGroup(Card.IsMonster,e:GetHandlerPlayer(),LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,nil)
	for tc in aux.Next(g) do
		att=att|tc:GetAttribute()
	end
	return att
end