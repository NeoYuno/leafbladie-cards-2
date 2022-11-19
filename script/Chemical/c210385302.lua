-- Metallic Hydrogeddon
-- by MasterQuestMaster
local s, id = GetID()
local CARD_HYDROGEDDON = 22587018
function s.initial_effect(c)
  -- Name change
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
  e1:SetCode(EFFECT_CHANGE_CODE)
  e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
  e1:SetValue(CARD_HYDROGEDDON)
  c:RegisterEffect(e1)

  -- unaffected
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD)
  e2:SetCode(EFFECT_IMMUNE_EFFECT)
  e2:SetRange(LOCATION_MZONE)
  e2:SetTargetRange(LOCATION_MZONE,0)
  e2:SetValue(s.efilter)
  c:RegisterEffect(e2)

  -- Add Bonding S/T
  local e3=Effect.CreateEffect(c)
  e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
  e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
  e3:SetCode(EVENT_SUMMON_SUCCESS)
  e3:SetCountLimit(1,id)
  e3:SetTarget(s.thtg)
  e3:SetOperation(s.thop)
  c:RegisterEffect(e3)
  local e4=e3:Clone()
  e4:SetCode(EVENT_SPSUMMON_SUCCESS)
  c:RegisterEffect(e4)
end
s.listed_names = {CARD_HYDROGEDDON}
s.listed_series = {0x100} --Bonding

-- unaffected
function s.efilter(e,re)
  local c=re:GetHandler()
	return (c:IsRace(RACE_PYRO) or c:IsAttribute(ATTRIBUTE_FIRE)) and re:IsActivated()
end

-- Add Bonding S/T
function s.thfilter(c)
	return c:IsSetCard(0x100) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
function s.ssfilter(c,e,tp,class)
  return class.listed_names and c:IsCode(table.unpack(class.listed_names))
      and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)~=0 then
    local thc=g:GetFirst()
		Duel.ConfirmCards(1-tp,thc)
    local class=Duel.GetMetatable(thc:GetCode())
    if class==nil or class.listed_names==nil then return end
    -- Special Summon a listed monster
    if Duel.IsExistingMatchingCard(s.ssfilter,tp,LOCATION_DECK,0,1,nil,e,tp,class)
    and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then -- Special Summon a monster?
      Duel.BreakEffect()
      Duel.Hint(HINT_SELECTMSG, tp, 509)
      g = Duel.SelectMatchingCard(tp,s.ssfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,class)
      if #g > 0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
      end
    end
	end
end
