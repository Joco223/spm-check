require("utils.science")
require("utils.ui")

local function init_storage(player)
    if storage.players == nil then
        storage.players = {}
    end
    if storage.players[player.index] == nil then
        storage.players[player.index] = { spmc_gui = nil }
    end
end

script.on_event(defines.events.on_player_created, function(event)
    init_storage(game.get_player(event.player_index))
    create_ui(game.get_player(event.player_index))
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
    for _, player in pairs(storage.players) do
        update_science_table(player.spmc_gui)
    end
    script.on_nth_tick(300, function()
        storage.current_spm = {}
        status, spm_data = is_spm_valid_research()
        storage.spm_data = spm_data
        if not status then
            for _, player in pairs(storage.players) do
                clear_science_table(player.spmc_gui)
            end
        end
        script.on_nth_tick(300, nil)
    end)
end)

script.on_event(defines.events.on_research_cancelled, function(event)
    for _, player in pairs(storage.players) do
        clear_science_table(player.spmc_gui)
    end
end)

script.on_event(defines.events.on_research_finished, function(event)
    for _, player in pairs(storage.players) do
        clear_science_table(player.spmc_gui)
    end
end)

script.on_event("spmc_toggle_interface", function(event)
    toggle_interface(game.get_player(event.player_index))
end)

script.on_init(function()
    storage.players = {}

    -- Initializing player data
    for _, player in pairs(game.players) do
        init_storage(player)
    end

    -- Initialzing science data
    storage.science_pack_data = update_science_pack_data()
    storage.current_spm = {}

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