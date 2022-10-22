--Ultimate D Burst
local s,id=GetID()
function s.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
    --Fusion Summon
	local e2=Fusion.CreateSummonEff({handler=c,fusfilter=s.ffilter,matfilter=Card.IsAbleToDeck,
									 extrafil=s.fextra,extraop=Fusion.ShuffleMaterial,stage2=s.desop,extratg=s.extrtarget})
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(aux.bfgcost)
	c:RegisterEffect(e2)
end
s.listed_series={0x8,0xc008}
s.listed_names={76263644}
--Checks for a level 8 or higher D HERO or Destiny End Dragoon
function s.filter(c)
	return c:IsFaceup() and c:IsLevelAbove(8) and (c:IsSetCard(0xc008) or c:IsCode(76263644))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if tc:IsCode(76263644) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
        --Unaffectd by other cards' effects until the end of the next turn
        local e1=Effect.CreateEffect(c)
        e1:SetDescription(3100)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT+EFFECT_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
        e1:SetCode(EFFECT_IMMUNE_EFFECT)
        e1:SetRange(LOCATION_MZONE)
        e1:SetValue(s.efilter)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
        tc:RegisterEffect(e1)
        --Opponent cannot conduct their battle phase
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_FIELD)
        e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
        e2:SetCode(EFFECT_CANNOT_BP)
        e2:SetRange(LOCATION_MZONE)
        e2:SetTargetRange(0,1)
        tc:RegisterEffect(e2)
    else
        local op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
        if op==0 then
            --Unaffectd by other cards' effects until the end of the next turn
            local e1=Effect.CreateEffect(c)
            e1:SetDescription(3100)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT+EFFECT_CANNOT_DISABLE)
            e1:SetCode(EFFECT_IMMUNE_EFFECT)
            e1:SetRange(LOCATION_MZONE)
            e1:SetValue(s.efilter)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
            tc:RegisterEffect(e1)
        else
            --Opponent cannot conduct their battle phase
            local e2=Effect.CreateEffect(c)
            e2:SetType(EFFECT_TYPE_FIELD)
            e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_CANNOT_DISABLE)
            e2:SetCode(EFFECT_CANNOT_BP)
            e2:SetRange(LOCATION_MZONE)
            e2:SetTargetRange(0,1)
            tc:RegisterEffect(e2)
        end
    end
end
function s.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
--A fusion monster that mentions a "HERO" monster as material
function s.ffilter(c)
	return c:IsType(TYPE_FUSION) and c:ListsArchetypeAsMaterial(0x8)
end
--Checks for additional materials that are banished or in GY
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(aux.NecroValleyFilter(Fusion.IsMonsterFilter(Card.IsAbleToDeck)),tp,LOCATION_GRAVE+LOCATION_ONFIELD,0,nil)
end
--Monsters that are not D HEROes and has less ATK than the fusion summoned monster
function s.desfilter(c,atk)
	return c:IsFaceup() and c:GetAttack()<atk and not c:IsSetCard(0xc008)
end
function s.desop(e,tc,tp,mg,chk)
	if chk==0 then
        local atk=tc:GetBaseAttack()
		local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,atk)
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
            Duel.BreakEffect()
            Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
function s.extrtarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,0,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,0,0,LOCATION_ONFIELD)
end