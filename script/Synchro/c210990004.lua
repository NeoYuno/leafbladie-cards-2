--Beautiful Life
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c,nil,s.eqfilter)
    --Special Summon from deck
    local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_LVCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--Special Summon from Extra Deck/GY
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg2)
	e3:SetOperation(s.spop2)
	c:RegisterEffect(e3)
	--level change
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCondition(s.lvcon)
	e4:SetCost(aux.bfgcost)
	e4:SetOperation(s.lvop)
	c:RegisterEffect(e4)
end
s.listed_names={25165047}
s.listed_series={0x26}
function s.eqfilter(c)
	return c:IsSetCard(0x26) or c:IsCode(2403771,68084557)
end
function s.spfilter(c,e,tp,lv)
	return c:IsSetCard(0x26) and c:GetLevel()<lv and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local ec=e:GetHandler():GetEquipTarget()
		if not ec or Duel.GetLocationCount(tp,LOCATION_MZONE)==0 then return false end
		return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,ec:GetLevel())
    end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local ec=c:GetEquipTarget()
	if not ec or Duel.GetLocationCount(tp,LOCATION_MZONE)==0 then return false end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,ec:GetLevel())
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 and ec:IsFaceup() then
        local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(-g:GetFirst():GetOriginalLevel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		ec:RegisterEffect(e1)
	end
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetPreviousEquipTarget()
	return c:IsPreviousPosition(POS_FACEUP) and c:IsReason(REASON_LOST_TARGET) and ec and ec:IsReason(REASON_SYNCHRO) and ec:GetReasonCard():IsRace(RACE_DRAGON)
end
function s.tgfilter(c,e,tp)
	return c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spfilter2(c,e,tp)
	return c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tgfilter(chkc,e,tp) end
	if chk==0 then return (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 or Duel.GetLocationCountFromEx(tp)>0)
		and Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	e:SetProperty(EFFECT_FLAG_CARD_TARGET)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.filter(c)
	return c:GetSequence()>=5
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	--Cannot Special Summon from the Extra Deck, except Synchro Monsters
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e0:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e0:SetTargetRange(1,0)
	e0:SetTarget(s.splimit)
	e0:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e0,tp)
	--Clock Lizard check
	aux.addTempLizardCheck(c,tp,s.lizfilter)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)==1 then
		Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP,0x60)
	else
		Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP)
	end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	sc:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	sc:RegisterEffect(e2)
	Duel.SpecialSummonComplete()
	if tc and tc:IsCanBeSpecialSummoned(e,0,tp,false,false) then
		Duel.BreakEffect()
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		local spc=Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetTarget(s.limittg)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetLabel(spc)
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_LEFT_SPSUMMON_COUNT)
		e2:SetValue(s.countval)
		Duel.RegisterEffect(e2,tp)
		aux.RegisterClientHint(c,nil,tp,1,0,aux.Stringid(id,1),nil)
	end
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsType(TYPE_SYNCHRO) and c:IsLocation(LOCATION_EXTRA)
end
function s.lizfilter(e,c)
	return not c:IsOriginalType(TYPE_SYNCHRO)
end
function s.limittg(e,c,tp)
	local sp=Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)
	return sp-e:GetLabel()>=1
end
function s.countval(e,re,tp)
	local sp=Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)
	if sp-e:GetLabel()>=1 then return 0 else return 1-sp+e:GetLabel() end
end

function s.lvcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,25165047),tp,LOCATION_MZONE,0,1,nil)
end
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local lv=Duel.AnnounceLevel(tp,1,2)
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsType,TYPE_SYNCHRO),tp,LOCATION_MZONE,0,nil)
	g:Remove(aux.FaceupFilter(Card.IsCode,25165047),nil)
	local tc=g:GetFirst()
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(lv)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end