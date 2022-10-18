-- Doppel Release
local s, id = GetID()
local CARD_ULTIMATE_MADOKA = 210633308
function s.initial_effect(c)
  -- activate
  local e1 = Effect.CreateEffect(c)
  e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_COUNTER)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetCountLimit(1,id)
  e1:SetCost(s.cost)
  e1:SetTarget(s.target)
  e1:SetOperation(s.operation)
  c:RegisterEffect(e1)

  -- add to hand from GY
  local e2=Effect.CreateEffect(c)
  e2:SetCategory(CATEGORY_TOHAND)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetCode(EVENT_FREE_CHAIN)
  e2:SetRange(LOCATION_GRAVE)
  e2:SetCountLimit(1,id+2)
  e2:SetCost(s.thcost)
  e2:SetTarget(s.thtg)
  e2:SetOperation(s.thop)
  c:RegisterEffect(e2)

  if not GhostBelleTable then GhostBelleTable={} end
  table.insert(GhostBelleTable,e2)
end
s.listed_series={0xf72,0x1f72}
s.listed_names={CARD_ULTIMATE_MADOKA}
s.counter_place_list={COUNTER_SPELL}

-- Reveal Ultimate Madoka from Extra
function s.cost(e, tp, eg, ep, ev, re, r, rp, chk)
  if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_EXTRA,0,1,nil,CARD_ULTIMATE_MADOKA) end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
  local g=Duel.SelectMatchingCard(tp,Card.IsCode,tp,LOCATION_EXTRA,0,1,1,nil,CARD_ULTIMATE_MADOKA)
  Duel.ConfirmCards(1-tp,g)
end
-- Puella Magi
function s.tgfilter(c)
  return c:IsSetCard(0xf72) and c:IsType(TYPE_PENDULUM)
end
--Witch filter
function s.ssfilter(c,e,tp)
  return c:IsSetCard(0x1f72) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- Target Puella Magi Pend monster.
function s.target(e, tp, eg, ep, ev, re, r, rp, chk)
  if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,0,1,nil)
    and Duel.GetLocationCountFromEx(tp) > 0 and Duel.IsExistingMatchingCard(s.ssfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end

  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COUNTER)
  local tg=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil)
  Duel.SetOperationInfo(0,CATEGORY_COUNTER,tg,1,0,0)
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end

function s.operation(e, tp, eg, ep, ev, re, r, rp)
  local tc=Duel.GetFirstTarget()
  -- Special Summon Witch
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
  local sg=Duel.SelectMatchingCard(tp,s.ssfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
  local sc=sg:GetFirst()
  if sc and Duel.SpecialSummonStep(sc,0,tp,tp,true,false,POS_FACEUP) then
    -- Shuffle into Deck during End Phase.
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_PHASE+PHASE_END)
    e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetOperation(s.tdop)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    sc:RegisterEffect(e1,true)
    sc:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,0))

    -- Place up to 3 counters on target.
    if tc and tc:IsRelateToEffect(e) then
      local counter = 0
  		for i=1,3 do
  			if tc:IsCanAddCounter(COUNTER_SPELL, i) then counter=i end
  		end
  		if counter > 1 then
        Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
  			counter=Duel.AnnounceLevel(tp,1,counter)
  			tc:AddCounter(COUNTER_SPELL,counter)
  		elseif counter > 0 then
  			tc:AddCounter(COUNTER_SPELL,1)
  		end
    end
  end
  Duel.SpecialSummonComplete()
end
-- Shuffle back into Deck.
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	Duel.SendtoDeck(e:GetHandler(),nil,2,REASON_EFFECT)
end

-- Add from GY
function s.thcost(e, tp, eg, ep, ev, re, r, rp, chk)
  if chk==0 then return Duel.IsCanRemoveCounter(tp,LOCATION_ONFIELD,0,COUNTER_SPELL,3,REASON_COST) end
  Duel.RemoveCounter(tp,LOCATION_ONFIELD,0,COUNTER_SPELL,3,REASON_COST)
end

function s.thtg(e, tp, eg, ep, ev, re, r, rp, chk)
  if chk==0 then return e:GetHandler():IsAbleToHand() end
  Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end

function s.thop(e, tp, eg, ep, ev, re, r, rp)
  if e:GetHandler():IsRelateToEffect(e) then
    Duel.SendtoHand(e:GetHandler(),tp,REASON_EFFECT)
  end
end
