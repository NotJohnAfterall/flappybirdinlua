local sqlite3 = require('sqlite3');
DbScore = 0
DisScore = 0


Dificulty = 3 --// lower harder
DificultyName = "Medium"
StartScreen = true

local mainFont = love.graphics.newFont("RobotoMono.ttf", 40)
local ScoreFont = love.graphics.newFont("RobotoMono.ttf", 20)
local FPSfont = love.graphics.newFont("RobotoMono.ttf", 15)
local TitleFont = love.graphics.newFont("RobotoMono.ttf", 60)

function Init() --// Must set it depending on the screen with, bigger screen = less time between spawns
    Bird = {x = 15, y = ScreenData.height / 2, Grav = 0}

    --create/open database / create table
    local hDB = sqlite3.open("database.db");
    if hDB then 
    local tableExists = false
    for row in hDB:nrows("PRAGMA table_info(main);") do
        if row.name == "score" then
            tableExists = true
            break
        end
    end

    if not tableExists then
        hDB:execute("CREATE TABLE main (id INTEGER PRIMARY KEY, score INTEGER);")
    end    

    for row in hDB:nrows("SELECT score FROM main WHERE id=1;") do
        DbScore = row.score
    end
    print(DbScore)

    hDB:close();   
 end
end

function ResetVars()
    Bird = {}
    Pipes = {}

    LAST_SPAWNED = 0
    SPAWN_INTERVAL = 0 
    SPAWN_DISTANCE = 5

    PIPE_WIDTH = 70
    PIPE_HEIGHT = 10000
    PIPE_MAX_OFFSET = 200
    PIPE_GAP = 350

    SPEED = 0.1
    Birdsize = 100
    WasPressed = false
    Rotation = 0

    BeatScreen = false
    LoseScreen = false
    ScreenData = {}
    Stopped = false


    StoppedTimeout = 50
    WasSpeedChange = false
    

    Score = 0


    ScreenData.width, ScreenData.height = love.graphics.getDimensions()

    if DbScore < DisScore then
        local hDB = sqlite3.open("database.db");
        hDB:execute("UPDATE main SET score = " .. DisScore .. " WHERE id = 1;")
        hDB:close();   
    end

    DisScore = 0
end

function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
    return x1 < x2+w2 and
           x2 < x1+w1 and
           y1 < y2+h2 and
           y2 < y1+h1
  end

function love.load()
    love.window.setFullscreen(true)
    love.window.setTitle("Flappy Bird:Beat Yourself")

    ResetVars()

    ScreenData.width, ScreenData.height = love.graphics.getDimensions()
    love.graphics.setBackgroundColor(1, 1, 1)

    BirdImg = love.graphics.newImage("bird.png")
    BirdImgHi = Birdsize / BirdImg:getHeight()
    BirdImgWi = Birdsize / BirdImg:getWidth()
    
    Init()
end

function love.draw()
    for i, pipe in ipairs(Pipes) do
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle("fill", pipe.x, pipe.y, PIPE_WIDTH, PIPE_HEIGHT)
    end

    love.graphics.push()
    love.graphics.translate(20, Bird.y)
    love.graphics.rotate(-Rotation)
    love.graphics.draw(BirdImg, 15, -25, 0, Birdsize / BirdImg:getWidth(), Birdsize / BirdImg:getHeight())
    love.graphics.pop()

    love.graphics.setFont(mainFont)
    local scoreText = tostring(DisScore)
    love.graphics.print(scoreText, ScreenData.width - ScoreFont:getWidth(scoreText) - 30, 0)

    love.graphics.printf(DificultyName, 0, 0, ScreenData.width, "center")
    love.graphics.print("LHS: " .. DbScore, 20, ScoreFont:getHeight(scoreText) - 20)

    love.graphics.setFont(FPSfont)
    love.graphics.printf("FPS: " .. love.timer.getFPS(), 5, ScreenData.height - 20, ScreenData.width , "left")

    love.graphics.setFont(mainFont)

    if LoseScreen then
        local textL = "You lost\nPress space to restart"

        love.graphics.setColor(1, 0, 0, 0.5)
        love.graphics.rectangle("fill", 0, 0, ScreenData.width, ScreenData.height)
        
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf(textL, 0, ScreenData.height / 2 , ScreenData.width, "center")
        -- love.graphics.print("Press space to restart", ScreenData.width / 2 - text_size_x / 2, ScreenData.height / 2 - text_size_y / 2 + 50)
    elseif BeatScreen then
        local textB = "You beat the highscore!\nPress space to restart"
        local text_size_y = mainFont:getHeight(textB)

        love.graphics.setColor(0, 1, 0, 0.5)
        love.graphics.rectangle("fill", 0, 0, ScreenData.width, ScreenData.height)

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf(textB, 0, ScreenData.height / 2 - text_size_y / 2, ScreenData.width, "center")
    elseif StartScreen then
        local textT = "Flappy Bird:Beat Yourself"
        local textS = "To win you need to beat your Last Highscore (LHS)\nPress: 1(Easy) 2(Medium) 3(Hard) to start (SPACE for quick Medium)\nPress 0 to RESET\nPress ESC to stop game\nPress DELETE in menu to exit\nLHS\nControls:\nSPACE to jump up \nSHIFT to quickly drop\nGood Luck!"
        local text_size_y = mainFont:getHeight(textS)

        love.graphics.setColor(0, 0, 1, 0.5)
        love.graphics.rectangle("fill", 0, 0, ScreenData.width, ScreenData.height)

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setFont(TitleFont)
        love.graphics.printf(textT, 0, ScreenData.height / 2 - text_size_y / 2 - 300, ScreenData.width, "center")

        love.graphics.setFont(mainFont)
        love.graphics.printf(textS, 0, ScreenData.height / 2 - text_size_y / 2 - 150, ScreenData.width, "center")
    end
end

function love.update(dt)
    SPAWN_INTERVAL = (1920 / ScreenData.width) * SPAWN_DISTANCE
    
    if StartScreen then
        if love.keyboard.isDown("space") then
            ResetVars()
            Stopped = false
            Init()
            StartScreen = false

            Dificulty = 3
            DificultyName = "Medium"
        elseif love.keyboard.isDown("0") then
            local hDB = sqlite3.open("database.db");
            hDB:execute("UPDATE main SET score = " .. 0 .. " WHERE id = 1;")
            hDB:close();   
        elseif love.keyboard.isDown("1") then
            ResetVars()
            Stopped = false
            Init()
            StartScreen = false

            Dificulty = 4
            DificultyName = "Easy"

        elseif love.keyboard.isDown("2") then
            ResetVars()
            Stopped = false
            Init()
            StartScreen = false

            Dificulty = 3
            DificultyName = "Medium"
        elseif love.keyboard.isDown("3") then
            ResetVars()
            Stopped = false
            Init()
            StartScreen = false

            Dificulty = 2
            DificultyName = "Hard"
        elseif love.keyboard.isDown("delete") then
            love.event.quit()
        end
        return
    end

    if LoseScreen then
        if love.keyboard.isDown("escape") then
            LoseScreen = false
            StartScreen = true
            Stopped = true
        elseif love.keyboard.isDown("delete") then
        love.event.quit()
        end
    end

    if Stopped then
        if love.keyboard.isDown("space") and StoppedTimeout == 0 then
            Stopped = false
            ResetVars()
            Init()
        elseif StoppedTimeout ~= 0 then
            StoppedTimeout = StoppedTimeout - 1
        end
        return
    end

    if love.keyboard.isDown("escape") then
        StartScreen = true
        Stopped = true
    end

    if love.keyboard.isDown("space") and WasPressed == false then
        Bird.Grav = 10
        WasPressed = true
    elseif love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift") then
        Bird.Grav = Bird.Grav - 1
    else
        Bird.Grav = Bird.Grav - 0.4
        WasPressed = false
    end

    Bird.y = Bird.y - Bird.Grav
    Rotation = math.rad(Bird.Grav * 3)

    --// Move all the pipes to the left 
    local coll = false
    for i, pipe in ipairs(Pipes) do
        pipe.x = pipe.x - ScreenData.width * SPEED * dt     

        if pipe.Scored == false and pipe.x < 15 then
            print("Scored")
            Score = Score + 1
            pipe.Scored = true
            if Score % 2 == 0 then
                DisScore = Score * 0.5
                WasSpeedChange = false
            end
        end

        if DisScore % Dificulty == 0 and WasSpeedChange == false then
            if SPEED < 2 then
                SPEED = SPEED + 0.05
            end
            if SPAWN_DISTANCE > 1 then
                SPAWN_DISTANCE = SPAWN_DISTANCE - 0.5
            end
            WasSpeedChange = true
            print(SPEED, SPAWN_DISTANCE)
        end

        if pipe.x < -PIPE_WIDTH * 2 then
            table.remove(Pipes, i)
        end      
        if CheckCollision(Bird.x, Bird.y, 120, 60, pipe.x, pipe.y, PIPE_WIDTH, PIPE_HEIGHT) or Bird.y > ScreenData.height or Bird.y < 0 then 
            coll = true
            print (BirdImgWi, BirdImgHi, pipe.x, pipe.y, PIPE_WIDTH, PIPE_HEIGHT, Bird.x, Bird.y)
            print (BirdImg:getHeight(), BirdImg:getWidth(), BirdImgHi, BirdImgWi)
        end
    end

    if coll and DisScore > DbScore then
        BeatScreen = true
        Stopped = true
    elseif coll then
        LoseScreen = true
        Stopped = true
    end

    --// Spawn a new pipe every SPAWN_INTERVAL seconds
    if love.timer.getTime() - LAST_SPAWNED > SPAWN_INTERVAL then
        LAST_SPAWNED = love.timer.getTime()

        -- local offset = (math.random() * 2 - 1) * PIPE_MAX_OFFSET
        local point = math.min(math.max(math.random(0, ScreenData.height), ScreenData.height / 2 - PIPE_MAX_OFFSET), ScreenData.height / 2 + PIPE_MAX_OFFSET)

        local rnd = math.random(3)

        table.insert(Pipes, {x = ScreenData.width + PIPE_WIDTH / 2, y = point - PIPE_HEIGHT - PIPE_GAP / 2, Scored = false})
        table.insert(Pipes, {x = ScreenData.width + PIPE_WIDTH / 2, y = point + PIPE_GAP / 2, Scored = false})
    end
end

function love.run()
	if love.load then love.load(love.arg.parseGameArguments(arg), arg) end

	-- We don't want the first frame's dt to include time taken by love.load.
	if love.timer then love.timer.step() end
	local dt = 0

	-- Main loop time.
	return function()
		-- Process events.
		if love.event then
			love.event.pump()
			for name, a,b,c,d,e,f in love.event.poll() do
				if name == "quit" then
					if not love.quit or not love.quit() then
						return a or 0
					end
				end
				love.handlers[name](a,b,c,d,e,f)
			end
		end

		-- Update dt, as we'll be passing it to update
		if love.timer then dt = love.timer.step() end

		-- Call update and draw
		if love.update then love.update(dt) end -- will pass 0 if love.timer is disabled

		if love.graphics and love.graphics.isActive() then
			love.graphics.origin()
			love.graphics.clear(love.graphics.getBackgroundColor())

			if love.draw then love.draw() end

			love.graphics.present()
		end

		if love.timer then love.timer.sleep(1 / 60) end
	end
end