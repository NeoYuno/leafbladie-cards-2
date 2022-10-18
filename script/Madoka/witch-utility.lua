-- Puella Magi Witch Summon Procedure
function Auxiliary.AddWitchProcedure(c,releasefilter,desc_self,desc_opp)
  desc_self = desc_self or 0
  desc_opp = desc_opp or 0
  releasefilter = releasefilter or aux.TRUE

  --cannot link summon normally.
  local e1=Effect.CreateEffect(c)
  e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetCode(EFFECT_SPSUMMON_CONDITION)
  c:RegisterEffect(e1)

  -- special summon to your field.
  local e2=Effect.CreateEffect(c)
  e2:SetDescription(desc_self)
  e2:SetType(EFFECT_TYPE_FIELD)
  e2:SetCode(EFFECT_SPSUMMON_PROC)
  e2:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
  e2:SetRange(LOCATION_EXTRA)
  e2:SetTargetRange(POS_FACEUP_ATTACK,0)
  e2:SetValue(0)
  e2:SetCondition(Auxiliary.WitchCondition(releasefilter))
  e2:SetTarget(Auxiliary.WitchTarget(releasefilter))
  e2:SetOperation(Auxiliary.WitchOperation)
  c:RegisterEffect(e2)

  --special summon to opponent's field.
  local e3=e2:Clone()
  e3:SetDescription(desc_opp)
  e3:SetTargetRange(POS_FACEUP_ATTACK,1)
  e3:SetValue(1)
  c:RegisterEffect(e3)

  return e1, e2, e3
end
-- Tribute is
function Auxiliary.WitchCondition(filter)
  return function(e,c)
    if c==nil then return true end
    local mg=Duel.GetMatchingGroup(aux.AND(Card.IsReleasable,filter),c:GetControler(),LOCATION_MZONE,0,nil)
    return aux.SelectUnselectGroup(mg,e,c:GetControler(),1,1,Auxiliary.WitchResCon,0)
  end
end
function Auxiliary.WitchResCon(sg,e,tp,mg)
  local to_player=tp
  if e:GetValue()==1 then to_player = (1-tp) end
  return Duel.GetLocationCountFromEx(to_player,tp,sg,e:GetHandler()) > 0
end
function Auxiliary.WitchTarget(filter)
  return function(e,tp,eg,ep,ev,re,r,rp,c)
    local mg=Duel.GetMatchingGroup(aux.AND(Card.IsReleasable,filter),tp,LOCATION_MZONE,0,nil)
    local g=aux.SelectUnselectGroup(mg,e,tp,1,1,Auxiliary.WitchResCon,1,tp,HINTMSG_RELEASE,nil,nil,true)
  	if g then
  		g:KeepAlive()
  		e:SetLabelObject(g)
  	  return true
  	end
  	return false
  end
end
function Auxiliary.WitchOperation(e,tp,eg,ep,ev,re,r,rp,c)
  local g=e:GetLabelObject()
	if not g then return end
	Duel.Release(g,REASON_COST)
	g:DeleteGroup()
end
