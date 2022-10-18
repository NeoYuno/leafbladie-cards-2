-- Blue-Eyes Silver Dragon
local s, id = GetID()
function s.initial_effect(c)
  -- Summon Normal Monster from GY
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id, 0))
  e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
  e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
  e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
  e1:SetCode(EVENT_SUMMON_SUCCESS)
  e1:SetCountLimit(1,id)
  e1:SetTarget(s.sstg)
  e1:SetOperation(s.ssop)
  c:RegisterEffect(e1)
  local e2= e1:Clone()
  e2:SetCode(EVENT_SPSUMMON_SUCCESS)
  c:RegisterEffect(e2)

  -- Change Position, Bounce, then Summon Blue-Eyes
  local e3=Effect.CreateEffect(c)
  e3:SetDescription(aux.Stringid(id, 1))
  e3:SetCategory(CATEGORY_POSITION+CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
  e3:SetType(EFFECT_TYPE_QUICK_O)
  e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
  e3:SetCode(EVENT_FREE_CHAIN)
  e3:SetRange(LOCATION_MZONE)
  e3:SetCountLimit(1,id+100)
  e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_ATTACK)
  e3:SetTarget(s.postg)
  e3:SetOperation(s.posop)
  c:RegisterEffect(e3)
end

s.listed_names = {CARD_BLUEEYES_W_DRAGON}

-- filter Normal Dragon monster
function s.ssfilter(c,e,tp)
  return c:IsType(TYPE_NORMAL) and c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end

-- target Normal Dragon in GY, check if summon allowed.
function s.sstg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.ssfilter(chkc,e,tp) end
  if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE) > 0
    and Duel.IsExistingTarget(s.ssfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end

  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
  local g=Duel.SelectTarget(tp,s.ssfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end

-- Special Summon the Dragon from GY
function s.ssop(e,tp,eg,ep,ev,re,r,rp)
  local tc=Duel.GetFirstTarget()
  if tc and tc:IsRelateToEffect(e) then
    Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
  end
end

-- filter AtkPos monsters except CARDNAME
function s.posfilter(c)
  return c:IsAttackPos() and c:IsCanChangePosition() and not c:IsCode(id)
end

-- filter Blue-Eyes White Dragons
function s.bewdfilter(c,e,tp)
  return c:IsCode(CARD_BLUEEYES_W_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.posfilter(chkc) end
  local c=e:GetHandler()
  if chk==0 then return Duel.IsExistingTarget(s.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
    and c:IsAbleToHand() and Duel.IsExistingMatchingCard(s.bewdfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
    and Duel.GetLocationCount(tp,LOCATION_MZONE) > 0 end

  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
  local g=Duel.SelectTarget(tp,s.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
  Duel.SetOperationInfo(0,CATEGORY_POSITION,g,#g,0,0)
  Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end

function s.posop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  local tc=Duel.GetFirstTarget()
  -- change target position
  if tc and tc:IsRelateToEffect(e) and Duel.ChangePosition(tc, POS_FACEUP_DEFENSE, POS_FACEDOWN_DEFENSE)~=0 then
    -- return self to hand
    if c:IsRelateToEffect(e) and c:IsControler(tp) and Duel.SendtoHand(c,tp,REASON_EFFECT)~=0 then
      -- Special Summon a Blue-Eyes White Dragon from GY, if able.
      if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
      Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
      local g=Duel.SelectMatchingCard(tp,s.bewdfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
      if #g > 0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
      end
    end
  end
end
