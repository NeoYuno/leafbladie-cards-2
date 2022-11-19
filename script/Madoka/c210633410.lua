-- Incubator's Entropy Solution
local s, id = GetID()
function s.initial_effect(c)
  -- activate
  local e1 = Effect.CreateEffect(c)
  e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
  e1:SetHintTiming(0,TIMING_END_PHASE)
  e1:SetCountLimit(1,id)
  e1:SetTarget(s.target)
  e1:SetOperation(s.operation)
  c:RegisterEffect(e1)

  local e2 = Effect.CreateEffect(c)
  e2:SetCategory(CATEGORY_TOHAND)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetCode(EVENT_LEAVE_FIELD)
  e2:SetRange(LOCATION_GRAVE)
  e2:SetCountLimit(1,id+2)
  e2:SetCondition(s.thcon)
  e2:SetTarget(s.thtg)
  e2:SetOperation(s.thop)
  c:RegisterEffect(e2)

  if not AshBlossomTable then AshBlossomTable={} end
  table.insert(AshBlossomTable,e1)

  if not GhostBelleTable then GhostBelleTable={} end
  table.insert(GhostBelleTable,e2)
end
s.listed_series={0xf72,0x1f72}

-- Destroy, then Special Summon Witch to opponent, then draw 2.
function s.pmfilter(c,e,tp)
  return c:IsType(TYPE_PENDULUM) and c:IsSetCard(0xf72) and (c:IsFaceup() or not c:IsOnField())
    and Duel.IsExistingMatchingCard(s.ssfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c) and c:IsDestructable()
end
-- Witch filter that lists the destroyed card.
function s.ssfilter(c,e,tp,pc)
  return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x1f72) and c:IsCanBeSpecialSummoned(e,0,tp,true,false,POS_FACEUP,(1-tp))
    and c:ListsCode(pc:GetCode())
end

function s.target(e, tp, eg, ep, ev, re, r, rp, chk)
  if chk == 0 then return Duel.IsExistingMatchingCard(s.pmfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_PZONE,0,1,nil,e,tp)
    and Duel.GetLocationCountFromEx(1-tp) > 0 and Duel.IsPlayerCanDraw(tp,2) end

  Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_PZONE)
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
  Duel.SetTargetPlayer(tp)
  Duel.SetTargetParam(2)
  Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end

function s.operation(e, tp, eg, ep, ev, re, r, rp)
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
  local tg=Duel.SelectMatchingCard(tp,s.pmfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_PZONE,0,1,1,nil,e,tp)
  if Duel.Destroy(tg,REASON_EFFECT) > 0 and Duel.GetLocationCountFromEx(1-tp) > 0 then
    Duel.BreakEffect()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sg=Duel.SelectMatchingCard(tp,s.ssfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tg:GetFirst())

    if Duel.SpecialSummon(sg,0,tp,(1-tp),true,false,POS_FACEUP) > 0 then
      local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
      Duel.Draw(p,d,REASON_EFFECT)
    end
  end
end

-- Add from GY to hand
function s.witchfil(c)
  return c:IsSetCard(0x1f72) and c:IsType(TYPE_MONSTER)
end
function s.thcon(e, tp, eg, ep, ev, re, r, rp)
  return eg:IsExists(s.witchfil,1,nil)
end
function s.thtg(e, tp, eg, ep, ev, re, r, rp, chk)
  if chk==0 then return e:GetHandler():IsAbleToHand() end
  Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function s.thop(e, tp, eg, ep, ev, re, r, rp)
  local c=e:GetHandler()
  if c:IsRelateToEffect(e) then
    Duel.SendtoHand(c,tp,REASON_EFFECT)
  end
end
