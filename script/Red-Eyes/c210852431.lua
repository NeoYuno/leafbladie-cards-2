--Red-Eyes Re-Fusion
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Fusion.CreateSummonEff(c,aux.FilterBoolFunction(aux.IsMaterialListSetCard,0x3b),Card.IsAbleToDeck,
                                    s.fextra,Fusion.ShuffleMaterial,nil,s.stage2)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	c:RegisterEffect(e1)
	if not AshBlossomTable then AshBlossomTable={} end
	table.insert(AshBlossomTable,e1)
    --Copy effect
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1)
    e2:SetCondition(s.cpcon)
    e2:SetCost(s.cpcost)
    e2:SetTarget(s.cptg)
    e2:SetOperation(s.cpop)
    c:RegisterEffect(e2)
end
s.listed_names={CARD_REDEYES_B_DRAGON,52684508}
function s.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToDeckAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return se~=e:GetLabelObject()
end
function s.fextra(e,tp,mg,sumtype)
	return Duel.GetMatchingGroup(aux.NecroValleyFilter(Fusion.IsMonsterFilter(Card.IsAbleToDeck)),tp,LOCATION_GRAVE,0,nil),s.fcheck
end
function s.stage2(e,tc,tp,mg,chk)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
	if tc and Duel.Equip(tp,c,tc) and chk==1 then
        --Add Equip limit
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(s.eqlimit)
		c:RegisterEffect(e1)
        --Change name
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CHANGE_CODE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetValue(CARD_REDEYES_B_DRAGON)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
end
function s.eqlimit(e,c)
	return e:GetOwner()==c
end
function s.fcheck(tp,sg,fc,sumtype,tp)
	return sg:IsExists(s.ffilter,1,nil,fc,sumtype,tp)
end
function s.ffilter(c,fc,sumtype,tp)
	local mat=fc.material
	local set=fc.material_setcode
	local res
	if mat then
		for _,code in ipairs(mat) do
			res=res or (c:IsSummonCode(nil,SUMMON_TYPE_FUSION,PLAYER_NONE,code) and c:IsSetCard(0x3b,fc,sumtype,tp))
		end
	elseif set then
		res=res or (c:IsSetCard(0x3b,fc,sumtype,tp) and aux.IsMaterialListSetCard(fc,0x3b))
	else
		return false
	end
	return res
end
--
function s.cpcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==1-tp
end
function s.copfilter(c)
	return c:IsCode(52684508) and c:IsAbleToGraveAsCost() and c:CheckActivateEffect(true,true,false)~=nil
end
function s.cpcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.copfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.cptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local te=e:GetLabelObject()
		return tg and tg(e,tp,eg,ep,ev,re,r,rp,0,chkc)
	end
	if chk==0 then return Duel.IsExistingMatchingCard(s.copfilter,tp,LOCATION_DECK,0,1,nil) end
	local g=Duel.SelectMatchingCard(tp,s.copfilter,tp,LOCATION_DECK,0,1,1,nil)
	if not Duel.SendtoGrave(g,REASON_COST) then return end
	local te=g:GetFirst():CheckActivateEffect(true,true,false)
	e:SetLabel(te:GetLabel())
	e:SetLabelObject(te:GetLabelObject())
	local tg=te:GetTarget()
	if tg then
		tg(e,tp,eg,ep,ev,re,r,rp,1)
	end
	te:SetLabel(e:GetLabel())
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
	Duel.ClearOperationInfo(0)
end
function s.cpop(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if te then
		e:SetLabel(te:GetLabel())
		e:SetLabelObject(te:GetLabelObject())
		local op=te:GetOperation()
		if op then op(e,tp,eg,ep,ev,re,r,rp) end
		te:SetLabel(e:GetLabel())
		te:SetLabelObject(e:GetLabelObject())
	end
end