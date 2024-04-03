local Pipes = {}

local LAST_SPAWNED = 0
local SPAWN_INTERVAL = 0 --// Will be set depending on screen size
local SPAWN_DISTANCE = 1.5

local PIPE_WIDTH = 70
local PIPE_HEIGHT = 10000
local PIPE_MAX_OFFSET = 200
local PIPE_GAP = 350
local SPEED = 0.1

local ScreenData = {}

function love.load()
    love.window.setFullscreen(true)

    ScreenData.width, ScreenData.height = love.graphics.getDimensions()

    SPAWN_INTERVAL = (1920 / ScreenData.width) * SPAWN_DISTANCE --// Must set it depending on the screen with, bigger screen = less time between spawns
end

function love.draw()
    for i, pipe in ipairs(Pipes) do
        love.graphics.rectangle("fill", pipe.x, pipe.y, PIPE_WIDTH, PIPE_HEIGHT)
    end
end

function love.update(dt)
    --// Move all the pipes to the left
    for i, pipe in ipairs(Pipes) do
        pipe.x = pipe.x - ScreenData.width * SPEED * dt
        if pipe.x < -PIPE_WIDTH * 2 then
            table.remove(Pipes, i)
        end
    end

    --// Spawn a new pipe every SPAWN_INTERVAL seconds
    if love.timer.getTime() - LAST_SPAWNED > SPAWN_INTERVAL then
        LAST_SPAWNED = love.timer.getTime()

        -- local offset = (math.random() * 2 - 1) * PIPE_MAX_OFFSET
        local point = math.min(math.max(math.random(0, ScreenData.height), ScreenData.height / 2 - PIPE_MAX_OFFSET), ScreenData.height / 2 + PIPE_MAX_OFFSET)

        table.insert(Pipes, {x = ScreenData.width + PIPE_WIDTH / 2, y = point - PIPE_HEIGHT - PIPE_GAP / 2})
        table.insert(Pipes, {x = ScreenData.width + PIPE_WIDTH / 2, y = point + PIPE_GAP / 2})
    end
end