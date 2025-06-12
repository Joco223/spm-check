require("utils.science")
require("utils.ui")

local function init_storage(player)
    if storage.players == nil then
        storage.players = {}
    end

    if storage.players[player.index] == nil then
        storage.players[player.index] = { spmc_gui = nil }
    end

    storage.grace = settings.startup["grace-period-time"].value * 2
    storage.required_spm = {}
end

script.on_event(defines.events.on_player_created, function(event)
    local player = game.get_player(event.player_index)
    init_storage(player)
    create_ui(player)

    script.on_nth_tick(30, function()
        is_spm_valid_research()
        update_spmc(storage.players[player.index].spmc_gui)

        if storage.grace == 0 then
            game.forces.player.cancel_current_research()
        end
    end)
end)

script.on_event(defines.events.on_gui_click, function(event)
    if event.element.name == "scpm_close_ui" then
        close_interface(game.get_player(event.player_index))
    end
end)

script.on_event(defines.events.on_lua_shortcut, function(event)
    if event.prototype_name == "spmc_toggle" then
    	toggle_interface(game.get_player(event.player_index))
	end
end)

script.on_event(defines.events.on_research_started, function(event)
    storage.grace = settings.startup["grace-period-time"].value * 2
end)

script.on_event(defines.events.on_research_cancelled, function(event)
    storage.required_spm = {}
end)

script.on_event(defines.events.on_research_finished, function(event)
    storage.required_spm = {}
end)

script.on_event("spmc_toggle_interface", function(event)
    toggle_interface(game.get_player(event.player_index))
end)

script.on_init(function()
    storage.players = {}
    storage.science_pack_data = update_science_pack_data()
    storage.current_spm = {}

    -- Initializing player data
    for _, player in pairs(game.players) do
        init_storage(player)
    end


    for _, player in pairs(game.players) do
        local spmc_gui = player.gui.screen.spmc_gui
        if spmc_gui ~= nil then
            spmc_gui.destroy()
        end
    end
end)

script.on_configuration_changed(function(config_changed_data)
    if config_changed_data.mod_changes["spm-check"] then
        for _, player in pairs(game.players) do
            local spmc_gui = player.gui.screen.spmc_gui
            if spmc_gui ~= nil then
                spmc_gui.destroy()
                init_storage(player)
                create_ui(player)
            end
        end
    end
end)