player1 = {}
player1.canShoot = true
player1.canShootTimerMax = 0.2
player1.canShootTimer = player1.canShootTimerMax

player2 = {}
player2.canShoot = true
player2.canShootTimerMax = 0.2
player2.canShootTimer = player2.canShootTimerMax

bullets1 = {}
bullets2 = {}

function love.load()
  love.graphics.setBackgroundColor(00, 77, 190, 100)
  
  player1.x = love.graphics.getWidth() / 2
  player1.y = love.graphics.getHeight() / 2
  player1.img = love.graphics.newImage('sprites/shark.jpg')
  player1.speed = 200
  
  player2.x = love.graphics.getWidth() / 3
  player2.y = love.graphics.getHeight() * (2/3)
  player2.img = love.graphics.newImage('sprites/dolphin.jpg')
  player2.speed = 200
  
  bullet1Img = love.graphics.newImage('sprites/bullet1.png')
  bullet2Img = love.graphics.newImage('sprites/bullet2.png')
end
  
function love.update(dt)

--player1
  if love.keyboard.isDown('right') then
    if player1.x < (love.graphics.getWidth() - player1.img:getWidth()) then
      player1.x = player1.x + (player1.speed * dt)
    end
  elseif love.keyboard.isDown('left') then
    if player1.x > 0 then  
      player1.x = player1.x - (player1.speed * dt)
    end
  elseif love.keyboard.isDown('down') then
    if player1.y < (love.graphics.getHeight()) then
      player1.y = player1.y + (player1.speed * dt)
    end
  elseif love.keyboard.isDown('up') then
    if player1.y > player1.img:getHeight() then
      player1.y = player1.y - (player1.speed * dt)
    end
  end 
  
  if love.keyboard.isDown('.') and player1.canShoot then
    newBullet = { x = player1.x + (player1.img:getWidth()/2), y = player1.y, img = bullet1Img }
    table.insert(bullets1, newBullet)
    player1.canShoot = false
    player1.canShootTimer = player1.canShootTimerMax
  end
    
  player1.canShootTimer = player1.canShootTimer - (1 * dt)
  if player1.canShootTimer < 0 then
    player1.canShoot = true
  end
  
--player2
   if love.keyboard.isDown('d') then
    if player2.x < (love.graphics.getWidth() - player2.img:getWidth()) then
      player2.x = player2.x + (player2.speed * dt)
    end
  elseif love.keyboard.isDown('a') then
    if player2.x > 0 then  
      player2.x = player2.x - (player2.speed * dt)
    end
  elseif love.keyboard.isDown('s') then
    if player2.y < (love.graphics.getHeight()) then
      player2.y = player2.y + (player2.speed * dt)
    end
  elseif love.keyboard.isDown('w') then
    if player2.y > player2.img:getHeight() then
      player2.y = player2.y - (player2.speed * dt)
    end
  end
 
 if love.keyboard.isDown('c') and player2.canShoot then
    newBullet = { x = player2.x + (player2.img:getWidth()/2), y = player2.y, img = bullet2Img }
    table.insert(bullets2, newBullet)
    player2.canShoot = false
    player2.canShootTimer = player2.canShootTimerMax
  end
  
  player2.canShootTimer = player2.canShootTimer - (1 * dt)
  if player2.canShootTimer < 0 then
    player2.canShoot = true
  end
  
  
  
  
end

function love.draw()
  love.graphics.draw(player1.img, player1.x, player1.y, 0, 1, 1, 0, 32)
  love.graphics.draw(player2.img, player2.x, player2.y, 0, 1, 1, 0, 32)
  
  for i, bullet in ipairs(bullets1) do
    love.graphics.draw(bullet.img, bullet.x, bullet.y)
  end
  
  for i, bullet in ipairs(bullets2) do
    love.graphics.draw(bullet.img, bullet.x, bullet.y)
  end
  
  for i, bullet in ipairs(bullets1) do
    bullet.x = bullet.x - (10)
    if bullet.x < 0 then
      table.remove(bullets1, i)
    end
  end
  
  for i, bullet in ipairs(bullets2) do
    bullet.x = bullet.x + (10)
    if bullet.x > love.graphics.getWidth() then
      table.remove(bullets2, i)
    end
  end
  
end









