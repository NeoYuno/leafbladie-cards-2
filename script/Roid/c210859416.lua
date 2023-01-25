--Fixeroid
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,0x16),2)
    --Apply Effect(s)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
    --Change Position
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetHintTiming(TIMINGS_CHECK_MONSTER_E)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.postg)
	e2:SetOperation(s.posop)
	c:RegisterEffect(e2)
end
s.listed_series={0x16}
--[Apply Effect(s)]
function s.thfilter(c)
	return c:IsSetCard(0x16) and c:IsSpellTrap() and c:IsAbleToHand()
end
function s.exfilter(c,e,tp)
	return c.material and c:IsSetCard(0x16) and c:IsType(TYPE_FUSION) and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp,c)
end
function s.spfilter(c,e,tp,fc)
	return c:IsCode(table.unpack(fc.material)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
	    and Duel.IsExistingMatchingCard(s.exfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
	if chk==0 then return b1 or b2 end
	if b1 then Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK) end
	if b2 then Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK) end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local b1=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
	    and Duel.IsExistingMatchingCard(s.exfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
	local op=0
	if b1 and b2 and Duel.GetLP(tp)<=4000 then op=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))
	elseif b1 and b2 and Duel.GetLP(tp)>4000 then op=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
	elseif b1 then op=Duel.SelectOption(tp,aux.Stringid(id,0))
	elseif b2 then op=Duel.SelectOption(tp,aux.Stringid(id,1))+1
	else return end
	if op==0 then
		s.searchop(e,tp,eg,ep,ev,re,r,rp)
	elseif op==1 then
		s.spsummonop(e,tp,eg,ep,ev,re,r,rp)
	else
		s.searchop(e,tp,eg,ep,ev,re,r,rp)
		s.spsummonop(e,tp,eg,ep,ev,re,r,rp)
	end
end
function s.searchop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.spsummonop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local cg=Duel.SelectMatchingCard(tp,s.exfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if #cg==0 then return end
	Duel.ConfirmCards(1-tp,cg)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp,cg:GetFirst())
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		local code=c:GetCode()
		s.announce_filter={0x16,OPCODE_ISSETCARD,code,OPCODE_ISCODE,OPCODE_NOT,OPCODE_AND,TYPE_MONSTER,OPCODE_ISTYPE,OPCODE_AND}
		local ac=Duel.AnnounceCard(tp,table.unpack(s.announce_filter))
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetValue(ac)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
--[Change Position]
function s.posfilter(c)
	return c:IsAttackPos() and c:IsCanChangePosition()
end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.posfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local g=Duel.SelectTarget(tp,s.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)>0 then
        if tc:IsSetCard(0x16) then
            --Unaffected by opponent's card effects
            local e1=Effect.CreateEffect(c)
            e1:SetDescription(3110)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_IMMUNE_EFFECT)
            e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
            e1:SetRange(LOCATION_MZONE)
            e1:SetValue(s.efilter)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            e1:SetOwnerPlayer(tp)
            tc:RegisterEffect(e1)
        else
			--DEF becomes 0
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_SET_DEFENSE_FINAL)
            e1:SetValue(0)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            tc:RegisterEffect(e1)
        end
	end
end
function s.efilter(e,re)
	return e:GetOwnerPlayer()~=re:GetOwnerPlayer()
end