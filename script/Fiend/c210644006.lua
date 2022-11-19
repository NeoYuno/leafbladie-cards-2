--Volcano Golem
local s,id=GetID()
function s.initial_effect(c)
    --Cannot be normal summoned/set
	c:EnableUnsummonable()
	--Must be special summoned by a card effect
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(s.splimit)
	c:RegisterEffect(e1)
	--Special Summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_RELEASE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--Special Summon or take damage
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.phcon)
	e3:SetCost(s.phcost)
	e3:SetOperation(s.phop)
	c:RegisterEffect(e3)
	--Search or burn
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DAMAGE)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,{id,2})
	e4:SetCost(s.cost)
	e4:SetOperation(s.operation)
	c:RegisterEffect(e4)
end

--Must be special summoned by a card effect
function s.splimit(e,se,sp,st)
	return se:IsHasType(EFFECT_TYPE_ACTIONS)
end

--Special Summon
function s.sumfilter(c)
	return c:GetAttack()+c:GetDefense()
end
function s.rescon1(sg,e,tp,mg)
	Duel.SetSelectedCard(sg)
	return aux.ChkfMMZ(1)(sg,e,tp,mg) and sg:CheckWithSumGreater(s.sumfilter,3000)
end
function s.rescon2(sg,e,tp,mg)
	Duel.SetSelectedCard(sg)
	return aux.ChkfMMZ(1)(sg,e,1-tp,mg) and sg:CheckWithSumGreater(s.sumfilter,3000)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g1=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	local g2=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
	local b1=aux.SelectUnselectGroup(g1,e,tp,1,#g1,s.rescon1,0)
	local b2=aux.SelectUnselectGroup(g2,e,tp,1,#g2,s.rescon2,0)
	if chk==0 then return b1 or b2 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,e,tp) end
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    local g1=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	local g2=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
	local b1=aux.SelectUnselectGroup(g1,e,tp,1,#g1,s.rescon1,0)
	local b2=aux.SelectUnselectGroup(g2,e,tp,1,#g2,s.rescon2,0)
	local dtab={}
	if b1 then
		table.insert(dtab,aux.Stringid(id,6))
	end
	if b2 then
		table.insert(dtab,aux.Stringid(id,7))
	end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_RESOLVEEFFECT)
	local op=Duel.SelectOption(tp,table.unpack(dtab))+1
	if not b1 then op=2 end
	if not b2 then op=1 end
	if op==1 then
        local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
		if chk==0 then return aux.SelectUnselectGroup(g,e,tp,1,#g,s.rescon1,0) end
		local rg=aux.SelectUnselectGroup(g,e,tp,1,#g,s.rescon1,1,tp,HINTMSG_RELEASE,s.rescon1,nil,false)
		if Duel.Release(rg,REASON_EFFECT)~=0 and c:IsRelateToEffect(e) then
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		end
    elseif op==2 then
        local g=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
		if chk==0 then return aux.SelectUnselectGroup(g,e,tp,1,#g,s.rescon2,0) end
		local rg=aux.SelectUnselectGroup(g,e,tp,1,#g,s.rescon2,1,tp,HINTMSG_RELEASE,s.rescon2,nil,false)
		if Duel.Release(rg,REASON_EFFECT)~=0 and c:IsRelateToEffect(e) then
			Duel.SpecialSummon(c,0,tp,1-tp,false,false,POS_FACEUP)
		end
    end
end

--Special Summon or take damage
function s.phcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end
function s.phcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckLPCost(tp,500) end
    Duel.PayLPCost(tp,500)
end
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_FIEND) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.phop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	if #g>0 then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:Select(tp,1,1,nil)
		if #sg>0 then
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	else Duel.Damage(tp,1000,REASON_EFFECT) end
end

--Search or burn
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,100) end
	local lp=Duel.GetLP(tp)
	local m=math.floor(math.min(lp,3000)/100)
	local t={}
	for i=1,m do
		t[i]=i*100
	end
	local ac=Duel.AnnounceNumber(tp,table.unpack(t))
	Duel.PayLPCost(tp,ac)
	e:SetLabel(ac)
end
function s.filter(c,costvalue)
	return c:IsRace(RACE_FIEND) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAttack(costvalue) and c:IsAbleToHand()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local costvalue=e:GetLabel()
	local op=Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4))
	if op==0 then
		local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil,costvalue)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,costvalue)
		if #sg>0 then
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,sg)
		end
	else
		Duel.Damage(1-tp,costvalue,REASON_EFFECT)
	end
end
