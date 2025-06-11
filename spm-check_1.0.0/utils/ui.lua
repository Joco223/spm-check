local function get_gui_screen_from_player(player)
    return player.gui.screen.spmc_main_frame
end

local function get_science_table_from_main_frame(frame)
    if frame.spmc_inner_frame == nil then
        return nil
    end

    return frame.spmc_inner_frame.spmc_science_table
end

function update_science_table(spmc_gui)
    if spmc_gui == nil then
        game.print("[ERROR][SPMC] Main GUI hasn't been created.")
        return
    end

    local science_table = get_science_table_from_main_frame(spmc_gui)

    if science_table == nil then
        game.print("[ERROR][SPMC] Science table hasn't been created.")
        return
    end

    if storage.spm_data ~= nil then
        science_table.clear()
        spmc_gui.spmc_inner_frame.spmc_science_table_no_research.visible = false
        science_table.visible = true

        for name, item in pairs(storage.spm_data) do
            local science_parent_elem = science_table.add { type = "frame", name = "spmc_science_element_parent_" .. name, style = "flib_shallow_frame_in_shallow_frame", horizontally_stretchable = true }
            local science_elem = science_parent_elem.add { type = "flow", name = "spmc_science_element_" .. name, direction = "horizontal", horizontally_stretchable = true }
            science_elem.style.vertical_align = "center"
            science_elem.style.padding = 6
            science_elem.style.horizontally_stretchable = true
            local icon = science_elem.add { type = "sprite-button", name = "spmc_science_sprite_" .. name, sprite = "item/" .. name, tooltip = { item.item.name } }
            local science_count = science_elem.add { type = "flow", name = "spmc_science_count_" .. name, direction = "vertical" }
            local total_label = science_count.add { type = "label", name = "spmc_science_made_" .. name, caption = storage.current_spm[name] .. " / " .. item.required .. " SPM" }
            total_label.style.font = "default-bold"
            total_label.style.natural_width = 180
            if storage.current_spm[name] >= item.required then
                total_label.style.font_color = { 0.42, 0.86, 0.3 }
            else
                total_label.style.font_color = { 1, 0.35, 0.1 }
            end
        end
    end

end

function create_ui(player)
    if player == nil then
        game.print("[ERROR][INFO] No player provided for GUI creation.")
    end
    local screen_element = player.gui.screen.spmc_gui

    if screen_element ~= nil then
        return
    end

    storage.players[player.index].spmc_gui = player.gui.screen.add { type = "frame", name = "spmc_main_frame", direction = "vertical" }
    local title_flow = storage.players[player.index].spmc_gui.add{type = "flow", name = "title_flow"}

    local title = title_flow.add{type = "label", caption = { "spmc.ui_title" }, style = "frame_title"}
    title.drag_target = storage.players[player.index].spmc_gui

    local pusher = title_flow.add{type = "empty-widget", style = "draggable_space_header"}
    pusher.style.vertically_stretchable = true
    pusher.style.horizontally_stretchable = true
    pusher.drag_target = storage.players[player.index].spmc_gui

    title_flow.add { type = "sprite-button", style = "frame_action_button", sprite = "utility/close", name = "scpm_close_ui" }

    storage.players[player.index].spmc_gui.style.natural_width = 400
    storage.players[player.index].spmc_gui.auto_center = true
    storage.players[player.index].spmc_gui.visible = false

    local inner_ui = storage.players[player.index].spmc_gui.add { type = "frame", name = "spmc_inner_frame", style = "inside_shallow_frame_with_padding" }
    inner_ui.add{ type = "label", name = "spmc_science_table_no_research", caption = "No research selected!", visible = true }
    science_table = inner_ui.add { type = "table", name = "spmc_science_table", column_count = 2, vertical_centering = true, visible = false }
end

function toggle_interface(player)
    if storage.players[player.index].spmc_gui ~= nil then
        storage.players[player.index].spmc_gui.visible = not storage.players[player.index].spmc_gui.visible
    end
end

function show_interface(spmc_gui)
    if spmc_gui ~= nil then
        spmc_gui.visible = true
    end
end

function close_interface(player)
    if player ~= nil then
        storage.players[player.index].spmc_gui.visible = false
    end
end

function show_science_table(spmc_gui)
    if spmc_gui == nil then
        game.print("[ERROR][SPMC] Main GUI hasn't been created.")
        return
    end

    local science_table = get_science_table_from_main_frame(spmc_gui)

    if science_table == nil then
        game.print("[ERROR][SPMC] Science table hasn't been created hasn't been created.")
        return
    end

    science_table.visible = true
    spmc_gui.spmc_inner_frame.spmc_science_table_no_research.visible = false
end

function clear_science_table(spmc_gui)
    if spmc_gui == nil then
        game.print("[ERROR][SPMC] Main GUI hasn't been created.")
        return
    end

    local science_table = get_science_table_from_main_frame(spmc_gui)

    if science_table == nil then
        game.print("[ERROR][SPMC] Science table hasn't been created hasn't been created.")
        return
    end

    science_table.clear()
    science_table.visible = false
    spmc_gui.spmc_inner_frame.spmc_science_table_no_research.visible = true
end