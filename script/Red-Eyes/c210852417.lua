--Gilford the Red-Eyes Lightning
local s,id=GetID()
function s.initial_effect(c)
	--Special summon itself
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
    --Special summon equips
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_LEAVE_FIELD_P)
	e3:SetOperation(s.eqcheck)
	c:RegisterEffect(e3)
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	e2:SetLabelObject(e3)
	c:RegisterEffect(e2)
end
s.listed_series={0x3b}
function s.eqfilter(c)
	return c:IsSetCard(0x3b) and c:IsFaceup() and c:IsType(TYPE_MONSTER)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.eqfilter(chkc) end
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and ft>0
		and Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_MZONE,0,1,nil)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	local g=Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_MZONE,0,1,ft,nil)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
    if #g>=3 then
		Duel.SetChainLimit(s.chainlm)
	end
end
function s.chainlm(e,rp,tp)
	return tp==rp
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
		local g=Duel.GetTargetCards(e):Match(Card.IsType,nil,TYPE_MONSTER):Match(Card.IsSetCard,nil,0x3b)
		if ft<#g then return end
		Duel.BreakEffect()
		for tc in aux.Next(g) do
			local ct=Duel.Equip(tp,tc,c,false)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(s.eqlimit)
			tc:RegisterEffect(e1)
		end
        local dg=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
        if #g>=2 and #dg>0 then
            Duel.BreakEffect()
            Duel.Destroy(dg,REASON_EFFECT)
        end
	end
end
function s.eqlimit(e,c)
	return e:GetOwner()==c
end
function s.eqcheck(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabelObject() then e:GetLabelObject():DeleteGroup() end
	local g=e:GetHandler():GetEquipGroup()
	g:KeepAlive()
	e:SetLabelObject(g)
end
function s.spfilter2(c,e,tp)
	return c:IsLocation(LOCATION_GRAVE) and c:IsControler(tp) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=e:GetLabelObject():GetLabelObject()
	if chk==0 then return g and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and g:IsExists(s.spfilter2,1,nil,e,tp) and not Duel.IsEnvironment(CARD_NECROVALLEY) end
	local sg=g:Filter(s.spfilter2,nil,e,tp)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg,#sg,0,0)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetTargetCards(e)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	if #sg>ft then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		sg=sg:Select(tp,ft,ft,nil)
	end
	Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
end