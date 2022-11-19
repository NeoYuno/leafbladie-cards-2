-- Kisara
local s,id=GetID()
function s.initial_effect(c)
  --Synchro summon
  Synchro.AddProcedure(c,nil,2,2,Synchro.NonTuner(nil),1,99)
  c:EnableReviveLimit()
  --act limit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_FZONE)
	e1:SetOperation(s.chainop)
	c:RegisterEffect(e1)
  -- change battle positions
  local e2=Effect.CreateEffect(c)
  e2:SetDescription(aux.Stringid(id,0))
  e2:SetCategory(CATEGORY_POSITION+CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
  e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
  e2:SetType(EFFECT_TYPE_QUICK_O)
  e2:SetCode(EVENT_FREE_CHAIN)
  e2:SetRange(LOCATION_MZONE)
  e2:SetCountLimit(1)
  e2:SetTarget(s.postg)
  e2:SetOperation(s.posop)
  c:RegisterEffect(e2)
  -- negate targeting effect
  local e3=Effect.CreateEffect(c)
  e3:SetDescription(aux.Stringid(id,1))
  e3:SetCategory(CATEGORY_NEGATE+CATEGORY_SPECIAL_SUMMON)
  e3:SetType(EFFECT_TYPE_QUICK_O)
  e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
  e3:SetCode(EVENT_CHAINING)
  e3:SetRange(LOCATION_MZONE)
  e3:SetCountLimit(1)
  e3:SetCondition(s.negcon)
  e3:SetTarget(s.negtg)
  e3:SetOperation(s.negop)
  c:RegisterEffect(e3)
  
end
s.listed_series={0xdd}

function s.chainop(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) or not re:GetHandler():IsControler(tp) then return false end
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if tg and tg:IsExists(Card.IsLocation,1,nil,tp,LOCATION_ONFIELD) then
		Duel.SetChainLimit(s.chainlm)
	end
end
function s.chainlm(e,rp,tp)
	return tp==rp
end

-- [Position Change effect]
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsCanChangePosition() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsCanChangePosition,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local g=Duel.SelectTarget(tp,Card.IsCanChangePosition,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,#g,0,0)
end

function s.posop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  local tc=Duel.GetFirstTarget()
	if tc and Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK) ~= 0 then
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_SET_ATTACK_FINAL)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetValue(0)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    tc:RegisterEffect(e1,true)
    local e2=e1:Clone()
    e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
    tc:RegisterEffect(e2,true)
	end
end

-- [Negate targeting effect]
-- filter cards you control.
function s.targfilter(c,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_ONFIELD)
end
-- Filter Blue-Eyes for SS ignoring conditions.
function s.befilter(c,e,tp)
  return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xdd) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
  and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- Check if the related effect can be negated.
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return g and g:IsExists(s.targfilter,1,nil,tp) and Duel.IsChainNegatable(ev)
end
-- Check the "Blue-Eyes" monster Special Summon
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
    and Duel.IsExistingMatchingCard(s.befilter, tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA+LOCATION_GRAVE)
end
-- Negate, then Special "Blue-Eyes" monster
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) then
    -- Negated S/T without target go to GY.
    if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsRelateToEffect(re) then
		    Duel.SendtoGrave(eg,REASON_EFFECT)
    end
    -- Special Summon "Blue-Eyes" monster
    if Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 then
      Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
      local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.befilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA+LOCATION_GRAVE,0,1,1,nil,e,tp)
      if #g>0 then
        local tc=g:GetFirst()
        if Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)~=0 and tc:IsNonEffectMonster() then
          --Double ATK/DEF
          local e1=Effect.CreateEffect(e:GetHandler())
          e1:SetType(EFFECT_TYPE_SINGLE)
          e1:SetCode(EFFECT_SET_ATTACK_FINAL)
          e1:SetRange(LOCATION_MZONE)
          e1:SetValue(tc:GetAttack()*2)
          e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
          tc:RegisterEffect(e1)
          local e2=e1:Clone()
          e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
          e2:SetValue(tc:GetDefense()*2)
          tc:RegisterEffect(e2)
        end
      end
    end
	end
end
