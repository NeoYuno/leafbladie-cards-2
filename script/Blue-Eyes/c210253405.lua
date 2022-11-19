-- Blue-Eyes Krystal Dragon
local s,id=GetID()
function s.initial_effect(c)
  -- Special self from hand by bouncing Effect Monster.
  local e1=Effect.CreateEffect(c)
  e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
  e1:SetType(EFFECT_TYPE_QUICK_O)
  e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetRange(LOCATION_HAND)
  e1:SetCountLimit(1,id)
  e1:SetCost(s.spcost)
  e1:SetTarget(s.sptg)
  e1:SetOperation(s.spop)
  c:RegisterEffect(e1)
  -- on battle destroy, draw 2 or special Blue-Eyes
  local e2=Effect.CreateEffect(c)
  e2:SetCategory(CATEGORY_DRAW+CATEGORY_SPECIAL_SUMMON)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
  --e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
  e2:SetCode(EVENT_BATTLE_DESTROYING)
  e2:SetTarget(s.target)
  e2:SetOperation(s.operation)
  c:RegisterEffect(e2)
end
s.listed_names = {CARD_BLUEEYES_W_DRAGON}

-- Special Summon self from hand and bounce the target.
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
function s.spfilter(c)
	return c:IsType(TYPE_MONSTER+TYPE_EFFECT) and c:IsFaceup() and c:IsAbleToHand() and not c:IsCode(id)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.spfilter(chkc) end
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		end
	end
end

-- Filter Level 1 LIGHT Tuner
function s.discfilter(c)
  return c:IsLevel(1) and c:IsType(TYPE_TUNER) and c:IsAttribute(ATTRIBUTE_LIGHT)
    and c:IsDiscardable()
end
-- Filter "Blue-Eyes White Dragon"
function s.bewdfilter(c,e,tp)
  return c:IsCode(CARD_BLUEEYES_W_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- On Battle Destroy, choose 1.
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return
    (Duel.IsPlayerCanDraw(tp,2)
    and Duel.IsExistingMatchingCard(s.discfilter,tp,LOCATION_HAND,0,1,nil))
    or (Duel.GetLocationCount(tp,LOCATION_MZONE)>0
    and Duel.IsExistingMatchingCard(s.bewdfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp))
  end
  local op=0
  -- if can't activate draw eff, use Special Summon effect.
  if not Duel.IsPlayerCanDraw(tp,2) or not Duel.IsExistingMatchingCard(s.discfilter,tp,LOCATION_HAND,0,1,nil) then
    Duel.SelectOption(tp,aux.Stringid(id,1))
    op=1
  -- if can't activate Special Summon eff, use draw effect.
  elseif Duel.GetLocationCount(tp,LOCATION_MZONE) <= 0 or not Duel.IsExistingMatchingCard(s.bewdfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) then
    Duel.SelectOption(tp,aux.Stringid(id,0))
    op=0
  -- if can activate both effects, let player choose.
  else
		op=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
  end
  e:SetLabel(op)

  if op==0 then
    -- Draw effect needs player target flag
    e:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND)
    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(2)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
  else
		e:SetProperty(0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
  end

end

-- draw cards or special summon
function s.operation(e,tp,eg,ep,ev,re,r,rp)
  if e:GetLabel() == 0 then
    -- Discard LIGHT Tuner, then draw 2 cards.
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
    local tg = Duel.SelectMatchingCard(tp,s.discfilter,tp,LOCATION_HAND,0,1,1,nil)
    if #tg > 0 and Duel.SendtoGrave(tg, REASON_EFFECT+REASON_DISCARD) ~= 0 then
    	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
    	Duel.Draw(p,d,REASON_EFFECT)
    end
  else
    -- Special Summon Blue-Eyes (if from GY, apply NecroValleyFilter)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
  	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
  	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.bewdfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
  	if #g>0 then
  		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
  	end
  end
end
