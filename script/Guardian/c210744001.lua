--バックアップ・ガードナー
--Backup Guardna
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	--Destroy Replace
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(s.reptg)
	e2:SetValue(s.repval)
	e2:SetOperation(s.repop)
	e2:SetLabel(0)
	c:RegisterEffect(e2)
	--Transfer Equip
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_EQUIP)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetHintTiming(0,TIMING_EQUIP)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.eqtg)
	e3:SetOperation(s.eqop)
	c:RegisterEffect(e3)
end
s.listed_series={0x52}
function s.spcon(e,c)
	if c==nil then return true end
	local mc=Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)
	return (mc==0 or Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsSetCard,0x52),c:GetControler(),LOCATION_MZONE,0,nil)==mc)
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
function s.repfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x52) and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) 
		and not c:IsReason(REASON_REPLACE) and c:IsReason(REASON_EFFECT+REASON_BATTLE)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=eg:FilterCount(s.repfilter,nil,tp)
	if chk==0 then return g>0 and Duel.CheckLPCost(tp,g*1000) end
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		e:SetLabel(g)
		return true
	else return false end
end
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.PayLPCost(tp,e:GetLabel()*1000)
end
function s.tcfilter(tc,ec)
	return tc:IsFaceup() and ec:CheckEquipTarget(tc)
end
function s.ecfilter(c)
	return c:IsType(TYPE_EQUIP) and (not c:IsOriginalType(TYPE_MONSTER) or c:IsOriginalType(TYPE_UNION)) and c:GetEquipTarget()~=nil and Duel.IsExistingTarget(s.tcfilter,0,LOCATION_MZONE,LOCATION_MZONE,1,c:GetEquipTarget(),c)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.ecfilter,tp,LOCATION_SZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(43641473,0))
	local g=Duel.SelectTarget(tp,s.ecfilter,tp,LOCATION_SZONE,0,1,1,nil)
	local ec=g:GetFirst()
	e:SetLabelObject(ec)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(43641473,1))
	local tc=Duel.SelectTarget(tp,s.tcfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,ec:GetEquipTarget(),ec)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetLabelObject()
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc=g:GetFirst()
	if tc==ec then tc=g:GetNext() end
	if ec:IsFaceup() and ec:IsRelateToEffect(e) then 
		if tc:IsFaceup() and tc:IsRelateToEffect(e) then
			Duel.Equip(tp,ec,tc)
		else 
			Duel.SendtoGrave(ec,REASON_EFFECT) 
		end
	end
end