-- Find all science packs in the game
function update_science_pack_data()
    local data = {}

    for _, item in pairs(prototypes.item) do
        if item.name and string.find(item.name, "science%-pack") then
            data[item.name] = item
        end
    end

    return data
end

function update_science_pack_spm()
    if storage.science_pack_data == {} then
        game.print("[ERROR][SPMC] Science packs haven't been loaded")
        return
    end

    -- Reseting data

    for _, sp in pairs(storage.science_pack_data) do
        storage.current_spm[sp.name] = 0
    end

    for surface_name, _ in pairs(game.surfaces) do
        if game.forces.player then
            local stats = game.forces.player.get_item_production_statistics(surface_name)
            for _, sp in pairs(storage.science_pack_data) do
                if storage.current_spm[sp.name] == nil then storage.current_spm[sp.name] = 0 end
                storage.current_spm[sp.name] = math.floor(storage.current_spm[sp.name] + stats.get_flow_count { name = sp.name, category = "input", precision_index = defines.flow_precision_index.one_minute, count = true } + 0.5)
            end
        else
            game.print("[ERROR][SPMC] No player or force found to calculate science pack rates.")
        end
    end
end

function is_spm_valid_research()
    update_science_pack_spm()

    if storage.grace == 0 then
        storage.required_spm = {}
        return
    end

    local current_research = game.forces.player.current_research or nil

    if current_research == nil then
        storage.required_spm = {}
        return
    end

    local research_ingredients = current_research.research_unit_ingredients
    local research_unit_count = current_research.research_unit_count
    local science_spoil_time = settings.startup["science-spoilage-time"].value

    local fail = false

    for _, item in ipairs(research_ingredients) do

        local science_cost = item.amount * research_unit_count
        local required_spm = science_cost / science_spoil_time

        storage.required_spm[item.name] = { item = item, required = required_spm }

        if storage.current_spm[item.name] < required_spm then
            fail = true
        end
    end

    if fail then
        game.print("check failed")
        storage.grace = storage.grace - 1
    end

    if storage.required_spm ~= nil then
        game.print(#storage.required_spm.." asdnasiuhgdisa")
    end
end