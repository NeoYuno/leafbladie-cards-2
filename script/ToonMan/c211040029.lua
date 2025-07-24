--Psi-Magnet Warrior Iota
local s,id=GetID()
function s.initial_effect(c)
    --Normal Summon without Tribute
    local e0=Effect.CreateEffect(c)
    e0:SetDescription(aux.Stringid(id,0))
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_SUMMON_PROC)
    e0:SetCondition(s.ntcon)
    c:RegisterEffect(e0)
    --Normal Summon
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,1))
    e1:SetCategory(CATEGORY_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.nstg)
    e1:SetOperation(s.nsop)
    c:RegisterEffect(e1)
    local e1b=e1:Clone()
    e1b:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
    c:RegisterEffect(e1b)
    local e1c=e1:Clone()
    e1c:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e1c)
    --Search
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,2))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetRange(LOCATION_MZONE)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.thcon)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e3)
end
s.listed_series={0x2066}

function s.ntcon(e,c,minc)
    if c==nil then return true end
    return minc==0 and c:GetLevel()>4
        and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end

function s.nsfilter(c)
    return c:IsSetCard(0x2066) and c:IsSummonable(true,nil)
end
function s.nstg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.nsfilter,tp,LOCATION_HAND,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
function s.nsop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
    local g=Duel.SelectMatchingCard(tp,s.nsfilter,tp,LOCATION_HAND,0,1,1,nil)
    if #g>0 then
        Duel.Summon(tp,g:GetFirst(),true,nil)
    end
end

function s.cfilter(c,tp)
    return c:IsFaceup() and c:IsSetCard(0x2066) and c:IsControler(tp)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.cfilter,1,e:GetHandler(),tp)
end
function s.thfilter(c)
    return c:IsCode(54734082,94940436,100000571,170000115,450000357,80352158,511002567,4740489,17841166,77133792,211040033) and c:IsAbleToHand()
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
