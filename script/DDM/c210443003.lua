--Thunder Ball
local s,id=GetID()
function s.initial_effect(c)
	--Destroy
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(s.descon)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	--Move
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.seqtg)
	e3:SetOperation(s.seqop)
	c:RegisterEffect(e3)
    --Dice
	local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_DESTROY+CATEGORY_DICE)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(s.target)
	e4:SetOperation(s.operation)
	c:RegisterEffect(e4)
end
s.roll_dice=true
function s.descon(e)
	return e:GetHandler():GetSequence()~=2
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
function s.desfilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and c:GetSequence()<5
end
function s.seqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
	local seq=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0)
	Duel.Hint(HINT_ZONE,tp,seq)
	e:SetLabel(math.log(seq,2))
end
function s.seqop(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local seq2=e:GetLabel()
	if not c:IsRelateToEffect(e) or c:IsControler(1-tp) or c:IsImmuneToEffect(e) or not Duel.CheckLocation(tp,LOCATION_MZONE,seq2) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
	local seq1=c:GetSequence() --register the sequence it comes from
	local dg=c:GetColumnGroup():Filter(s.desfilter,c,tp,cg) --and the group of cards there
	Duel.MoveSequence(c,seq2)
	if c:GetSequence()==seq2 and seq1~=seq2 then
		Duel.BreakEffect()
		local diff=math.abs(seq1-seq2)
		if seq1>seq2 then
			dg:Merge(c:GetColumnGroup(nil,diff):Filter(s.desfilter,c,tp))
		else
			dg:Merge(c:GetColumnGroup(diff,nil):Filter(s.desfilter,c,tp))
		end
		if #dg>0 then
			Duel.BreakEffect()
			Duel.Destroy(dg,REASON_EFFECT)
		end
	end
end
function s.desfilter1(c)
	return c:GetSequence()<5
end
function s.desfilter2(c,cg)
	return cg:IsContains(c)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local cg=e:GetHandler():GetColumnGroup()
	local b1=Duel.IsExistingMatchingCard(s.desfilter1,tp,0,LOCATION_MZONE,1,nil)
	local b2=Duel.IsExistingMatchingCard(s.desfilter2,tp,0,LOCATION_ONFIELD,1,e:GetHandler(),cg)
	local b3=Duel.IsExistingMatchingCard(s.desfilter1,tp,0,LOCATION_SZONE,1,nil)
	if chk==0 then return b1 or b2 or b3 end
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local cg=c:GetColumnGroup()
	local d=Duel.TossDice(tp,1)
	if d==1 then
		local g=Duel.GetMatchingGroup(s.desfilter1,tp,0,LOCATION_MZONE,nil)
		if #g==0 then return end
		Duel.Destroy(g,REASON_EFFECT)
	elseif d==6 then
		local g=Duel.GetMatchingGroup(s.desfilter1,tp,0,LOCATION_SZONE,nil)
		if #g==0 then return end
		Duel.Destroy(g,REASON_EFFECT)
	else
		local g=Duel.GetMatchingGroup(s.desfilter2,tp,0,LOCATION_ONFIELD,c,cg)
		if #g==0 then return end
		Duel.Destroy(g,REASON_EFFECT)
	end
end