local Object = require("thirdparty.classic.classic")

local Widget = Object:extend()
local Container = Widget:extend()
local Layout = Container:extend()
local Button = Widget:extend()

local UI = Container:extend()
local StackLayout = Layout:extend()

string.lpad = function(str, len, char)
  if char == nil then
    char = " "
  end
  return str .. string.rep(char, len - #str)
end

--- Pads str to length len with char from left
string.rpad = function(str, len, char)
  if char == nil then
    char = " "
  end
  return string.rep(char, len - #str) .. str
end

--[[
  ******************************************************************
  Widget
  ******************************************************************
--]]
function Widget:new(x, y, width, height)
  self.x = x or 0
  self.y = y or 0
  self.width = width or 0
  self.height = height or 0
  self.isDirty = true
  self.parent = nil
  self.isPressed = false
  self.isHovered = false
  self.tag = nil

  self.actions = {
    pressed = function()
    end
  }
end

function Widget:__toString()
  return "Widget"
end

function Widget:onMouseEnter()
  -- print("onMouseEnter", self:__toString())
  self.isHovered = true
end

function Widget:onMouseLeave()
  -- print("onMouseLeave", self:__toString())
  self.isHovered = false
  self.isPressed = false
end

function Widget:onMouseMove()
  -- print("onMouseMove", self:__toString())
end

function Widget:onMouseDown(button, mx, my)
  -- print("onMouseDown", self:__toString(), button, mx, my)
  self.isHovered = true
  self.isPressed = true
end

function Widget:onMousePressed(button, mx, my)
  -- print("onMousePressed", self:__toString(), button, mx, my)
  self.isPressed = true
  self.actions.pressed(self, button, mx, my)
end

function Widget:onMouseReleased(button, mx, my)
  -- print("onMouseReleased", self:__toString(), button, mx, my)
  self.isPressed = false
end

function Widget:getLocation()
  return self.x, self.y
end

function Widget:getDimensions()
  return self.width, self.height
end

function Widget:setLocation(x, y)
  self.x, self.y = x, y
end

function Widget:setDimensions(width, height)
  self.width, self.height = width, height
end

function Widget:update(dt)
  if self.isDirty then
    self:cleanDirtyFlag()
  end
end

function Widget:cleanDirtyFlag()
  self.isDirty = false
end

function Widget:setDirty()
  self.isDirty = true
end

function Widget:setParent(parent)
  self.parent = parent
end

function Widget:print(level)
  level = level or 0

  local pad = ""
  for i = 1, level do
    pad = pad .. "-"
  end
  local sx, sy = self:toScreenCoordinates()
  print(
    (pad .. self:__toString()):lpad(50),
    "x: " .. self.x,
    "y: " .. self.y,
    "sx: " .. sx,
    "sy: " .. sy,
    "w: " .. self.width,
    "h: " .. self.height
  )

  if self.elements then
    for k, v in pairs(self.elements) do
      v:print(level + 1)
    end
  end
end

function Widget:toScreenCoordinates()
  if self.parent then
    local sx, sy = self.parent:toScreenCoordinates()
    return self.x + sx, self.y + sy
  end
  return self.x, self.y
end

function Widget:findElement(mx, my)
  -- print("[FINDELEMENT] " .. self:__toString(), self.x, self.y, self.width, self.height)
  local wx, wy = self:toScreenCoordinates()
  -- print((self:__toString()):lpad(50), wx, wy)

  if mx >= wx and my >= wy and mx <= wx + self.width and my <= wy + self.height then
    return self
  else
    return nil
  end
end

function Widget:drawBoundingBox()
  love.graphics.push("all")
  love.graphics.setColor(1, 0, 0)
  love.graphics.setLineWidth(3)
  love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
  love.graphics.pop()
end

--[[
  ******************************************************************
  Layout
  ******************************************************************
--]]
function Layout:new(x, y, width, height)
  Layout.super.new(self, x, y, width, height)
end

function Layout:__toString()
  return "Layout"
end

function Layout:updateLayout(parentDimensions)
end

--[[
  ******************************************************************
  Container
  ******************************************************************
--]]
function Container:new(x, y, width, height)
  Container.super.new(self, x, y, width, height)
  self.isDirty = true
  self.elements = {}
end

function Container:__toString()
  if self.tag then
    return "Container [" .. self.tag .. "]"
  end
  return "Container"
end

function Container:update(dt)
  Container.super.update(self, dt)

  if self.elements then
    for _, element in ipairs(self.elements) do
      element:update(dt)
    end
  end
end

function Container:findElement(mx, my)
  -- print("[FINDELEMENT] " .. self:__toString())
  local hitContainer = Container.super.findElement(self, mx, my)
  if hitContainer then
    for _ = #self.elements, 1, -1 do
      local foundElement = self.elements[_]:findElement(mx, my)
      if foundElement then
        return foundElement
      end
    end
  end

  return hitContainer
end

function Container:cleanDirtyFlag()
  Container.super.cleanDirtyFlag(self)

  if self.elements then
    for _, element in ipairs(self.elements) do
      element:cleanDirtyFlag()
    end
  end
end

function Container:setDirty()
  Container.super.setDirty(self)

  if self.elements then
    for _, element in ipairs(self.elements) do
      element:setDirty()
    end
  end
end

function Container:addElement(element)
  local hasALayout = #self.elements == 1 and self.elements[1]:is(Layout)
  local hasElements = #self.elements >= 1

  if self:is(Layout) then
    table.insert(self.elements, element)
    element:setParent(self)
    if self.parent then
      self.parent:setDirty()
    else
      self:setDirty()
    end

    self:updateLayout(self:getDimensions())
    return element
  end

  if element:is(Layout) then
    if hasElements then
      if hasALayout then
        -- new element is a layout. there is already an layout. new layout is now a child of the existing layout.
        local currentLayout = self.elements[1]
        table.insert(currentLayout.elements, element)
        element:setParent(currentLayout)
        if self.parent then
          self.parent:setDirty()
        else
          self:setDirty()
        end
        currentLayout:updateLayout(self:getDimensions())
        return element
      else
        -- new element is a layout. there is no layout but there are already some elements. layout is now a child of the current container.
        -- existing elements are now children of the new layout
        for _, existingElement in ipairs(self.elements) do
          element:addElement(existingElement)
          existingElement:setParent(element)
        end
        self.elements = {}
        table.insert(self.elements, element)
        element:setParent(self)
        return element
      end
    else
      -- new element is a layout. there are no elements. layout is now a child of the current container
      table.insert(self.elements, element)
      element:setParent(self)
      if self.parent then
        self.parent:setDirty()
      else
        self:setDirty()
      end
      element:updateLayout(self:getDimensions())
      return element
    end
  else
    if hasALayout then
      -- new element is not a layout. there is already a layout. new element is now a child of the existing layout
      local currentLayout = self.elements[1]
      table.insert(currentLayout.elements, element)
      element:setParent(currentLayout)
      if self.parent then
        self.parent:setDirty()
      else
        self:setDirty()
      end
      currentLayout:updateLayout(self:getDimensions())
      return element
    else
      -- new element is not a layout. there is no layout. new element is now just a child of the current container
      table.insert(self.elements, element)
      element:setParent(self)
      if self.parent then
        self.parent:setDirty()
      else
        self:setDirty()
      end
      return element
    end
  end
end

function Container:draw()
  love.graphics.push("all")
  love.graphics.setScissor(self.x, self.y, self.width, self.height)
  love.graphics.translate(self.x, self.y)
  for _, element in ipairs(self.elements) do
    element:draw()
  end
  love.graphics.pop()
  self:drawBoundingBox()
end

--[[
  ******************************************************************
  StackLayout
  ******************************************************************
--]]
function StackLayout:__toString()
  if self.tag then
    return "StackLayout [" .. self.tag .. "]"
  else
    return "StackLayout"
  end
end

function StackLayout:new(horizontal)
  StackLayout.super.new(self)
  self.horizontal = horizontal or false
end

-- function StackLayout:setLocation()
--   local ox, oy = self.parent:getLocation()
--   local w, h = self.parent:getDimensions()
--   local elementNumber = 1
--   if self.parent:is(StackLayout) then
--     elementNumber = #self.parent.elements or 1
--   end

--   if self.horizontal then
--     local chunkSize = self.width / elementNumber
--     self.x, self.y = chunkSize + ox, oy
--   else
--     self.x, self.y = ox, oy + h / elementNumber
--   end
-- end

-- function StackLayout:setDimensions()
--   local w, h = self.parent:getDimensions()

--   local elementNumber = 1
--   if self.parent:is(StackLayout) then
--     elementNumber = #self.parent.elements or 1
--   end

--   if self.horizontal then
--     local chunkSize = w / elementNumber
--     self.width, self.height = chunkSize, h / elementNumber
--   else
--     self.width, self.height = w, h / elementNumber
--   end

--   print(self.width, self.height)
-- end

function StackLayout:updateLayout(parentWidth, parentHeight)
  -- print((self:__toString() .. " StackLayout:updateLayout"):lpad(50), parentWidth, parentHeight)
  self:setDimensions(parentWidth, parentHeight)

  if self.horizontal then
    local chunkSize = self.width / (#self.elements or 1)
    for _, e in ipairs(self.elements) do
      e.width = chunkSize
      e.height = self.height
      e.x = (_ - 1) * chunkSize
      e.y = 0
      -- print(("Element H " .. e:__toString()):lpad(50), e.x, e.y, e.width, e.height)
    end
  else
    local chunkSize = self.height / (#self.elements or 1)
    for _, e in ipairs(self.elements) do
      e.width = self.width
      e.height = chunkSize
      e.x = 0
      e.y = (_ - 1) * chunkSize
      -- print(("Element V " .. e:__toString()):lpad(50), e.x, e.y, e.width, e.height)
    end
  end
end

function StackLayout:cleanDirtyFlag()
  StackLayout.super.cleanDirtyFlag(self)

  -- self:setDimensions(self.parent:getDimensions())
  -- self:setLocation(0, 0)

  -- if self.horizontal then
  --   local chunkSize = self.width / (#self.elements or 1)
  --   for _, e in ipairs(self.elements) do
  --     e.width = chunkSize
  --     e.height = self.height
  --     e.x = (_ - 1) * chunkSize
  --     e.y = 0
  --     print("Element H " .. e:__toString(), e.x, e.y, e.width, e.height, chunkSize)
  --   end
  -- else
  --   local chunkSize = self.height / (#self.elements or 1)
  --   for _, e in ipairs(self.elements) do
  --     e.width = self.width
  --     e.height = chunkSize
  --     e.x = 0
  --     e.y = (_ - 1) * chunkSize
  --     print("Element V " .. e:__toString(), e.x, e.y, e.width, e.height, chunkSize)
  --   end
  -- end
end

--[[
  ******************************************************************
  UI
  ******************************************************************
--]]
function Button:__toString()
  if self.text then
    return "Button [" .. self.text .. "]"
  end
  return "Button"
end

function Button:new(text, x, y, width, height)
  self.text = text or "Button" -- workaround: __toString would crash because text is nil

  Button.super.new(self, x or 0, y or 0, width or 100, height or 20)

  self.textWidth = 0
  self.textHeight = 0
  self.parent = nil
  -- actions
  self.pressed = nil
  self.down = nil
  self.released = nil
  -- style
  self.style = {
    background = {0, 0, 0},
    text = {1, 1, 1}
  }
  self.hoverStyle = {
    background = {0.2, 0.2, 0.2},
    text = {1, 1, 1}
  }
  self.pressedStyle = {
    background = {0.4, 0.3, 0.2},
    text = {1, 1, 1}
  }

  self:setText(self.text)
end

function Button:setText(text)
  self.text = text
  self:setDirty()
  self:cleanDirtyFlag()
end

function Button:cleanDirtyFlag()
  Button.super.cleanDirtyFlag(self)

  local currentFont = love.graphics.getFont()
  self.textWidth, self.textHeight = currentFont:getWidth(self.text), currentFont:getHeight(self.text)
  self.isDirty = false
end

function Button:draw()
  love.graphics.push("all")

  if self.isPressed then
    love.graphics.setColor(self.pressedStyle.background)
  elseif self.isHovered then
    love.graphics.setColor(self.hoverStyle.background)
  else
    love.graphics.setColor(self.style.background)
  end
  love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

  if self.isHovered then
    love.graphics.setColor(self.hoverStyle.text)
  elseif self.isPressed then
    love.graphics.setColor(self.pressedStyle.text)
  else
    love.graphics.setColor(self.style.text)
  end
  love.graphics.print(
    self.text,
    self.x + (self.width * 0.5) - (self.textWidth * 0.5),
    self.y + (self.height * 0.5) - (self.textHeight * 0.5)
  )
  love.graphics.pop()
  self:drawBoundingBox()
end

--[[
  ******************************************************************
  UI
  ******************************************************************
--]]
function UI:__toString()
  return "UI"
end

function UI:new()
  UI.super.new(self)

  self.elements = {}
  self.font = love.graphics.getFont()
  self.parent = nil
  self.canvas = nil
  self.width, self.height = love.graphics.getDimensions()
  self.visible = true
  self.canvas = love.graphics.newCanvas(self.width, self.height)
  self.hoveredElement = nil

  self.mouse = {
    x = 0,
    y = 0,
    buttons = {
      left = false,
      right = false,
      middle = false
    }
  }
end

function UI:draw()
  if not self.visible then
    return
  end
  love.graphics.push("all")
  love.graphics.setCanvas(self.canvas)
  love.graphics.clear(1, 1, 1, 0)
  love.graphics.setFont(self.font)
  for _, element in ipairs(self.elements) do
    element:draw()
  end
  love.graphics.setCanvas()
  love.graphics.draw(self.canvas, self.x, self.y)
  if self.hoveredElement then
    love.graphics.print("hovered " .. self.hoveredElement:__toString(), 10, 10)
  end
  love.graphics.pop()
  self:drawBoundingBox()
end

function UI:update(dt)
  if not self.visible then
    return
  end

  UI.super.update(self, dt)

  local mx, my = love.mouse.getPosition()
  local lb = love.mouse.isDown(1)
  local rb = love.mouse.isDown(2)
  local mb = love.mouse.isDown(3)

  local buttonPressed = nil
  local buttonReleased = nil
  local buttonBefore = nil
  if lb then
    buttonPressed = 1
  end
  if rb then
    buttonPressed = 2
  end
  if mb then
    buttonPressed = 3
  end
  if self.mouse.buttons.left and lb == false then
    buttonReleased = 1
  end
  if self.mouse.buttons.right and rb == false then
    buttonReleased = 2
  end
  if self.mouse.buttons.middle and mb == false then
    buttonReleased = 3
  end
  if self.mouse.buttons.left then
    buttonBefore = 1
  end
  if self.mouse.buttons.right then
    buttonBefore = 2
  end
  if self.mouse.buttons.middle then
    buttonBefore = 3
  end

  local foundElement = self:findElement(mx, my)
  if foundElement then
    if buttonBefore == nil and buttonPressed ~= nil then
      foundElement:onMousePressed(buttonPressed, mx, my)
    elseif buttonPressed ~= nil and buttonPressed == buttonBefore then
      foundElement:onMouseDown(buttonPressed, mx, my)
    elseif buttonReleased ~= nil then
      foundElement:onMouseReleased(buttonReleased, mx, my)
    end
  end

  if foundElement and foundElement ~= self.hoveredElement then
    if self.hoveredElement then
      self.hoveredElement:onMouseLeave()
    end
    foundElement:onMouseEnter()
  end

  if foundElement and (self.mouse.x ~= mx or self.mouse.y ~= my) then
    foundElement:onMouseMove(mx, my)
  end

  self.hoveredElement = foundElement
  self.mouse.x, self.mouse.y = mx, my
  self.mouse.buttons.left = lb
  self.mouse.buttons.right = rb
  self.mouse.buttons.middle = mb
end

return {
  UI = UI,
  StackLayout = StackLayout,
  Button = Button,
  Container = Container
}
