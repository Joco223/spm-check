data:extend({
    {
        type = "custom-input",
        name = "spmc_toggle_interface",
        key_sequence = "CONTROL + I",
        order = "a"
    },
	{
		type = "shortcut",
		name = "spmc_toggle",
		order = "b[blueprints]-s[spm-check]",
		action = "lua",
		toggleable = true,
		icon = "__spm-check__/graphics/icon.png",
		icon_size = 64,
		small_icon = "__spm-check__/graphics/icon.png",
		small_icon_size = 64
	}
})