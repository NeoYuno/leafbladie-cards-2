--Decisive Power of Absolute Destiny
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
    e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
    --Limits
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(TIMING_END_PHASE)
	e2:SetCountLimit(1,{id,1})
    e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.eftg)
	e2:SetOperation(s.efop)
	c:RegisterEffect(e2)
end
s.toss_coin=true
s.listed_names={CARD_LIGHT_BARRIER}
s.listed_series={SET_ARCANA_FORCE}
--[Activate]
function s.spfilter(c,e,tp) 
	return c:IsSetCard(SET_ARCANA_FORCE) and c:IsMonster() and (c:IsCanBeSpecialSummoned(e,0,tp,false,false) or c:IsCanBeSpecialSummoned(e,0,1-tp,false,false))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,ft,tp) end
    Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    local sel
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
    if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_LIGHT_BARRIER),tp,LOCATION_FZONE,0,1,nil) then
        Duel.BreakEffect()
        local self=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
        local oppo=Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,1-tp,false,false)
        local op=Duel.SelectEffect(tp,{self,aux.GetCoinEffectHintString(COIN_HEADS)},{oppo,aux.GetCoinEffectHintString(COIN_TAILS)})
        if op==1 then
            sel=COIN_HEADS
        elseif op==2 then
            sel=COIN_TAILS
        else
            return
        end
    else
        sel=Duel.TossCoin(tp,1)
    end
    if sel==COIN_HEADS then
        Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
    elseif sel==COIN_TAILS then
        Duel.SpecialSummon(tc,0,tp,1-tp,false,false,POS_FACEUP)
    end
end
--[Limits]
function s.eftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsOnField() end
	if chk==0 then return Duel.IsExistingTarget(aux.FaceupFilter(Card.IsSetCard,SET_ARCANA_FORCE),tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,aux.FaceupFilter(Card.IsSetCard,SET_ARCANA_FORCE),tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
function s.efop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not (tc:IsFaceup() and tc:IsRelateToEffect(e)) then return end
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetLabel(tc:GetAttack())
    e1:SetLabelObject(tc)
    e1:SetCondition(s.limitcon)
	e1:SetTarget(s.splimit)
	Duel.RegisterEffect(e1,tc:GetControler())
    tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_CONTROL,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,0))
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_TOSS_COIN_CHOOSE)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetCondition(function(e,tp,eg,ep)return ep==c:GetOwner() end)
	e2:SetOperation(s.repop(false,Duel.SetCoinResult,function(tp)
		return Duel.AnnounceCoin(c:GetOwner(),aux.Stringid(300102004,4))
	end))
	Duel.RegisterEffect(e2,c:GetOwner())
end
function s.limitcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffect(id)==0 then
		e:Reset()
		return false
	end
	return tc:GetFlagEffect(id)>0
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA) and c:GetAttack()>e:GetLabel() and not c:IsSetCard(SET_ARCANA_FORCE)
end
--[Change coin result]
function s.repop(isdice,func2,func3)
    return function(e,tp,eg,ep,ev,re,r,rp)
        if Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
            Duel.Hint(HINT_CARD,tp,id)
            local total=(ev&0xff)+(ev>>16)
            local res={}
            res[1]=func3(ep)
            for i=2,total do
                table.insert(res,Duel.GetRandomNumber(0,1)==0 and COIN_TAILS or COIN_HEADS)	
            end
            func2(table.unpack(res))
        end
    end
end