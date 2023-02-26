--Twinkling Pentastars
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetCost(s.cost)
	e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
function s.costfilter(c)
	return c:IsLevel(5) and c:IsMonster() and c:IsAbleToGraveAsCost() 
end
function s.tgfilter(c)
	return c:IsLevel(5) and c:IsMonster() and c:IsAbleToGrave() and (c:IsFaceup() or c:IsFacedown())
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tgfilter(chkc)
	end
	local b1=e:GetLabel()==100 and Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil)
	local b2=Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,0,1,nil)
	if chk==0 then
		local res=b1 or b2
		e:SetLabel(0)
		return res and Duel.IsPlayerCanDraw(tp,2)
	end
	e:SetLabel(0)
	local op=Duel.SelectEffect(tp,{b1,aux.Stringid(id,0)},{b2,aux.Stringid(id,1)})
	if op==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,nil)
		if not Duel.SendtoGrave(g,REASON_COST) then return end
        Duel.SetTargetPlayer(tp)
        Duel.SetTargetParam(2)
        Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	else
        e:SetProperty(EFFECT_FLAG_CARD_TARGET)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil)
        Duel.SetTargetPlayer(tp)
        Duel.SetTargetParam(2)
        Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
        Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,0,tp,1)
	end
	e:SetLabel(op)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
    local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if op==1 then
        Duel.Draw(p,d,REASON_EFFECT)
	elseif op==2 then
        local tc=Duel.GetFirstTarget()
        if tc and Duel.Draw(p,d,REASON_EFFECT)>0 then
            Duel.BreakEffect()
            Duel.SendtoGrave(tc,REASON_EFFECT)
        end
    end
end