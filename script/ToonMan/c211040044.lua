--Infinity Unchained Dominion
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
    --Unaffected
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTarget(function(e,c) return c:IsSetCard(0x0f7c) end)
	e1:SetValue(s.immval)
	c:RegisterEffect(e1)
    --Protection
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetValue(1)
	e2:SetCondition(s.indcon)
	c:RegisterEffect(e2)
    --Draw
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_DRAW)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_FZONE)
    e3:SetCountLimit(1)
    e3:SetCondition(function(e)
        return Duel.IsExistingMatchingCard(function(tc)
            return tc:IsFaceup() and tc:IsCode(211040040)
        end,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
    end)
    e3:SetTarget(s.drawtg)
    e3:SetOperation(s.drawop)
    c:RegisterEffect(e3)
end
s.listed_names={211040040}
s.listed_series={0x0f7c}

function s.immval(e,te)
	return te:GetOwnerPlayer()==1-e:GetHandlerPlayer()
end

function s.indcon(e)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,211040040),0,LOCATION_MZONE,0,1,nil)
end

function s.drawtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanDraw(tp,2)
        and Duel.IsExistingMatchingCard(function(c) return c:IsType(TYPE_XYZ) and c:IsFaceup() end,tp,LOCATION_MZONE,0,1,nil)
        and Duel.IsExistingMatchingCard(Card.IsAbleToOverlay,tp,LOCATION_HAND,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end

function s.drawop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.Draw(tp,2,REASON_EFFECT)==2 then
        Duel.ShuffleHand(tp)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACH)
        local hand=Duel.SelectMatchingCard(tp,Card.IsAbleToOverlay,tp,LOCATION_HAND,0,1,1,nil)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
        local xyz=Duel.SelectMatchingCard(tp,function(c) return c:IsType(TYPE_XYZ) and c:IsFaceup() end,tp,LOCATION_MZONE,0,1,1,nil)
        local tc=xyz:GetFirst()
        if #hand>0 and tc then
            Duel.Overlay(tc,hand)
        end
    end
end