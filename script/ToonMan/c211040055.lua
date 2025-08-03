--Predaplanet Starving Invasion
local s,id=GetID()
function s.initial_effect(c)
    --Activate
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e0)
    --Treat Starving Venom as Predaplant
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_ADD_SETCODE)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.target)
	e1:SetValue(0x10f3)
	c:RegisterEffect(e1)
    --Search on Fusion Summon of Predaplant
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetRange(LOCATION_FZONE)
    e2:SetCountLimit(1,id)
    e2:SetCondition(s.thcon)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
    --Negate all monster effects if destroyed by opponent
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_DISABLE)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_DESTROYED)
    e3:SetCondition(s.negcon)
    e3:SetOperation(s.negop)
    e3:SetCountLimit(1,{id,1},EFFECT_COUNT_CODE_DUEL)
    c:RegisterEffect(e3)
end
s.listed_series={0x1050,0x10f3,0xf3}

function s.target(e,c)
    return c:IsFaceup() and c:IsCode(39915560,45014450,41209827,43387895)
end
function s.cfilter(c,tp)
    return c:IsSummonPlayer(tp) and c:IsType(TYPE_FUSION) and c:IsSetCard(0x10f3)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.thfilter(c)
    return c:IsSetCard(0xf3) and c:IsSpellTrap() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return (r&REASON_EFFECT)~=0 and rp==1-tp and c:IsPreviousLocation(LOCATION_FZONE)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(Card.IsNegatableMonster,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local c=e:GetHandler()
	for tc in g:Iter() do
		tc:NegateEffects(c,RESET_PHASE|PHASE_END)
	end
end
