local scene = {}

-- initialize
function scene:init()
  self.initialized = false
  love.graphics.setFont(fonts.monospace[26])
  self.ui = UI.UI()
  self.ui.visible = true
  self.stack = self.ui:addElement(UI.StackLayout())
  self.stack:addElement(UI.Button("Button 1 in StackLayout", 100, 300, 300, 200))
  self.stack:addElement(UI.Button("Button 2 in StackLayout", 100, 300, 300, 200))

  -- self.stack:addElement(UI.Button("Button 2 in StackLayout"))
  -- self.stack:addElement(UI.Button("Button 3 in StackLayout"))

  self.ui:addElement(UI.Button("Lowest", 25, 75, 300, 50))
  self.ui:addElement(UI.Button("Below", 50, 50, 300, 50))
  self.ui:addElement(UI.Button("Above", 100, 75, 300, 50))

  -- self.stack:addElement(UI.Button("Foo"))
  -- self.stack:addElement(UI.Button("Bar"))
  -- buildButton.style.background = colors.darkGray
  -- buildButton.hoverStyle.background = colors.lightGray
  -- buildButton.style.text = colors.white
  -- buildButton.pressed = function()
  --   self:buildHarbor()
  -- end

  self.ui:print()

  self.initialized = true
end

function scene:draw()
  if self.initialized == false then
    return false
  end

  local g = love.graphics
  g.clear(0.1, 0.2, 0.3)
  self.ui:draw()
end

function scene:update(dt)
  if self.initialized == false then
    return
  end

  self.ui:update(dt)
end

function scene:keypressed(key, scancode, isrepeat)
  if key == "escape" then
    love.event.quit()
  end
end

return scene
