--Silent Ceremony
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_CANNOT_INACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
    --Adjust
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(id)
	e2:SetRange(LOCATION_FZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_CANNOT_INACTIVATE)
	e2:SetTargetRange(1,0)
	e2:SetCondition(s.condition)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	c:RegisterEffect(e3)
    --Token
    local e4=Effect.CreateEffect(c)
    e4:SetCategory(CATEGORY_TOKEN+CATEGORY_SPECIAL_SUMMON)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_CANNOT_INACTIVATE)
    e4:SetRange(LOCATION_FZONE)
    e4:SetCost(s.cost)
    e4:SetTarget(s.target)
    e4:SetOperation(s.operation)
    c:RegisterEffect(e4)
	--Copy
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_CANNOT_INACTIVATE)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCode(EVENT_ATTACK_ANNOUNCE)
	e5:SetHintTiming(TIMING_BATTLE_PHASE)
	e5:SetCountLimit(1)
	e5:SetCondition(s.cpcon)
	e5:SetCost(s.cpcost)
	e5:SetTarget(s.cptg)
	e5:SetOperation(s.cpop)
	c:RegisterEffect(e5)
    --Register types
	aux.GlobalCheck(s,function()
		s.type_list={}
		s.type_list[0]={}
		s.type_list[1]={}
		aux.AddValuesReset(function()
			s.type_list[0]={}
			s.type_list[1]={}
		end)
	end)
end
s.listed_series={0xe7,0xe8}
function s.condition(e)
	return e:GetHandler():GetFlagEffect(id)==0
end
function s.costfilter(c,tp)
    local race=c:GetRace()
	return (c:IsSetCard(0xe7) or c:IsSetCard(0xe8)) and c:IsMonster() and not c:IsPublic() and not table.includes(s.type_list[tp],race)
	    and Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0,TYPE_TOKEN+TYPE_MONSTER+TYPE_NORMAL,1000,1000,4,race,ATTRIBUTE_LIGHT) and Duel.GetMZoneCount(tp,nil,tp,LOCATION_REASON_TOFIELD,zone)>0
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil,tp)
	end
	e:SetLabel(0)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,nil,tp)
	local tc=g:GetFirst()
	Duel.ConfirmCards(1-tp,tc)
	Duel.SetTargetCard(tc)
	local code=tc:GetCode()
	Duel.SetTargetParam(code)
	Duel.ShuffleHand(tp)
	table.insert(s.type_list[tp],tc:GetRace())
    Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
end
function s.spfilter(c,class,e,tp,code)
	return c:IsType(TYPE_MONSTER) and not c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
		and class.listed_names and c:IsCode(table.unpack(class.listed_names))
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local code=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	local class=tc:GetMetatable(code)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0,TYPE_TOKEN+TYPE_MONSTER+TYPE_NORMAL,1000,1000,4,tc:GetRace(),ATTRIBUTE_LIGHT) then
		local token=Duel.CreateToken(tp,id+1)
		--Change Type
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CHANGE_RACE)
        e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
        e1:SetRange(LOCATION_MZONE)
        e1:SetValue(tc:GetRace())
        e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
        token:RegisterEffect(e1,true)
		Duel.BreakEffect()
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
		if class==nil or class.listed_names==nil then return end
		if tc:IsAbleToGrave() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,class,e,tp,tc:GetCode())
		and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.BreakEffect()
			Duel.SendtoGrave(tc,REASON_EFFECT)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,class,e,tp,tc:GetCode())
			Duel.SpecialSummon(sg,0,tp,tp,true,false,POS_FACEUP)
		end
	end
end

function s.cpcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttacker()
	if tc:IsControler(1-tp) then tc=Duel.GetAttackTarget() end
	return tc and tc:IsFaceup() and tc:IsControler(tp) and (tc:IsSetCard(0xe7) or tc:IsSetCard(0xe8))
end
function s.cpcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
function s.cpfilter(c)
	return c:GetType()==TYPE_SPELL+TYPE_QUICKPLAY and (c:ListsArchetype(0xe7,0xe8) or c.LVset) and c:IsAbleToGraveAsCost()
		and c:CheckActivateEffect(false,true,false)~=nil
end
function s.cptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()==0 then return false end
		e:SetLabel(0)
		return Duel.IsExistingMatchingCard(s.cpfilter,tp,LOCATION_DECK,0,1,nil)
	end
	e:SetLabel(0)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.cpfilter,tp,LOCATION_DECK,0,1,1,nil)
	local te,ceg,cep,cev,cre,cr,crp=g:GetFirst():CheckActivateEffect(false,true,true)
	Duel.SendtoGrave(g,REASON_COST)
	e:SetProperty(te:GetProperty())
	local tg=te:GetTarget()
	if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
	Duel.ClearOperationInfo(0)
end
function s.cpop(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if not te then return end
	e:SetLabelObject(te:GetLabelObject())
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
end

if not table.includes then
	--binary search
	function table.includes(t,val)
		if #t<1 then return false end
		if #t==1 then return t[1]==val end --saves sorting for efficiency
		table.sort(t)
		local left=1
		local right=#t
		while left<=right do
			local middle=(left+right)//2
			if t[middle]==val then return true
			elseif t[middle]<val then left=middle+1
			else right=middle-1 end
		end
		return false
	end
end