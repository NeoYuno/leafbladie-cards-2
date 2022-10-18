--Full Psychic Armor Gravitation
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
    --Salvage
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,{id,1})
	e2:SetCondition(aux.exccon)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_names={210183801}
s.listed_series={0xf102}
function s.tgfilter(c)
	return c:IsFaceup() and c:IsCode(210183801)
end
function s.thfilter(c)
    return c:IsSetCard(0xf102) and c:IsAbleToHand()
end
function s.eqfilter(c)
	return not c:IsForbidden() and c:IsType(TYPE_MONSTER) and c:IsSetCard(0xf102)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.tgfilter(chkc,tp) end
    if chk==0 then 
		if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<5 then return false end
		local g=Duel.GetDecktopGroup(tp,5)
		return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,0,1,nil,tp) and g:FilterCount(Card.IsAbleToHand,nil)>0
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
    Duel.ConfirmDecktop(tp,5)
    local g=Duel.GetDecktopGroup(tp,5)
    if #g>0 then
        local sg=g:Filter(s.thfilter,nil)
        if #sg>0 then
            if sg:GetFirst():IsAbleToHand() then
                Duel.SendtoHand(sg,nil,REASON_EFFECT)
                Duel.ConfirmCards(tp,sg)
                Duel.ShuffleHand(tp)
                g:RemoveCard(sg)
                Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
            end
        end
        Duel.ShuffleDeck(tp)
    end
    if Duel.GetOperatedGroup()==0 then return end
    local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
    if ft>0 and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_HAND,0,1,nil) 
		and tc:IsRelateToEffect(e) and tc:IsFaceup() and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		local g2=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_HAND,0,1,ft,nil)
		if #g2>0 then
            for eq in aux.Next(g2) do
                Duel.BreakEffect()
                Duel.Equip(tp,eq,tc,true)
                local e1=Effect.CreateEffect(c)
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetCode(EFFECT_EQUIP_LIMIT)
                e1:SetReset(RESET_EVENT+RESETS_STANDARD)
                e1:SetValue(s.eqlimit)
                e1:SetLabelObject(tc)
                eq:RegisterEffect(e1)
            end
		end
    end
end
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end

function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToDeckAsCost() end
	Duel.SendtoDeck(e:GetHandler(),nil,2,REASON_COST)
end
function s.filter(c)
	return c:IsSetCard(0xf102) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
    end
end