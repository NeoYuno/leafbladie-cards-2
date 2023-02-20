--Tarot Fusion
local s,id=GetID()
function s.initial_effect(c)
	--Coin Effect
	local e1=Effect.CreateEffect(c)
    local fparams={aux.FilterBoolFunction(Card.IsType,TYPE_FUSION),Fusion.InHandMat,s.fextra,nil,nil,s.stage2}
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg(Fusion.SummonEffTG(table.unpack(fparams)),Fusion.SummonEffOP(table.unpack(fparams))))
	e1:SetOperation(s.spop(Fusion.SummonEffTG(table.unpack(fparams)),Fusion.SummonEffOP(table.unpack(fparams))))
	c:RegisterEffect(e1)
    --Recover
	local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.toss_coin=true
s.listed_names={CARD_LIGHT_BARRIER}
s.listed_series={SET_ARCANA_FORCE}
--[Coin Effect]
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,1-tp,false,false) and Duel.GetLocationCountFromEx(1-tp,1-tp,nil,c)>0
end
function s.sptg(fustg,fusop)
    return function(e,tp,eg,ep,ev,re,r,rp,chk)
        local b1=fustg(e,tp,eg,ep,ev,re,r,rp,0)
        local b2=Duel.IsExistingMatchingCard(s.spfilter,1-tp,0,LOCATION_EXTRA,1,nil,e,1-tp)
        if chk==0 then return b1 or b2 end
        Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
    end
end
function s.spop(fustg,fusop)
	return function(e,tp,eg,ep,ev,re,r,rp)
        local sel
        if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_LIGHT_BARRIER),tp,LOCATION_FZONE,0,1,nil) then
            local self=fustg(e,tp,eg,ep,ev,re,r,rp,0)
            local oppo=Duel.IsExistingMatchingCard(s.spfilter,1-tp,0,LOCATION_EXTRA,1,nil,e,1-tp)
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
            fusop(e,tp,eg,ep,ev,re,r,rp)
        elseif sel==COIN_TAILS then
            Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)
            local g=Duel.SelectMatchingCard(1-tp,s.spfilter,1-tp,LOCATION_EXTRA,0,1,1,nil,e,1-tp)
            if #g>0 then
                Duel.SpecialSummon(g,0,1-tp,1-tp,false,false,POS_FACEUP)
            end
        end
	end
end
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToGrave),tp,LOCATION_DECK,0,nil)
end
--[Recover]
function s.thfilter(c,e)
	return c:IsSetCard(SET_ARCANA_FORCE) and c:IsMonster() and c:IsCanBeEffectTarget(e) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	if chk==0 then return aux.SelectUnselectGroup(g,e,tp,1,#g,aux.dpcheck(Card.GetLevel),0) end
	local tg=aux.SelectUnselectGroup(g,e,tp,1,#g,aux.dpcheck(Card.GetLevel),1,tp,HINTMSG_ATOHAND)
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,tg,#tg,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end