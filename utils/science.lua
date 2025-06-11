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

    for surface_name, _ in pairs(game.surfaces) do
        if game.forces.player then
            local stats = game.forces.player.get_item_production_statistics(surface_name)
            for _, sp in pairs(storage.science_pack_data) do
                if storage.current_spm[sp.name] == nil then storage.current_spm[sp.name] = 0 end
                storage.current_spm[sp.name] = storage.current_spm[sp.name] + stats.get_input_count(sp.name)
            end
        else
            game.print("[ERROR][SPMC] No player or force found to calculate science pack rates.")
        end
    end
end

function is_spm_valid_research()
    update_science_pack_spm()

    if storage.grace == 0 then
        return {}
    end

    local current_research = game.forces.player.current_research or nil

    if current_research == nil then
        return {}
    end

    local research_ingredients = current_research.research_unit_ingredients
    local research_unit_count = current_research.research_unit_count
    local science_spoil_time = settings.startup["science-spoilage-time"].value

    local fail = false
    local spm_data = {}

    for _, item in ipairs(research_ingredients) do
        if storage.science_pack_data[item.name] == nil then
            return
        end

        local science_cost = item.amount * research_unit_count
        local required_spm = science_cost / science_spoil_time

        spm_data[item.name] = { item = item, required = required_spm }

        if storage.current_spm[item.name] < required_spm then
            fail = true
        end
    end

    if fail then
        game.forces.player.cancel_current_research()
        game.print("Not enough SPM to research this technology! Start research and open SPM Checker window to see how much you need.")
        return spm_data
    end

    return spm_data
end