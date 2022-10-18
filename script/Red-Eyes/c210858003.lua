--Red-Eyes Blade of Chaos
local s,id=GetID()
function s.initial_effect(c)
	local e1=Ritual.CreateProc({handler=c,lvtype=RITPROC_GREATER,filter=s.ritualfil,extrafil=s.extrafil,extraop=s.extraop,matfilter=s.forcedgroup,stage2=s.stage2})
	e1:SetCountLimit(1,id)
	c:RegisterEffect(e1)
    --To hand
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_HAND)
    e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.thcon)
    e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_names={210858001}
s.listed_series={0x3b}
function s.ritualfil(c)
	return c:IsRace(RACE_DRAGON)
end
function s.exfilter0(c)
	return c:IsSetCard(0x3b) and c:IsLevelAbove(1) and c:IsAbleToGrave()
end
function s.extrafil(e,tp,eg,ep,ev,re,r,rp,chk)
	return Duel.GetMatchingGroup(s.exfilter0,tp,LOCATION_DECK,0,nil)
end
function s.extraop(mg,e,tp,eg,ep,ev,re,r,rp)
	local mat2=mg:Filter(Card.IsLocation,nil,LOCATION_DECK)
	mg:Sub(mat2)
	Duel.ReleaseRitualMaterial(mg)
	Duel.SendtoGrave(mat2,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
end
function s.forcedgroup(c,e,tp)
	return c:IsLocation(LOCATION_HAND+LOCATION_ONFIELD) or (c:IsSetCard(0x3b) and c:IsLocation(LOCATION_DECK))
end
function s.stage2(mat,e,tp,eg,ep,ev,re,r,rp,tc)
    local g=tc:GetMaterial()
    if not g:IsExists(Card.IsType,1,nil,TYPE_EFFECT) then return end
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
    e1:SetTargetRange(1,0)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
end
function s.cfilter(c,tp)
	return c:IsCode(210858001) and c:IsControler(tp) and not c:IsReason(REASON_DRAW)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return (r&REASON_EFFECT)~=0 and eg:IsExists(s.cfilter,1,nil,tp)
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return eg:IsExists(s.cfilter,1,nil,tp) end
    if #eg==1 then
        Duel.SendtoGrave(eg,REASON_COST+REASON_DISCARD)
    elseif #eg>1 then
        local g=eg:Filter(s.cfilter,nil,tp)
        Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
    end
end
function s.thfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsRitualMonster() and c:GetAttack()<2800 and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand()
        and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SendtoHand(c,nil,REASON_EFFECT)>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
end