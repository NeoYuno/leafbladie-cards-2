--Salesman 777
local s,id=GetID()
function s.initial_effect(c)
    c:SetUniqueOnField(1,0,id)
	c:EnableReviveLimit()
	Link.AddProcedure(c,s.matfilter,1,1)
	--Search
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--Draw
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_TOSS_COIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(s.drawop)
	c:RegisterEffect(e2)
	--Equip
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_EQUIP)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.eqcon)
	e3:SetTarget(s.eqtg)
	e3:SetOperation(s.eqop)
	c:RegisterEffect(e3)
    local e4=e3:Clone()
    e4:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e4)
    local e5=e3:Clone()
    e5:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
    c:RegisterEffect(e5)
end
s.listed_series={0x0f7a,0x0f7b}

function s.matfilter(c,lc,sumtype,tp)
	return c:IsRace(RACE_MACHINE,lc,sumtype,tp) and c:IsAttribute(ATTRIBUTE_DARK,lc,sumtype,tp) and c:IsLevel(7)
end

function s.thfilter(c)
	return c:IsAbleToHand() and c:IsSpellTrap() and (c:IsSetCard(0x0f7b) or c:IsCode(38120068,111008301,810000087,48712195))
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT) Duel.ConfirmCards(1-tp,g) 
    end
end

function s.drawop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.CheckLPCost(tp,700) and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		Duel.PayLPCost(tp,700)
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end

function s.eqfilter(c)
	return c:IsFaceup() and (c:IsCode(3797883,210363003) or c:IsSetCard(0x0f7a))
end
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.eqfilter,1,nil)
end
function s.eqspellfilter(c,tp)
	return (c:IsSetCard(0x0f7a) or c:IsCode(86198326)) and c:IsType(TYPE_EQUIP)
	    and Duel.IsExistingMatchingCard(s.eqfilter2,tp,LOCATION_MZONE,0,1,nil,c)
end
function s.eqfilter2(c,tc)
	return c:IsFaceup() and tc:CheckEquipTarget(c)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.eqspellfilter,tp,LOCATION_DECK,0,1,nil,tp) end
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local eqc=Duel.SelectMatchingCard(tp,s.eqspellfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	local g=Duel.SelectMatchingCard(tp,s.eqfilter2,tp,LOCATION_MZONE,0,1,1,nil,eqc)
	if eqc then
        Duel.HintSelection(g)
		Duel.Equip(tp,eqc,g:GetFirst())
	end
end