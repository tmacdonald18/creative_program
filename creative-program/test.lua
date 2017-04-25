--"C:\Program files\Love\love.exe" "C:\Users\Tyler\Desktop\School\Programming_Languages\creative_project\creative-program"

pause = coroutine.create(function ()
	display_pause_menu()
	while true do
		if love.keyboard.isDown('e') then
			coroutine.yield()
		end
		
		if love.keyboard.isDown('r') then
			reset_game()
			coroutine.yield()
		end
		
		if love.keyboard.isDown('q') then
			love.event.push('quit')
		end
	end
end)



player1 = {}
player2 = {}
bullets = {}
powerups = {}
bullets_meta = {}

bullets_meta.__index = function(t, key)
	rawset(t, key, math.random(500))
	return t[key]
end
setmetatable(bullets, bullets_meta)

invincibility = {isDrawn = false, img = love.graphics.newImage('sprites/powerup.png')}
fast_shoot = {isDrawn = false, img = love.graphics.newImage('sprites/powerup.png')}
fast_move = {isDrawn = false, img = love.graphics.newImage('sprites/powerup.png')}

powerup_meta = {}
powerup_meta.__index = function(t, key) 
	if key == "x" then
		rawset(t, key, math.random(1, love.graphics.getWidth()))
		return t[key]
	elseif key == "y" then
		rawset(t, key, math.random(1, love.graphics.getHeight()))
		return t[key]
	end
end

setmetatable(invincibility, powerup_meta)
setmetatable(fast_shoot, powerup_meta)
setmetatable(fast_move, powerup_meta)

--spawns a powerup
function spawn_powerup(i)
	if i == 1 then
		invincibility.isDrawn = true
	elseif i == 2 then
		fast_shoot.isDrawn = true
	elseif i == 3 then
		fast_move.isDrawn = true
	end
end

--coroutine for timing powerup
-- display_power = coroutine.create(function (player, key)
	-- love.graphics.print(key, love.graphics:getWidth()/2 - 50, love.graphics:getHeight()/2)
	-- local start = love.timer.getTime()
	-- local elapsed = love.timer.getTime() - start
	-- while elapsed < 2 do
		-- elapsed = love.timer.getTime() - start
	-- end
	-- player[key] = false
	-- key[isDrawn] = false
	-- coroutine.yield()
-- end)

function display_pause_menu()
	--graphics
	love.graphics.rectangle('fill', 100, 100, love.graphics:getWidth()/4, love.graphics:getHeight()/4)
end
	

function reset_game()
	--
end



-- Sets up each player with default values
function playerSetUp(player) 
	player.canShoot = true
	player.canShootTimerMax = 0.2
	player.canShootTimer = player.canShootTimerMax
	player.x = love.graphics.getWidth() / 2
	player.y = love.graphics.getHeight() / 2
	player.orientation = 0
	player.img = love.graphics.newImage(player.sprite)
	player.speed = 0
	player.maxspeed = 2
	player.brake = false
	player.gas = false
	player.isAlive = true
	player.invincibility = false
	player.fast_move = false
	player.fast_shoot = false
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
		newBullet = {}
		setmetatable(newBullet, bullets_meta)
		newBullet.x = player.x + (player.img:getWidth()/2) * math.cos(player.orientation - math.pi/2)
		newBullet.y = player.y + (player.img:getHeight()/2) * math.sin(player.orientation - math.pi/2)
		newBullet.img = bulletImg
		newBullet.orientation = player.orientation
		
		table.insert(bullets, newBullet)
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
  love.graphics.setBackgroundColor(00, 77, 190, 100)
  
  player1.sprite = 'sprites/shark.png'
  player2.sprite = 'sprites/dolphin.png'
  playerSetUp(player1)
  playerSetUp(player2)
  
  bulletImg = love.graphics.newImage('sprites/bullet.png')
  
  time_start = love.timer.getTime()
  
  
  
  num = 1
end
  
function love.update(dt)
	
	player1.x, player1.y = player_movement(player1, dt, 'left', 'right', 'down', 'up')
	player2.x, player2.y = player_movement(player2, dt, 'a', 'd', 's', 'w')
	  
	player_shoot(player1, dt, '.')
	player_shoot(player2, dt, 'c')  
	  
	for i, bullet in ipairs(bullets) do
		bullet.x = bullet.x + (bullet.speed * dt) * math.cos(bullet.orientation - math.pi/2)
		bullet.y = bullet.y + (bullet.speed * dt) * math.sin(bullet.orientation - math.pi/2)
		
		if bullet.x < 0 or bullet.x > love.graphics.getWidth() then
			table.remove(bullets, i)
		end
		
		if checkCollisions(player1, bullet) then
			table.remove(bullets, i)
			if player1.invincibility == false then
				player1.isAlive = false
			end
		end
	end	
	
	if invincibility.isDrawn then
		if checkCollisions(player1, invincibility) then
			player1.invincibility = true
			coroutine.resume(display_power, player1, invincibility)
			invincibility.isDrawn = false
		end
	end
	
	if fast_shoot.isDrawn then
		if checkCollisions(player1, fast_shoot) then
			player1.fast_shoot = true
			coroutine.resume(display_power, player1, fast_shoot)
			fast_shoot.isDrawn = false
		end
	end
	
	if fast_move.isDrawn then
		if checkCollisions(player1, fast_move) then
			player1.fast_move = true
			coroutine.resume(display_power, player1, fast_move)
			fast_move.isDrawn = false
		end
	end
	
	time_elapsed = love.timer.getTime() - time_start
	if time_elapsed > 10 and num < 4 then
		time_start = time_elapsed
		time_elapsed = 0
		spawn_powerup(num)
		num = num + 1
	end
  
end

function love.draw()
	if player1.isAlive == true and player2.isAlive == true then
		if love.keyboard.isDown('p') then
			coroutine.resume(pause)
		end
	
		love.graphics.draw(player1.img, player1.x, player1.y, player1.orientation, 1, 1, player1.img:getWidth()/2, player1.img:getHeight()/2)
		love.graphics.draw(player2.img, player2.x, player2.y, player2.orientation, 1, 1, player1.img:getWidth()/2, player2.img:getHeight()/2)
  
		love.graphics.print(time_elapsed, love.graphics:getWidth()/2 - 50, 20)
		love.graphics.print(num, love.graphics:getWidth()/2 - 100, 20)
  
		for i, bullet in ipairs(bullets) do
			love.graphics.draw(bullet.img, bullet.x, bullet.y, bullet.orientation, 1, 1, bullet.img:getWidth()/2, bullet.img:getHeight()/2)
		end
		
		if invincibility.isDrawn then
			love.graphics.draw(invincibility.img, invincibility.x, invincibility.y, 0, 1, 1, 0, 0)
		end
		
		if fast_shoot.isDrawn then
			love.graphics.draw(fast_shoot.img, fast_shoot.x, fast_shoot.y, 0, 1, 1, 0, 0)
		end
		
		if fast_move.isDrawn then
			love.graphics.draw(fast_move.img, fast_move.x, fast_move.y, 0, 1, 1, 0 ,0)
		end
	else
		if player1.isAlive == false then
			love.graphics.print('Player 2 Wins!', love.graphics:getWidth()/2 - 50, love.graphics:getHeight()/2 - 10)
		else
			love.graphics.print('Player 1 Wins!', love.graphics:getWidth()/2 - 50, love.graphics:getHeight()/2 - 10)
		end
	end  
end


