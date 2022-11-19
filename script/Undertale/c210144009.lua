--Loox the Underground Victim
local COUNTER_LV=0x1950
local s,id=GetID()
function s.initial_effect(c)
	--To hand
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
    --Counter
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_COUNTER)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_BE_BATTLE_TARGET)
    e3:SetCondition(s.ctcon)
	e3:SetTarget(s.cttg)
	e3:SetOperation(s.ctop)
	c:RegisterEffect(e3)
end
s.counter_place_list={COUNTER_LV}
s.listed_names={210144001}
s.listed_series={0x0f4a}
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local ct=Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsSetCard,0x0f4a),tp,LOCATION_MZONE,0,nil)
		return ct>0 and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=ct+2 and Duel.GetDecktopGroup(tp,ct):FilterCount(Card.IsSetCard,nil,0xf4a)>0
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsSetCard,0x0f4a),tp,LOCATION_MZONE,0,nil)
	Duel.ConfirmDecktop(tp,ct+2)
	local g=Duel.GetDecktopGroup(tp,ct+2)
	if #g<1 or not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sg=g:FilterSelect(tp,Card.IsSetCard,1,1,nil,0xf4a)
	Duel.DisableShuffleCheck()
	if sg:GetFirst():IsAbleToHand() then
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
		Duel.ShuffleHand(tp)
		g:Sub(sg)
	end
	Duel.SortDecktop(tp,tp,#g)
end

function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetAttacker():IsCode(210144001)
end
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local at=Duel.GetAttacker()
	if chk==0 then return at and at:IsFaceup() and at:IsRelateToBattle() end
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local at=Duel.GetAttacker()
	if at:GetCounter(COUNTER_LV)==19 or not (at:IsFaceup() and at:IsLocation(LOCATION_MZONE)) then return end
	if at:IsCanAddCounter(COUNTER_LV,2) then
		Duel.Hint(HINT_CARD,tp,id)
		at:AddCounter(COUNTER_LV,2)
	elseif at:IsCanAddCounter(COUNTER_LV,1) then
		Duel.Hint(HINT_CARD,tp,id)
		at:AddCounter(COUNTER_LV,1)
	end
end