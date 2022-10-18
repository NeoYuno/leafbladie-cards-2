--Dice Dungeon
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
    --Roll
    local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DICE+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,id)
    e2:SetCost(s.drcost)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
    --Change ATK/DEF
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCondition(s.condition)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
    --Change dice result
    local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_TOSS_DICE_NEGATE)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCondition(s.dicecon)
	e4:SetOperation(s.diceop)
	c:RegisterEffect(e4)
end
s.roll_dice=true
function s.cfilter(c)
	return c.roll_dice and not c:IsPublic()
end
function s.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,63,nil)
	Duel.ConfirmCards(1-tp,g)
	Duel.ShuffleHand(tp)
	e:SetLabel(#g)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
    local ct=e:GetLabel()
    local res=Duel.TossDice(tp,1)
    if res<=ct then
        Duel.Draw(tp,2,REASON_EFFECT)
    end
end
function s.filter1(c)
    local atk=c:GetAttack()
	return c:IsDefenseAbove(atk) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
function s.filter2(c)
	local atk=c:GetAttack()
	return c:IsDefenseAbove(atk) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave() and c.roll_dice
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local at=Duel.GetAttackTarget()
    e:SetLabelObject(at)
	return at:GetColumnGroup():IsContains(a) and (at:GetAttack()>0 or at:GetDefense()>0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
    local p=tc:GetControler()
    local b1=Duel.IsExistingMatchingCard(s.filter1,p,LOCATION_GRAVE,0,1,nil)
    local b2=Duel.IsExistingMatchingCard(s.filter2,p,LOCATION_DECK,0,1,nil)
    if (b1 or b2) and Duel.SelectYesNo(p,aux.Stringid(id,0)) then
        local op=0
        if b1 and b2 then
            op=Duel.SelectOption(p,aux.Stringid(id,1),aux.Stringid(id,2))
        elseif b1 then
            op=Duel.SelectOption(p,aux.Stringid(id,1))
        else
            op=Duel.SelectOption(p,aux.Stringid(id,2))+1
        end
        if op==0 then
            Duel.Hint(HINT_SELECTMSG,p,HINTMSG_REMOVE)
            local sg=Duel.SelectMatchingCard(p,s.filter1,p,LOCATION_GRAVE,0,1,1,nil)
            Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
            if Duel.IsChainDisablable(0) then
                Duel.NegateEffect(0)
                return
            end
        else
            Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TOGRAVE)
            local sg=Duel.SelectMatchingCard(p,s.filter2,p,LOCATION_DECK,0,1,1,nil)
            Duel.SendtoGrave(sg,REASON_EFFECT)
            if Duel.IsChainDisablable(0) then
                Duel.NegateEffect(0)
                return
            end
        end
    end
    if tc:IsRelateToBattle() and tc:IsFaceup() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_PHASE+PHASE_DAMAGE_CAL)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
        e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
        tc:RegisterEffect(e2)
	end
end
function s.filter(c)
	return c:IsType(TYPE_MONSTER) and c.roll_dice
end
function s.dicecon(e,tp,eg,ep,ev,re,r,rp)
    local ct=Duel.GetMatchingGroupCount(s.filter,tp,LOCATION_MZONE,0,nil)
	return ct==Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0) and e:GetHandler():GetFlagEffect(id)==0 and rp==e:GetHandlerPlayer()
end
function s.diceop(e,tp,eg,ep,ev,re,r,rp)
    local cc=Duel.GetCurrentChain()
	local cid=Duel.GetChainInfo(cc,CHAININFO_CHAIN_ID)
	if s[0]~=cid and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
        local num=Duel.AnnounceNumber(tp,1,2,3,4,5,6)
        local res={Duel.GetDiceResult()}
        local ct=ev
        for i=1, ct do
            res[i]=num
        end
        Duel.SetDiceResult(table.unpack(res))
        s[0]=cid
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
    end
end