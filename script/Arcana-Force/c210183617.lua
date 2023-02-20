--The Judgment's Light
local s,id=GetID()
function s.initial_effect(c)
	--Negate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
    --Set itself but banish it when it leaves the field
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(TIMING_END_PHASE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
s.toss_coin=true
s.listed_names={CARD_LIGHT_BARRIER}
s.listed_series={SET_ARCANA_FORCE}
--[Negate]
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_ARCANA_FORCE)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(ev)
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsSetCard,SET_ARCANA_FORCE),tp,LOCATION_MZONE,0,nil)
    local sg=g:GetMaxGroup(Card.GetAttack)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,sg:GetFirst():GetAttack())
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) and Duel.Destroy(eg,REASON_EFFECT)>0 then
        local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsSetCard,SET_ARCANA_FORCE),tp,LOCATION_MZONE,0,nil)
        local sg=g:GetMaxGroup(Card.GetAttack)
        if not sg or #sg==0 then return end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
        local sc=sg:Select(tp,1,1,nil):GetFirst()
        Duel.BreakEffect()
        Duel.Recover(tp,sc:GetAttack(),REASON_EFFECT)
	end
end
--[Set itself but banish it when it leaves the field]
function s.setfilter(c)
	return c:IsSpellTrap() and c:IsSSetable(true)
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    local sel
    if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_LIGHT_BARRIER),tp,LOCATION_FZONE,0,1,nil) then
        local self=Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and c:IsSSetable()
        local oppo=Duel.GetLocationCount(1-tp,LOCATION_SZONE)>0 and Duel.IsExistingMatchingCard(s.setfilter,tp,0,LOCATION_GRAVE,1,nil)
        local op=Duel.SelectEffect(tp,{self,aux.GetCoinEffectHintString(COIN_HEADS)},{oppo,aux.GetCoinEffectHintString(COIN_TAILS)})
        if op==1 then
            sel=COIN_HEADS
        elseif op==2 then
            sel=COIN_TAILS
        else
            return
        end
    else
        sel=Duel.TossCoin(tp,1)
    end
    if sel==COIN_HEADS then
        if c:IsRelateToEffect(e) and c:IsSSetable() and Duel.SSet(tp,c)>0 then
            --Banish it if it leaves the field
            local e1=Effect.CreateEffect(c)
            e1:SetDescription(3300)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
            e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
            e1:SetValue(LOCATION_REMOVED)
            c:RegisterEffect(e1)
        end
    elseif sel==COIN_TAILS then
        local g=Duel.GetMatchingGroup(s.setfilter,tp,0,LOCATION_GRAVE,nil)
        if Duel.GetLocationCount(1-tp,LOCATION_SZONE,1-tp,LOCATION_REASON_TOFIELD)>0 and #g>0 then
            Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SET)
            local sg=g:Select(1-tp,1,1,nil)
            Duel.SSet(1-tp,sg)
        end
    end
end