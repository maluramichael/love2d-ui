local scene = {}

-- initialize
function scene:init()
  self.initialized = false
  love.graphics.setFont(fonts.monospace[16])
  self.ui = UI.UI()
  self.ui.visible = true

  local stackA = self.ui:addElement(UI.StackLayout(true))
  local stackB = self.ui:addElement(UI.StackLayout())
  stackA.tag = "stackA"
  stackB.tag = "stackB"

  local container = stackB:addElement(UI.Container())
  local innerContainer = container:addElement(UI.Container(50, 40, 200, 300))
  container.tag = "container"
  innerContainer.tag = "inner container"
  innerContainer:addElement(UI.Button("Hello", 30, 50, 100, 50))
  innerContainer:addElement(UI.Button("!!Overflow!!", 60, 120, 200, 50))

  self.ui:addElement(UI.Button("HUGE BUTTON"))

  print(self.ui:getHierarchyText())

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
