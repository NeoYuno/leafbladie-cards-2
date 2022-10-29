--Boundless Gigarays
local s,id=GetID()
function s.initial_effect(c)
	--To grave
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_CANNOT_INACTIVATE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
    --Search
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_CANNOT_INACTIVATE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_series={0xf5,0xe7,0xe8}
function s.tgfilter(c)
	return c:IsMonster() and c:IsAbleToGrave()
end
function s.thfilter(c)
	return c:IsSetCard(0xf5) and c:IsMonster() and c:IsAbleToHand()
end
function s.spfilter(c,e,tp)
    return c:IsSetCard(0xf5) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.chkfilter1(c)
    return c:IsSetCard(0xe7) and c:IsLocation(LOCATION_MZONE)
end
function s.chkfilter2(c)
    return c:IsSetCard(0xe8) and c:IsLocation(LOCATION_MZONE)
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,2,nil)
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND+LOCATION_MZONE)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
    local atk=0
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tg=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,2,2,nil)
    if tg:IsExists(s.chkfilter1,1,nil) and tg:IsExists(s.chkfilter2,1,nil) then atk=tg:GetSum(Card.GetAttack) end
	if Duel.SendtoGrave(tg,REASON_EFFECT)==0 then return end
    local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
    if #g<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local sg=g:Select(tp,1,1,nil)
    Duel.SendtoHand(sg,nil,REASON_EFFECT)
    Duel.ConfirmCards(1-tp,sg)
    if Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local spc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp):GetFirst()
        if spc then
            Duel.SpecialSummon(spc,0,tp,tp,true,false,POS_FACEUP)
            --Increase ATK
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_UPDATE_ATTACK)
            e1:SetValue(atk)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            spc:RegisterEffect(e1)
        end
    end
end

function s.cfilter(c)
	return c:IsSetCard(0xf5) and c:IsMonster() and (c:IsAbleToHand() or c:IsAbleToGrave())
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
	local tc=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	aux.ToHandOrElse(tc,tp)
end