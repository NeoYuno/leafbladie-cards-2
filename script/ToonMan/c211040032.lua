--PK-Theta the Psi-Magna Warrior
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    -- Special Summon Procedure (inherent)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_HAND)
    e1:SetCondition(s.spcon)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- Return a monster by shuffling Magnet Warrior
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id)
    e2:SetCost(s.rmcost)
    e2:SetTarget(s.rmtg)
    e2:SetOperation(s.rmop)
    c:RegisterEffect(e2)

    -- Shuffle itself and summon 3 specific monsters
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,{id,1})
    e3:SetCost(s.sscost)
    e3:SetTarget(s.sstg)
    e3:SetOperation(s.ssop)
    c:RegisterEffect(e3)
end
s.listed_names={211040029,211040030,211040031}

function s.matfilter(c)
    return c:IsCode(211040029) or c:IsCode(211040030) or c:IsCode(211040031)
end

function s.spcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    local g=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,nil)
    return g:IsExists(Card.IsCode,1,nil,211040029)
        and g:IsExists(Card.IsCode,1,nil,211040030)
        and g:IsExists(Card.IsCode,1,nil,211040031)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
    local g=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,nil)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local iota=g:FilterSelect(tp,Card.IsCode,1,1,nil,211040029)
    g:Remove(Card.IsCode,nil,211040029)
    local sigma=g:FilterSelect(tp,Card.IsCode,1,1,nil,211040030)
    g:Remove(Card.IsCode,nil,211040030)
    local omega=g:FilterSelect(tp,Card.IsCode,1,1,nil,211040031)
    local mat=Group.CreateGroup()
    mat:Merge(iota)
    mat:Merge(sigma)
    mat:Merge(omega)
    Duel.SendtoDeck(mat,nil,SEQ_DECKSHUFFLE,REASON_COST)
end

function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then 
        return Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,0x2066) 
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(tp,Card.IsSetCard,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,0x2066)
    Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end

function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsOnField() and chkc:IsAbleToHand() end
    if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
    local g2=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,g2,1,0,0)
end

function s.rmop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.SendtoHand(tc,nil,REASON_EFFECT)
    end
end

function s.sscost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsAbleToDeckAsCost() end
    Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_COST)
end

function s.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then 
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>=3
            and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_DECK,0,1,nil,211040029)
            and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_DECK,0,1,nil,211040030)
            and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_DECK,0,1,nil,211040031)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,3,tp,LOCATION_DECK)
end

function s.ssop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<3 then return end
    local codes={211040029,211040030,211040031}
    local g=Group.CreateGroup()
    for _,code in ipairs(codes) do
        local sc=Duel.GetFirstMatchingCard(Card.IsCode,tp,LOCATION_DECK,0,nil,code)
        if sc then g:AddCard(sc) end
    end
    if #g==3 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end
