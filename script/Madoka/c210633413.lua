-- Homura's Rewind
local s, id = GetID()
local CARD_HOMURA_AKEMI = 210633302
Duel.LoadScript("madoka-utility.lua")
function s.initial_effect(c)
  -- activate
  local e1 = Effect.CreateEffect(c)
  e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetTarget(s.target)
  e1:SetOperation(s.activate)
  c:RegisterEffect(e1)

  -- place in Pendulum Zone
  local e2 = Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetCode(EVENT_FREE_CHAIN)
  e2:SetRange(LOCATION_GRAVE)
  e2:SetCost(aux.bfgcost)
  e2:SetTarget(s.pendtg)
  e2:SetOperation(s.pendop)
  c:RegisterEffect(e2)

  aux.ActInSetTurnIfSetBy(s,c,s.setbyfilter)
end
s.listed_names={CARD_HOMURA_AKEMI}
s.listed_series={0xf72} -- Puella Magi
s.counter_place_list={COUNTER_SPELL}

-- Activatable if set by this card
function s.setbyfilter(c)
  return c:IsCode(CARD_HOMURA_AKEMI)
end

-- Filter for possible materials
function s.mfilter(c)
  return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER) and not c:IsType(TYPE_TOKEN)
end
-- Check if a summonable monster exists
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then
    local mg=Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_MZONE,0,nil)
    return Duel.IsExistingMatchingCard(Card.IsXyzSummonable,tp,LOCATION_EXTRA,0,1,nil,nil,mg)
  end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.tfilter(c,e)
	return c:IsRelateToEffect(e) and c:IsFaceup()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  local g=Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_MZONE,0,nil)
	local xyzg=Duel.GetMatchingGroup(Card.IsXyzSummonable,tp,LOCATION_EXTRA,0,nil,nil,g)
	if #xyzg>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local xyzc=xyzg:Select(tp,1,1,nil):GetFirst()

    -- Register additional effects on summon.
    local se=Effect.CreateEffect(c)
    se:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    se:SetCode(EVENT_SPSUMMON_SUCCESS)
    se:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
    se:SetOperation(s.regop)
    xyzc:RegisterEffect(se)
    -- Summon the monster (after the effect resolves)
		Duel.XyzSummon(tp,xyzc,nil,g,1,99)
	end
end
-- Name change, counters, targeting protection on summon success of the XYZ monster.
function s.regop(e,tp,eg,ep,ev,re,r,rp)
  local rc = e:GetOwner()
  local xyzc=e:GetHandler()

  -- name becomes Homura Akemi
  local e1=Effect.CreateEffect(rc)
  e1:SetDescription(3061)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetCode(EFFECT_CHANGE_CODE)
  e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
  e1:SetValue(CARD_HOMURA_AKEMI)
  e1:SetReset(RESET_EVENT+RESETS_STANDARD)
  xyzc:RegisterEffect(e1)

  -- place up to 2 counters.
  if xyzc:IsCanAddCounter(COUNTER_SPELL,2) then
    scn=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1)) -- Place 1/2 Counters.
    xyzc:AddCounter(COUNTER_SPELL,scn+1)
  elseif xyzc:IsCanAddCounter(COUNTER_SPELL,1) then
    xyzc:AddCounter(COUNTER_SPELL,1)
  end

  -- Targeting Protection
  local og = xyzc:GetOverlayGroup()
  if og:IsExists(Card.IsCode,1,nil,CARD_HOMURA_AKEMI) then
    local e2=Effect.CreateEffect(rc)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetValue(aux.tgoval)
    e2:SetRange(LOCATION_MZONE)
    e2:SetReset(RESET_EVENT+RESETS_STANDARD)
    xyzc:RegisterEffect(e2)
  end
  e:Reset()
end

-- Place in Pendulum Zone
function s.pendfilter(c)
  return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsSetCard(0xf72)
end
function s.pendtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then
    return Duel.IsExistingMatchingCard(s.pendfilter,tp,LOCATION_EXTRA,0,1,nil)
    and (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
  end
end
function s.pendop(e,tp,eg,ep,ev,re,r,rp)
  Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2)) -- Select card to place in PZone.
  local sg = Duel.SelectMatchingCard(tp,s.pendfilter,tp,LOCATION_EXTRA,0,1,1,nil)
  Duel.MoveToField(sg:GetFirst(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
end
