-- Blue-Eyes Fusion
local s, id = GetID()
function s.initial_effect(c)
  --Activate
  local e1=Fusion.CreateSummonEff(c, aux.FilterBoolFunction(aux.IsMaterialListSetCard,0xdd), nil, s.fextra, Fusion.ShuffleMaterial, nil, s.stage2)
	e1:SetCountLimit(1, id)
	c:RegisterEffect(e1)
  --Search
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
  e2:SetCountLimit(1, id+100)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_BLUEEYES_W_DRAGON, 23995346}
s.listed_series={0xdd}
--Activate
function s.fcheck(tp, sg, fc)
	return sg:IsExists(aux.FilterBoolFunction(Card.IsSetCard, 0xdd, fc, SUMMON_TYPE_FUSION, tp), 1, nil)
      and sg:GetClassCount(function(c) return c:GetLocation()&~(LOCATION_ONFIELD) end)==#sg
end
function s.fextra(e, tp, mg)
	return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(aux.AND(Card.IsAbleToDeck)), tp, LOCATION_GRAVE+LOCATION_REMOVED, 0, nil), s.fcheck
end
function s.stage2(e, tc, tp, sg, chk)
	if chk==1 then
		local mats=sg:FilterCount(Card.IsOriginalCode, nil, CARD_BLUEEYES_W_DRAGON)
    local g=Duel.GetMatchingGroup(aux.TRUE, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, tc)
    g:RemoveCard(tc)
    if mats==3 and #g>0 and Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
      Duel.Destroy(g, REASON_EFFECT)
    end
	end
end
--Search
function s.tgfilter(c)
	return c:IsSetCard(0xdd) and c:IsAbleToGraveAsCost()
end
function s.thcost(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost()
		and Duel.IsExistingMatchingCard(s.tgfilter, tp, LOCATION_EXTRA, 0, 1, nil) end
  local g=Duel.SelectMatchingCard(tp, s.tgfilter, tp, LOCATION_EXTRA, 0, 1, 1, nil)
	Duel.Remove(e:GetHandler(), POS_FACEUP, REASON_COST)
  Duel.SendtoGrave(g, REASON_COST)
end
function s.thfilter(c)
	return (c:IsLevel(8) and c:IsRitualMonster() and c:IsAbleToHand()) or ((aux.IsCodeListed(c, CARD_BLUEEYES_W_DRAGON) or aux.IsCodeListed(c, 23995346))
  and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand())
end
function s.thtg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter, tp, LOCATION_DECK, 0, 1, nil) end
	Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end
function s.thop(e, tp, eg, ep, ev, re, r, rp)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp, s.thfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
	if #g>0 then
		Duel.SendtoHand(g, nil, REASON_EFFECT)
		Duel.ConfirmCards(1-tp, g)
	end
end