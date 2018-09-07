local PointerActions = {}
local DEFAULT_MOVE_DURATION = 0.25 -- 250ms

function PointerActions:pointer_down(button, device)
  return self:button_action(button, "create_pointer_down", device)
end

function PointerActions:pointer_up(button, device)
  return self:button_action(button, "create_pointer_up", device)
end

function PointerActions:move_to(element, right_by, down_by, device)
  local pointer = self:get_pointer(device)
  local left = 0
  local top = 0
  if right_by or down_by then
    local rect = element:get_rect()
    local left_offset = math.floor(rect.width / 2)
    local top_offset = math.floor(rect.height/ 2)
    left = - left_offset + (right_by or 0)
    top = - top_offset + (down_by or 0)
  end
  pointer:create_pointer_move({ duration = DEFAULT_MOVE_DURATION, x = left, y = top, element = element })
  self:tick(pointer)
  return self
end

function PointerActions:move_by(right_by, down_by, device)
  local pointer = self:get_pointer(device)
  pointer:create_pointer_move({ duration = DEFAULT_MOVE_DURATION, x = right_by, y = down_by, origin = "pointer" })
  return self
end

function PointerActions:move_to_location(x, y, device)
  local pointer = self:get_pointer(device)
  pointer:create_pointer_move({ duration = DEFAULT_MOVE_DURATION, x = x, y = y, origin = "viewport" })
  tick(pointer)
  return self
end

function PointerActions:click_and_hold(element, device)
  if element then
    self:move_to(element, device)
  end
  self:pointer_down("left", device)
  return self
end

function PointerActions:release(device)
  self:pointer_up("left", device)
  return self
end

function PointerActions:click(element, device)
  if element then
    self:move_to(element, device)
  end
  self:pointer_down("left", device)
  self:pointer_up("left", device)
  return self
end

function PointerActions:double_click(element, device)
  if element then
    self:move_to(element, device)
  end
  self:click(nil, device)
  self:click(nil, device)
  return self
end

function PointerActions:context_click(element, device)
  if element then
    self:move_to(element, device)
  end
  self:pointer_down("right", device)
  self:pointer_up("right", device)
  return self
end

function PointerActions:drag_and_drop(source, target, device)
  self:click_and_hold(source, device)
  self:move_to(target, device)
  self:release(device)
  return self
end

function PointerActions:drag_and_drop_by(source, right_by, down_by, device)
  self:click_and_hold(source, device)
  self:move_by(right_by, down_by, device)
  self:release(device)
  return self
end

function PointerActions:button_action(button, action, device)
  local pointer = self:get_pointer(device)
  pointer[action](pointer, button)
  self:tick(pointer)
  return self
end

function PointerActions:get_pointer(device)
  return self:get_device(device) or self:pointer_inputs()[1]
end

return PointerActions
