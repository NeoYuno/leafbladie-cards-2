--Red-Eyes Thousand Dragon
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,58257569,aux.FilterBoolFunctionEx(Card.IsRace,RACE_SPELLCASTER))
    --Normal monster
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_ADD_TYPE)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetValue(TYPE_NORMAL)
	c:RegisterEffect(e1)
    --Duel status
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_GEMINI))
	e2:SetCode(EFFECT_GEMINI_STATUS)
	c:RegisterEffect(e2)
    --Apply effect
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(s.con)
	e3:SetTarget(s.tg)
	e3:SetOperation(s.op)
	c:RegisterEffect(e3)
end
s.material={58257569}
s.listed_names={58257569}
s.material_setcode={0x3b}
function s.con(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_FUSION)
end
function s.filter(c)
	return c:IsSetCard(0x3b) and c:IsType(TYPE_SPELL+TYPE_TRAP) and (c:CheckActivateEffect(false,true,false)~=nil and c:GetType()==TYPE_SPELL) or (c:GetType()~=TYPE_SPELL and c:IsSSetable())
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not (tc and tc:IsRelateToEffect(e)) then return end
    if tc:GetType()==TYPE_SPELL  then
        local te,ceg,cep,cev,cre,cr,crp=tc:CheckActivateEffect(false,true,true)
        if not te then return end
        local tg=te:GetTarget()
        local op=te:GetOperation()
        if tg then tg(te,tp,Group.CreateGroup(),PLAYER_NONE,0,e,REASON_EFFECT,PLAYER_NONE,1) end
        Duel.BreakEffect()
        tc:CreateEffectRelation(te)
        Duel.BreakEffect()
        local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
        for etc in aux.Next(g) do
            etc:CreateEffectRelation(te)
        end
        if op then op(te,tp,Group.CreateGroup(),PLAYER_NONE,0,e,REASON_EFFECT,PLAYER_NONE,1) end
        tc:ReleaseEffectRelation(te)
        for etc in aux.Next(g) do
            etc:ReleaseEffectRelation(te)
        end
        Duel.BreakEffect()
        Duel.SendtoDeck(te:GetHandler(),nil,2,REASON_EFFECT)
    else 
        if tc:IsSSetable() and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
            Duel.SSet(tp,tc)
            local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			if tc:IsType(TYPE_QUICKPLAY) then
				e1:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
			elseif  tc:IsType(TYPE_TRAP) then
				e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
			end
			e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
        else
            Duel.SendtoGrave(tc,REASON_EFFECT+REASON_REVEAL)
        end
    end
end