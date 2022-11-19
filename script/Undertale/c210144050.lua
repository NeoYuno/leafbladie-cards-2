--KARMA
local s,id=GetID()
function s.initial_effect(c)
    --Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Reduce ATK
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
    --Change LP
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e3:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
    e3:SetCondition(s.lpcon)
    e3:SetOperation(s.lpop)
    c:RegisterEffect(e3)
    --Change ATK
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCondition(s.con)
	e4:SetTarget(s.tg)
	e4:SetOperation(s.op)
	c:RegisterEffect(e4)
end
s.listed_names={210144027}
s.listed_series={0x0f4a}
function s.filter(c)
    return c:IsSetCard(0x0f4a) and c:IsMonster()
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
    local atkg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_GRAVE,0,nil)
	local atk=atkg:GetClassCount(Card.GetCode)
	if #g==0 or atk==0 then return end
	for tc in aux.Next(g) do
        local e2=Effect.CreateEffect(e:GetHandler())
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_UPDATE_ATTACK)
        if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,210144027),tp,LOCATION_MZONE,0,1,nil) then
            e2:SetValue(atk*-400)
        else
            e2:SetValue(atk*-200)
        end
        e2:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e2)
    end
end

function s.lpcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,210144027),tp,LOCATION_MZONE,0,1,nil)
        and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)==0
end
function s.lpop(e,tp,eg,ep,ev,re,r,rp)
	Duel.SetLP(1-tp,100)
end

function s.con(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and rp==1-tp and c:GetPreviousControler()==tp
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	for tc in aux.Next(g) do
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_SET_ATTACK_FINAL)
		e2:SetValue(100)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
end