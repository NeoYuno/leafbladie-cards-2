--Red-Eyes Dark Flare Knight
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,210852411,{CARD_DARK_MAGICIAN,s.ffilter})
    --Immune
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.econ)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)
    --Destroy
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_START)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
    --Special Summon if destroyed
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
s.material={210852411,CARD_DARK_MAGICIAN}
s.listed_names={210852411,CARD_DARK_MAGICIAN}
s.material_setcode={0x3b}
function s.ffilter(c,fc,sumtype,tp)
	return c:IsRace(RACE_SPELLCASTER,fc,sumtype,tp) and c:IsType(TYPE_EFFECT,fc,sumtype,tp)
end
function s.econ(e)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end
function s.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetAttacker()==c and Duel.GetAttackTarget()~=nil end
	local g=Duel.GetAttackTarget()
    local atk=e:GetHandler():GetAttack()
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,atk)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	local g=Duel.GetAttackTarget()
	if g and g:IsRelateToBattle() and Duel.Destroy(g,REASON_EFFECT)>0 then
        if c:IsFaceup() and c:IsRelateToEffect(e) then
            local atk=c:GetAttack()
            Duel.Damage(1-tp,atk,REASON_EFFECT)
        end
	end
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return (r&REASON_EFFECT+REASON_BATTLE)~=0
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x3b) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end