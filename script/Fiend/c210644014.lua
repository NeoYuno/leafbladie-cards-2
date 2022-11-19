--Contract of Darkness
local s,id=GetID()
function s.initial_effect(c)
    Ritual.AddProcEqual(c,s.ritualfil,nil,nil,s.extrafil,s.extraop)
    --Destroy replace
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetTarget(s.reptg)
	e1:SetValue(s.repval)
	e1:SetOperation(s.repop)
	c:RegisterEffect(e1)
end
s.listed_names={97642679,210644007}

--Ritual materials
function s.ritualfil(c)
    return c:IsRace(RACE_FIEND) and c:IsLevel(8) and c:IsRitualMonster()
end
function s.mfilter(c)
    return c:HasLevel() and c:IsRace(RACE_FIEND) and c:IsNonEffectMonster() and c:IsAbleToGrave()
end
function s.extrafil(e,tp,eg,ep,ev,re,r,rp,chk)
    return Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_DECK,0,nil)
end
function s.extraop(mg,e,tp,eg,ep,ev,re,r,rp)
    local mat2=mg:Filter(Card.IsLocation,nil,LOCATION_DECK):Filter(Card.IsRace,nil,RACE_FIEND)
    mg:Sub(mat2)
    Duel.ReleaseRitualMaterial(mg)
    Duel.SendtoGrave(mat2,tp,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
end

--Destroy replace
function s.repfilter(c,tp)
	return c:IsFaceup() and (c:IsCode(97642679) or c:IsCode(210644007)) and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) 
		and not c:IsReason(REASON_REPLACE) and c:IsReason(REASON_EFFECT+REASON_BATTLE)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(s.repfilter,1,nil,tp) end
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end
