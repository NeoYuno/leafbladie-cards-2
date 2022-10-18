--ガーディアン・サモナー
--Guardian Summoner
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Equip
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(1068)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(s.eqcost)
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)
	--Special Summon and Equip
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(2)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(aux.NOT(s.quickcon))
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--become Quick
	local e3=e2:Clone()
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCondition(s.quickcon)
	c:RegisterEffect(e3)
	if not grdnMonster then grdnMonster={10755153,47150851,46037213,18175965,9633505,73544866,74367458,511001771} end
	if not grdnEquip then grdnEquip={95638658,32022366,21900719,81954378,95515060,68427465,69243953,55569674} end
	--reverse ATK/DEF reduction
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_ADJUST)
	e4:SetRange(LOCATION_MZONE)
	e4:SetOperation(s.revop)
	c:RegisterEffect(e4)
end
s.listed_series={0x52}
function s.eqcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD,nil)
end
function s.eqfilter(c,ec)
	return c:IsType(TYPE_EQUIP) and c:CheckEquipTarget(ec)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.eqfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,c)
	local tc=g:GetFirst()
	if tc then
		Duel.Equip(tp,tc,c)
	end
end
function s.tgfilter(c,e,tp,tc)
	return c:IsType(TYPE_EQUIP) and c:IsFaceup() and c:GetEquipTarget()==tc
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp,c:GetCode())
end
function s.spfilter(c,e,tp,eqcode)
	local mcode_indx=0
	for i,v in pairs(grdnEquip) do
		if v==eqcode then
			mcode_indx=i
			break
		end
	end
	return (c:IsCode(grdnMonster[mcode_indx]) or c:IsOriginalCode(grdnMonster[mcode_indx])) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_SZONE,0,1,nil,e,tp,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_SZONE,0,1,1,nil,e,tp,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_SZONE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp,tc:GetCode())
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
		Duel.Equip(tp,tc,g:GetFirst())
		--cannot Special Summon from the Extra Deck
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetAbsoluteRange(tp,1,0)
		e1:SetTarget(s.splimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		g:GetFirst():RegisterEffect(e1,true)
	end
end
function s.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA)
end
function s.quickcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsHasEffect(210744007)
end
function s.revfilter(c)
	return c:IsType(TYPE_EQUIP) and c:IsFaceup() and c:GetEquipTarget() and c:GetEquipTarget():IsSetCard(0x52)
end
function s.revop(e,tp,eg,ep,ev,re,r,rp)
	if not s.grdnSumm then s.grdnSumm={} end
	if not s.grdnSummReff then s.grdnSummReff={} end
	local c=e:GetHandler()
	local lg=Duel.GetMatchingGroup(s.revfilter,tp,LOCATION_SZONE,LOCATION_SZONE,nil)
	for lc in aux.Next(lg) do
		local effs={lc:GetEquipTarget():GetCardEffect(EFFECT_UPDATE_ATTACK)}
		for _,eff in ipairs(effs) do
			if eff:GetOwner()==lc and s.grdnSumm[eff]==nil and not s.grdnSummReff[eff] then
				local reff=eff:Clone()
				reff:SetCondition(function(reff) return s.reffcon(reff,lc,c,eff) end)
				reff:SetValue(function(reff) return s.reffvalue(reff,eff,lc) end)
				reff:SetLabelObject(c)
				lc:RegisterEffect(reff)
				s.grdnSumm[eff]=reff
				s.grdnSummReff[reff]=true
			end
			if not (lc:GetEquipTarget() and c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and not c:IsDisabled()) then
				if reff:GetLabelObject()==c then
					reff:Reset()
					s.grdnSumm[eff]=nil
					s.grdnSummReff[reff]=false
				end
			end
		end
		local effs={lc:GetEquipTarget():GetCardEffect(EFFECT_UPDATE_DEFENSE)}
		for _,eff in ipairs(effs) do
			if eff:GetOwner()==lc and s.grdnSumm[eff]==nil and not s.grdnSummReff[eff] then
				local reff=eff:Clone()
				reff:SetCondition(function(reff) return s.reffcon(reff,lc,c,eff) end)
				reff:SetValue(function(reff) return s.reffvalue(reff,eff) end)
				reff:SetLabelObject(c)
				lc:RegisterEffect(reff)
				s.grdnSumm[eff]=reff
				s.grdnSummReff[reff]=true
			end
			if not (lc:GetEquipTarget() and c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and not c:IsDisabled()) then
				if reff:GetLabelObject()==c then
					reff:Reset()
					s.grdnSumm[eff]=nil
					s.grdnSummReff[reff]=false
				end
			end
		end
	end
end
function s.reffcon(reff,lc,c,eff)
	if not (lc:GetEquipTarget() and c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and not c:IsDisabled()) then
		return false 
	end 
	if eff:GetCondition() then 
		return eff:GetCondition()(reff) 
	else 
		return true 
	end
end
function s.reffvalue(reff,eff,lc)
	if type(eff:GetValue())=='function' and eff:GetValue()(reff,lc) and eff:GetValue()(reff,lc)<0 then
		return -eff:GetValue()(reff,lc)*2
	elseif not (type(eff:GetValue())=='function') and eff:GetValue()<0 then
		return -eff:GetValue()*2
	end
end