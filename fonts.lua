local function makeFont(path)
  return setmetatable(
    {},
    {
      __index = function(t, size)
        local f = love.graphics.newFont(path, size)
        rawset(t, size, f)
        return f
      end
    }
  )
end

local Fonts = {
  default = makeFont "assets/fonts/ff3.ttf",
  monospace = makeFont "assets/fonts/november.ttf"
}

-- Fonts.default = Fonts.monospace

return Fonts
