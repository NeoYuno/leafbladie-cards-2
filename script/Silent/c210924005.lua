--Silent Ninja
local s,id=GetID()
function s.initial_effect(c)
	--Banish
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_POSITION)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
    --Banish itself
	local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.bancon)
	e2:SetTarget(s.bantg)
	e2:SetOperation(s.banop)
	c:RegisterEffect(e2)
    --Special Summon itself
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
s.listed_series={0xe7,0xe8}
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_MZONE)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,e:GetHandler(),1,0,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local tc=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,1,nil):GetFirst()
	if tc and Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)>0 then
        Duel.BreakEffect()
        Duel.ChangePosition(e:GetHandler(),POS_FACEUP_DEFENSE)
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		--Return the monster in the End Phase
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetLabelObject(tc)
		e1:SetCountLimit(1)
		e1:SetCondition(s.retcon)
		e1:SetOperation(s.retop)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():GetFlagEffect(id)>0
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ReturnToField(e:GetLabelObject())
end

function s.bancon(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return rc~=e:GetHandler() and re:IsActiveType(TYPE_MONSTER)
end
function s.bantg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return e:GetHandler():IsAbleToRemove() end
end
function s.thfilter(c)
    return (c:ListsArchetype(0xe7,0xe8) or c.LVset) and c:IsMonster() and not c:IsCode(id) and c:IsAbleToHand()
end
function s.banop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
	if not c:IsFaceup() or not c:IsRelateToEffect(e) then return end
	if Duel.Remove(c,POS_FACEUP,REASON_EFFECT+REASON_TEMPORARY)>0 and #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
        local sg=g:FilterSelect(tp,aux.NecroValleyFilter(s.thfilter),1,1,nil)
        Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetLabelObject(c)
		e1:SetCountLimit(1)
		e1:SetOperation(s.retop)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
    Duel.ReturnToField(e:GetLabelObject())
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:IsReason(REASON_BATTLE) or (rp~=tp and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp)))
		and c:IsPreviousLocation(LOCATION_ONFIELD)
end
function s.spfilter(c,e,tp)
	return (c:ListsArchetype(0xe7,0xe8) or c.LVset) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
		end
	end
end