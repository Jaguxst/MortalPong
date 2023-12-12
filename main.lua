local state = "instructions"
local points = 0
local deathBalls = {}  -- Table to store multiple death balls

-- Player paddle properties
local paddle = {
    width = 200,
    height = 25,
    speed = 450,
    x = love.graphics.getWidth() / 2 - 200 / 2,
    y = love.graphics.getHeight() - 50
}

-- Normal ball properties
local ball = {
    width = 25,
    height = 25,
    speed = 300,
    x = love.graphics.getWidth() / 2 - 25 / 2,
    y = love.graphics.getHeight() / 2 - 25 / 2,
    direction = { x = 1, y = -1 }
}

-- Initialize the score
local score = 0

-- Function to spawn a new death ball
function spawnDeathBall()
    local newDeathBall = {
        width = 25,
        height = 25,
        speed = 250,
        x = love.graphics.getWidth() / 2 - 25 / 2,
        y = 50,
        direction = { x = love.math.random() > 0.5 and 1 or -1, y = 1 }
    }
    table.insert(deathBalls, newDeathBall)
end

-- Function to restart the game
function restartGame()
    -- Reset variables
    score = 0
    ball.speed = 300
    state = "playing"
    ball.direction.x = love.math.random() > 0.5 and 1 or -1
    deathBalls = {} --Clear the death ball table
end

-- Love function: called every frame to update the game state
function love.update(dt)
    if state == 'instructions' then
        -- Check for the space key press to start the game
        if love.keyboard.isDown("space") then
            state = 'playing'
        end
    elseif state == 'playing' then
        local direction = 0

        -- Move the player paddle based on input
        if love.keyboard.isDown("d") then
            direction = 1
        end
        if love.keyboard.isDown("a") then
            direction = -1
        end
        paddle.x = paddle.x + (dt * paddle.speed) * direction

        -- Update the position of the normal ball
        ball.x = ball.x + (dt * ball.speed) * ball.direction.x
        ball.y = ball.y + (dt * ball.speed) * ball.direction.y

        -- Update the position of all death balls
        for _, deathBall in ipairs(deathBalls) do
            deathBall.x = deathBall.x + (dt * deathBall.speed) * deathBall.direction.x
            deathBall.y = deathBall.y + (dt * deathBall.speed) * deathBall.direction.y

            -- Ball and wall collisions for the death balls
            if deathBall.x < 0 then
                deathBall.x = 0
                deathBall.direction.x = math.abs(deathBall.direction.x)
            elseif deathBall.x > love.graphics.getWidth() - deathBall.width then
                deathBall.x = love.graphics.getWidth() - deathBall.width
                deathBall.direction.x = -math.abs(deathBall.direction.x)
            end

            if deathBall.y < 0 or deathBall.y > love.graphics.getHeight() - deathBall.height then
                deathBall.direction.y = -deathBall.direction.y
            end
        end

        -- Ball and wall collisions for the normal ball
        if ball.x < 0 then
            ball.x = 0
            ball.direction.x = math.abs(ball.direction.x)
        elseif ball.x > love.graphics.getWidth() - ball.width then
            ball.x = love.graphics.getWidth() - ball.width
            ball.direction.x = -math.abs(ball.direction.x)
        end

        if ball.y < 0 or ball.y > love.graphics.getHeight() - ball.height then
            ball.direction.y = -ball.direction.y
        end

        -- Collision check with the player paddle for the normal ball
        if ball.y + ball.height > paddle.y and ball.y < paddle.y + paddle.height then
            if ball.x + ball.width > paddle.x and ball.x < paddle.x + paddle.width then
                ball.direction.y = -ball.direction.y
                ball.y = paddle.y - ball.height - 1
                score = score + 1

                -- For every 10 point the game will spawn a new  death ball
                if score > 0 and score % 10 == 0 then
                    for i = 1, score / 10 do
                        spawnDeathBall()
                    end
                end
            else
                state = 'gameover'
            end
        end
    elseif state == 'gameover' then
        -- Switch to the game over menu state when the game is over
        state = 'gameover_menu'
    elseif state == 'gameover_menu' then
        -- When pressing "R" the it will restart the game 
        if love.keyboard.isDown("r") then
            restartGame()
        end
    end
end

-- Love function: called every frame to draw the game
function love.draw()
    if state == 'instructions' then
        -- Display instructions
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.print("Welcome to the Game!", love.graphics.getWidth()/2 - 150, love.graphics.getHeight()/2 - 30)
        love.graphics.print("Press Space to Start", love.graphics.getWidth()/2 - 150, love.graphics.getHeight()/2 + 30)
        love.graphics.print("Press a to move right & d to move left", love.graphics.getWidth()/2 - 150, love.graphics.getHeight()/2 + 60)
    elseif state == 'playing' then
        -- Draw the player paddle
        love.graphics.setColor(0, 255, 0, 255)
        love.graphics.rectangle("fill", paddle.x, paddle.y, paddle.width, paddle.height)

        -- Draw the normal ball
        love.graphics.setColor(255, 0, 0, 255)
        love.graphics.rectangle("fill", ball.x, ball.y, ball.width, ball.height)

        -- Draw all death balls
        love.graphics.setColor(255, 0, 255)
        for _, deathBall in ipairs(deathBalls) do
            love.graphics.rectangle("fill", deathBall.x, deathBall.y, deathBall.width, deathBall.height)
        end
        love.graphics.setColor(255, 255, 255)

        -- Display the score
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.print("Score: " .. score, 10, 10)
    elseif state == 'gameover' then
        love.graphics.setColor(0, 255, 0, 255)
        love.graphics.rectangle("fill", paddle.x, paddle.y, paddle.width, paddle.height)

        love.graphics.setColor(255, 0, 0, 255)
        love.graphics.rectangle("fill", ball.x, ball.y, ball.width, ball.height)

        love.graphics.setColor(255, 0, 255)
        for _, deathBall in ipairs(deathBalls) do
            love.graphics.rectangle("fill", deathBall.x, deathBall.y, deathBall.width, deathBall.height)
        end
        love.graphics.setColor(255, 255, 255)

        -- Display the game over message and final score
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.print("GAME OVER!!!", love.graphics.getWidth()/2 - 100, love.graphics.getHeight()/2)
        love.graphics.print("Final Score: " .. score, love.graphics.getWidth()/2 - 100, love.graphics.getHeight()/2 + 30)
    elseif state == 'gameover_menu' then
        -- Draw the player paddle
        love.graphics.setColor(0, 255, 0, 255)
        love.graphics.rectangle("fill", paddle.x, paddle.y, paddle.width, paddle.height)

        -- Draw the normal ball
        love.graphics.setColor(255, 0, 0, 255)
        love.graphics.rectangle("fill", ball.x, ball.y, ball.width, ball.height)

        -- Draw all death balls
        love.graphics.setColor(255, 0, 255)
        for _, deathBall in ipairs(deathBalls) do
            love.graphics.rectangle("fill", deathBall.x, deathBall.y, deathBall.width, deathBall.height)
        end
        love.graphics.setColor(255, 255, 255)

        -- Display the game over message and final score
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.print("GAME OVER!!!", love.graphics.getWidth()/2 - 100, love.graphics.getHeight()/2)
        love.graphics.print("Final Score: " .. score, love.graphics.getWidth()/2 - 100, love.graphics.getHeight()/2 + 30)

        -- Display the restart button
        love.graphics.print("Press R to restart", love.graphics.getWidth()/2 - 100, love.graphics.getHeight()/2 + 60)
    end
end