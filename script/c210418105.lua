--King of Darkness Yamimakai
local s,id=GetID()
function s.initial_effect(c)
    --Special Summon
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
    --Atk Up
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(e3)
    --Attack In Defense
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_DEFENSE_ATTACK)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetTarget(s.atktg)
	e4:SetValue(1)
	c:RegisterEffect(e4)
end
function s.tgfilter(c)
    return (c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK) and c:IsLocation(LOCATION_MZONE)) or c:IsFacedown() and c:IsDestructable()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local c=e:GetHandler()
    if chkc then return chkc:IsOnField() and s.tgfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,2,nil) 
        and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,2,2,nil)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,2,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local g=Duel.GetTargetCards(e)
    local fg=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    if not c:IsRelateToEffect(e) or not Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) then return end
    if #g>0 and Duel.Destroy(g,REASON_EFFECT)>0 then
        local og=Duel.GetOperatedGroup()
        if not og:IsExists(Card.IsPreviousControler,1,nil,1-tp) and #fg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
            Duel.Destroy(fg,REASON_EFFECT)
        end
	end
end

function s.atkfilter(c)
    return c:IsFacedown() or c:IsAttribute(ATTRIBUTE_DARK)
end
function s.atkval(e,c)
	return Duel.GetMatchingGroupCount(s.atkfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,LOCATION_ONFIELD,nil)*300
end

function s.atktg(e,c)
    local atk=c:GetAttack()
    local def=c:GetDefense()
	return c:IsAttribute(ATTRIBUTE_DARK) and (atk%50~=0 or def%50~=0)
end