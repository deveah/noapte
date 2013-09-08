
--[[
	
	Noapte
	a roguelike in infinite development

	(c) 2013, Vlad Dumitru

	Project guidelines:
	Every function should be safely invoked with correct parameters.
	Every game-related aspect should be logged.
	Use assertions everywhere to check the sanity of the game.

	License:
	As long as you retain this notice, you are free to do whatever you want
	with this stuff. If one day we shall meet, and you shall find me worthy,
	I will gladly accept donations in either beer or coffee. If it's winter,
	though, a cup of spiced wine should be a fine replacement for beer.

	Contribution is greatly appreciated, so go ahead and fork away!

]]--

require "lua/game"

game.init()
game.loop()
game.terminate()

