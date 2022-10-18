--Silent Golem
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
    --Destroy
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
    --Special Summon itself
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg2)
	e3:SetOperation(s.spop2)
	c:RegisterEffect(e3)
end
s.listed_series={0xe7,0xe8}
function s.spfilter(c,e,tp,ft)
	return (c:ListsArchetype(0xe7,0xe8) or c.LVset) and not c:IsCode(id) and (c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,true,false)))
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,ft)
	end
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp,ft):GetFirst()
	if sc then
		aux.ToHandOrElse(sc,tp,
			function(sc) return ft>0 and sc:IsCanBeSpecialSummoned(e,0,tp,true,false) end,
			function(sc) return Duel.SpecialSummon(sc,0,tp,tp,true,false,POS_FACEUP) end,
			aux.Stringid(id,0))
	end
end

function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return rc~=e:GetHandler() and re:IsActiveType(TYPE_MONSTER)
end
function s.desfilter(c,g)
	return g:IsContains(c)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local cg=e:GetHandler():GetColumnGroup()
	local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler(),cg)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local cg=c:GetColumnGroup()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c,cg)
		if #g>0 then
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end

function s.thfilter(c)
    return (c:ListsArchetype(0xe7,0xe8) or c.LVset) and c:IsMonster() and not c:IsCode(id) and c:IsAbleToHand()
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:IsReason(REASON_BATTLE) or (rp~=tp and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp)))
		and c:IsPreviousLocation(LOCATION_ONFIELD)
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if e:GetHandler():IsRelateToEffect(e) and Duel.SpecialSummon(e:GetHandler(),0,tp,1-tp,false,false,POS_FACEUP)>0
        and aux.SelectUnselectGroup(g,e,tp,1,2,aux.dpcheck(Card.GetRace),0) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
        local sg=aux.SelectUnselectGroup(g,e,tp,1,2,aux.dpcheck(Card.GetRace),1,tp,HINTMSG_ATOHAND)
        if #sg>0 and Duel.SendtoHand(sg,nil,REASON_EFFECT)>0 then
            Duel.ConfirmCards(1-tp,sg)
        end
	end
end