function love.conf(t)
  local width = 800
  local height = 600

  t.window.resizable = false
  t.window.highdpi = false -- Enable high-dpi mode for the window on a Retina display (boolean)
  t.window.width = width
  t.window.height = height
end
