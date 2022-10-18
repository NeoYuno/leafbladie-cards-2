--Red-Eyes Time Wizard
local s,id=GetID()
function s.initial_effect(c)
	-- Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
    -- Fusion Summon
    local params = {nil,nil,s.fextra,s.extraop}
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,3))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetCountLimit(1,{id,1})
	e2:SetTarget(Fusion.SummonEffTG(table.unpack(params)))
	e2:SetOperation(Fusion.SummonEffOP(table.unpack(params)))
	c:RegisterEffect(e2)
    if not GhostBelleTable then GhostBelleTable={} end
	table.insert(GhostBelleTable,e2)
    --Synchro Summon
    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,4))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetCountLimit(1,{id,1})
	e3:SetTarget(s.sytg)
	e3:SetOperation(s.syop)
	c:RegisterEffect(e3)
end
s.listed_series={0x3b}
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x3b) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 and tc:IsRace(RACE_DRAGON) 
    and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
        if tc:GetLevel()==1 then
            Duel.SelectOption(tp,aux.Stringid(id,1))
        else
            sel=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
        end
        local lv=Duel.AnnounceLevel(tp,1,2)
        if sel==0 then
            local e1=Effect.CreateEffect(c)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_UPDATE_LEVEL)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            e1:SetValue(lv)
            tc:RegisterEffect(e1)
        else
            local e1=Effect.CreateEffect(c)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_UPDATE_LEVEL)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            e1:SetValue(-lv)
            tc:RegisterEffect(e1)
        end
	end
end
function s.fcheck(tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)<=2
end
function s.fextra(e,tp,mg)
	if not Duel.IsPlayerAffectedByEffect(tp,69832741) then
		local eg=Duel.GetMatchingGroup(s.exfilter0,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
		if #eg>0 then
			return eg,s.fcheck
		end
	end
	return nil
end
function s.exfilter0(c)
	return c:IsSetCard(0x3b) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
function s.extraop(e,tc,tp,sg)
	local rg=sg:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
	if #rg>0 then
		Duel.Remove(rg,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
		sg:Sub(rg)
	end
end
function s.sytg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,nil,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.syop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsControler(1-tp) or not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	local g=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,c)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:Select(tp,1,1,nil)
		Duel.SynchroSummon(tp,sg:GetFirst(),c)
	end
end