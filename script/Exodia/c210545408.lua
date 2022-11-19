--Nekroz Contract with Exodia
local s,id=GetID()
function s.initial_effect(c)
    --Ritual
	local e1=Ritual.AddProcEqual(c,s.ritualfil,nil,nil,s.extrafil,s.extraop):SetCountLimit(1,id)
	if not AshBlossomTable then AshBlossomTable={} end
	table.insert(AshBlossomTable,e1)
	--Draw
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(s.drcon)
	e2:SetCost(s.drcost)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
end
s.listed_names={id}
s.listed_series={0xb4,0xde,0x40}
--Ritual
function s.ritualfil(c)
	return c:IsSetCard(0xb4) and c:IsRitualMonster()
end
function s.mfilter(c)
	return (c:IsSetCard(0xde) and c:HasLevel()) or (c:IsSetCard(0x40) and c:HasLevel()) and c:IsAbleToGraveAsCost()
end
function s.extrafil(e,tp,eg,ep,ev,re,r,rp,chk)
	return Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_DECK,0,nil)
end
function s.extraop(mat,e,tp,eg,ep,ev,re,r,rp,tc)
	local mat2=mat:Filter(Card.IsLocation,nil,LOCATION_DECK):Filter(s.mfilter,nil)
	mat:Sub(mat2)
	Duel.ReleaseRitualMaterial(mat)
	Duel.SendtoGrave(mat2,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
end
--Draw
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
function s.cfilter(c)
	return c:IsSetCard(0xb4) and c:IsRitualMonster() and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true)
end
function s.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost()
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil)
	g:AddCard(e:GetHandler())
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.tdfilter(c)
	return c:IsSetCard(0x40) and c:IsAbleToDeck()
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil)
	if chk==0 then return Duel.IsPlayerCanDraw(tp)
		and aux.SelectUnselectGroup(g,e,tp,1,g:GetClassCount(Card.GetCode),aux.dncheck,0) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,nil)
	if #g==0 then return end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,g:GetClassCount(Card.GetCode),s.rescon,1,tp,HINTMSG_TODECK)
	Duel.ConfirmCards(1-tp,sg)
	Duel.SendtoDeck(sg,nil,SEQ_DECKBOTTOM, REASON_EFFECT)
	local og=Duel.GetOperatedGroup()
	local ct=og:FilterCount(Card.IsLocation,nil,LOCATION_DECK)
	if ct>0 then
		Duel.SortDeckbottom(tp,tp,ct)
		Duel.BreakEffect()
		Duel.Draw(tp,ct,REASON_EFFECT)
	end
end
