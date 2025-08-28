--Mythisch Of Miracles, Rifistor
local s,id=GetID()
function s.initial_effect(c)
    -- Effect 1: On Summon → Add 1 "Mythisch" or "Miracle" card
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2)
    -- Effect 2: When attacking → Double ATK, then switch to DEF
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e3:SetCode(EVENT_ATTACK_ANNOUNCE)
    e3:SetCountLimit(1,{id,1})
    e3:SetOperation(s.atkop)
    c:RegisterEffect(e3)
    -- Effect 3: If detached from Mythisch Xyz → Topdeck from GY
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,2))
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_TO_GRAVE)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetCountLimit(1,{id,2})
    e4:SetCondition(s.topcon)
    e4:SetOperation(s.topop)
    c:RegisterEffect(e4)
    -- Effect 4: If sent as Synchro Material for "Rezal" → Special Summon
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,3))
    e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e5:SetCode(EVENT_BE_MATERIAL)
    e5:SetProperty(EFFECT_FLAG_DELAY)
    e5:SetCountLimit(1,{id,3})
    e5:SetCondition(s.spcon2)
    e5:SetTarget(s.sptg2)
    e5:SetOperation(s.spop2)
    c:RegisterEffect(e5)
end
s.listed_series={0xf8a}
-- Effect 1: Search "Mythisch" or "Miracle"
function s.thfilter(c)
    return (c:IsSetCard(0xf8a) or c:IsCode(id)) and c:IsAbleToHand()
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
-- Effect 2: Double ATK, then switch to DEF
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) or not c:IsFaceup() then return end
    local atk=c:GetAttack()
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_SET_ATTACK_FINAL)
    e1:SetValue(atk*2)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
    c:RegisterEffect(e1)
    -- Switch to DEF at end of Damage Step
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_DAMAGE_STEP_END)
    e2:SetCountLimit(1)
    e2:SetOperation(function(_,tp,_,_,_,_,_) 
        if c:IsFaceup() and c:IsAttackPos() then
            Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
        end
    end)
    e2:SetReset(RESET_PHASE+PHASE_DAMAGE)
    Duel.RegisterEffect(e2,tp)
end

-- Effect 3: Detached from Mythisch Xyz → Topdeck
function s.topcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsPreviousLocation(LOCATION_OVERLAY)
        and re and re:GetHandler():IsSetCard(0xf8a) and re:GetHandler():IsType(TYPE_XYZ)
end
function s.topop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsLocation(LOCATION_GRAVE) then
        Duel.SendtoDeck(c,nil,SEQ_DECKTOP,REASON_EFFECT)
    end
end

-- Effect 4: Sent as Synchro Material for "Rezal" → Special Summon
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
    local rc=e:GetHandler():GetReasonCard()
    return e:GetHandler():IsLocation(LOCATION_GRAVE)
        and e:GetHandler():IsReason(REASON_SYNCHRO)
        and rc:IsSetCard(nil)
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
    end
end