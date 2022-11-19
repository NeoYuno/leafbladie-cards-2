--Yubel's Garden
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
    --Damage
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_DAMAGE)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1,id)
    e2:SetCondition(s.damcon)
	e2:SetTarget(s.damtg)
	e2:SetOperation(s.damop)
	c:RegisterEffect(e2)
    --Destroy replace
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetTarget(s.reptg)
	e3:SetValue(s.repval)
	e3:SetOperation(s.repop)
	c:RegisterEffect(e3)
	local g=Group.CreateGroup()
	g:KeepAlive()
	e3:SetLabelObject(g)
    --to S/T Zone
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetCountLimit(1,{id,2})
	e4:SetCondition(s.tfcond)
	e4:SetTarget(s.tftg)
	e4:SetOperation(s.tfop)
	c:RegisterEffect(e4)
end
s.listed_series={0xf101}
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
    local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	return d and a:IsControler(tp) and a~=e:GetHandler() and (a:IsSetCard(0xf101) or a:IsCode(78371393,4779091,31764700)) and a:IsLevelAbove(10)
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local at=Duel.GetAttacker()
	local bc=at:GetBattleTarget()
	local dam=bc:GetAttack()
	if chk==0 then return true end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(dam)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end
function s.repfilter(c,tp)
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and not c:IsReason(REASON_REPLACE)
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:GetFlagEffect(id)==0
end
function s.desfilter(c,e)
	return c:IsCode(78371393,4779091,31764700) or (c:IsSetCard(0xf101) and c:IsType(TYPE_MONSTER)) and c:IsDestructable(e)
		and not c:IsStatus(STATUS_DESTROY_CONFIRMED+STATUS_BATTLE_DESTROYED)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=eg:FilterCount(s.repfilter,nil,tp)
	if chk==0 then return ct>0
		and Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_HAND+LOCATION_DECK,0,ct,nil,e) end
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)
		local tg=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_HAND+LOCATION_DECK,0,ct,ct,nil,e)
		local g=e:GetLabelObject()
		g:Clear()
		local tc=tg:GetFirst()
		for tc in aux.Next(tg) do
			tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_CHAIN,0,1)
			tc:SetStatus(STATUS_DESTROY_CONFIRMED,true)
			g:AddCard(tc)
		end
		return true
	else return false end
end
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,1-tp,id)
	local tg=e:GetLabelObject()
	local tc=tg:GetFirst()
	for tc in aux.Next(tg) do
		tc:SetStatus(STATUS_DESTROY_CONFIRMED,false)
	end
	Duel.Destroy(tg,REASON_EFFECT+REASON_REPLACE)
end
function s.tfcond(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsLevelAbove,10),tp,LOCATION_MZONE,0,1,nil)
end
function s.tftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,tp,0)
end
function s.tfop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end