function Auxiliary.ActInSetTurnIfSetBy(s,c,setbyfilter)
  aux.GlobalCheck(s, function()
    local e3= Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_SSET)
    e3:SetOperation(Auxiliary.GlobalSetInTurnOperation(c,setbyfilter))
    Duel.RegisterEffect(e3,0)
  end)
end

-- Check set cards to see if this card was set by the named card
function Auxiliary.GlobalSetInTurnOperation(c,setbyfilter)
  return function(e,tp,eg,ep,ev,re,r,rp)
  	local g=eg:Filter(Card.IsCode,nil,c:GetCode())
  	for ec in aux.Next(g) do
  		if re and re:GetOwner() and setbyfilter and setbyfilter(re:GetOwner())  then
        -- Activate the turn it is set.
        local e0=Effect.CreateEffect(ec)
        e0:SetType(EFFECT_TYPE_SINGLE)
        if c:IsType(TYPE_QUICKPLAY) then
          e0:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
        else
          e0:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
        end
        e0:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
        e0:SetReset(RESET_EVENT+RESETS_STANDARD)
        ec:RegisterEffect(e0)
  		end
  	end
  end
end
