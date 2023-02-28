--Forbidden Requiem
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
    --Foolish Extra Deck
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TOGRAVE)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCost(s.tgcost)
    e2:SetTarget(s.tgtg)
    e2:SetOperation(s.tgop)
    c:RegisterEffect(e2)
end
s.listed_names={18175965}
s.listed_series={0x52}
function s.thfilter(c)
	return c:IsSetCard(0x52) and c:IsMonster() and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_HAND+LOCATION_ONFIELD)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local hg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #hg>0 and Duel.SendtoHand(hg,nil,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-tp,hg)
		Duel.ShuffleHand(tp)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local dg=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil)
		if #dg>0 then
			Duel.BreakEffect()
			Duel.Destroy(dg,REASON_EFFECT)
		end
	end
end

function s.cfilter(c)
	return c:IsSetCard(0x52) and c:IsMonster() and c:IsAbleToGraveAsCost() and (c:IsLocation(LOCATION_HAND+LOCATION_DECK) or c:IsFaceup())
end
function s.check(sg,e,tp,mg)
	return sg:GetClassCount(Card.GetAttribute)==#sg
end
function s.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    local Dscythe=Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,18175965),tp,LOCATION_MZONE,0,1,nil)
    local loc=LOCATION_HAND+LOCATION_ONFIELD
    if Dscythe then loc=loc+LOCATION_DECK end
    local rg=Duel.GetMatchingGroup(s.cfilter,tp,loc,0,nil)
	if chk==0 then return c:IsAbleToRemoveAsCost() and aux.SelectUnselectGroup(rg,e,tp,1,#rg,s.check,0) end
    if Duel.Remove(c,POS_FACEUP,REASON_COST)>0 then
        local g=aux.SelectUnselectGroup(rg,e,tp,1,#rg,s.check,1,tp,HINTMSG_TOGRAVE)
        Duel.BreakEffect()
        Duel.SendtoGrave(g,REASON_COST)
    end
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_EXTRA)>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,1-tp,LOCATION_EXTRA)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
    local rg=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,0,LOCATION_EXTRA,nil)
    if #rg==0 then return end
    Duel.ConfirmCards(tp,rg)
    local tg=Group.CreateGroup()
    local g=Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_GRAVE,0,nil,0x52)
    local ct=g:GetClassCount(Card.GetAttribute)
    local i=ct
    repeat
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
        local tc=rg:Select(tp,1,1,nil):GetFirst()
        rg:Remove(Card.IsCode,nil,tc:GetCode())
        tg:AddCard(tc)
        i=i-1
    until i<1 or #rg==0 or not Duel.SelectYesNo(tp,aux.Stringid(id,0))
    Duel.SendtoGrave(tg,REASON_EFFECT)
    Duel.ShuffleExtra(1-tp)
end