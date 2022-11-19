--Red-Eyes Legendary Fisherman
local s,id=GetID()
function s.initial_effect(c)
	--Immune
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x3b))
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)
    --Equip
	local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
    e2:SetCondition(s.eqcon)
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)
    aux.AddEREquipLimit(c,s.eqcon,s.eqval,s.equipop,e2)
    --Return banished cards
	local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.damtg)
	e3:SetOperation(s.damop)
	c:RegisterEffect(e3)
    --Search
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCountLimit(1,{id,1})
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
end
s.listed_series={0x3b}
--Immune
function s.efilter(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer() and te:IsActiveType(TYPE_SPELL)
end
--Equip
function s.filter(c)
	return c:IsSetCard(0x3b) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
function s.eqfilter(c,lv)
	return c:IsSetCard(0x3b) and c:GetLevel()==lv and not c:IsForbidden()
end
function s.lvfilter(c)
    return c:IsSetCard(0x3b) and c:IsFaceup() or c:IsLocation(LOCATION_HAND)
end
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetHandler():GetEquipGroup():Filter(s.eqconfilter,nil)
	return #g==0
end
function s.eqconfilter(c)
	return c:GetFlagEffect(id)==0 
end
function s.eqval(ec,c,tp)
	return ec:IsControler(tp) and ec:IsSetCard(0x3b) and ec:IsType(TYPE_MONSTER)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,e:GetHandler())
	end
	local tg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
	local lvt={}
	local tc=tg:GetFirst()
	for tc in aux.Next(tg) do
		local tlv=0
		tlv=tlv+tc:GetLevel()
		lvt[tlv]=tlv
	end
	local pc=1
	for i=1,12 do
		if lvt[i] then lvt[i]=nil lvt[pc]=i pc=pc+1 end
	end
	lvt[pc]=nil
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
	local lv=Duel.AnnounceNumber(tp,table.unpack(lvt))
	e:SetLabel(lv)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_DECK)
end
function s.equipop(c,e,tp,tc)
	if not c:EquipByEffectAndLimitRegister(e,tp,tc,nil,true) then return end
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_EQUIP_LIMIT)
    e1:SetProperty(EFFECT_FLAG_COPY_INHERIT+EFFECT_FLAG_OWNER_RELATE)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    e1:SetValue(s.eqlimit)
    e1:SetLabelObject(c)
    tc:RegisterEffect(e1)
    --ATK Boost
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OWNER_RELATE)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetRange(LOCATION_SZONE)
    e2:SetTargetRange(LOCATION_MZONE,0)
    e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x3b))
    e2:SetReset(RESET_EVENT+RESETS_STANDARD)
    e2:SetValue(200)
    tc:RegisterEffect(e2)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    local lv=e:GetLabel()
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local tc=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_DECK,0,1,1,nil,lv,c):GetFirst()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		s.equipop(c,e,tp,tc)
	else
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
    local g2=Duel.GetMatchingGroup(s.lvfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,nil)
    local tc=g2:GetFirst()
	for tc in aux.Next(g2) do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(lv)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
--Return banished cards
function s.tgfilter(c)
    return c:IsSetCard(0x3b) and c:IsFaceup()
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_REMOVED,0,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,#g,0,0)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_REMOVED,0,nil)
	if Duel.SendtoGrave(g,REASON_EFFECT+REASON_RETURN)~=0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CHANGE_DAMAGE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(0,1)
		e1:SetValue(s.damval)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetTargetRange(0,1)
		e2:SetValue(DOUBLE_DAMAGE)
		e2:SetReset(RESET_PHASE+PHASE_DAMAGE_CAL+PHASE_END)
		Duel.RegisterEffect(e2,tp)
	end
end
function s.damval(e,re,val,r,rp,rc)
	local tp=e:GetHandlerPlayer()
	if Duel.GetFlagEffect(tp,id)==0 or r&REASON_EFFECT==0 then
		return val
	end
	Duel.ResetFlagEffect(tp,id)
	return val*2
end
--Search
function s.thfilter(c)
	return c:IsSetCard(0x3b) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
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