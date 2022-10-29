--Silent Spell
local s,id=GetID()
function s.initial_effect(c)
	--Negate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_CANNOT_INACTIVATE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
    --To Deck and Draw
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_CANNOT_INACTIVATE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.tdrtg)
	e2:SetOperation(s.tdrop)
	c:RegisterEffect(e2)
end
s.listed_series={0xe7,0xe8}
function s.filter(c)
    return c:IsSetCard(0xe7) or c:IsSetCard(0xe8) and c:IsMonster()
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
        local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
        local ct=g:GetClassCount(Card.GetCode)
        local cg=Duel.GetMatchingGroup(Card.IsNegatable,tp,0,LOCATION_ONFIELD,nil)
        return ct>0 and #cg>0
    end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,0,1-tp,LOCATION_ONFIELD)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local ph=Duel.GetCurrentPhase()
    local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
    local ct=g:GetClassCount(Card.GetCode)
    local cg=Duel.GetMatchingGroup(Card.IsNegatable,tp,0,LOCATION_ONFIELD,nil)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local sg=cg:Select(tp,1,ct,nil)
    if #sg==0 then return end
    Duel.HintSelection(sg,true)
    Duel.BreakEffect()
    for tc in aux.Next(sg) do
        --Negate its effects
        Duel.NegateRelatedChain(tc,RESET_TURN_SET)
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetCode(EFFECT_DISABLE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e1)
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e2:SetCode(EFFECT_DISABLE_EFFECT)
        e2:SetValue(RESET_TURN_SET)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e2)
        if tc:IsType(TYPE_TRAPMONSTER) then
            local e3=Effect.CreateEffect(c)
            e3:SetType(EFFECT_TYPE_SINGLE)
            e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
            e3:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e3)
        end
    end
    if (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE) then
        --"Silent Magician" and "Silent Swordsman" monsters become unaffected by your opponent's cards' effects
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_IMMUNE_EFFECT)
        e1:SetTargetRange(LOCATION_MZONE,0)
        e1:SetTarget(s.etarget)
        e1:SetValue(s.efilter)
        e1:SetReset(RESET_PHASE+PHASE_END,2)
        Duel.RegisterEffect(e1,tp)
        --The opponent takes no damage
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_FIELD)
        e2:SetCode(EFFECT_CHANGE_DAMAGE)
        e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e2:SetTargetRange(0,1)
        e2:SetValue(0)
        e2:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e2,tp)
        local e3=e2:Clone()
        e3:SetCode(EFFECT_NO_EFFECT_DAMAGE)
        e3:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e3,tp)
    end
end
function s.etarget(e,c)
	return c:IsSetCard(0xe7) or c:IsSetCard(0xe8) and c:IsMonster()
end
function s.efilter(e,re)
	return re:GetOwnerPlayer()~=e:GetHandlerPlayer()
end

function s.tdfilter(c)
	return (c:IsSetCard(0xe7) or c:IsSetCard(0xe8)) and c:IsMonster() and c:IsAbleToDeck()
end
function s.tdrtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil)
	if chk==0 then return Duel.IsPlayerCanDraw(tp)
		and aux.SelectUnselectGroup(g,e,tp,1,g:GetClassCount(Card.GetCode),aux.dncheck,0) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.tdrop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,nil)
	if #g==0 then return end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,g:GetClassCount(Card.GetCode),s.rescon,1,tp,HINTMSG_TODECK)
	Duel.ConfirmCards(1-tp,sg)
	Duel.SendtoDeck(sg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	local og=Duel.GetOperatedGroup()
	local ct=og:FilterCount(Card.IsLocation,nil,LOCATION_DECK)
	if ct>0 then
		Duel.SortDeckbottom(tp,tp,ct)
		Duel.BreakEffect()
		Duel.Draw(tp,ct,REASON_EFFECT)
	end
end