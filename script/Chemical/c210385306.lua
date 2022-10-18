-- Bonding - CO
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

  -- Add from GY
  local e2=Effect.CreateEffect(c)
  e2:SetCategory(CATEGORY_TOHAND)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetRange(LOCATION_GRAVE)
  e2:SetCountLimit(1,id)
	e2:SetCost(s.gycost)
  e2:SetTarget(s.gytg)
  e2:SetOperation(s.gyop)
  c:RegisterEffect(e2)
end
s.listed_names={CARD_CARBONEDDON,CARD_FIRE_DRAGON,CARD_OXYGEDDON}

function s.spcheck(sg,tp)
	return aux.ReleaseCheckMMZ(sg,tp) and sg:IsExists(s.chk,1,nil,sg)
end
function s.chk(c,sg)
	return aux.IsCodeOrChemist(c,CARD_OXYGEDDON) and sg:IsExists(aux.IsCodeOrChemist,1,c,CARD_CARBONEDDON)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,aux.IsCodeOrChemist,2,true,s.spcheck,nil,CARD_CARBONEDDON,CARD_OXYGEDDON) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local sg=Duel.SelectReleaseGroupCost(tp,aux.IsCodeOrChemist,2,2,true,s.spcheck,nil,CARD_CARBONEDDON,CARD_OXYGEDDON)
	Duel.Release(sg,REASON_COST)
end
function s.filter(c,e,tp)
	return c:IsCode(CARD_FIRE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
		e:SetLabel(0)
		return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,true,true,POS_FACEUP)
		g:GetFirst():CompleteProcedure()
	end
end

-- Add from GY
function s.costfil(c)
	-- shuffles as cost, so also affected by chemist.
	local e=c:IsHasEffect(CARD_LEGENDARY_CHEMIST) -- const from utility.
  return (c:IsRace(RACE_DINOSAUR) or (e~=nil and not e:GetHandler():IsDisabled())) and c:IsAbleToDeckAsCost()
end
function s.gycost(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(s.costfil,tp,LOCATION_GRAVE,0,2,nil) end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
  local g=Duel.SelectMatchingCard(tp,s.costfil,tp,LOCATION_GRAVE,0,2,2,nil)
  Duel.SendtoDeck(g,tp,SEQ_DECKSHUFFLE,REASON_COST)
end
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return e:GetHandler():IsAbleToHand() end
  Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  if c:IsRelateToEffect(e) then
    Duel.SendtoHand(c,tp,REASON_EFFECT)
  end
end
