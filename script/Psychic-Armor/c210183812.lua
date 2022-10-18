--Double Cloth Psychic Armor
local s,id=GetID()
function s.initial_effect(c)
    --Damage and destroy
    local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DAMAGE+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	if s.condition then
		e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_INACTIVATE+EFFECT_FLAG_CANNOT_NEGATE)
	else
		e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	end
	e3:SetCode(EVENT_BATTLE_CONFIRM)
	e3:SetTarget(s.damtg)
	e3:SetOperation(s.damop)
	c:RegisterEffect(e3)
    --Set from deck
    local e4=Effect.CreateEffect(c)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DESTROYED)
    e4:SetCountLimit(1,id)
	e4:SetCondition(s.setcon)
    e4:SetTarget(s.settg)
	e4:SetOperation(s.setop)
	c:RegisterEffect(e4)
end
s.listed_series={0xf102}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_TRIBUTE)
end
--Damage and destroy
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		local a=Duel.GetAttacker()
		if a==c then a=Duel.GetAttackTarget() end
		return a
	end
    Duel.SetTargetPlayer(1-tp)
	local atk=e:GetHandler():GetBattleTarget():GetAttack()
	Duel.SetTargetParam(atk)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,atk)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler():GetBattleTarget(),1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
    local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	local bc=e:GetHandler():GetBattleTarget()
	if bc and bc:IsRelateToBattle() and Duel.Damage(p,d,REASON_EFFECT) then
        Duel.BreakEffect()
		Duel.Destroy(bc,REASON_EFFECT)
        Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	end
end
--Set from deck
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsReason(REASON_EFFECT) and re and re:GetHandler():IsSetCard(0xf102)
end
function s.setfilter(c)
	return c:IsSetCard(0xf102) and c:IsType(TYPE_TRAP+TYPE_SPELL) and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if tc then
		Duel.SSet(tp,tc)
    end
end