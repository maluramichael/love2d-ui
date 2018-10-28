# Love2D UI

![Screenshot](/screenshot.png?raw=true "Screenshot")

## Example

```lua
local UI = require("ui")

local ui = UI.UI()
function love.load()
  ui.visible = true

  local container = ui:addElement(UI.Container(100, 100, 200, 400))
  container:addElement(UI.StackLayout())
  container:addElement(UI.Button("Hello", 30, 50, 100, 50))
  container:addElement(UI.Button("!!Overflow!!", 200, 120, 200, 50))

  local listView = ui:addElement(UI.ListView(400, 150, 200, 100))
  listView:addElement(UI.Button("Element 1"))
  listView:addElement(UI.Button("Element 2"))

  local checkbox = ui:addElement(UI.CheckBox("Check!!!", 350, 350))
  local label = ui:addElement(UI.Label("Label", 350, 380))

  ui:addElement(UI.Button("Floating", 350, 50, 100, 50))

  print(ui:getHierarchyText())
end
```
