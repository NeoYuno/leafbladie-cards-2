--Puella Magi Incubator - Kyubey
--updated by MasterQuest
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Link.AddProcedure(c,s.matfilter,2,2,nil,nil)
	--cannot link material
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e0:SetValue(1)
	c:RegisterEffect(e0)
	--add a card
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	e1:SetCountLimit(1,id)
	c:RegisterEffect(e1)
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(s.spt1)
	e2:SetOperation(s.spo1)
	e2:SetCountLimit(1,id+1)
	c:RegisterEffect(e2)
	--special summon self from GY
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg2)
	e3:SetOperation(s.spop2)
	e3:SetCountLimit(1,id+2)
	c:RegisterEffect(e3)
end
s.listed_series={0xf74}

function s.matfilter(c,scard,sumtype,tp)
	return c:IsSetCard(0xf72,scard,SUMMON_TYPE_LINK,tp)
end
-- Add Incubator S/T to hand.
function s.thfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSetCard(0xf74)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,tp,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
-- Special Summon Puella Magi monsters.
function s.spfilter(c,e,tp,sg)
	return c:IsSetCard(0xf72) and (c:IsFaceup() or c:IsLocation(LOCATION_HAND))
		and c:IsCanBeSpecialSummoned(e,72,tp,false,false) and (not sg or not sg:IsExists(Card.IsCode,1,c,c:GetCode()))
end
function s.spt1(e,tp,eg,ep,ev,re,r,rp,chk)
	local loc=0
	if chk==0 then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then loc=loc|LOCATION_HAND end
		if Duel.GetLocationCountFromEx(tp)>0 then loc=loc|LOCATION_EXTRA end
		return loc>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,loc,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_EXTRA)
end
function s.spo1(e,tp,eg,ep,ev,re,r,rp)
	--zone check
	if Duel.GetLocationCount(tp,LOCATION_MZONE)==0 and Duel.GetLocationCountFromEx(tp)==0 then return end
	--Summon Gate check
	local ect=c29724053 and Duel.IsPlayerAffectedByEffect(tp,CARD_SUMMON_GATE) and c29724053[tp]
	--number of monster summoned from extra
	local st=0
	--special summoned monster
	local sg=Group.CreateGroup()
	while true do
		--check from where you can special summon and exit if there no place
		local loc=0
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then loc=loc|LOCATION_HAND end
		if Duel.GetLocationCountFromEx(tp)>0 then loc=loc|LOCATION_EXTRA end
		if loc==0 then break end
		--check if you can stop already
		local min=(#sg>0) and 0 or 1
		--select a card
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tcgrp=Duel.SelectMatchingCard(tp,s.spfilter,tp,loc,0,min,1,nil,e,tp,sg)
		--if no card then exit
		if not tcgrp or not tcgrp:GetFirst() then break end
		local tc=tcgrp:GetFirst()
		--add the card to special summoned monster group
		sg:AddCard(tc)
		--counts number of monster special summoned from extra
		if tc:IsLocation(LOCATION_EXTRA) then
			st=st+1
		end
		--special summon
		Duel.SpecialSummonStep(tc,72,tp,tp,false,false,POS_FACEUP)
		--BE Spirit Dragon Check
		if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) and #sg>=1 then break end
		--Summon Gate Check
		if ect and st>=ect then break end
	end
	if Duel.SpecialSummonComplete() then
		local g=Duel.GetOperatedGroup()
		local spcg,selg,cnt_placed = 0
		-- Place up to 9 counters
		for i=1,9 do
			-- Can place spell counters? if not, cancel
			spcg = g:Filter(Card.IsCanAddCounter,nil,COUNTER_SPELL,1)
			if #spcg==0 then break end
			-- let player choose a card for the next spell counter.
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COUNTER)
			selg = spcg:Select(tp,1,1,true)
			-- check if canceled
			if selg == nil or #selg == 0 then break end
			selg:GetFirst():AddCounter(COUNTER_SPELL,1)
		end
	end
end
-- Special Summon self from GY
function s.spconf(c)
	return c:IsFaceup() and c:IsSetCard(0xf72)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.spconf,tp,LOCATION_ONFIELD,0,1,nil)
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,LOCATION_GRAVE)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
