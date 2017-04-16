player1 = {}
player2 = {}
bullets = {}

-- Sets up each player with default values
function playerSetUp(player, sprite_path) 
	player.canShoot = true
	player.canShootTimerMax = 0.2
	player.canShootTimer = player.canShootTimerMax
	player.x = love.graphics.getWidth() / 2
	player.y = love.graphics.getHeight() / 2
	player.img = love.graphics.newImage(player.sprite)
	player.speed = 200
end

-- Handles player movement
function player_movement(player, dt, left, right, down, up)
	if love.keyboard.isDown(left) then
		if player.x > 0 then
			player.x = player.x - (player.speed * dt)
		end
	elseif love.keyboard.isDown(right) then
		if player.x < (love.graphics.getWidth() - player.img:getWidth()) then
			player.x = player.x + (player.speed * dt)
		end
	elseif love.keyboard.isDown(down) then
		if player.y < (love.graphics.getHeight()) then
			player.y = player.y + (player.speed * dt)
		end
	elseif love.keyboard.isDown(up) then
		if player.y > player.img:getHeight() then
			player.y = player.y - (player.speed * dt)
		end
	end 
end

-- Handles shooting
function player_shoot(player, dt, shoot)
	if love.keyboard.isDown(shoot) and player.canShoot then
		if player == player1 then
			acc = -10
		else
			acc = 10
		end
		newBullet = { x = player.x + (player.img:getWidth()/2), y = player.y, img = bulletImg, accel = acc }
		table.insert(bullets, newBullet)
		player.canShoot = false
		player.canShootTimer = player.canShootTimerMax
	end
	
	player.canShootTimer = player.canShootTimer - (1 * dt)
	if player.canShootTimer < 0 then
		player.canShoot = true
	end
end

function love.load()
  love.graphics.setBackgroundColor(00, 77, 190, 100)
  
  player1.sprite = 'sprites/shark.jpg'
  player2.sprite = 'sprites/dolphin.jpg'
  playerSetUp(player1)
  playerSetUp(player2)
  
  bulletImg = love.graphics.newImage('sprites/bullet1.png')
end
  
function love.update(dt)

  player_movement(player1, dt, 'left', 'right', 'down', 'up')
  player_movement(player2, dt, 'a', 'd', 's', 'w')
  player_shoot(player1, dt, '.')
  player_shoot(player2, dt, 'c')  
  
end

function love.draw()
  love.graphics.draw(player1.img, player1.x, player1.y, 0, 1, 1, 0, 32)
  love.graphics.draw(player2.img, player2.x, player2.y, 0, 1, 1, 0, 32)
  
  for i, bullet in ipairs(bullets) do
    love.graphics.draw(bullet.img, bullet.x, bullet.y)
  end
  
  for i, bullet in ipairs(bullets) do
    bullet.x = bullet.x + (bullet.accel)
    if bullet.x < 0 or bullet.x > love.graphics.getWidth() then
      table.remove(bullets, i)
    end
  end
  
end







