local function pack_in_elements(pack, elements)
    for _, element in pairs(elements) do
        if string.find(element.name, pack, 1, true) ~= nil then
            return true
        end
    end

    return false
end

local function find_in_elements(elements, type, name)
    for _, element in pairs(elements) do
        if string.find(element.name, type, 1, true) ~= nil and string.find(element.name, name, 1, true) ~= nil then
            return element
        end
    end

    return nil
end

function update_spmc(spmc_gui)
    if spmc_gui == nil then
        game.print("[ERROR][SPMC] Main GUI hasn't been created.")
        return
    end

    local science_table = spmc_gui.spmc_inner_frame.spmc_inner_flow.spmc_science_table

    if science_table == nil then
        game.print("[ERROR][SPMC] Science table hasn't been created.")
        return
    end

    if storage.current_spm == nil or storage.current_spm == {} then
        game.print("[ERROR][SPMC] Science SPM hasn't been calculated.")
        return
    end

    local elements = science_table.children

    for name, _ in pairs(storage.science_pack_data) do
        if pack_in_elements(name, elements) then
            local science_element = find_in_elements(elements, "element", name)

            if science_element == nil then
                game.print("[ERROR][SCPM] Couldn't find parent element for " .. name)
                return
            end

            local parent_elements = science_element.children
            local science_progressbar = find_in_elements(parent_elements, "progressbar", name)
            local science_label = find_in_elements(parent_elements, "label", name)

            local max_grace = settings.startup["grace-period-time"].value
            local grace_progessbar = spmc_gui.spmc_inner_frame_lower.spmc_inner_flow_lower.spmc_grace_period_progressbar
            local grace_label = spmc_gui.spmc_inner_frame_lower.spmc_inner_flow_lower.spmc_grace_caption

            if science_progressbar == nil then
                game.print("[ERROR][SCPM] Couldn't find progressbar for " .. name)
                return
            end

            if science_label == nil then
                game.print("[ERROR][SCPM] Couldn't find label for " .. name)
                return
            end

            if storage.required_spm ~= nil and #storage.required_spm ~= 0 then
                science_progressbar.value = storage.current_spm[name] / storage.required_spm[name]
                science_label.caption = storage.current_spm[name].." / "..storage.required_spm[name].." SPM"

                if storage.current_spm[name] >= storage.required_spm[name] then
                    science_label.style.font_color = { 0.42, 0.86, 0.3 }
                else
                    science_label.style.font_color = { 1, 0.35, 0.1 }
                end

                grace_progessbar.value = storage.grace / max_grace
                grace_label.caption = "Grace period left: "..storage.grace.."s"
            else
                science_progressbar.value = 1
                science_label.caption = storage.current_spm[name] .. " SPM"

                grace_progessbar.value = 1
                grace_label.caption = "No research active!"
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
    storage.players[player.index].spmc_gui.style.natural_width = 400
    local title_flow = storage.players[player.index].spmc_gui.add { type = "flow", name = "title_flow" }

    local title = title_flow.add { type = "label", caption = { "spmc.ui_title" }, style = "frame_title" }
    title.drag_target = storage.players[player.index].spmc_gui

    local pusher = title_flow.add { type = "empty-widget", style = "draggable_space_header" }
    pusher.style.vertically_stretchable = true
    pusher.style.horizontally_stretchable = true
    pusher.drag_target = storage.players[player.index].spmc_gui

    title_flow.add { type = "sprite-button", style = "frame_action_button", sprite = "utility/close", name = "scpm_close_ui" }

    storage.players[player.index].spmc_gui.auto_center = true
    storage.players[player.index].spmc_gui.visible = false

    local inner_ui = storage.players[player.index].spmc_gui.add { type = "frame", name = "spmc_inner_frame", style = "inside_shallow_frame_with_padding" }
    local inner_flow = inner_ui.add { type = "flow", name = "spmc_inner_flow", direction = "vertical" }
    inner_flow.style.horizontal_align = "center"
    inner_flow.style.horizontally_stretchable = true
    local science_title = inner_flow.add { type = "label", name = "spmc_science_title", caption = "Science production", style = "subheader_caption_label" }
    science_title.style.font = "heading-2"
    science_title.style.font_color = {1, 0.901961, 0.752941}
    local science_table = inner_flow.add { type = "scroll-pane", name = "spmc_science_table", vertical_centering = true, direction = "vertical", style = "scroll_pane" }

    local inner_lower_ui = storage.players[player.index].spmc_gui.add { type = "frame", name = "spmc_inner_frame_lower", style = "inside_shallow_frame_with_padding" }
    local inner_flow_lower = inner_lower_ui.add { type = "flow", name = "spmc_inner_flow_lower", direction = "vertical" }
    inner_flow_lower.style.horizontal_align = "center"
    inner_flow_lower.style.horizontally_stretchable = true
    local grace_title = inner_flow_lower.add { type = "label", name = "spmc_grace_title", caption = "Grace period", style = "subheader_label" }
    grace_title.style.font = "heading-2"
    grace_title.style.font_color = {1, 0.901961, 0.752941}
    local progress_bar = inner_flow_lower.add { type = "progressbar", name = "spmc_grace_period_progressbar", style = "progressbar", value = 1 }
    progress_bar.style.horizontally_stretchable = true
    progress_bar.style.natural_width = 300
    local grace_caption = inner_flow_lower.add { type = "label", name = "spmc_grace_caption", caption = "No research selected!", style="subheader_caption_label" }
    grace_caption.style.font = "default-bold"

    for name, item in pairs(storage.science_pack_data) do
        local science_elem = science_table.add { type = "flow", name = "spmc_science_element_" .. name, direction = "horizontal", horizontally_stretchable = true }
        science_elem.style.vertical_align = "center"
        science_elem.style.padding = 2
        science_elem.style.horizontally_stretchable = true
        science_elem.add { type = "sprite-button", name = "spmc_science_sprite_" .. name, sprite = "item/" .. name, tooltip = { item.name } }
        local progress = science_elem.add { type = "progressbar", name = "spmc_science_progressbar_" .. name, style = "progressbar", value = 1 }
        progress.style.horizontally_stretchable = true
        progress.style.natural_width = 300
        local total_label = science_elem.add { type = "label", name = "spmc_science_label_" .. name, caption = "0 SPM" }
        total_label.style.font = "default-bold"
        total_label.style.natural_width = 80
        total_label.style.horizontal_align = "right"
        total_label.style.left_padding = 4
    end
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