local scene = {}

-- initialize
function scene:init()
  self.initialized = false
  love.graphics.setFont(fonts.monospace[16])
  self.ui = UI.UI()
  self.ui.visible = true

  local container = self.ui:addElement(UI.Container(100, 100, 200, 100))
  container:addElement(UI.StackLayout())
  container:addElement(UI.Button("Hello", 30, 50, 100, 50))
  container:addElement(UI.Button("!!Overflow!!", 200, 120, 200, 50))

  local listView = self.ui:addElement(UI.ListView(400, 150, 200, 100))
  listView:addElement(UI.Button("Element 1"))
  listView:addElement(UI.Button("Element 2"))

  local checkbox = self.ui:addElement(UI.CheckBox("Check!!!", 200, 350))
  local label = self.ui:addElement(UI.Label("Label", 200, 380))

  self.ui:addElement(UI.Button("Floating", 350, 50, 100, 50))

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

  if key == "r" then
    love.event.quit("restart")
  end
end

return scene
