--Salesman 7’s Casino
local s,id=GetID()
function s.initial_effect(c)
    -- Activate: Add 1 Spell/Trap that requires a coin toss
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)

    -- ATK boost on Heads
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_TOSS_COIN)
    e2:SetRange(LOCATION_SZONE)
    e2:SetOperation(s.atkop)
    c:RegisterEffect(e2)

    -- Special Summon Slotbot Token
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCountLimit(1,{id,1})
    e3:SetCondition(s.tkcon)
    e3:SetTarget(s.tktg)
    e3:SetOperation(s.tkop)
    c:RegisterEffect(e3)

    -- When destroyed: Protect coin-based monster from battle
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetCode(EVENT_DESTROYED)
    e4:SetCountLimit(1,{id,2})
    e4:SetTarget(s.battletg)
    e4:SetOperation(s.battleop)
    c:RegisterEffect(e4)
end

-- Filter: Spell/Trap with coin toss
function s.coinspelltrap_filter(c)
    return c:IsSpellTrap() and c.toss_coin and c:IsAbleToHand()
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    if Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local g=Duel.SelectMatchingCard(tp,s.coinspelltrap_filter,tp,LOCATION_DECK,0,1,1,nil)
        if #g>0 then
            Duel.SendtoHand(g,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,g)
        end
    end
end

-- Condition: a Heads result occurred
function s.coincond(e,tp,eg,ep,ev,re,r,rp)
    return re and re:GetHandler():GetControler()==tp
        and eg:IsExists(function(val) return val==1 end,1,nil) -- Heads is 1
end

-- Operation: Boost all DARK Machine monsters you control by 500 ATK
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=Duel.GetCoinResult()
	if not ct then return end
	local heads=0
	for _,v in ipairs({Duel.GetCoinResult()}) do
		if v==1 then heads=heads+1 end
	end
	if heads==0 then return end

	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil)
	for tc in g:Iter() do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end

function s.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_DARK)
end
-- Condition: no monsters or exactly 1 Level 7 DARK monster
function s.tkcon(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
    return #g==0 or (#g==1 and g:GetFirst():IsLevel(7) and g:GetFirst():IsAttribute(ATTRIBUTE_DARK))
end

function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
        and Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0,TYPES_TOKEN,1000,1000,7,RACE_MACHINE,ATTRIBUTE_DARK) end
    Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end

function s.tkop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    if not Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0,TYPES_TOKEN,1000,1000,7,RACE_MACHINE,ATTRIBUTE_DARK) then return end
    local token=Duel.CreateToken(tp,id+1)
    Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
end

-- Target a monster you control that uses coin toss effects
function s.battlefilter(c)
    return c:IsFaceup() and c.toss_coin
end

function s.battletg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingTarget(s.battlefilter,tp,LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    Duel.SelectTarget(tp,s.battlefilter,tp,LOCATION_MZONE,0,1,1,nil)
end

function s.battleop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
        e1:SetValue(1)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e1)
    end
end
