local Pipes = {}
local Bird = {}

local LAST_SPAWNED = 0
local SPAWN_INTERVAL = 0 --// Will be set depending on screen size
local SPAWN_DISTANCE = 2

local PIPE_WIDTH = 70
local PIPE_HEIGHT = 10000
local PIPE_MAX_OFFSET = 200
local PIPE_GAP = 350

local SPEED = 0.1
local wasPressed = false
local rotation = 0

local LoseScreen = false
local ScreenData = {}
local stopped = false

local mainFont = love.graphics.newFont("RobotoMono.ttf", 40)
local Score = 0
local disScore = 0
local ScoreFont = love.graphics.newFont("RobotoMono.ttf", 20)

function Init()
    ScreenData.width, ScreenData.height = love.graphics.getDimensions()

    SPAWN_INTERVAL = (1920 / ScreenData.width) * SPAWN_DISTANCE --// Must set it depending on the screen with, bigger screen = less time between spawns
    Bird = {x = 15, y = ScreenData.height / 2, Grav = 0}
end

function ResetVars()
    Bird = {}
    Pipes = {}

    LAST_SPAWNED = 0
    SPAWN_INTERVAL = 0 --// Will be set depending on screen size
    SPAWN_DISTANCE = 2

    PIPE_WIDTH = 70
    PIPE_HEIGHT = 10000
    PIPE_MAX_OFFSET = 200
    PIPE_GAP = 350

    SPEED = 0.1
    wasPressed = false
    rotation = 0

    LoseScreen = false
    ScreenData = {}

    Score = 0
    disScore = 0
end

function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
    return x1 < x2+w2 and
           x2 < x1+w1 and
           y1 < y2+h2 and
           y2 < y1+h1
  end

function love.load()
    love.window.setFullscreen(false)
    love.window.setMode(1000, 720)
    Init()
end

function love.draw()
    for i, pipe in ipairs(Pipes) do
        love.graphics.rectangle("fill", pipe.x, pipe.y, PIPE_WIDTH, PIPE_HEIGHT)
    end

    love.graphics.push()
    love.graphics.translate(20, Bird.y)
    love.graphics.rotate(-rotation)
    love.graphics.rectangle("fill", 15, -25, 50, 50)
    love.graphics.pop()
    local scoreText = tostring(disScore)
    love.graphics.setFont(mainFont)
    love.graphics.print(scoreText, ScreenData.width - ScoreFont:getWidth(scoreText) - 20, 0)

    if LoseScreen then
        local text = "You lost\nPress space to restart"
        local text_size_x = mainFont:getWidth(text)
        local text_size_y = mainFont:getHeight(text)

        love.graphics.setColor(1, 0, 0, 0.5)
        love.graphics.rectangle("fill", 0, 0, ScreenData.width, ScreenData.height)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf(text, ScreenData.width / 2 - text_size_x, ScreenData.height / 2 - text_size_y / 2, ScreenData.width, "center")
        -- love.graphics.print("Press space to restart", ScreenData.width / 2 - text_size_x / 2, ScreenData.height / 2 - text_size_y / 2 + 50)
    end
end

function love.update(dt)
    
    if stopped then
            if love.keyboard.isDown("space") then
            ResetVars()
            stopped = false
            Init()
        end
        return
    end
    if love.keyboard.isDown("space") and wasPressed == false then
        -- print("Space was pressed")
        Bird.Grav = 7
        wasPressed = true
    else
        -- print ("Space was not pressed")
        Bird.Grav = Bird.Grav - 0.2
        wasPressed = false
    end

    Bird.y = Bird.y - Bird.Grav

    rotation = math.rad(Bird.Grav * 3)

    --// Move all the pipes to the left 
    local coll = false
    for i, pipe in ipairs(Pipes) do
        pipe.x = pipe.x - ScreenData.width * SPEED * dt     

        if pipe.Scored == false and pipe.x < 15 then
            print("Scored")
            Score = Score + 1
            pipe.Scored = true
            if Score % 2 == 0 then
                disScore = Score * 0.5
            end
        end

        if pipe.x < -PIPE_WIDTH * 2 then
            table.remove(Pipes, i)
        end      
        if CheckCollision(Bird.x, Bird.y, 50, 50, pipe.x, pipe.y, PIPE_WIDTH, PIPE_HEIGHT) or Bird.y > ScreenData.height or Bird.y < 0 then 
            coll = true
        end

    end

    if coll then
        LoseScreen = true
        stopped = true
    end

    --// Spawn a new pipe every SPAWN_INTERVAL seconds
    if love.timer.getTime() - LAST_SPAWNED > SPAWN_INTERVAL then
        LAST_SPAWNED = love.timer.getTime()

        -- local offset = (math.random() * 2 - 1) * PIPE_MAX_OFFSET
        local point = math.min(math.max(math.random(0, ScreenData.height), ScreenData.height / 2 - PIPE_MAX_OFFSET), ScreenData.height / 2 + PIPE_MAX_OFFSET)

        local rnd = math.random(3)

        table.insert(Pipes, {x = ScreenData.width + PIPE_WIDTH / 2, y = point - PIPE_HEIGHT - PIPE_GAP / 2, Scored = false})
        table.insert(Pipes, {x = ScreenData.width + PIPE_WIDTH / 2, y = point + PIPE_GAP / 2, Scored = false})

        -- if rnd == 1 then
        --     table.insert(Pipes, {x = ScreenData.width + PIPE_WIDTH / 2, y = point - PIPE_HEIGHT - PIPE_GAP / 2, Scored = false})
        --     print(1, point - PIPE_HEIGHT - PIPE_GAP / 2)
        -- elseif rnd == 2 then
        --     table.insert(Pipes, {x = ScreenData.width + PIPE_WIDTH / 2, y = point + PIPE_GAP / 2, Scored = false})
        --     print(1, point + PIPE_GAP / 2)
        -- else
        --     table.insert(Pipes, {x = ScreenData.width + PIPE_WIDTH / 2, y = point - PIPE_HEIGHT - PIPE_GAP / 2, Scored = false})
        --     table.insert(Pipes, {x = ScreenData.width + PIPE_WIDTH / 2, y = point + PIPE_GAP / 2, Scored = false})
        -- end
    end
end