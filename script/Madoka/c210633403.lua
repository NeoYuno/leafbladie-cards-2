-- Puella Magi Witch - Homuilly
local s, id = GetID()
local CARD_HOMURA_AKEMI=210633302
Duel.LoadScript("witch-utility.lua")
function s.initial_effect(c)
  c:EnableReviveLimit()
  --cannot link material
  local e0=Effect.CreateEffect(c)
  e0:SetType(EFFECT_TYPE_SINGLE)
  e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
  e0:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
  e0:SetValue(1)
  c:RegisterEffect(e0)
  -- Witch Summon (to either field, by tributing a monster you control)
  local e1,e2,e3 = aux.AddWitchProcedure(c,s.sprfilter,aux.Stringid(id,0),aux.Stringid(id,1))

  -- Banish monsters on Summon.
  local e4=Effect.CreateEffect(c)
  e4:SetCategory(CATEGORY_REMOVE)
  e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e4:SetCode(EVENT_SPSUMMON_SUCCESS)
  e4:SetProperty(EFFECT_FLAG_DELAY)
  e4:SetRange(LOCATION_MZONE)
  e4:SetCondition(aux.zptcon(s.rmfilter))
	e4:SetTarget(s.rmtg)
	e4:SetOperation(s.rmop)
	c:RegisterEffect(e4)

  -- GY effect: Special Summon
  local e5=Effect.CreateEffect(c)
  e5:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_COUNTER)
  e5:SetType(EFFECT_TYPE_IGNITION)
  e5:SetCode(EVENT_FREE_CHAIN)
  e5:SetRange(LOCATION_GRAVE)
  e5:SetCountLimit(1,id)
  e5:SetCost(s.sscost)
  e5:SetTarget(s.sstg)
  e5:SetOperation(s.ssop)
  c:RegisterEffect(e5)
end
s.listed_names={CARD_HOMURA_AKEMI}
s.listed_series={0xf72}
s.counter_place_list={COUNTER_SPELL}

-- Filter for Witch Tribute
function s.sprfilter(c)
	return c:IsCode(CARD_HOMURA_AKEMI) and c:GetCounter(COUNTER_SPELL) == 0
end
-- Banish monsters on Summon.
function s.rmfilter(c)
  return not c:IsSetCard(0xf72) and c:IsAbleToRemove()
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=aux.zptgroup(eg,s.rmfilter,e:GetHandler(),tp)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  --Zone points to group (only for summoned monsters), excluding PM.
	local g=aux.zptgroup(eg,s.rmfilter,c,tp)

  if #g>0 then
    -- Remove each of the cards until your next Standby.
		for tc in aux.Next(g) do
			Duel.Remove(tc,tc:GetPosition(),REASON_EFFECT+REASON_TEMPORARY)
		end

    -- 1 Return effect for all.
		local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,2))
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN)
		e1:SetCountLimit(1)
		e1:SetCondition(s.retcon)
		e1:SetOperation(s.retop)
		e1:SetLabelObject(g)
		Duel.RegisterEffect(e1,tp)
		g:KeepAlive() --needed to keep reference.
	end
end
-- Return from banished Condition/Operation
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	return tp==Duel.GetTurnPlayer()
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	for tc in aux.Next(e:GetLabelObject()) do
		Duel.ReturnToField(tc)
	end
end
-- GY effect: Special Summon.
function s.sscost(e,tp,eg,ep,ev,re,r,rp,chk)
  local c=e:GetHandler()
  if chk==0 then return c:IsAbleToDeckOrExtraAsCost() end
  Duel.SendtoDeck(c,tp,SEQ_DECKSHUFFLE,REASON_COST)
end
function s.ssfilter(c,e,tp)
  return c:IsCode(CARD_HOMURA_AKEMI) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
    and ((c:IsFaceup() and Duel.GetLocationCountFromEx(tp) > 0)
    or (Duel.GetLocationCount(tp,LOCATION_MZONE) > 0 and not c:IsLocation(LOCATION_EXTRA)))
end
function s.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then
    return Duel.IsExistingMatchingCard(s.ssfilter,tp,LOCATION_HAND+LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil,e,tp)
  end
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_EXTRA+LOCATION_GRAVE)
end
function s.ssop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.ssfilter),tp,LOCATION_HAND+LOCATION_EXTRA+LOCATION_GRAVE,0,1,1,nil,e,tp)
    if #g>0 and Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)>0 and g:GetFirst():IsCanAddCounter(COUNTER_SPELL,2) then
      g:GetFirst():AddCounter(COUNTER_SPELL,2)
    end
end
