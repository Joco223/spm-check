data:extend({
  {
    type = "int-setting",
    name = "science-spoilage-time",
    setting_type = "startup",
    default_value = 5,
    minimum_value = 1,
    maximum_value = 60,
    order = "a",
    localised_name = "Science Pack Spoilage Time (minutes)"
    },
  {
    type = "int-setting",
    name = "grace-period-time",
    setting_type = "startup",
    default_value = 10,
    minimum_value = 1,
    maximum_value = 60,
    order = "b",
    localised_name = "Research grace period time"
  }
})