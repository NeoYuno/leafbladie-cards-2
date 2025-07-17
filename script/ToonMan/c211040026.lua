--Boot-up Nuclear Dynamo, The Moving Battle Fortress
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    -- Fusion material
    local f1=Fusion.AddProcMixN(c,true,true,aux.FilterBoolFunction(Card.IsSetCard,0x51),5)[1]
    f1:SetDescription(aux.Stringid(id,0))
    local f2=Fusion.AddProcMix(c,true,true,
        aux.FilterBoolFunction(Card.IsCode,36322312),
        aux.FilterBoolFunction(Card.IsSetCard,0x51),
        aux.FilterBoolFunction(Card.IsSetCard,0x51))[1]
    f2:SetDescription(aux.Stringid(id,1))
    Fusion.AddContactProc(c,s.contactfil,s.contactop,s.splimit,nil,nil,nil,false)
    -- Cannot activate Spell/Traps when this card declares attack
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_ACTIVATE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetTargetRange(0,1)
    e1:SetValue(s.actlimit)
    e1:SetCondition(s.actcon)
    c:RegisterEffect(e1)

    -- Equip destroyed monster + gain ATK
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,2))
    e2:SetCategory(CATEGORY_EQUIP)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_BATTLE_DESTROYING)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCondition(s.eqcon)
    e2:SetTarget(s.eqtg)
    e2:SetOperation(s.eqop)
    e2:SetCountLimit(1,id)
    c:RegisterEffect(e2)

    -- Battle protection while equipped
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetTargetRange(LOCATION_MZONE,0)
    e3:SetTarget(s.prottg)
    e3:SetCondition(s.eqcon2)
    e3:SetValue(1)
    c:RegisterEffect(e3)

    -- Destroy all on destruction
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,3))
    e4:SetCategory(CATEGORY_DESTROY)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_DESTROYED)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetCountLimit(1,id+1000)
    e4:SetTarget(s.destg)
    e4:SetOperation(s.desop)
    c:RegisterEffect(e4)
end

function s.splimit(e,se,sp,st)
	return (st&SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
end
function s.contactfil(tp)
	return Duel.GetMatchingGroup(Card.IsAbleToGraveAsCost,tp,LOCATION_MZONE+LOCATION_SZONE,0,nil)
end
function s.contactop(g)
	Duel.SendtoGrave(g,REASON_COST|REASON_MATERIAL)
end
-- Prevent Spell/Trap activation during Battle Phase if this card declared attack
function s.actlimit(e,re,tp)
    return re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
function s.actcon(e)
    return Duel.GetAttacker()==e:GetHandler()
end

-- Equip destroyed monster + gain its ATK
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetBattleTarget()
	return c:IsRelateToBattle() and c:IsFaceup() and tc:IsMonster() and tc:IsReason(REASON_BATTLE)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
	local tc=e:GetHandler():GetBattleTarget()
	Duel.SetTargetCard(tc)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if not Duel.Equip(tp,tc,c,false) then return end

    -- Equip limit
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_EQUIP_LIMIT)
    e1:SetProperty(EFFECT_FLAG_COPY_INHERIT+EFFECT_FLAG_OWNER_RELATE)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    e1:SetValue(function(e,c) return e:GetOwner()==c end)
    tc:RegisterEffect(e1)

    -- Gain ATK equal to equipped monster
    local atk=tc:GetAttack()
    if atk>0 then
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_UPDATE_ATTACK)
        e2:SetValue(atk)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD)
        c:RegisterEffect(e2)
    end
end

-- Condition: this card has an equipped monster
function s.eqcon2(e)
    return e:GetHandler():GetEquipCount()>0
end

-- Protection target: "Gadget" and "Boot-Up" monsters
function s.prottg(e,c)
    return c:IsSetCard(0x51) or c:IsCode(36322312,938717,13316346,211040025,211040026)
end

-- Destroy all cards on the field
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
    if chk==0 then return #g>0 end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
    Duel.Destroy(g,REASON_EFFECT)
end
