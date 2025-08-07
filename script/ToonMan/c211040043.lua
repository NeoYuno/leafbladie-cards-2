-- Infinity Gate
local s,id=GetID()
function s.initial_effect(c)
    --Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
    -- Search
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_SZONE)
    e1:SetCountLimit(1,id)
    e1:SetCost(s.thcost)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)
    -- Once per Duel: Send this card to GY to steal and convert monster
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_CONTROL+CATEGORY_DISABLE)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1,{id,1},EFFECT_COUNT_CODE_DUEL)
    e2:SetCost(s.ctcost)
    e2:SetTarget(s.cttg)
    e2:SetOperation(s.ctop)
    c:RegisterEffect(e2)
end
s.listed_series={0x0f7c}

function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,1,nil)
    Duel.SendtoGrave(g,REASON_COST)
end
function s.thfilter(c)
	return c:IsSetCard(0x0f7c) and c:IsMonster() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

-- Take control and transform monster
function s.ctcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsAbleToGraveAsCost() end
    Duel.SendtoGrave(c,REASON_COST)
end
function s.ctfilter(c)
    return c:IsFaceup() and c:IsControler(1) and c:IsAbleToChangeControler()
end
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1) and s.ctfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.ctfilter,tp,0,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
    local g=Duel.SelectTarget(tp,s.ctfilter,tp,0,LOCATION_MZONE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and Duel.GetControl(tc,tp)~=0 then
        -- Change name to "Infinity Servant"
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CHANGE_CODE)
        e1:SetValue(211040045) -- "Infinity Servant" ID
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e1)
        local e2=Effect.CreateEffect(e:GetHandler())
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_XYZ_LEVEL)
        e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
        e2:SetRange(LOCATION_MZONE)
        e2:SetValue(9)
        c:RegisterEffect(e2)
        -- Negate effects
        local e3=Effect.CreateEffect(e:GetHandler())
        e3:SetType(EFFECT_TYPE_SINGLE)
        e3:SetCode(EFFECT_DISABLE)
        e3:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e3)
        local e4=Effect.CreateEffect(e:GetHandler())
        e4:SetType(EFFECT_TYPE_SINGLE)
        e4:SetCode(EFFECT_DISABLE_EFFECT)
        e4:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e4)
    end
end