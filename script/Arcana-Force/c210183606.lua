--Arcana Force EX - The Chaos Ruler
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_ARCANA_FORCE),5)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,nil,nil,nil,nil,false)
    --Special Summon Limit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
    --Coin Effect
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_COIN)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(s.cointg)
	e1:SetOperation(s.coinop)
	c:RegisterEffect(e1)
    --Special Summon
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.toss_coin=true
s.listed_series={SET_ARCANA_FORCE}
function s.contactfil(tp)
	return Duel.GetMatchingGroup(Card.IsAbleToGraveAsCost,tp,LOCATION_MZONE,0,nil)
end
function s.contactop(g)
	Duel.SendtoGrave(g,REASON_COST+REASON_MATERIAL)
end
--[Coin Effect]
function s.cointg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end
function s.coinop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	s.arcanareg(c,Arcana.TossCoin(c,tp))
end
function s.arcanareg(c,coin)
    --Double ATK/DEF
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.headscon)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_ARCANA_FORCE))
	e1:SetValue(s.val)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
    c:RegisterEffect(e2)
    --Immunity
    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCondition(s.tailscon)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_ARCANA_FORCE))
	e3:SetValue(s.efilter)
	e3:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e3)
	Arcana.RegisterCoinResult(c,coin)
end
function s.val(e,c)
    return c:GetBaseAttack()+c:GetBaseDefense()
end
function s.efilter(e,re)
	return e:GetOwnerPlayer()~=re:GetOwnerPlayer() and re:IsActivated()
end
function s.headscon(e)
	return Arcana.GetCoinResult(e:GetHandler())==COIN_HEADS
end
function s.tailscon(e)
	return Arcana.GetCoinResult(e:GetHandler())==COIN_TAILS
end
--[Special Summon]
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsSummonType(SUMMON_TYPE_FUSION) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_ARCANA_FORCE) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if e:GetHandler():GetSequence()<5 then ft=ft+1 end
	if chk==0 then return ft>1 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,2,nil,e,tp)
		and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND+LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 or Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,2,2,nil,e,tp)
	if #g==2 then
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end