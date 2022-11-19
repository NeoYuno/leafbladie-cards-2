--Red-Eyes Gamble
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DICE+CATEGORY_DRAW+CATEGORY_HANDES)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={0x3b}
function s.costfilter(c)
	return c:IsSetCard(0x3b) and (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsAbleToGraveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,e:GetHandler())
	Duel.SendtoGrave(g,REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp) end
	local ht=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
    local ct=Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsSetCard,0x3b),tp,LOCATION_ONFIELD,0,nil)
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(5-ht)
    Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,ct)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,5-ht)
    Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local ct=Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsSetCard,0x3b),tp,LOCATION_ONFIELD,0,nil)
    local d=math.min(Duel.TossDice(tp,ct))
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local ht=Duel.GetFieldGroupCount(p,LOCATION_HAND,0)
	if ht<5 and Duel.Draw(p,5-ht,REASON_EFFECT)>0 then
        Duel.BreakEffect()
        if d-1>0 then
            Duel.DiscardHand(tp,aux.TRUE,d-1,d-1,REASON_EFFECT+REASON_DISCARD)
		end
	end
end