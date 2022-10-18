--Volcanic Cyclone
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={0xb9}
function s.filter(c)
	return c:IsRace(RACE_PYRO) and c:IsAbleToGrave()
end
function s.bafilter(c)
	return c:IsFaceup() and c:IsSetCard(0xb9)
end
function s.spcheck(sg,e,tp,mg)
    if Duel.IsExistingMatchingCard(s.bafilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil) then
        return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)==1
    else
        return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)==0
    end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_HAND+LOCATION_DECK,0,nil)
    local fg=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler(),TYPE_SPELL+TYPE_TRAP)
	if chk==0 then return #g>0 and #fg>0 and aux.SelectUnselectGroup(g,e,tp,1,#fg,s.spcheck,0) end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_HAND+LOCATION_DECK,0,nil)
	local fg=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler(),TYPE_SPELL+TYPE_TRAP)
	if #g*#fg==0 then return end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,#fg,s.spcheck,1,tp,HINTMSG_TOGRAVE)
	local oc=Duel.SendtoGrave(sg,REASON_EFFECT)
	if oc==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local sg2=fg:Select(tp,oc,oc,nil)
    Duel.HintSelection(sg2)
	if Duel.Destroy(sg2,REASON_EFFECT)>0 then
        Duel.Damage(1-tp,#sg2*500,REASON_EFFECT)
        local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetLabel(#sg)
		e1:SetOperation(s.drop)
		Duel.RegisterEffect(e1,tp)
    end
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	Duel.Draw(tp,e:GetLabel(),REASON_EFFECT)
end