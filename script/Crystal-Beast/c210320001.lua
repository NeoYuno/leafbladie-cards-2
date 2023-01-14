--Crystal Prisma
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon from hand or gy
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
    --Change stats
    local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.cpcost)
	e2:SetOperation(s.cpop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
    --Place a "Crystal Beast" monster from deck
    local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCountLimit(1,{id,2})
	e4:SetTarget(s.tftg)
	e4:SetOperation(s.tfop)
	c:RegisterEffect(e4)
end
s.listed_series={0x1034,0x2034}
--Special Summon from hand or gy
function s.cfilter(c,tp)
	return c:IsSetCard(0x1034) and (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsAbleToGraveAsCost() and Duel.GetMZoneCount(tp,c)>0
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,1,nil,tp)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		 Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
--Change stats
function s.cpfilter(c,code,lv,race,att,atk,def)
	return (c:IsSetCard(0x1034) or c:IsSetCard(0x2034)) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
		and (not c:IsCode(code) or not c:IsLevel(lv) or not c:IsRace(race) or not c:IsAttribute(att) or not c:IsAttack(atk) or not c:IsDefense(def))
end
function s.cpcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.cpfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,c:GetCode(),c:GetLevel(),c:GetRace(),c:GetAttribute(),c:GetBaseAttack(),c:GetBaseDefense()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.cpfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,c:GetCode(),c:GetLevel(),c:GetRace(),c:GetAttribute(),c:GetBaseAttack(),c:GetBaseDefense())
	Duel.SendtoGrave(g,REASON_EFFECT)
	e:SetLabelObject(g:GetFirst())
end
function s.cpop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	if c:IsRelateToEffect(e) and not c:IsFacedown() and tc then
        local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+RESET_OPPO_TURN)
		e1:SetValue(tc:GetCode())
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CHANGE_LEVEL)
		e2:SetValue(tc:GetLevel())
		c:RegisterEffect(e2)
		local e3=e1:Clone()
		e3:SetCode(EFFECT_CHANGE_RACE)
		e3:SetValue(tc:GetRace())
		c:RegisterEffect(e3)
		local e4=e1:Clone()
		e4:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e4:SetValue(tc:GetAttribute())
		c:RegisterEffect(e4)
        local e5=e1:Clone()
        e5:SetCode(EFFECT_SET_BASE_ATTACK)
        e5:SetValue(tc:GetBaseAttack())
        c:RegisterEffect(e5)
        local e6=e1:Clone()
        e6:SetCode(EFFECT_SET_BASE_DEFENSE)
        e6:SetValue(tc:GetBaseDefense())
        c:RegisterEffect(e6)
	end
end
--Place a "Crystal Beast" monster from deck
function s.tffilter(c,tp)
	return c:IsSetCard(0x1034) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
        and not Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,c:GetCode())
end
function s.tftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tffilter,tp,LOCATION_DECK,0,1,nil,tp)
        and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
end
function s.tfop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,s.tffilter,tp,LOCATION_DECK,0,1,1,nil,tp)
	local tc=g:GetFirst()
	if tc then
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		Duel.RaiseEvent(tc,EVENT_CUSTOM+47408488,e,0,tp,0,0)
	end
end