-- Mitakihara City
local s, id = GetID()
function s.initial_effect(c)
  -- activate
  local e1 = Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetOperation(s.activate)
  c:RegisterEffect(e1)

  -- Add from Deck on Witch Summon
  local e2 = Effect.CreateEffect(c)
  e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
  e2:SetCode(EVENT_SPSUMMON_SUCCESS)
  e2:SetProperty(EFFECT_FLAG_DELAY)
  e2:SetRange(LOCATION_FZONE)
  e2:SetCountLimit(1)
  e2:SetCondition(s.thcon)
  e2:SetTarget(s.thtg)
  e2:SetOperation(s.thop)
  c:RegisterEffect(e2)

  -- Distribute counters on leave.
  local e3=Effect.CreateEffect(c)
  e3:SetCategory(CATEGORY_COUNTER)
  e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e3:SetCode(EVENT_LEAVE_FIELD)
  --e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
  e3:SetRange(LOCATION_FZONE)
  e3:SetCondition(s.cntcon)
  e3:SetTarget(s.cnttg)
  e3:SetOperation(s.cntop)
  c:RegisterEffect(e3)

end
s.listed_series={0xf72,0x1f72}
s.listed_names={210633301}
s.counter_place_list={COUNTER_SPELL}

-- Place to PZone on Activation
function s.tpzfilter(c)
	return (c:IsCode(210633301) or (c:IsSetCard(0xf72) and c:IsType(TYPE_PENDULUM)))
    and not c:IsForbidden()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
  -- only ask for pzone if there is space.
	if not e:GetHandler():IsRelateToEffect(e) or (not Duel.CheckLocation(tp,LOCATION_PZONE,0)
    and not Duel.CheckLocation(tp,LOCATION_PZONE,1)) then return end

	local g=Duel.GetMatchingGroup(s.tpzfilter,tp,LOCATION_DECK,0,nil)
  -- for field spells, no target func, ask in activate func.
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local sg=g:Select(tp,1,1,nil)
    Duel.MoveToField(sg:GetFirst(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end

-- Add from Deck on Witch Summon
function s.witchfil(c,tp)
  return c:IsFaceup() and c:IsSetCard(0x1f72) and c:IsControler(1-tp)
end
function s.thcon(e, tp, eg, ep, ev, re, r, rp)
  return eg:IsExists(s.witchfil,1,nil,tp)
end
function s.thfilter(c)
  return c:IsSetCard(0xf72) and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
function s.thtg(e, tp, eg, ep, ev, re, r, rp, chk)
  if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
  Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,0)
end
function s.thop(e, tp, eg, ep, ev, re, r, rp)
  if not e:GetHandler():IsRelateToEffect(e) then return end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
  local g = Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
  if #g > 0 then
    Duel.SendtoHand(g,tp,REASON_EFFECT)
  end
end

-- Place Spell Counters
function s.witchfil2(c)
  return c:IsPreviousSetCard(0x1f72) and c:IsPreviousLocation(LOCATION_MZONE)
    and c:IsPreviousPosition(POS_FACEUP) and c:IsType(TYPE_LINK)
end
function s.cntcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.witchfil2,1,nil)
end
function s.cntfilter(c)
  return c:IsFaceup() and c:IsSetCard(0xf72) and c:IsCanAddCounter(COUNTER_SPELL,1)
end
function s.cnttg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk == 0 then return Duel.IsExistingMatchingCard(s.cntfilter,tp,LOCATION_ONFIELD,0,1,nil) end
end
function s.cntop(e,tp,eg,ep,ev,re,r,rp,chk)
  -- Get the sum of Link rating (max counters to place) and the targets for counter placing
  local cnt = eg:Filter(s.witchfil2,nil):GetSum(Card.GetLink)
  local tg = Duel.GetMatchingGroup(s.cntfilter,tp,LOCATION_ONFIELD,0,nil)

  if cnt > 0 and #tg > 0 then
    for i=1,cnt do
			-- Can place any spell counters? if not, cancel
			tg = tg:Filter(Card.IsCanAddCounter,nil,COUNTER_SPELL,1)
			if #tg<=0 then break end
			-- let player choose a card for the next spell counter.
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COUNTER)
			local selg = tg:Select(tp,1,1,true)
			-- check if canceled
			if selg == nil or #selg == 0 then break end
			selg:GetFirst():AddCounter(COUNTER_SPELL,1)
		end
  end
end
