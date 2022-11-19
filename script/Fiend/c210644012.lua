--Mask of Fusion
Duel.LoadScript("c420.lua")
local s,id=GetID()
function s.initial_effect(c)
	local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_ADD_SETCODE)
	e0:SetRange(LOCATION_HAND+LOCATION_DECK+LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED)
    e0:SetValue(0x583)
    c:RegisterEffect(e0)
	--Activate
	local e1=Fusion.CreateSummonEff(c,s.fnfilter,Fusion.OnFieldMat(Card.IsAbleToDeck),s.fextra,Fusion.ShuffleMaterial)
	e1:SetCountLimit(1,id)
	c:RegisterEffect(e1)
    --Search
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
    e2:GetCategory(CATEGORY_TOHAND)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_PHASE+PHASE_END)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCondition(s.thcon)
    e2:SetCost(s.thcost)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
	if not GhostBelleTable then GhostBelleTable={} end
	table.insert(GhostBelleTable,e1)
end

--fusion materials
function s.fnfilter(c)
    return c:IsRace(RACE_FIEND) and c:GetLevel()==8
end
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(aux.NecroValleyFilter(Fusion.IsMonsterFilter(Card.IsFaceup,Card.IsAbleToDeck)),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
end

--Search
function s.thfilter(c,e)
	return c:IsMask() and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand() and c:IsCanBeEffectTarget(e)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    for _,te in ipairs({Duel.GetPlayerEffect(tp,EFFECT_LPCOST_CHANGE)}) do
		local val=te:GetValue()
		if val(te,e,tp,500)~=500 then return false end
	end
    return tp==Duel.GetTurnPlayer() and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e)
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		e:SetLabel(10)
		return e:GetHandler():IsAbleToRemoveAsCost()
	end
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_GRAVE,0,e:GetHandler(),e)
	local fg=g:GetClassCount(Card.GetCode)
	if chkc then return false end
	if chk==0 then
		if e:GetLabel()~=10 then return false end
		return #g>0 and Duel.CheckLPCost(tp,500)
	end
	local n=math.min(fg,Duel.GetLP(tp)//500)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
	local pay_list={}
	for p=1, n do
		if Duel.CheckLPCost(tp,500*p) then table.insert(pay_list,p) end
	end
	local pay=Duel.AnnounceNumber(tp,table.unpack(pay_list))
	Duel.PayLPCost(tp,pay*500)
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
	local sg=aux.SelectUnselectGroup(g,e,tp,pay,pay,aux.dncheck,1,tp,HINTMSG_ATOHAND)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,#sg,tp,LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		Duel.SendtoHand(g,tp,REASON_EFFECT)
	end
end