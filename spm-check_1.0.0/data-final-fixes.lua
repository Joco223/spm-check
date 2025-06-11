require("__flib__.prototypes.style")

-- Sets spoilage time for science packs
local spoilage_time = settings.startup["science-spoilage-time"].value * 60 * 60

for _, item in pairs(data.raw["tool"]) do
  if item.name and string.find(item.name, "science%-pack") then
    item.spoil_ticks = spoilage_time
  end
end