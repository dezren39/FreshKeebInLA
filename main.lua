gamestate = require('gamestate')
wordpro = require('wordpro')
sideboard = require('sideboard')
font = 'Cousine-Regular.ttf'

function love.load(arg)
   success = love.window.setFullscreen(true)
   gamestate:setMenu()

   keyboard = arg[1]

   if not keyboard or keyboard == 'asetniop' then
      keyboard = require('asetniop')
   elseif keyboard == 'butterstick' then
      keyboard = require('butterstick')
   end

   local fontSize = love.graphics.getHeight() / 32
   keyboard:setup(love.graphics.newFont(font, fontSize))

   local fontSize = love.graphics.getHeight() / 24
   wordpro:setup('dictionaries/mixed.txt',
		 love.graphics.newFont(font, fontSize),
		 love.graphics.getWidth() / 2)

   background = {
      image = love.graphics.newImage('images/backgroundColorForest.png'),
      y = -64
   }
   background.tiles = love.graphics.getWidth() / background.image:getWidth()

   local fontSize = love.graphics.getHeight() / 24
   menu = {
      font = love.graphics.newFont(font, fontSize),
      message = 'Press any key to start',
      y = love.graphics.getHeight() / 2
   }
   menu.x = (love.graphics.getWidth() / 2) - (menu.font:getWidth(menu.message) / 2)
   endScreen = {
      font = menu.font,
      y = love.graphics.getHeight() / 2
   }

   local fontSize = love.graphics.getHeight() / 32
   sideboard:setup(love.graphics.newFont(font, fontSize))
end

function love.update()
   if gamestate:isMenu() then
   elseif gamestate:isGame() then
      sideboard:update()
      if wordpro:isComplete() then
	 sideboard:newWord(wordpro.current, wordpro.typingCorrectlyWord)
	 wordpro:newWord()
      end
      if sideboard:timesUp() then
	 gamestate:setScore()
      end

      keyboard:update(wordpro.nextLetter)
   elseif gamestate:isScore() then
   end
end

function love.draw()
   love.graphics.setColor(1, 1, 1)
   for x=0,background.tiles do
      love.graphics.draw(background.image,
			 x * background.image:getWidth(), background.y)
   end

   sideboard:draw()
   keyboard:draw()
   
   if gamestate:isMenu() then
      darkenScreen()
      love.graphics.setColor(0, 0, 0)
      love.graphics.setFont(menu.font)
      love.graphics.print(menu.message, menu.x, menu.y)
   elseif gamestate:isGame() then
      wordpro:draw()
   elseif gamestate:isScore() then
      if not endScreen.x then
	 endScreen.message = sideboard.score .. ' points, ' .. sideboard.words .. ' words'
	 endScreen.x = (love.graphics.getWidth() / 2) -
	    (endScreen.font:getWidth(endScreen.message) / 2)
      end
      darkenScreen()
      love.graphics.setColor(0, 0, 0)
      love.graphics.setFont(endScreen.font)
      love.graphics.print(endScreen.message, endScreen.x, endScreen.y)
   end
end

function love.keypressed(key, scancode, isrepeat)
   if gamestate:isMenu() then
      if key == 'escape' then
	 love.event.quit()
      end
   elseif gamestate:isGame() then
      if key == 'escape' then
	 gamestate:setMenu()
      end
   elseif gamestate:isScore() then
      if key == 'escape' or
	 key == 'space'
      then
	 endScreen.x = nil
	 gamestate:setMenu()
      end
   end
end

function love.keyreleased(key)
   if gamestate:isMenu() then
      if key ~= 'escape' then
	 newGame()
      end
   elseif gamestate:isGame() then
      wordpro:typing(key)
      sideboard:typing(wordpro.typingCorrectlyLetter)
   elseif gamestate:isScore() then
   end
end

function darkenScreen()
   love.graphics.setColor(0, 0, 0, 0.3)
   love.graphics.rectangle('fill', 0, 0,
			   love.graphics.getWidth(),
			   love.graphics.getHeight())
end

function newGame()
   gamestate:setGame()
   wordpro:newWord()
   sideboard:start()
end
