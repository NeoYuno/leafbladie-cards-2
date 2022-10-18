CARD_LEGENDARY_CHEMIST = 210385305
local Chemical={}

--c: Card to check
--...: card ids
function Auxiliary.IsCodeOrChemist(c,...)
  return c:IsCode(...) or Chemical.CheckChemistEff(c)
end

function Chemical.CheckChemistEff(c)
  for _,eff in ipairs({c:GetCardEffect(CARD_LEGENDARY_CHEMIST)}) do
    if eff:IsHasProperty(EFFECT_FLAG_CANNOT_DISABLE) or not c:IsDisabled() then
      local val=eff:GetValue()
      if type(val)=="number" and val==1 then return true end
      if type(val)=="function" and val(eff,c) then return true end
    end
  end
  return false
end
