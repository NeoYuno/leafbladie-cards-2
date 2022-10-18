--Big Bang Dragon Blow
local s,id=GetID()
Duel.LoadScript ("specific_functions.lua")
function s.initial_effect(c)
	c:EnableReviveLimit()
	--spsummon condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	--equip
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)
	aux.AddHermosEquipLimit(c,nil,function(tc,c,tp) tc:IsOnField() end,s.equipop,e2)
end
s.material_race=RACE_MACHINE
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() and chkc~=e:GetHandler() end
	if chk==0 then return true end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,e:GetHandler())
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc then return end
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsLocation(LOCATION_SZONE) or c:IsFacedown() then return end
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsFacedown() or not tc:IsRelateToEffect(e) then
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	s.equipop(c,e,tp,tc)
end
function s.equipop(c,e,tp,tc)
	if not aux.EquipAndLimitRegister(c,e,tp,tc) then return end
    --Granted effect
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetReset(RESET_EVENT+RESETS_STANDARD)
    e2:SetCountLimit(1)
    e2:SetCost(s.descost)
    e2:SetTarget(s.destg)
    e2:SetOperation(s.desop)
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
    e3:SetRange(LOCATION_SZONE)
    e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
    e3:SetTarget(s.eftg)
    e3:SetLabelObject(e2)
    c:RegisterEffect(e3)
end
function s.eftg(e,c)
	return e:GetHandler():GetEquipTarget()==c
end
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,nil,1,false,nil,e:GetHandler()) end
	local g=Duel.SelectReleaseGroupCost(tp,nil,1,1,false,nil,e:GetHandler())
	Duel.Release(g,REASON_COST)
    e:SetLabel(g:GetFirst():GetPreviousRaceOnField())
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0 end
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
	local rc=e:GetLabel()
	local dam=0
	if rc==RACE_DRAGON then
		dam=g:GetSum(Card.GetBaseAttack)
	else
		g,dam=g:GetMaxGroup(Card.GetBaseAttack)
	end
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,1,1-tp,dam)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil)
	if #g>0 and Duel.Destroy(g,REASON_EFFECT)>0 then
		local og=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_GRAVE)
		if #og==0 then return end
		local rc=e:GetLabel()
		local dam=0
		if rc==RACE_DRAGON then
			dam=og:GetSum(Card.GetBaseAttack)
		else
			g,dam=og:GetMaxGroup(Card.GetBaseAttack)
		end
		Duel.Damage(1-tp,dam,REASON_EFFECT)
	end
end