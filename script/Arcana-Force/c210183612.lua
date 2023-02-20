--Arcana Sacrifice
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
    --Special Summon
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
    --Alter Summon Proc
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetCode(id)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCountLimit(1,{id,1})
    e3:SetCost(s.efcost)
    e3:SetOperation(s.efop)
    c:RegisterEffect(e3)
end
s.toss_coin=true
s.listed_names={CARD_LIGHT_BARRIER}
s.listed_series={SET_ARCANA_FORCE}
--[Special Summon]
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_ARCANA_FORCE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.trfilter(c,ct)
    local mi,ma=c:GetTributeRequirement()
	return (mi==ct or ma==ct) and c:IsRace(RACE_FAIRY) and c:IsSummonableCard(true,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	local ct=Duel.GetLocationCount(1-tp,LOCATION_MZONE)
	if ct>2 then ct=2 end
	if Duel.IsPlayerAffectedByEffect(1-tp,CARD_BLUEEYES_SPIRIT) then ct=1 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,ct,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,#g,0,0)
    Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(1-tp,LOCATION_MZONE)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if #sg==0 or ft<#sg or (#sg>1 and Duel.IsPlayerAffectedByEffect(1-tp,CARD_BLUEEYES_SPIRIT)) then return end
	if Duel.SpecialSummon(sg,0,tp,1-tp,false,false,POS_FACEUP)>0 then
        local ct=Duel.GetOperatedGroup():GetCount()
        local sel
        if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_LIGHT_BARRIER),tp,LOCATION_FZONE,0,1,nil) then
            local op=Duel.SelectOption(tp,aux.GetCoinEffectHintString(COIN_HEADS),aux.GetCoinEffectHintString(COIN_TAILS))
            if op==0 then
                sel=COIN_HEADS
            elseif op==1 then
                sel=COIN_TAILS
            else
                return
            end
        else
            sel=Duel.TossCoin(tp,1)
        end
        if sel==COIN_HEADS then
            if Duel.IsExistingMatchingCard(s.trfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,ct) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
                local tc=Duel.SelectMatchingCard(tp,s.trfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,ct):GetFirst()
                if tc then
                    Duel.SendtoHand(tc,nil,REASON_EFFECT)
                    Duel.BreakEffect()
                    local e1=Effect.CreateEffect(e:GetHandler())
                    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
                    e1:SetType(EFFECT_TYPE_SINGLE)
                    e1:SetCode(EFFECT_SUMMON_PROC)
                    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
                    tc:RegisterEffect(e1)
                    Duel.Summon(tp,tc,true,nil)
                end
            end
        elseif sel==COIN_TAILS then
            if Duel.IsExistingMatchingCard(s.trfilter,tp,LOCATION_HAND,0,1,nil,ct) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
                local tc=Duel.SelectMatchingCard(tp,s.trfilter,tp,LOCATION_HAND,0,1,1,nil,ct):GetFirst()
                if tc then
                    local e1=Effect.CreateEffect(e:GetHandler())
                    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
                    e1:SetType(EFFECT_TYPE_SINGLE)
                    e1:SetCode(EFFECT_SUMMON_PROC)
                    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
                    tc:RegisterEffect(e1)
                    Duel.Summon(tp,tc,true,nil)
                end
            end
        end
    end
end
--[Alter Summon Proc]
function s.exfilter(c)
    return c:IsCode(5861892,69831560)
end
function s.efcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
function s.efop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local g=Duel.GetMatchingGroup(s.exfilter,tp,LOCATION_ALL,0,nil)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetCode(id)
	e1:SetTargetRange(1,0)
	e1:SetCondition(s.condition)
    e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
    for tc in aux.Next(g) do
        local e1=Effect.CreateEffect(c)
        e1:SetDescription(aux.Stringid(id,1))
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_SPSUMMON_PROC)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
        e1:SetRange(LOCATION_HAND)
        e1:SetCondition(s.spcon)
        e1:SetTarget(s.sptg2)
        e1:SetOperation(s.spop2)
        e1:SetReset(RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e1)
    end
end
function s.condition(e)
	return e:GetHandler():GetFlagEffect(id)==0
end
function s.filter(c)
	return (c:IsMonster() and c:IsLocation(LOCATION_MZONE) and c:IsAbleToGraveAsCost()) or (c:IsMonster() and c:IsLocation(LOCATION_GRAVE) and c:IsAbleToRemoveAsCost())
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=e:GetHandlerPlayer()
	local rg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and #rg>2 and aux.SelectUnselectGroup(rg,e,tp,3,3,nil,0)
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,c)
	local c=e:GetHandler()
	local g=nil
	local rg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	local g=aux.SelectUnselectGroup(rg,e,tp,3,3,nil,1,tp,HINTMSG_SELECT,nil,nil,true)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g or #g~=3 then return end
    for tc in aux.Next(g) do
        if tc:IsLocation(LOCATION_MZONE) then
            Duel.SendtoGrave(tc,REASON_COST)
        else
            Duel.Remove(tc,POS_FACEUP,REASON_COST)
        end
    end
	g:DeleteGroup()
end