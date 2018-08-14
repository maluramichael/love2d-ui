local loadTimeStart = love.timer.getTime()

require "globals"

local debugMenu = false

function love.load()
  -- random
  math.randomseed(os.time())
  love.mouse.setCursor(love.mouse.newCursor("assets/images/cursor.png", 0, 0))

  -- physics
  love.physics.setMeter(16)

  -- graphics
  love.graphics.setDefaultFilter("nearest", "nearest")
  love.graphics.setBackgroundColor(0, 0, 0)

  -- states
  -- Draw is left out so we can override it ourselves
  local callbacks = {"errhand", "update"}
  for k in pairs(love.handlers) do
    callbacks[#callbacks + 1] = k
  end

  gameState.registerEvents(callbacks)
  gameState.switch(states.testScene)

  if DEBUG then
    local loadTimeEnd = love.timer.getTime()
    loadTime = (loadTimeEnd - loadTimeStart)
    print(("Loaded game in %.3f seconds."):format(loadTime))
  end
end

-- system
function love.draw(dt)
  if initialized == false then
    return false
  end

  local drawTime = love.timer.getTime()
  love.graphics.clear(0.2, 0.25, 0.4)
  gameState.current():draw()

  drawTime = love.timer.getTime() - drawTime

  if debugMenu then
    local width, height = love.graphics.getDimensions()

    love.graphics.push("all")
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", 0, 0, width, height)
    local x, y = 10, 10
    local dy = 30
    local stats = love.graphics.getStats()

    local memoryUnit = "KB"
    local ram = collectgarbage("count")
    local vram = stats.texturememory / 1024
    ram = ram / 1024
    vram = vram / 1024
    memoryUnit = "MB"
    local info = {
      "FPS: " .. ("%0d"):format(love.timer.getFPS()),
      "DRAW: " .. ("%0.3fms"):format(lume.round(drawTime * 1000, .001)),
      "RAM: " .. string.format("%0.2f", lume.round(ram, .01)) .. memoryUnit,
      "VRAM: " .. string.format("%0.2f", lume.round(vram, .01)) .. memoryUnit,
      "Draw: " .. stats.drawcalls,
      "Draw batched: " .. stats.drawcallsbatched,
      "Images: " .. stats.images,
      "Canvases: " .. stats.canvases,
      "Switches: " .. stats.canvasswitches,
      "Shader switches: " .. stats.shaderswitches,
      "Fonts: " .. stats.fonts,
      string.format("Loaded game in %.3f seconds.", loadTime)
    }

    love.graphics.setFont(fonts.monospace[32])
    love.graphics.setColor(1, 1, 1)
    for i, text in ipairs(info) do
      love.graphics.print(text, x, y + (i - 1) * dy)
    end
    love.graphics.pop()
  end
end

function love.update(dt)
  if DEBUG and lurker then
    lurker.update()
  end
end

function love.keypressed(key, code, isRepeat)
  if code == "`" then
    debugMenu = not debugMenu
  end

  if gameState.current() ~= states.debugTween and gameState.current() ~= states.debugMenu then
    if not RELEASE and code == "f11" then
      gameState.push(states.debugTween)
    end

    if not RELEASE and code == "f12" then
      gameState.push(states.debugInput)
    end
  end
end

function love.resize(w, h)
  print(("Window resized to width: %d and height: %d."):format(w, h))
end
