--Royal Straight Slasher
local s,id=GetID()
function s.initial_effect(c)
	--Fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,CARD_JACK_KNIGHT,CARD_KING_KNIGHT,CARD_QUEEN_KNIGHT)
    --Destroy
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,id)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
    --Banish itself temporarily
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
    e2:SetCost(s.bancost)
	e2:SetTarget(s.bantg)
	e2:SetOperation(s.banop)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_JACK_KNIGHT,CARD_KING_KNIGHT,CARD_QUEEN_KNIGHT}
function s.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
function s.rescon(sg,e,tp,mg)
	return sg:FilterCount(s.tgfilter,nil,e,tp)==5
		and sg:FilterCount(Card.IsLevel,nil,10)==1 and sg:FilterCount(Card.IsLevel,nil,1)==1
        and sg:FilterCount(Card.IsCode,nil,CARD_JACK_KNIGHT)==1 and sg:FilterCount(Card.IsCode,nil,CARD_KING_KNIGHT)==1
        and sg:FilterCount(Card.IsCode,nil,CARD_QUEEN_KNIGHT)==1
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_DECK,0,nil)
    local dg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	if chk==0 then return #dg>0 and aux.SelectUnselectGroup(g,e,tp,5,5,s.rescon,chk) end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,#dg,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_DECK,0,nil)
    local dg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	local sg=aux.SelectUnselectGroup(g,e,tp,5,5,s.rescon,1,tp,HINTMSG_TOGRAVE)
	if #sg>0 and #dg>0 and Duel.SendtoGrave(sg,REASON_EFFECT)>0 then
        Duel.Destroy(dg,REASON_EFFECT)
    end
end
function s.bancost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsAbleToRemove() end
    if c:IsFaceup() and c:IsRelateToEffect(e) then
		Duel.Remove(c,POS_FACEUP,REASON_COST+REASON_TEMPORARY)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetLabelObject(c)
		e1:SetCountLimit(1)
		e1:SetOperation(s.retop)
		Duel.RegisterEffect(e1,tp)
    end
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
    Duel.ReturnToField(e:GetLabelObject())
end
function s.bantg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.banop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end
