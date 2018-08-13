gameState = require "thirdparty.hump.gamestate"
lume = require "thirdparty.lume.lume"
lurker = require "thirdparty.lurker.lurker"

RELEASE = false
DEBUG = not RELEASE

UI = require "ui"
fonts = require "fonts"
colors = require "colors"

states = {
  testScene = require "testScene"
}
