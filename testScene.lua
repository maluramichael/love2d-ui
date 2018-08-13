local scene = {}

-- initialize
function scene:init()
  self.initialized = false
  love.graphics.setFont(fonts.monospace[26])
  self.ui = UI.UI()
  self.ui.visible = true
  local stack = self.ui:addElement(UI.StackLayout())
  stack:addElement(UI.Button("Button 1 in StackLayout", 100, 300, 300, 200))
  local button = stack:addElement(UI.Button("Button 2 in StackLayout", 100, 300, 300, 200))

  stack:addElement(UI.Button("Button 3 in StackLayout"))

  self.ui:addElement(UI.Button("Lowest", 25, 75, 300, 50))
  self.ui:addElement(UI.Button("Below", 50, 50, 300, 50))
  self.ui:addElement(UI.Button("Above", 100, 75, 300, 50))

  button.actions.pressed = function(sender, button, mx, my)
    print(sender:__toString().." pressed")
  end

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
