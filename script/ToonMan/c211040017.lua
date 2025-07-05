--Salesman 7's Ring of Fortune
local s,id=GetID()
function s.initial_effect(c)
    aux.AddEquipProcedure(c,nil,aux.FilterBoolFunction(Card.IsCode,211040008),nil,nil,nil,nil,nil,EFFECT_FLAG_CANNOT_INACTIVATE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
    --Cannot be targeted by attacks or card effects
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_EQUIP)
    e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e1:SetValue(aux.tgoval)
    c:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_EQUIP)
    e2:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
    e2:SetValue(1)
    c:RegisterEffect(e2)
    --Choose coin toss result
    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EFFECT_TOSS_COIN_CHOOSE)
    e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(function(e,tp,eg,ep)return ep==c:GetOwner() end)
	e3:SetOperation(s.repop(false,Duel.SetCoinResult,function(tp)
		return Duel.AnnounceCoin(c:GetOwner(),aux.Stringid(300102004,4))
	end))
    c:RegisterEffect(e3)
    --Cannot be negated while equipped to "Salesman 777"
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetCode(EFFECT_CANNOT_DISABLE)
    e4:SetCondition(s.nodisablecond)
    c:RegisterEffect(e4)
end
s.listed_names={211040008}

function s.repop(isdice,func2,func3)
    return function(e,tp,eg,ep,ev,re,r,rp)
        if Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
            Duel.Hint(HINT_CARD,tp,id)
            local total=(ev&0xff)+(ev>>16)
            local res={}
            res[1]=func3(ep)
            for i=2,total do
                table.insert(res,Duel.GetRandomNumber(0,1)==0 and COIN_TAILS or COIN_HEADS)	
            end
            func2(table.unpack(res))
        end
    end
end

function s.nodisablecond(e)
    local ec=e:GetHandler():GetEquipTarget()
    return ec and ec:IsCode(211040008)
end
