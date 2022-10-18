--Mami's Tiro Finale
--updated by MasterQuest
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)

	-- Check for activating the turn it is set.
	aux.GlobalCheck(s, function()
    local e3= Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_SSET)
    e3:SetOperation(s.gblop)
    Duel.RegisterEffect(e3,0)
  end)

end
s.listed_names={210633304} -- Mami

function s.conf(c)
	return c:IsFaceup() and c:IsCode(210633304)
end
function s.filter(c)
	return c:GetCounter(0x1901)>0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local flag=0
	if Duel.IsExistingMatchingCard(s.conf,tp,LOCATION_ONFIELD,0,1,nil) then flag=1 end
	local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 end
	if flag==0 then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
	elseif flag==1 then
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local flag=0
	if Duel.IsExistingMatchingCard(s.conf,tp,LOCATION_ONFIELD,0,1,nil) then flag=1 end
	local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil)
	if #g>0 then
		if flag==0 then
			Duel.Destroy(g,REASON_EFFECT)
		elseif flag==1 then
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		end
	end
end

-- Check set cards to see if this card was set by the specific card.
function s.gblop(e,tp,eg,ep,ev,re,r,rp)	
	local g=eg:Filter(Card.IsCode,nil,id)
	for ec in aux.Next(g) do
		if re and re:GetOwner() and re:GetOwner():IsCode(210633304) then
      -- Activate the turn it is set.
      local e0=Effect.CreateEffect(ec)
      e0:SetType(EFFECT_TYPE_SINGLE)
      e0:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
      e0:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
      e0:SetReset(RESET_EVENT+RESETS_STANDARD)
      ec:RegisterEffect(e0)
		end
	end
end
