--"C:\Program files\Love\love.exe" "C:\Users\Tyler\Desktop\School\Programming_Languages\creative_project\creative-program"

player1 = {}
player2 = {}
Bullet = {}

function Bullet:new (o, player)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	self.x = player.x + (player.img:getWidth()/2) * math.cos(player.orientation - math.pi/2)
	self.y = player.y + (player.img:getHeight()/2) * math.sin(player.orientation - math.pi/2)
	self.img = love.graphics.newImage('sprites/fish.png')
	self.orientation = player.orientation
	return o
end

function Bullet:setSpeed ()
	self.speed = math.random(75)
end

switches = {}
switch_meta = {}
switch_meta.__index = function(t, key) 
	if key == "x" then
		rawset(t, key, math.random(1, love.graphics.getWidth()))
		return t[key]
	elseif key == "y" then
		rawset(t, key, math.random(1, love.graphics.getHeight()))
		return t[key]
	end
end
setmetatable(switches, powerup_meta)

-- Sets up each player with default values
function playerSetUp(player) 
	player.canShoot = true
	player.canShootTimerMax = 2
	player.canShootTimer = player.canShootTimerMax
	player.x = love.graphics.getWidth() / 2
	player.y = love.graphics.getHeight() / 2
	player.orientation = 0
	player.img = love.graphics.newImage(player.sprite)
	player.speed = 0
	player.maxspeed = 4
	player.brake = false
	player.gas = false
	player.isAlive = true
	
	if player == player1 then
		player.isAngry = true
		player.x = 50
		player.y = love.graphics.getHeight() - 50
		player.orientation = 1
	else
		player.isAngry = false
		player.x = love.graphics.getWidth() - 50
		player.y = 50
		player.orientation = 4
	end
	
end
-- Handles player movement
function player_movement(player, dt, left, right, down, up)
	
	if love.keyboard.isDown(left) then
		player.orientation = player.orientation - (2 * dt)
	end
	
	if love.keyboard.isDown(right) then
		player.orientation = player.orientation + (2 * dt)
	end
	
	if love.keyboard.isDown(down) then
		player.brake = true
	else
		player.brake = false
	end
	
	if love.keyboard.isDown(up) then
		player.gas = true
	else
		player.gas = false
	end	
	
	---speed
	if player.gas == true then
		if player.speed < player.maxspeed then
			player.speed = player.speed + dt
		end
	elseif player.gas == false and player.speed > 0 then
		player.speed = player.speed - dt
	end
	
	if player.brake == true and player.speed > 0 then
		player.speed = player.speed - (2 * dt)
	end
	
	local x = player.x + player.speed * math.cos(player.orientation - math.pi/2)
	local y = player.y + player.speed * math.sin(player.orientation - math.pi/2)
	
	return x, y
end

-- Handles shooting
function player_shoot(player, dt, shoot)
	if love.keyboard.isDown(shoot) and player.canShoot then
		newBullet = Bullet:new(nil, player)
		newBullet.speed = math.random(50)
		
		table.insert(Bullet, newBullet)
		player.canShoot = false
		player.canShootTimer = player.canShootTimerMax
	end
	
	player.canShootTimer = player.canShootTimer - (1 * dt)
	if player.canShootTimer < 0 then
		player.canShoot = true
	end
end

-- Handles collision detection
function checkCollisions(obj1, obj2)
	if (obj1 == nil) then  -- Make sure the first object exists
        return false
    end
    if (obj2 == nil) then  -- Make sure the other object exists
        return false
    end
 
	local first_radius = obj1.img:getWidth()/2
	local second_radius = obj2.img:getWidth()/2
	local first_center_x =  obj1.x + first_radius
	local first_center_y =	obj1.y + obj1.img:getHeight()/2
	local second_center_x =	obj2.x + second_radius
	local second_center_y = obj2.y + obj2.img:getHeight()/2
	
 
    local dx = second_center_x - first_center_x
    local dy = second_center_y - first_center_y
 
    local distance = math.sqrt(dx*dx + dy*dy)
    local objectSize = first_radius + second_radius
 
    if (distance < objectSize) then
        return true
    end
    return false
end

function love.load()
  love.window.setFullscreen(true, "desktop")
  
  background = love.graphics.newImage('sprites/ocean.png')
  
  player1.sprite = 'sprites/shark.png'
  player2.sprite = 'sprites/dolphin.png'
  playerSetUp(player1)
  playerSetUp(player2)
  
  switchImg = love.graphics.newImage('sprites/switch.png')
  
  backgroundMusic = love.audio.newSource('sprites/song.mp3')
  backgroundMusic:play()
  
  spawned = false
  
end
  
function love.update(dt)
	--how to exit the game
	if love.keyboard.isDown('escape') then
		love.event.push('quit')
	end
	
	player1.x, player1.y = player_movement(player1, dt, 'left', 'right', 'down', 'up')
	player2.x, player2.y = player_movement(player2, dt, 'a', 'd', 's', 'w')
	  
	if player1.isAngry then
		calm = player2
		player_shoot(player1, dt, '.')
	else
		calm = player1
		player_shoot(player2, dt, 'c')
	end
	
	for i, switch in ipairs(switches) do		
		if checkCollisions(calm, switch) then
			table.remove(switches, i)
			spawned = false
			if calm == player2 then
				calm = player1
				player2.isAngry = true
				player1.isAngry = false
			else
				calm = player2
				player1.isAngry = true
				player2.isAngry = false
			end
		end	
	end
	
	for i, bullet in ipairs(Bullet) do
		bullet.x = bullet.x + (bullet.speed * dt) * math.cos(bullet.orientation - math.pi/2)
		bullet.y = bullet.y + (bullet.speed * dt) * math.sin(bullet.orientation - math.pi/2)
		
		if bullet.x < 0 or bullet.x > love.graphics.getWidth() then
			table.remove(Bullet, i)
		end
		
		if checkCollisions(calm, bullet) then
			table.remove(Bullet, i)
			if calm == player1 then
				player1.isAlive = false
			else
				player2.isAlive = false
			end
		end
	end	
	
	if #Bullet % 5 == 0 and spawned == false and #Bullet ~= 0 then
		newSwitch = {}
		setmetatable(newSwitch, switch_meta)
		newSwitch.img = switchImg
		table.insert(switches, newSwitch)
		spawned = true
	end
  
end

function love.draw()
	 for i = 0, love.graphics.getWidth() / background:getWidth() do
        for j = 0, love.graphics.getHeight() / background:getHeight() do
            love.graphics.draw(background, i * background:getWidth(), j * background:getHeight())
        end
    end

	if player1.isAlive == true and player2.isAlive == true then
		if love.keyboard.isDown('p') then
			coroutine.resume(pause)
		end
	
		love.graphics.draw(player1.img, player1.x, player1.y, player1.orientation, 1, 1, player1.img:getWidth()/2, player1.img:getHeight()/2)
		love.graphics.draw(player2.img, player2.x, player2.y, player2.orientation, 1, 1, player1.img:getWidth()/2, player2.img:getHeight()/2)
  
		for i, bullet in ipairs(Bullet) do
			love.graphics.draw(bullet.img, bullet.x, bullet.y, bullet.orientation, 1, 1, bullet.img:getWidth()/2, bullet.img:getHeight()/2)
		end
		
		for i, switch in ipairs(switches) do
			love.graphics.draw(switch.img, switch.x, switch.y, 0, 1, 1, switch.img:getWidth()/2, switch.img:getHeight()/2)
		end
		
	else
		if player1.isAlive == false then
			love.graphics.print('Player 2 Wins!', love.graphics:getWidth()/2 - 50, love.graphics:getHeight()/2 - 10)
		else
			love.graphics.print('Player 1 Wins!', love.graphics:getWidth()/2 - 50, love.graphics:getHeight()/2 - 10)
		end
	end  
end


