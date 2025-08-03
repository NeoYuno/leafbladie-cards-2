--Number ∞: The Kingly Dragon of Desires, Ouroboros
local s,id=GetID()
function s.initial_effect(c)
    c:SetUniqueOnField(1,0,id)
	c:EnableReviveLimit()
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x0f7c),9,5)
    --Summon Limit
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_CANNOT_SUMMON)
	e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e0:SetRange(LOCATION_MZONE)
	e0:SetTargetRange(1,0)
	e0:SetTarget(s.limit)
	c:RegisterEffect(e0)
    local e00=e0:Clone()
    e00:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    c:RegisterEffect(e00)
    --Cannot be destroyed by effects
	local e000=Effect.CreateEffect(c)
	e000:SetType(EFFECT_TYPE_SINGLE)
	e000:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e000:SetRange(LOCATION_MZONE)
	e000:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e000:SetValue(1)
	c:RegisterEffect(e000)
    --ATK/DEF
	local e0000=Effect.CreateEffect(c)
	e0000:SetType(EFFECT_TYPE_SINGLE)
	e0000:SetCode(EFFECT_UPDATE_ATTACK)
	e0000:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0000:SetRange(LOCATION_MZONE)
	e0000:SetValue(s.val)
	c:RegisterEffect(e0000)
    local e00000=e0000:Clone()
    e00000:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(e00000)
    --cannot attack
	local e000000=Effect.CreateEffect(c)
	e000000:SetType(EFFECT_TYPE_FIELD)
	e000000:SetRange(LOCATION_MZONE)
	e000000:SetCode(EFFECT_CANNOT_ATTACK)
	e000000:SetTargetRange(LOCATION_MZONE,0)
	e000000:SetTarget(s.antarget)
	c:RegisterEffect(e000000)
    --Reverse damage
    local e0000000=Effect.CreateEffect(c)
    e0000000:SetType(EFFECT_TYPE_FIELD)
    e0000000:SetCode(EFFECT_REVERSE_DAMAGE)
    e0000000:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e0000000:SetRange(LOCATION_MZONE)
    e0000000:SetTargetRange(1,0)
    e0000000:SetValue(s.rev)
    c:RegisterEffect(e0000000)
    local e00000000=Effect.CreateEffect(c)
    e00000000:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e00000000:SetCode(EVENT_RECOVER)
    e00000000:SetRange(LOCATION_MZONE)
    e00000000:SetCondition(s.damcon)
    e00000000:SetOperation(s.damop)
    c:RegisterEffect(e00000000)
    -- Trigger on any form of Summon
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2)
    local e3=e1:Clone()
    e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
    c:RegisterEffect(e3)
    --GAIN ATK
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_ATTACK_ANNOUNCE)
    e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1,{id,1})
    e4:SetOperation(s.atkop)
    c:RegisterEffect(e4)
    --Attach material
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e5:SetCode(EVENT_TO_GRAVE)
    e5:SetProperty(EFFECT_FLAG_DELAY)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCondition(s.matcon)
    e5:SetTarget(s.mattg)
    e5:SetOperation(s.matop)
    c:RegisterEffect(e5)
    local e6=e5:Clone()
    e6:SetCode(EVENT_REMOVE)
    c:RegisterEffect(e6)
    --Protection
    local e7=Effect.CreateEffect(c)
    e7:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
    e7:SetCode(EFFECT_DESTROY_REPLACE)
    e7:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e7:SetRange(LOCATION_MZONE)
    e7:SetCountLimit(1,{id,3})
    e7:SetTarget(s.reptg)
    e7:SetOperation(s.repop)
    c:RegisterEffect(e7)
end

function s.limit(e,c,tp,sumtp,sumpos)
	return not c:IsSetCard(0x0f7c)
end
function s.val(e,c)
	return c:GetOverlayCount()*300
end
function s.antarget(e,c)
	return c~=e:GetHandler()
end
function s.rev(e,re,r,rp,rc)
	return (r&REASON_EFFECT)~=0
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
    return ep==tp and bit.band(r,REASON_EFFECT)~=0 and ev>0
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Damage(1-tp,ev,REASON_EFFECT)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    local g=c:GetMaterial():Filter(Card.IsSetCard,nil,0x0f7c)
    if chk==0 then return #g>=4 and Duel.GetLocationCount(tp,LOCATION_MZONE)>=4
        and g:FilterCount(Card.IsCanBeSpecialSummoned,nil,e,0,tp,false,false)>=4 end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,4,tp,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local g=c:GetMaterial():Filter(Card.IsSetCard,nil,0x0f7c):Filter(Card.IsCanBeSpecialSummoned,nil,e,0,tp,false,false)
    if #g<4 or Duel.GetLocationCount(tp,LOCATION_MZONE)<4 then return end
    local sg=aux.SelectUnselectGroup(g,e,tp,4,4,function(sg,e,tp) return #sg==4 end,1,tp,HINTMSG_SPSUMMON)
    if #sg==4 then
        for tc in sg:Iter() do
            Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
        end
    end
end

function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnPlayer()==tp and e:GetHandler():IsRelateToEffect(e)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsFaceup() or not c:IsRelateToEffect(e) then return end
    local g=Duel.GetMatchingGroup(function(tc)
        return tc:IsFaceup() and tc:IsSetCard(0xf7c) and tc~=c
    end,tp,LOCATION_MZONE,0,nil)
    local val=g:GetSum(Card.GetAttack)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(val)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
    c:RegisterEffect(e1)
end

function s.matfilter(c,tp)
    return (c:IsLocation(LOCATION_GRAVE) or c:IsLocation(LOCATION_REMOVED))
        and (c:GetPreviousLocation()==LOCATION_HAND or c:GetPreviousLocation()==LOCATION_DECK or c:GetPreviousLocation()==LOCATION_ONFIELD)
        and c:GetPreviousControler()==tp
end
function s.matcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.matfilter,1,nil,tp)
end
function s.mattg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=eg:Filter(s.matfilter,nil,tp)
    if chk==0 then return #g>0 and e:GetHandler():IsType(TYPE_XYZ) end
end
function s.matop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) or c:IsFacedown() or not c:IsType(TYPE_XYZ) then return end
    local g=eg:Filter(s.matfilter,nil,tp)
    for tc in aux.Next(g) do
        Duel.Overlay(c,tc)
    end
end

function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    local og=c:GetOverlayGroup()
    if chk==0 then return bit.band(r,REASON_BATTLE)~=0 and og:IsExists(Card.IsAbleToDeck,1,nil) end
    Duel.Hint(HINT_CARD,0,e:GetHandler():GetCode())
    return true
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local og=c:GetOverlayGroup():Filter(Card.IsAbleToDeck,nil)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local tc=og:Select(tp,1,1,nil):GetFirst()
    if tc then
        Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
    end
end