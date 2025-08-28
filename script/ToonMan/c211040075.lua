--The Third Mythisch Heljasstvnir Helgvarr
local s,id=GetID()
function s.initial_effect(c)
	--Xyz Summon
	Xyz.AddProcedure(c,nil,2,2)
	c:EnableReviveLimit()
	--Search on Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--Direct attack
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e2)
	-- Monitor stats
    local echeck=Effect.CreateEffect(c)
    echeck:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    echeck:SetCode(EVENT_ADJUST)
    echeck:SetRange(LOCATION_MZONE)
    echeck:SetOperation(s.statcheck)
    c:RegisterEffect(echeck)
    -- Custom trigger: draw+attach
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_DRAW)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_CUSTOM+id)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(3)
    e3:SetTarget(s.drtg)
    e3:SetOperation(s.drop)
    c:RegisterEffect(e3)
	-- --Prevent detaching by opponent
    -- local e4=Effect.CreateEffect(c)
    -- e4:SetType(EFFECT_TYPE_FIELD)
    -- e4:SetCode(EFFECT_CANNOT_REMOVE_MATERIAL)
    -- e4:SetRange(LOCATION_MZONE)
    -- e4:SetTargetRange(LOCATION_MZONE,0)
    -- e4:SetTarget(function(e,c) return c:IsSetCard(0xf8a) and c:IsType(TYPE_XYZ) end)
    -- e4:SetValue(s.indval)
    -- c:RegisterEffect(e4)
end
s.listed_series={0xf8a}

function s.thfilter(c)
	return (c:IsSetCard(0xf8a) or c:ListsArchetype(0xf8a)) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

function s.statcheck(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsOnField() then return end
    local g=Duel.GetMatchingGroup(s.mythischfilter,tp,LOCATION_MZONE,0,nil)
    local changed=false
    for tc in aux.Next(g) do
        local fid=tc:GetFieldID()
        local atk,def=tc:GetAttack(),tc:GetDefense()
        if not s._vals then s._vals={} end
        local prev=s._vals[fid]
        if not prev then
            s._vals[fid]={atk=atk,def=def}
        else
            if prev.atk~=atk or prev.def~=def then
                changed=true
                s._vals[fid]={atk=atk,def=def}
            end
        end
    end
    if changed then
        Duel.RaiseSingleEvent(c,EVENT_CUSTOM+id,e,0,tp,tp,0)
    end
end


function s.mythischfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xf8a) and c:IsType(TYPE_XYZ)
end

function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.mythischfilter,tp,LOCATION_MZONE,0,nil)
	return #g>0
end

function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.Draw(tp,1,REASON_EFFECT)>0 then
		local tc=Duel.GetOperatedGroup():GetFirst()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACH)
		local g=Duel.SelectMatchingCard(tp,s.mythischfilter,tp,LOCATION_MZONE,0,1,1,nil)
		if #g>0 and tc then
			Duel.Overlay(g:GetFirst(),tc)
		end
	end
end

function s.indval(e,re,rp)
    return rp~=e:GetHandlerPlayer()
end
