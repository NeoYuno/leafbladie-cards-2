--Vanguard of the Mythisch, Veissrugr
local s,id=GetID()
function s.initial_effect(c)
    -- Xyz Summon procedure
    Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0xf8a),6,2)
    c:EnableReviveLimit()
    --indes
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE)
	e1:SetCondition(s.indcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
    --Detach 1, give Mythisch monster buff effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(Cost.DetachFromSelf(1))
	e2:SetTarget(s.bufftg)
	e2:SetOperation(s.buffop)
	c:RegisterEffect(e2)
    --On attack, draw 2 and apply effect
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.drtg)
	e3:SetOperation(s.drop)
	c:RegisterEffect(e3)
end
s.listed_series={0xf8a}
s.listed_names={211040071}

function s.indcon(e)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,211040071),e:GetOwnerPlayer(),LOCATION_MZONE,0,1,nil)
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end

function s.filter(c,tp)
	return c:IsFaceup() and c:IsCode(211040071) and c:IsControler(tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil,tp) end
end

function s.bufffilter(c)
    return c:IsFaceup() and c:IsSetCard(0xf8a) and c:IsType(TYPE_XYZ)
end
function s.bufftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingTarget(s.bufffilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.bufffilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.buffop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	local val=500*Duel.GetMatchingGroupCount(s.bufffilter,tp,LOCATION_MZONE,0,nil)
	if tc:IsStatus(STATUS_SPSUMMON_TURN) then val=800*Duel.GetMatchingGroupCount(s.bufffilter,tp,LOCATION_MZONE,0,nil) end
	local e1=Effect.CreateEffect(tc)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(val)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	tc:RegisterEffect(e2)
end

function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(2)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	local g=Duel.GetDecktopGroup(tp,2)
	if #g<2 then return end
	Duel.Draw(tp,2,REASON_EFFECT)
	Duel.ConfirmCards(1-tp,g)
	for tc in aux.Next(g) do
		if tc:IsType(TYPE_MONSTER) then
			--Attach and gain ATK/DEF
			local xyz=Duel.SelectMatchingCard(tp,s.bufffilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
			if xyz then
				Duel.Overlay(xyz,tc)
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetValue(1000)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
				xyz:RegisterEffect(e1)
				local e2=e1:Clone()
				e2:SetCode(EFFECT_UPDATE_DEFENSE)
				xyz:RegisterEffect(e2)
			end
		elseif tc:IsType(TYPE_SPELL) then
			local g2=Duel.GetMatchingGroup(s.bufffilter,tp,LOCATION_MZONE,0,nil)
			for xc in aux.Next(g2) do
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetValue(1000)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
				xc:RegisterEffect(e1)
				local e2=e1:Clone()
				e2:SetCode(EFFECT_UPDATE_DEFENSE)
				xc:RegisterEffect(e2)
			end
		elseif tc:IsType(TYPE_TRAP) then
			if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
				Duel.SSet(tp,tc)
				Duel.ConfirmCards(1-tp,tc)
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e1)
			end
		end
	end
end
