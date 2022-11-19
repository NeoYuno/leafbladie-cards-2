-- Tidal Blast
-- by MasterQuestMaster
local s, id = GetID()
local CARD_WATER_DRAGON = 85066822
function s.initial_effect(c)
  -- activate
  local e1 = Effect.CreateEffect(c)
  e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetCountLimit(1,id)
  e1:SetTarget(s.target)
  e1:SetOperation(s.activate)
  c:RegisterEffect(e1)

  -- GY eff
  local e2 = Effect.CreateEffect(c)
  e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_TODECK)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
  e2:SetRange(LOCATION_GRAVE)
  e2:SetCountLimit(1,{id,1})
  e2:SetTarget(s.thtg)
  e2:SetOperation(s.thop)
  c:RegisterEffect(e2)
end
s.listed_names={CARD_WATER_DRAGON}
s.listed_series={0x100}

function s.ssfilter(c,e,tp)
  return c:IsCode(CARD_WATER_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
  local gydino=Duel.GetMatchingGroup(Card.IsRace,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil,RACE_DINOSAUR)
	local cnt=gydino:GetClassCount(Card.GetAttribute)
  -- bX = show option x in option select.
	local b1=Duel.IsExistingMatchingCard(s.ssfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
  local b2=true
  local b3=true
  local b4=true
  -- There is always a true option, so only cnt is important.
	if chk==0 then return cnt>0 end
	local sel=0 -- selected options as bits
	local off=0

  -- choose multiple options
	repeat
		local ops={} -- option texts
		local opval={} -- option values
		off=1
    -- Summon Water Dragon
		if b1 then
			ops[off]=aux.Stringid(id,0)
			opval[off-1]=1
			off=off+1
		end
    -- Water Dragon attack all.
    if b2 then
  		ops[off]=aux.Stringid(id,1)
  		opval[off-1]=2
  		off=off+1
    end
    -- Water Dragon unaffected
    if b3 then
  		ops[off]=aux.Stringid(id,2)
  		opval[off-1]=3
  		off=off+1
    end
    -- become Fire/Pyro.
    if b4 then
      ops[off]=aux.Stringid(id,3)
      opval[off-1]=4
      off=off+1
    end

    -- Once the option was selected, the related b-val is false so the option is not available the next time.
    -- sel stores all the selections as binary, that's why it's + 1,2,4 in the original. 8 is the next.
		local op=Duel.SelectOption(tp,table.unpack(ops))
		if opval[op]==1 then
			sel=sel+1
			b1=false
		elseif opval[op]==2 then
			sel=sel+2
			b2=false
    elseif opval[op]==3 then
      sel=sel+4
      b3=false
		else
			sel=sel+8
			b4=false
		end
		cnt=cnt-1
    -- off < 3 means that there is only 1 option available.
	until cnt==0 or off<3 or not Duel.SelectYesNo(tp,aux.Stringid(id,4))
	e:SetLabel(sel)
	if (sel&1)~=0 then
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,0,tp,LOCATION_HAND+LOCATION_GRAVE)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local sel=e:GetLabel()
  -- 1: Special Summon Water Dragon
	if (sel&1)~=0 then
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sg=Duel.SelectMatchingCard(tp,s.ssfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)

    if #sg > 0 then
      Duel.SpecialSummon(sg,0,tp,tp,true,false,POS_FACEUP)
    end
	end
  -- 2: Water Dragon attack all opp. monsters.
	if (sel&2)~=0 then
    local e1=Effect.CreateEffect(c)
  	e1:SetType(EFFECT_TYPE_FIELD)
  	e1:SetCode(EFFECT_ATTACK_ALL)
  	e1:SetTargetRange(LOCATION_MZONE,0)
  	e1:SetTarget(aux.TargetBoolFunction(Card.IsCode,CARD_WATER_DRAGON))
  	e1:SetValue(1)
		e1:SetReset(RESET_PHASE+PHASE_END)
  	Duel.RegisterEffect(e1,tp)
    aux.RegisterClientHint(c,0,tp,1,0,aux.Stringid(id,1))
	end
  -- 3: Water Dragon unaffected
	if (sel&4)~=0 then
    local e2=Effect.CreateEffect(c)
  	e2:SetType(EFFECT_TYPE_FIELD)
  	e2:SetCode(EFFECT_IMMUNE_EFFECT)
  	e2:SetTargetRange(LOCATION_MZONE,0)
  	e2:SetTarget(aux.TargetBoolFunction(Card.IsCode,CARD_WATER_DRAGON))
  	e2:SetValue(s.immfilter)
		e2:SetReset(RESET_PHASE+PHASE_END)
  	Duel.RegisterEffect(e2,tp)
    aux.RegisterClientHint(c,0,tp,1,0,aux.Stringid(id,2))
	end
  -- Opponent's monsters become Fire Pyro.
  if (sel&8)~=0 then
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_CHANGE_ATTRIBUTE)
    e3:SetTargetRange(0,LOCATION_MZONE)
    e3:SetValue(ATTRIBUTE_FIRE)
    e3:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e3,tp)
    local e4=e3:Clone()
    e4:SetCode(EFFECT_CHANGE_RACE)
    e4:SetValue(RACE_PYRO)
    Duel.RegisterEffect(e4,tp)
  end
end
-- Filter for being unaffected
function s.immfilter(e,re)
  return e:GetOwnerPlayer()~=re:GetOwnerPlayer()
end

-- GY eff: Add Dinosaur & Bonding.
function s.tgfilter(c)
  return c:IsCode(CARD_WATER_DRAGON) and c:IsAbleToDeck()
end
function s.dinofil(c)
  return c:IsRace(RACE_DINOSAUR) and c:IsAbleToHand()
end
function s.bondfil(c)
  -- Type Normal is for Normal Monster, so check with exact equal instead.
  return c:IsSetCard(0x100) and (c:GetType()==TYPE_SPELL or c:GetType()==TYPE_TRAP) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tgfilter(chkc) end
  if chk == 0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_GRAVE,0,1,nil)
    and Duel.IsExistingMatchingCard(s.dinofil,tp,LOCATION_DECK,0,1,nil)
    and Duel.IsExistingMatchingCard(s.bondfil,tp,LOCATION_DECK,0,1,nil)
    and e:GetHandler():IsAbleToDeck() end

  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
  local tg=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_GRAVE,0,1,1,nil)

  Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
  if #tg > 0 then
    local tdg=Group.FromCards(e:GetHandler())
    tdg:AddCard(tg:GetFirst())
    Duel.SetOperationInfo(0,CATEGORY_TODECK,tdg,#tdg,tp,0)
  end
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  local tc=Duel.GetFirstTarget()

  if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		local g=Group.FromCards(c,tc)
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		Duel.BreakEffect()
		-- Add Dino and Bonding S/T
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g1=Duel.SelectMatchingCard(tp,s.dinofil,tp,LOCATION_DECK,0,1,1,nil)
    local g2=Duel.SelectMatchingCard(tp,s.bondfil,tp,LOCATION_DECK,0,1,1,nil)
    g1:Merge(g2)

    if #g1 > 0 then
      Duel.SendtoHand(g1,tp,REASON_EFFECT)
      Duel.ConfirmCards(1-tp,g1)
    end
	end
end
