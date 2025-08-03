--Sobek, The Slime Serpent of the Nile
local s,id=GetID()
function s.initial_effect(c)
	--summon with 3 tribute
	local e1=aux.AddNormalSummonProcedure(c,true,false,3,3)
	local e2=aux.AddNormalSetProcedure(c)
	--summon
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_DISABLE_SUMMON)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e3)
	--summon success
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetOperation(s.sumsuc)
	c:RegisterEffect(e4)
	--Gains ATK for each Slime
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetCode(EFFECT_UPDATE_ATTACK)
	e5:SetRange(LOCATION_MZONE)
	e5:SetValue(s.atkval)
	c:RegisterEffect(e5)

	--Special Summon Slime Token
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,id)
	e5:SetTarget(s.tktg)
	e5:SetOperation(s.tkop)
	c:RegisterEffect(e5)

	--Inflict damage when a monster tributed by DIVINE monster
	local e6=Effect.CreateEffect(c)
	e6:SetCategory(CATEGORY_DAMAGE)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_RELEASE)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCountLimit(1,id+1)
	e6:SetCondition(s.damcon)
	e6:SetOperation(s.damop)
	c:RegisterEffect(e6)
	--Tribute up to 2 monsters to summon Slimes or Humanoid Worm Drake
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,1))
	e7:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e7:SetType(EFFECT_TYPE_IGNITION)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCountLimit(1,id+2)
	e7:SetTarget(s.sptg)
	e7:SetOperation(s.spop)
	c:RegisterEffect(e7)
	--Change name to Egyptian God
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(id,2))
	e8:SetType(EFFECT_TYPE_IGNITION)
	e8:SetRange(LOCATION_MZONE)
	e8:SetCountLimit(1,id+3)
	e8:SetOperation(s.nameop)
	c:RegisterEffect(e8)
end

function s.sumsuc(e,tp,eg,ep,ev,re,r,rp)
	Duel.SetChainLimitTillChainEnd(aux.FALSE)
end

function s.slimefilter(c)
    return c:IsCode(511600034,68638985,46821314,18914778,15771991,511001208,513000142,
    79387392,511001205,3918345,511000482,511001207,511001206,20056760,
    80250319,80551022,42166000,511000285,id)
end
function s.atkval(e,c)
	local tp=c:GetControler()
	local g=Duel.GetMatchingGroup(s.slimefilter,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,nil)
	return #g*1000
end

--Slime Token
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,21770261,0x13d,0x13d,0,0,3,RACE_AQUA,ATTRIBUTE_WATER) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if Duel.IsPlayerCanSpecialSummonMonster(tp,21770261,0x13d,0x13d,0,0,3,RACE_AQUA,ATTRIBUTE_WATER) then
		local token=Duel.CreateToken(tp,21770261)
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
end

--Inflict damage
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return rc and rc:IsRace(RACE_DIVINE)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Damage(1-tp,2000,REASON_EFFECT)
end

--Tribute up to 2 monsters to summon Slimes or Humanoid Worm Drake
function s.spfilter(c,e,tp)
	return c:IsCode(511600034,68638985,46821314,18914778,15771991,511001208,513000142,
    79387392,511001205,3918345,511000482,511001207,511001206,20056760,
    80250319,80551022,42166000,511000285,id,5600127) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local ft=math.min(2,Duel.GetLocationCount(tp,LOCATION_MZONE))
	if ft<=0 then return end
	local g=Duel.SelectReleaseGroupCost(tp,aux.TRUE,1,ft,false,nil)
	local ct=Duel.Release(g,REASON_COST)
	if ct>0 then
		for i=1,ct do
			local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,e,tp)
			if #sg>0 then
				Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end

--Change name
--Name Change Effect (Sobek)
function s.nameop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    -- available codes
    local codes={10000010,10000000,10000020} -- replace with actual card IDs
    local names={aux.Stringid(id,4),aux.Stringid(id,5),aux.Stringid(id,6)} 
    -- player picks
    local sel=Duel.SelectOption(tp,table.unpack(names))+1
    if sel>0 then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CHANGE_CODE)
        e1:SetValue(codes[sel])
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        c:RegisterEffect(e1)
    end
end

