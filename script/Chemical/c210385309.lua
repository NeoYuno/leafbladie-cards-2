-- Bonding - CO2
-- by MasterQuestMaster
local s, id = GetID()
Duel.LoadScript("chemical-utility.lua")
local CARD_FIRE_DRAGON = 210385304
local CARD_CARBONEDDON = 15981690
local CARD_OXYGEDDON = 58071123
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

  -- Add/Special from GY
  local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0)) -- Add or Summon Carboneddon or Oxygeddon.
  e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
  e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
  e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
  e2:SetCountLimit(1,id)
  e2:SetCost(aux.bfgcost)
  e2:SetTarget(s.gytg)
  e2:SetOperation(s.gyop)
  c:RegisterEffect(e2)
end
s.listed_names={CARD_CARBONEDDON,CARD_FIRE_DRAGON,CARD_OXYGEDDON}
function s.cfilter(c,tp)
	return aux.IsCodeOrChemist(c,CARD_CARBONEDDON) and c:IsAbleToDeckAsCost()
		and Duel.IsExistingMatchingCard(s.oxyfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,2,c)
end
function s.oxyfilter(c)
	return aux.IsCodeOrChemist(c,CARD_OXYGEDDON) and c:IsAbleToDeckAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g1=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,tp)
	local g2=Duel.SelectMatchingCard(tp,s.oxyfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,2,2,g1)
	g1:Merge(g2)
	Duel.SendtoDeck(g1,tp,SEQ_DECKSHUFFLE,REASON_COST)
end
function s.filter(c,e,tp)
	return c:IsCode(CARD_FIRE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
		e:SetLabel(0)
		return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,true,true,POS_FACEUP)
		g:GetFirst():CompleteProcedure()
	end
end

-- Add from GY
function s.gyfilter(c,e,tp)
	return c:IsCode(CARD_CARBONEDDON,CARD_OXYGEDDON) and
		(c:IsAbleToHand() or (c:IsCanBeSpecialSummoned(e,0,tp,false,false) and ft>0))
end
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
  if chk==0 then return Duel.IsExistingTarget(s.gyfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,ft) end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local tg=Duel.SelectTarget(tp,s.gyfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
  Duel.SetOperationInfo(0,CATEGORY_TOHAND,tg,1,tp,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tg,1,tp,LOCATION_GRAVE)
end
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
  local tc=Duel.GetFirstTarget()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if tc and tc:IsRelateToEffect(e) then
		aux.ToHandOrElse(tc,tp,function(c)
			return tc:IsCanBeSpecialSummoned(e,0,tp,false,false) and ft>0 end,
		function(c)
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) end,
		1075) -- Special Summon
	end
end
