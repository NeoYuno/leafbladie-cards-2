--Red-Eyes Star Blaster
local s,id=GetID()
function s.initial_effect(c)
	--Dice
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
    if not AshBlossomTable then AshBlossomTable={} end
	table.insert(AshBlossomTable,e1)
    --Special Summon
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id)
	e2:SetCondition(aux.exccon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_series={0x3b}
s.listed_names={CARD_REDEYES_B_DRAGON}
s.roll_dice=true
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
function s.tgfilter(c)
	return c:HasLevel() and c:IsAbleToGrave()
end
function s.spfilter(c,e,tp)
    return c:IsCode(CARD_REDEYES_B_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local dc=Duel.TossDice(tp,1)
    local flag=true
    local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_DECK,0,nil)
    local sg=g:SelectWithSumEqual(tp,Card.GetLevel,7-dc,1,1,nil)
	if #sg>0 and Duel.SendtoGrave(sg,REASON_EFFECT)>0 then
        if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
        Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
        flag=false
    end
    if flag==true then Duel.Damage(tp,2400,REASON_EFFECT) end
end
function s.spfilter2(c,e,tp)
	return c:IsSetCard(0x3b) and c:IsLevel(7) or c:IsRank(7) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.spfilter2,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter2,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.mfilter(c)
	return c:IsSetCard(0x3b) and c:IsType(TYPE_MONSTER)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)>0 and tc:IsType(TYPE_XYZ) then
        local g=Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_DECK,0,nil)
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
            Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
			local mg=g:Select(tp,1,1,nil)
			Duel.Overlay(tc,mg)
		end
	end
end