
--[[
	This file isn't actually loaded at all, it's just here in case anybody wants to 
	put this inside of the Balatro executable itself, like if you're running it on another platform
	(Like if you're aiming to port it to mobile, in which case Steamodded isn't possible)
	That being said though I still 100% recommend buying the app when it comes out nonetheless
	Just because of how amazing this game and its dev are. Support your gamedevs kiddos!

	Plus this is Love2D and I've been using the engine for years I gotta love it lmao
]]


-- Put this at the end of "function love.update( dt )" in the extracted game's main.lua!

if not leftClickOriginalSpeed then
	if G.SETTINGS.GAMESPEED > 4 then
		G.SETTINGS.GAMESPEED = 4 -- In case game improperly loads with too high of a speed
	end
	leftClickOriginalSpeed = G.SETTINGS.GAMESPEED
end
if not G.OVERLAY_MENU then
	if love.mouse.isDown(1) then
		if G.STATE == (2 or 3 or 4 or 6 or 8 or 15 or 17 or 18 or 19) then --Values gotten from "self.STATES" in "globals.lua". Drawing cards isn't always able to be sped up, only works for individual card anims (holo, etc.)
			G.SETTINGS.GAMESPEED = 32 --Arbitrary speed to set game to! Change to increase it even more.
		end
	else
		G.SETTINGS.GAMESPEED = leftClickOriginalSpeed
	end
else
	if G.SETTINGS.GAMESPEED > 4 then -- In case game is being sped up while menu is created (Like on game over screen)
		G.SETTINGS.GAMESPEED = leftClickOriginalSpeed
	end
	leftClickOriginalSpeed = G.SETTINGS.GAMESPEED --Remember the current speed.
end


--[[	List of all gamestates you can detect!
	SELECTING_HAND = 1,
X	HAND_PLAYED = 2,
X	DRAW_TO_HAND = 3,
X	GAME_OVER = 4,
	SHOP = 5,
X	PLAY_TAROT = 6,
	BLIND_SELECT = 7,
X	ROUND_EVAL = 8,
	TAROT_PACK = 9,
	PLANET_PACK = 10,
	MENU = 11,
	TUTORIAL = 12,
	SPLASH = 13,
	SANDBOX = 14,
	SPECTRAL_PACK = 15,
	DEMO_CTA = 16,
	STANDARD_PACK = 17,
	BUFFOON_PACK = 18,
X	NEW_ROUND = 19,
]]



-- Added in version 1.1, insert at the end of the funciton "love.draw()"

--[[
if G.SETTINGS.GAMESPEED == 16 then
	local windowWidth, windowHeight = love.graphics.getDimensions()
	love.graphics.print(tostring(G.STATE),20,20)
	love.graphics.printf(">>",0,windowHeight*0.95,windowWidth*0.98,"right")
end
]]
