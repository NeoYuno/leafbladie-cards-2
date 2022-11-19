--Red-Eyes Insect Queen
local s,id=GetID()
function s.initial_effect(c)
    --Immune
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x3b))
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)
    --Equip
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
    e2:SetCondition(s.eqcon)
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)
	aux.AddEREquipLimit(c,s.eqcon,s.eqval,s.equipop,e2)
    --Token
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOKEN+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetCondition(s.tokencon)
    e3:SetTarget(s.tokentg)
	e3:SetOperation(s.tokenop)
	c:RegisterEffect(e3)
    --Special summon
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e4:SetCode(EVENT_TO_GRAVE)
    e4:SetCountLimit(1,id)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
s.listed_series={0x3b}
function s.efilter(e,re)
	return e:GetHandlerPlayer()~=re:GetOwnerPlayer() and re:IsActiveType(TYPE_MONSTER)
		and re:GetOwner():IsRace(RACE_INSECT)
end
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetHandler():GetEquipGroup():Filter(s.eqconfilter,nil)
	return #g==0
end
function s.eqconfilter(c)
	return c:GetFlagEffect(id)==0 
end
function s.eqval(ec,c,tp)
	return ec:IsControler(tp) and ec:IsSetCard(0x3b)
end
function s.eqfilter(c)
	return c:IsSetCard(0x3b) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_HAND+LOCATION_ONFIELD)
end
function s.equipop(c,e,tp,tc)
	c:EquipByEffectAndLimitRegister(e,tp,tc,nil,true)
    --Atk boost
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OWNER_RELATE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(s.atkval)
	tc:RegisterEffect(e1)
    --Change race
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EFFECT_CHANGE_RACE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,0xff)
    e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	e2:SetValue(RACE_INSECT)
	tc:RegisterEffect(e2)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,e:GetHandler())
	local tc=g:GetFirst()
	if tc then
		s.equipop(c,e,tp,tc)
	end
end
function s.atkval(e,c)
    local cg=Duel.GetMatchingGroup(Card.IsRace,c:GetControler(),LOCATION_MZONE,LOCATION_MZONE,nil,RACE_INSECT)
	return #cg*200
end
function s.tokencon(e,tp,eg,ep,ev,re,r,rp)
	return aux.bdocon(e,tp,eg,ep,ev,re,r,rp) and e:GetHandler():CanChainAttack()
end
function s.tokentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,210852442,0x3b,TYPES_TOKEN,100,100,1,RACE_INSECT,ATTRIBUTE_DARK) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.tokenop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
		and Duel.IsPlayerCanSpecialSummonMonster(tp,210852442,0x3b,TYPES_TOKEN,100,100,1,RACE_INSECT,ATTRIBUTE_DARK) then
		local token=Duel.CreateToken(tp,210852442)
		if Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)>0 then
            Duel.ChainAttack()
        end
	end
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x3b) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end