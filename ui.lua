local Object = require("thirdparty.classic.classic")

local Widget = Object:extend()
local Container = Widget:extend()
local Button = Widget:extend()

local UI = Container:extend()
local StackLayout = Container:extend()

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
  self.isDirty = false
  self.parent = nil
  self.isPressed = false
  self.isHovered = false
end

function Widget:__toString()
  return "Widget"
end

function Widget:onMouseEnter()
  print("onMouseEnter", self:__toString())
  self.isHovered = true
end

function Widget:onMouseLeave()
  print("onMouseLeave", self:__toString())
  self.isHovered = false
  self.isPressed = false
end

function Widget:onMouseMove()
  print("onMouseMove", self:__toString())
end

function Widget:onMouseDown(button, mx, my)
  print("onMouseDown", self:__toString(), button, mx, my)
  self.isHovered = true
  self.isPressed = true
end

function Widget:onMousePressed(button, mx, my)
  print("onMousePressed", self:__toString(), button, mx, my)
  self.isPressed = true
end

function Widget:onMouseReleased(button, mx, my)
  print("onMouseReleased", self:__toString(), button, mx, my)
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
  print(pad .. self:__toString())

  if self.elements then
    for k, v in pairs(self.elements) do
      v:print(level + 1)
    end
  end
end

function Widget:toScreenCoordinates()
  if self.parent then
    local px, py = self.parent:toScreenCoordinates()
    return self.x + px, self.y + py
  end
  return 0, 0
end

function Widget:findElement(mx, my)
  if self.elements then
    for _ = #self.elements, 1, -1 do
      local foundElement = self.elements[_]:findElement(mx, my)
      if foundElement then
        return foundElement
      end
    end
  end
  local wx, wy = self:toScreenCoordinates()
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
  Container
  ******************************************************************
--]]
function Container:new()
  Container.super.new(self)
  self.elements = {}
end

function Container:__toString()
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

function Container:cleanDirtyFlag()
  Container.super.cleanDirtyFlag(self)
end

function Container:addElement(element)
  table.insert(self.elements, element)
  element:setParent(self)
  self:setDirty()
  return element
end

--[[
  ******************************************************************
  StackLayout
  ******************************************************************
--]]
function StackLayout:__toString()
  return "StackLayout"
end

function StackLayout:new(horizontal)
  StackLayout.super.new(self)
  self.horizontal = horizontal or false
end

function StackLayout:cleanDirtyFlag()
  StackLayout.super.cleanDirtyFlag(self)

  print("StackLayout cleanDirtyFlag")

  self:setLocation(self.parent:getLocation())
  self:setDimensions(self.parent:getDimensions())

  if self.horizontal then
    local chunkSize = self.width / #self.elements
    for _, element in ipairs(self.elements) do
      element.width = chunkSize
      element.height = self.height
      element.x = (_ - 1) * chunkSize
      elememt.y = 0
    end
  else
    local chunkSize = self.height / #self.elements
    for _, element in ipairs(self.elements) do
      element.width = self.width
      element.height = chunkSize
      element.x = 0
      element.y = (_ - 1) * chunkSize
    end
  end
end

function StackLayout:draw()
  love.graphics.push("all")
  for _, element in ipairs(self.elements) do
    element:draw()
  end
  love.graphics.pop()
  self:drawBoundingBox()
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
  self.x = 0
  self.y = 0
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
    love.graphics.print("Hovered element: " .. self.hoveredElement:__toString(), 10, 10)
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

  if foundElement ~= self.hoveredElement then
    if self.hoveredElement then
      self.hoveredElement:onMouseLeave()
    end

    foundElement:onMouseEnter()

    self.hoveredElement = foundElement
  else
    if foundElement and (self.mouse.x ~= mx or self.mouse.y ~= my) then
      foundElement:onMouseMove(mx, my)
    end
  end

  self.mouse.x, self.mouse.y = mx, my
  self.mouse.buttons.left = lb
  self.mouse.buttons.right = rb
  self.mouse.buttons.middle = mb
end

return {
  UI = UI,
  StackLayout = StackLayout,
  Button = Button
}
