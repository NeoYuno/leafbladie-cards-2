--Red-Eyes Roulette Spider
local s,id=GetID()
function s.initial_effect(c)
	--Change effect
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(s.chcon)
	e1:SetTarget(s.chtg)
	e1:SetOperation(s.chop)
    c:RegisterEffect(e1)
    --Special summon itself as a monster
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_series={0x3b}
function s.chcon(e,tp,eg,ep,ev,re,r,rp)
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return (re:IsActiveType(TYPE_MONSTER) and loc==LOCATION_MZONE)
end
function s.chtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
function s.chop(e,tp,eg,ep,ev,re,r,rp)
    local d=Duel.TossDice(tp,1)
	local g=Group.CreateGroup()
	Duel.ChangeTargetCard(ev,g)
    if d==1 then
        Duel.ChangeChainOperation(ev,s.repop1)
    elseif d==2 then
        Duel.ChangeChainOperation(ev,s.repop2)
    elseif d==3 then
        Duel.ChangeChainOperation(ev,s.repop3)
    elseif d==4 then
        Duel.ChangeChainOperation(ev,s.repop4)
    elseif d==5 then
        Duel.ChangeChainOperation(ev,s.repop5)
    else 
        Duel.ChangeChainOperation(ev,s.repop6)
    end
end
--Halve opponent's LP
function s.repop1(e,tp,eg,ep,ev,re,r,rp)
    Duel.SetLP(1-tp,Duel.GetLP(1-tp)/2)
end
--Burn your opponent
function s.repop2(e,tp,eg,ep,ev,re,r,rp)
    Duel.Damage(1-tp,e:GetHandler():GetAttack(),REASON_EFFECT)
end
--Your opponent destroys a monster they control
function s.repop3(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_DESTROY)
    local dg=Duel.SelectMatchingCard(1-tp,aux.TRUE,1-tp,LOCATION_MZONE,0,1,1,nil)
    Duel.Destroy(dg,REASON_EFFECT)
end
--Destroy another monster you control
function s.repop4(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local dg=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
    Duel.Destroy(dg,REASON_EFFECT)
end
--Burn yourself
function s.repop5(e,tp,eg,ep,ev,re,r,rp)
    Duel.Damage(tp,e:GetHandler():GetAttack(),REASON_EFFECT)
end
--Destroy itself
function s.repop6(e,tp,eg,ep,ev,re,r,rp)
    Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
--
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
function s.filter(c,tp)
    return c:IsFaceup() and c:IsSetCard(0x3b) and c:HasLevel() 
        and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x3b,0x11,0,0,c:GetLevel(),RACE_INSECT,ATTRIBUTE_DARK)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x3b,0x11,0,0,tc:GetLevel(),RACE_INSECT,ATTRIBUTE_DARK) then
		c:AddMonsterAttribute(TYPE_NORMAL)
		c:AssumeProperty(ASSUME_RACE,RACE_INSECT)
		if Duel.SpecialSummonStep(c,0,tp,tp,true,false,POS_FACEUP_DEFENSE) then
            c:AddMonsterAttributeComplete()
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_CHANGE_LEVEL)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            e1:SetValue(tc:GetLevel())
            c:RegisterEffect(e1)
        end
		Duel.SpecialSummonComplete()
	end
end