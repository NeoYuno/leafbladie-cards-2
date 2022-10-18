--Red-Eyes Knight of Dark Dragon
local s,id=GetID()
function s.initial_effect(c)
	--link summon
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x3b),2,2)
	c:EnableReviveLimit()
    --Ritual
    local e1=Ritual.CreateProc({handler=c,lvtype=RITPROC_EQUAL,filter=s.ritfilter,extrafil=s.extrafil,extraop=s.extraop,matfilter=s.forcedgroup,location=LOCATION_HAND+LOCATION_GRAVE})
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,id)
    c:RegisterEffect(e1)
    --Burn
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCategory(CATEGORY_DESTROY)
    e2:SetCode(EVENT_BATTLE_START)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetTarget(s.damtg)
    e2:SetOperation(s.damop)
    c:RegisterEffect(e2)
end
s.listed_series={0x3b}
function s.ritfilter(c)
    return c:IsRace(RACE_DRAGON) and c:IsRitualMonster()
end
function s.extrafil(e,tp,eg,ep,ev,re,r,rp,chk)
    return Duel.GetFieldGroup(tp,LOCATION_DECK,0)
end
function s.extraop(mat,e,tp,eg,ep,ev,re,r,rp,tc)
    return Duel.SendtoGrave(mat,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
end
function s.forcedgroup(c,e,tp)
    return c:IsLocation(LOCATION_DECK) and c:IsSetCard(0x3b) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
function s.damfilter(c)
    return c:IsFaceup() and c:GetAttack()>0
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=e:GetHandler():GetLinkedGroup():Filter(s.damfilter,nil)
	if chk==0 then return #g>0 end
    local dam=g:GetSum(Card.GetBaseAttack)
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(dam//2)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam//2)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end