--Yule
local s,id=GetID()
function s.initial_effect(c)
    --Saerch
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
    --Apply effect
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCost(aux.bfgcost)
    e2:SetOperation(s.efop)
    c:RegisterEffect(e2)
end
s.listed_series={0x42,0x3042,0x4b}
function s.rescon(sg,e,tp,mg)
	return sg:GetClassCount(Card.GetLocation)==#sg
end
function s.cfilter(c)
    return c:IsSetCard(0x42) and c:IsType(TYPE_MONSTER)
        and (c:IsLocation(LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA+LOCATION_GRAVE) or c:IsFaceup()) and c:IsAbleToRemoveAsCost()
end
function s.thfilter(c,lv)
    return c:IsSetCard(0x42) and c:IsType(TYPE_MONSTER) and c:IsLevelBelow(lv) and c:IsAbleToHand()
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
function s.exfilter(c,lv)
	return c:IsLevel(lv) and c:IsLocation(LOCATION_DECK)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		local cg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA+LOCATION_GRAVE+LOCATION_MZONE,0,nil)
		local ct=math.min(5,cg:GetClassCount(Card.GetLocation))
		return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,ct-1)
	end
	local cg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA+LOCATION_GRAVE+LOCATION_MZONE,0,nil)
	local ct=math.min(5,cg:GetClassCount(Card.GetLocation))
	local tg=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil,ct)
	local lvt={}
	local pc=1
	for i=1,ct do
		if tg:IsExists(s.sfilter,1,nil,i,e,tp) then lvt[pc]=i pc=pc+1 end
	end
	lvt[pc]=nil
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
	local lv=Duel.AnnounceNumber(tp,table.unpack(lvt))
	if cg:FilterCount(s.exfilter,nil,lv)==1 then cg:Remove(s.exfilter,nil,lv) end
	local rg=aux.SelectUnselectGroup(cg,e,tp,lv,lv,s.rescon,1,tp,HINTMSG_REMOVE)
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
	Duel.SetTargetParam(lv)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.sfilter(c,lv)
	return c:IsSetCard(0x42) and c:IsType(TYPE_MONSTER) and c:GetLevel()==lv and c:IsAbleToHand()
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local lv=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.sfilter,tp,LOCATION_DECK,0,1,1,nil,lv)
    if #g>0 then
        Duel.SendtoHand(g,tp,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
        if g:GetFirst():IsSetCard(0x3042) then
            if Duel.GetFlagEffect(tp,id)~=0 then return end
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetDescription(aux.Stringid(id,0))
            e1:SetType(EFFECT_TYPE_FIELD)
            e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
            e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
            e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x42))
            e1:SetReset(RESET_PHASE+PHASE_END)
            Duel.RegisterEffect(e1,tp)
            Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
        end
    end
end
function s.efop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetCode(id)
	e1:SetTargetRange(1,0)
	e1:SetCondition(s.condition)
    e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.condition(e)
	return e:GetHandler():GetFlagEffect(id)==0
end
