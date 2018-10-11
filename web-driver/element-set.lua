local Searchable = require("web-driver/searchable")

local ElementSet = {}

local methods = {}

local metatable = {}

function metatable.__index(element_set, key)
  return methods[key] or
    Searchable[key]
end

function metatable.__add(added_element_set, add_element_set)
  return methods.merge(added_element_set, add_element_set)
end

local function map(values, func)
  local converted_values = {}
  for i, value in ipairs(values) do
    local converted_value = func(value)
    table.insert(converted_values, converted_value)
  end
  return converted_values
end

function methods:find_elements(strategy, selector)
  local element_set = ElementSet.new({})
  for _, element in ipairs(self) do
    element_set = element_set + element:find_elements(strategy, selector)
  end
  return element_set
end

function methods:text()
  return table.concat(self:texts(), "")
end

function methods:texts()
  return map(self,
             function(element)
               return element:text() or ""
             end)
end

function methods:get_attribute(name)
  return map(self,
             function(element)
               return element:get_attribute(name)
             end)
end

function methods:insert(element_or_position, element)
  local inserted_element = nil
  local position = nil

  if element == nil then
    inserted_element = element_or_position
  else
    position = element_or_position
    inserted_element = element
  end
  for i, self_element in ipairs(self) do
    if self_element.id == inserted_element.id then
      return
    end
  end
  if position == nil then
    table.insert(self, inserted_element)
  else
    table.insert(self, position, inserted_element)
  end
end

function methods:remove(element_or_position)
  if type(element_or_position) == "number" then
    local position = element_or_position
    return table.remove(self, position)
  else
    local element = element_or_position
    for position, self_element in ipairs(self) do
      if self_element.element == element.element then
        return table.remove(self, position)
      end
    end
    return nil
  end
end

local function is_included(element_set, search_element)
  for _, element in ipairs(element_set) do
    if element.id == search_element.id then
      return true
    end
  end
  return false
end

function methods:merge(element_set)
  local raw_element_set = {}
  for _, element in ipairs(self) do
    table.insert(raw_element_set, element)
  end
  for _, element in ipairs(element_set) do
    if not is_included(self, element) then
      table.insert(raw_element_set, element)
    end
  end
  return ElementSet.new(raw_element_set)
end

function methods:click()
  for _, element in ipairs(self) do
    element:click()
  end
end

function methods:send_keys(keys)
  for _, element in ipairs(self) do
    element:send_keys(keys)
  end
end

function ElementSet.new(elements)
  setmetatable(elements, metatable)
  return elements
end

return ElementSet
