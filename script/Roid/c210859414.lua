--Fünfroid
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
    --Excavate
	local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_series={0x16}
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD,e:GetHandler())
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<5 then return false end
		local g=Duel.GetDecktopGroup(tp,5)
		local result=g:FilterCount(Card.IsAbleToHand,nil)>0
		return result and Duel.IsPlayerCanDiscardDeck(tp,5)
	end
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsPlayerCanDiscardDeck(tp,5) then return end
	Duel.ConfirmDecktop(tp,5)
	local g=Duel.GetDecktopGroup(tp,5)
	if #g>0 then
		Duel.DisableShuffleCheck()
		if g:IsExists(Card.IsSetCard,1,nil,0x16) then
            if e:GetHandler():IsReason(REASON_BATTLE) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
                local sg=g:Filter(Card.IsSetCard,nil,0x16)
                Duel.SendtoHand(sg,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,sg)
				Duel.ShuffleHand(tp)
                g:Sub(sg)
                Duel.SendtoGrave(g,REASON_EFFECT+REASON_REVEAL)
            else
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
                local sg=g:FilterSelect(tp,Card.IsSetCard,1,1,nil,0x16)
                if sg:GetFirst():IsAbleToHand() then 
                    Duel.SendtoHand(sg,nil,REASON_EFFECT)
                    Duel.ConfirmCards(1-tp,sg)
                    Duel.ShuffleHand(tp)
                    g:Sub(sg)
                    Duel.SendtoGrave(g,REASON_EFFECT+REASON_REVEAL)
                else
                    Duel.SendtoGrave(g,REASON_EFFECT+REASON_REVEAL)
                end
			end
		else
            Duel.MoveToDeckBottom(g,tp)
            Duel.SortDeckbottom(tp,tp,#g)
		end
	end
end