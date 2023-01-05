--Crystal Hall
local s,id=GetID()
function s.initial_effect(c)
    --Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--"Ancient City - Rainbow Ruin" effect
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(id)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetCondition(s.condition)
	c:RegisterEffect(e2)
	--"Advanced Dark" effect
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_ADD_SETCODE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(LOCATION_ALL,0)
	e4:SetTarget(aux.TargetBoolFunction(Card.IsOriginalSetCard,0x1034))
	e4:SetValue(0x5034)
	c:RegisterEffect(e4)
	--Destruction replacement
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EFFECT_DESTROY_REPLACE)
	e5:SetRange(LOCATION_SZONE)
	e5:SetTarget(s.reptg)
	e5:SetValue(s.repval)
	c:RegisterEffect(e5)
	--Special Summon
	local e6=Effect.CreateEffect(c)
	e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetCountLimit(1)
	e6:SetRange(LOCATION_SZONE)
	e6:SetCondition(s.spcon)
	e6:SetTarget(s.sptg)
	e6:SetOperation(s.spop)
	c:RegisterEffect(e6)
end
s.listed_series={0x34,0x1034,0x2034}
s.listed_names={34487429,12644061}
--[Activate]
function s.cfilter(c)
	return c:IsCode(34487429,12644061) and not c:IsForbidden()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_DECK,0,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
		local tg1=g:Select(tp,1,1,nil)
		local op=Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4))
		if op==0 then
			Duel.MoveToField(tg1:GetFirst(),tp,tp,LOCATION_FZONE,POS_FACEUP,true)
			g:Remove(Card.IsCode,nil,tg1:GetFirst():GetCode())
			if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
				local tg2=g:Select(tp,1,1,nil)
				Duel.MoveToField(tg2:GetFirst(),tp,1-tp,LOCATION_FZONE,POS_FACEUP,true)
			end
		else
			Duel.MoveToField(tg1:GetFirst(),tp,1-tp,LOCATION_FZONE,POS_FACEUP,true)
			g:Remove(Card.IsCode,nil,tg1:GetFirst():GetCode())
			if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
				local tg2=g:Select(tp,1,1,nil)
				Duel.MoveToField(tg2:GetFirst(),tp,tp,LOCATION_FZONE,POS_FACEUP,true)
			end
		end
	end
end
--["Ancient City - Rainbow Ruin" effect]
function s.condition(e)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,34487429),e:GetHandlerPlayer(),LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
--[Destruction replacement]
function s.repfilter(c,tp)
	return c:IsLocation(LOCATION_ONFIELD) and c:IsControler(tp) and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
function s.tgfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1034) and c:IsAbleToGrave()
	    and not c:IsStatus(STATUS_DESTROY_CONFIRMED+STATUS_BATTLE_DESTROYED)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp)
		and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local sg=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
		Duel.Hint(HINT_CARD,0,id)
		sg:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,true)
		Duel.SendtoGrave(sg,REASON_EFFECT+REASON_REPLACE)
		return true
	else return false end
end
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
--[Special Summon]
function s.confilter(c)
	return c:IsOriginalSetCard(0x1034) and (not c:IsOnField() or c:IsFaceup())
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.confilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,nil)
	local ct=g:GetClassCount(Card.GetCode)
	return ct>6
end
function s.filter(c,e,tp)
	return c:IsSetCard(0x2034) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_HAND+LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end