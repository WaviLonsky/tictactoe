local composer = require( "composer" )
local widget = require( "widget" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------



-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen

    print("Project: Tic-tac-toe"); -- Пишем в консоле название проекта

    display.setStatusBar( display.HiddenStatusBar ) -- Прячем статусбар(который ешо наверху такой)

    local background = display.newImageRect(sceneGroup, "background.jpg", display.contentWidth, display.contentHeight); -- Добавляем круток бекграунд ;)
    background.x = display.contentCenterX -- Центруем по иксу
    background.y = display.contentCenterY -- Центруеи по игреку

    ---------------------------------------------------------------------------------------------------------------------------------------------
    -- Добавляем музыкальные кнопки
    ---------------------------------------------------------------------------------------------------------------------------------------------
    local musicPlayButton = display.newImageRect(sceneGroup, "playButton.png", 112.5, 62.5 ); -- Добавляем кнопку play!
    musicPlayButton.x = display.contentCenterX/1.5-12.5 -- Координаты по иксу
    musicPlayButton.y = 40 -- Координаты по игреку
    musicPlayButton.enabled = true; -- делаем её изначально доступной

    local musicStopButton = display.newImageRect(sceneGroup, "stopButton.png", 112.5, 62.5 ); -- Добавляем кнопку stop!
    musicStopButton.x = display.contentCenterX*1.5-12.5 -- Координаты по иксу
    musicStopButton.y = 40 -- Координаты по игреку
    musicStopButton.enabled = false; -- делаем её изначально недоступной
    cnd = true; -- Делаем переменную condition(условие)

    -----------------------------------------------------------------------------------------------------------------------------------------------

    local bgSound = audio.loadSound( "music/bg.mp3" ); -- Загружаем на саунд из папки music

    function musicPlayButton:touch(e) -- Функция, отвечающая за включение и возобновление музыки
        if (e.phase == "ended" and musicPlayButton.enabled == true and cnd == true) then -- ended - когда отпускаешь ЛКМ
            audio.setVolume( 0.1, { channel=1 } ) -- Устанавливаем громкость
            audio.play(bgSound, { channel = 1, loops = -1, fadein = 6000 }); -- Воспроизводим музыку на канале 1 с бесконечным повторением и входом в 6 секунд
            musicPlayButton.enabled = false; -- Делаем что бы нельзя было воспроизводить одну и ту же музыку по 10000 раз
            musicStopButton.enabled = true; --Делаем так что бы можно было остановить наш музик
            cnd = false;
        elseif (e.phase == "ended" and musicPlayButton.enabled == true and cnd == false) then
            audio.resume(1); --возобновляем музыку на канале 1 после остановки, если это надо
        end
    end

    function musicStopButton:touch(e) -- Функция, отвечающая за остановку музыки
        if (e.phase == "ended" and cnd == false) then
            audio.pause(1); -- Приостанавливаем музыку на канале 1
            musicPlayButton.enabled = true; -- Делаем так чтобы её можно было возобновить кнопкой play!
            musicStopButton.enabled = false; -- На всякий случай)
            cnd = false; -- Тоже на всякий случай, если проигрывающаа функция не переведёт условие в нужный момент в false
        end
    end


    musicPlayButton:addEventListener("touch", musicPlayButton) -- Можно назвать это использованием библиотеки(на самом деле нельзя, он просто отслеживает события, а точнее прослушивает)
    musicStopButton:addEventListener("touch", musicStopButton) -- Такая хрень реагирует на нажатия



    ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- Создаём все необходимые переменные, массивы и группы
    ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    local WhoNow = 1 -- Используется для емблем
    local count = 15; -- Размер поля
    local countToWin = 5; -- Сколько нужно поставить в ряд для победы
    local playerFigure = 1;
    local AIFigure = -1;
    local W = display.contentWidth; -- Создаём переменную W что бы не писать каждый раз Width
    local H = display.contentHeight; -- Создаём переменную H что бы не писать каждый раз Height
    local size = display.contentWidth/count; -- Размер клетки
    local startX = W/2 + size/2 - size*count/2; -- Начало отчета для клетки
    local startY = H/2 + size/2 - size*count/2; -- Начало отсчета для клетки
    local emblems = {"redKrestikButton.png", "greenNolikButton.png"} -- Массив с эмблемами "krestMenu.png", "nolMenu.png",
    local arrayText = {} -- Значения клеток хранятся тут
    local array = {} -- Сами клетки хранятся тут
    for i= 1, count do -- Заполняем двумерный массив
        array[i] = {}
        for j = 1, count do
            array[i][j] = nil
        end
    end

    local mainGroup = display.newGroup(); -- Тут создаём главную "группу" на которой будет находиться всё что у нас есть(Но это не точно ;)
    sceneGroup:insert(mainGroup);

    --------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- Functions
    --------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    function getCountFreeRect() --Функция, которая считает свободные квадратики
        local countFree = count^2;
        for i = 1, count do
            for j = 1, count do
                local item_mc = array[i][j];
                if (item_mc.enabled == false) then
                    countFree = countFree - 1;
                end
            end
        end
        return countFree;
    end

    ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------




    local function CheckWin() -- ооооо, тут все и начинается
        local function Victory(sum)
            -- print("---Victory---")
            -- print( "sum =" .. sum )
            if ( math.abs(sum) == countToWin ) then -- Если модуль счётчика равен нужному количеству фигур в ряд, то это значит, что кто то выиграл
                if ( sum > 0 ) then -- Если sum больше чем 0 (3, 4, 5, 6), то это значит, что выиграли крестики
                    print( "X Won" )
                    for i = 1, count do -- Перебераем двумерный массив, чтоб выключить поле
                        for j = 1, count do -- Перебераем двумерный массив, чтоб выключить поле
                            array[i][j].enabled = false; -- Выключаем все клетки
                        end -- Этот цикл нужен нам, что бы после победы нельзя было ставить крестики и нолики
                    end
                elseif (sum < 0 ) then -- Если sum меньше чем 0 (-3, -4, -5, -6), то это значит, что выиграли нолики
                    print( "O Won" )
                    for i = 1, count do -- Перебераем двумерный массив, чтоб выключить поле
                        for j = 1, count do -- Перебераем двумерный массив, чтоб выключить поле
                            array[i][j].enabled = false; -- Выключаем все клетки
                        end -- Снова цикл, делающий клетки недоступными после победы
                    end
                end
            end
        end
        local sumHorizontal = 0;
        local sumVertical = 0;
        local sumDiagonal1 = 0;
        local sumDiagonal2 = 0;
        for i= 1, count do
            sumHorizontal = 0;
            sumVertical = 0;
            for j= 1, count do
                if ( arrayText[j][i] ~= 0 ) then
                    ---------------------------------------------------------------------------------------------------
                    local function checkWinHorizontal() -- Проверяем горизонтали
                        sumHorizontal = sumHorizontal + arrayText[j][i];
                        ---------
                        Victory(sumHorizontal)
                        ---------
                        if ( j+1 <= count and arrayText[j][i] ~= arrayText[j+1][i] ) then
                            sumHorizontal = 0;
                        end
                    end

                    checkWinHorizontal()
                end
                if ( arrayText[i][j] ~= 0 ) then
                    -----------------------------------------------------------------------------------------------
                    local function checkWinVertical() -- Проверяем вертикали
                        sumVertical = sumVertical + arrayText[i][j]
                        ---------
                        Victory(sumVertical)
                        ---------
                        if ( j+1 <= count and arrayText[i][j] ~= arrayText[i][j+1] ) then -- Клетка нет серии
                            sumVertical = 0;
                        end
                    end
                    checkWinVertical()
                    -------------------------------------------------------------------------------------------------
                    for c = 0, countToWin-1 do

                        local function checkWinDiagonal1() -- Диагональ идущая слева-направо(от верхнего левого угла до нижнего правого)
                            if ( i+c <= count and j+c <= count and arrayText[i][j] == arrayText[i+c][j+c] ) then
                                sumDiagonal1 = sumDiagonal1 + arrayText[i+c][j+c];
                            else
                                sumDiagonal1 = 0;
                            end
                            ---------
                            Victory(sumDiagonal1)
                            ---------
                        end
                        checkWinDiagonal1()
                        ---------------------------------------------------------------------------------------------------
                        local function checkWinDiagonal2() -- Диагональ идущая справа-налево(от )
                            if ( i+c <= count and j-c <= count and arrayText[i][j] == arrayText[i+c][j-c] ) then
                                sumDiagonal2 = sumDiagonal2 + arrayText[i+c][j-c];
                            else
                                sumDiagonal2 = 0;
                            end
                            --------
                            Victory(sumDiagonal2)
                            --------
                        end
                        checkWinDiagonal2()
                    end
                end
            end
        end
    end

    ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    local function OUTPUTtable()
        for y = 1, count do
            local str = ""
            for x = 1, count do
                if arrayText[x][y] == 0 then
                    str = str .." ".."|"
                elseif arrayText[x][y] == 1 then
                    str = str .." ".."x"
                elseif arrayText[x][y] == -1 then
                    str = str .." ".."o"
                end
            end
            print(str)
        end
    end

    local function DrawFigure(iCord, jCord, prefix) -- префикс: Player, AI
        if ( array[iCord][jCord].enabled ) then
            local _x, _y = array[iCord][jCord]:localToContent( 0, 0 ) -- Тут узнаём координаты центров квадрата
            if ( WhoNow > 2 ) then
                WhoNow = 1
            end
            local Kartina = display.newImageRect(emblems[WhoNow], size/1.5, size/1.5)
            Kartina.x = _x
            Kartina.y = _y
            array[iCord][jCord].enabled = false;
            WhoNow = WhoNow + 1
            if ( WhoNow % 2 == 0 ) then
                arrayText[iCord][jCord] = 1
                print( prefix .. ": X has been printed in [" .. iCord .. "][" .. jCord .. "]" )
            else
                arrayText[iCord][jCord] = -1
                print( prefix .. ": O has been printed in [" .. iCord .. "][" .. jCord .. "]" )
            end
        end
        OUTPUTtable()
        CheckWin()
    end

    ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    local function TurnAI()

        local arrayAttacks = {} -- Массив с координатами атак/выгодных ходов
        local finalPol = {} -- Массив нужен по той причине, что функция LogicAI вызывается 4 раза и переменные потенциала при этом не сохраняются
        for i = 1, count do -- Заполняем массивы...
            finalPol[i] = {}
            for j = 1, count do
                finalPol[i][j] = 0
            end
        end
        local maxPotential = 0 -- Максимальный потенциал клетки на всём поле. Используется для сравнения с потенциалом конкретной клетки.

        local function LogicAI(mltX, mltY, DirCounter) -- = -1 or 0 or 1 // DirCounter - направление движения(для print-ов)
            for y=1, count do
                for x=1, count do
                    if ( arrayText[y][x] == 0 ) then
                        -- print( "Проверяется клетка: [" .. y .. ", " .. x .. "]" )
                        local cellDiv
                        local lenDir = 1 -- Определяет достаточно ли клеток внутри закрытой атаки, чтобы завершить игру. Если недостаточно, то прибавлять промежуточный потенциал к клетке не нужно
                        local mltDir = -1
                        local interPol = 0
                        local protectedCells = 0
                        for Dir = 1, 2 do
                            cellDiv = 1 -- Делитель, для обработки рваных атак
                            local function LogicDir()
                                mltDir = mltDir*-1 -- Определяются множители направления проверки
                                mltX = mltX * mltDir
                                mltY = mltY * mltDir
                                for c = 1, countToWin+1 do
                                    -- Если серия прерывается, то цикл не нуждается в продолжении
                                    if ( arrayText[y + (c-cellDiv) * mltY][x + (c-cellDiv) * mltX] == arrayText[y + c * mltY][x + c * mltX] * -1 and arrayText[y + c * mltY][x + c * mltX] ~= 0 ) then
                                        break
                                    -- Выражение c * mlt(Y/X) делает возможным движение в любое направление
                                    elseif (arrayText[y + c * mltY][x + c * mltX] == 0) then
                                        cellDiv = cellDiv + 1
                                    end

                                    lenDir = lenDir + 1

                                    if ( arrayText[y + c * mltY][x + c * mltX] == playerFigure ) then
                                        interPol = interPol + 1/cellDiv
                                    elseif ( arrayText[y + c * mltY][x + c * mltX] == AIFigure ) then
                                        interPol = interPol + 1.25/cellDiv
                                    end
                                end
                                -- print( "interPol for [" .. y .. "][" .. x .. "]: " .. interPol .. " witn Dir: " .. DirCounter)
                            end
                            pcall( LogicDir ) -- Безопасный вызов функции(ошибки игнорируются). Необходим, ибо иногда цмкл выходит за поле.
                        end

                        if ( cellDiv == 1 ) and ( interPol == countToWin-2 or interPol == (countToWin-2)*1.25 ) then
                            interPol = 1
                            print("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")
                        end

                        if ( interPol >= countToWin-1 ) then
                            interPol = interPol + 100
                        end
                        if ( interPol == countToWin-2 or interPol == (countToWin-2)*1.25 ) then
                            interPol = interPol + 50
                        end

                        ----- Creating Turns -----
                        if ( lenDir >= countToWin ) then
                            finalPol[y][x] = finalPol[y][x] + interPol
                            print( "interPol for [" .. y .. "][" .. x .. "]: " .. interPol .. " witn Dir: " .. DirCounter)
                        end

                        if ( finalPol[y][x] > maxPotential ) then
                            arrayAttacks = {}
                            maxPotential = finalPol[y][x] -- Обновляем максимальное значение потенциала
                            arrayAttacks[#arrayAttacks+1] = {y, x}
                            print("ArrAt[" .. #arrayAttacks+1 .. "] = " .. y .. ", " .. x .. " with finalPol: " .. finalPol[y][x])

                        elseif ( finalPol[y][x] == maxPotential ) then
                            local cndAddAttack = true
                            for a=1, #arrayAttacks do
                                if ( arrayAttacks[a][1] == y and arrayAttacks[a][2] == x ) then
                                    cndAddAttack = false
                                end
                            end
                            if ( cndAddAttack == true ) then
                                arrayAttacks[#arrayAttacks+1] = {y, x} -- Это на случай существования нескольких одинаково важных клеток
                                print("ArrAt[" .. #arrayAttacks+1 .. "] = " .. y .. ", " .. x .. " with finalPol: " .. finalPol[y][x])
                            end
                        end
                    end
                end
            end
        end
        LogicAI(0, 1, "H")
        LogicAI(1, 0, "V")
        LogicAI(1, 1, "D1")
        LogicAI(1, -1, "D2")

    --[[ Работа функции:
        1) При вызове функции определяется направление(Горизонталь, Вертикаль, Диагональ 1, Диагональ 2).
        2) Функция работает для всех пустых клеток, ибо это потенциальные клетки для атаки.
        3) По указанному направлению в обе стороны от текущей(пустой) клетки запускается мини-цикл:
        -------------------------------------------------------------------------------------------------------------------------------------------------------------
            3.1) Если серия прерывается, то цикл так же не нуждается в продолжении.
            3.2) Внутри мини-цикла определяется возможно-ли провести атаку или защиту, если поставить в проверяемую клетку(lendir).
            3.3) Внутри мини-цикла определяется промежуточный потенциал клетки(interPol):
                3.3.1) Если обнаружена пустая клетка - прибавляем делитель(cellDiv), по умолчанию он равен единице. Это необходимо для обработки "рваных" атак.
                3.3.2) Клетка с фигурой ИИ оценивается в 1.25/cellDiv очков, клетка Игрока в 1/cellDiv очко. Такое нужно, чтобы атака была приоритетнее защиты.
        -------------------------------------------------------------------------------------------------------------------------------------------------------------
        4) Финальный потенциал(finalPol) нужно прибавлять только в том случае, когда вокруг клетки достаточно места для атаки.
        5) Если обнаружена клетка с потенциалом выше максимального на данный момент(maxPotential), то потенциал этой клетки устанавливается в качестве максимального.
        6) Если финальный потенциал клетки больше, чем максимальный(на данный момент) потенциал, массив с атаками обнуляется и туда добавляется текущая клетка(атака).
        7) Если финальный потенциал клетки равен максимальному, то добавляем текущую клетку в массив с атаками.
    --]]

    --[[Вычисление потанцевала:
            2) if ( IsDangerous(currAttack) == True ) --> +cTW*3.75(AIFigure)/+cTW*3(playerFigure)
                -- IsDangerous(iCord, jCord) == True, если атака в любом случае приведёт
                -- к концу игры в чью-либо пользу, если правильно продолжать игру.
            3) +BonusOfCell(currAttack) - прибавляется только 1 раз к 1-й клетке
                -- BonusOfCell(iCord, jCord) == 0 для боковых клеток и 1 для центральных
    --]]


        ----- DrawAI -----
        print( "drawAI" )
        if ( #arrayAttacks == 0 ) then
            print( "В масиве нету циферак 0__o" )
        else
            for i=1, #arrayAttacks do
                print( "attacks", arrayAttacks[i][1], arrayAttacks[i][2] )
            end
        end
        local randomAttack = math.random(1, #arrayAttacks)
        local xCord = arrayAttacks[randomAttack][1]
        local yCord = arrayAttacks[randomAttack][2]

        print("Из бесчисленного множества ахуититиельнейших атак in this world рандом избрал атаку №" .. randomAttack)
        DrawFigure(xCord, yCord, "AI")
    end

    ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    local function checkButtons(event)
        for i = 1, count do -- Пробегаемся по массиву, который мы привязали к квадратикам
            for j = 1, count do -- Опана, а он двумерный :D
                local item_mc = array[i][j]; -- Обозначаем переменную item_mc
                local _x, _y = item_mc:localToContent( 0, 0 ); -- Тут узнаём координаты центров всех квадратов
                local dx = event.x - _x; --Считаем разницу нажатия и координат квадратика от центра по x
                local dy = event.y - _y; --Считаем разницу нажатия и координат квадратика от центра по y
                local wh  = item_mc.width; -- Записываем длину квадрата в переменную
                local ht  = item_mc.height; -- Записываем ширину квадрата в переменную

                if (math.abs(dx)<wh/2 and math.abs(dy)<ht/2) then --Если расстояние от центра одного квадрата меньше, чем половина его длины/ширины, то мы понимаем, что нему было произведено нажатие
                    if( item_mc.selected == false ) then -- Если по квадратику было произведено нажатие, но до этого он не был выбран - выбираем его
                        item_mc.selected = true;
                        -- print('S')
                    end
                else
                    if ( item_mc.selected == true ) then -- Если уже выбран какой то ещё объект, то делаем ему стаус "Не выбран"
                        item_mc.selected = false;
                        -- print( 'unS' )
                    end
                end
            end
        end
    end

    -- Функция отвечает за то что ты ставишь крестики
    local function touchTurn(event)
        local phase = event.phase;

        if ( phase == 'began' ) then
            for i = 1, count do
                for j = 1, count do
                    local item_mc = array[i][j];
                    if (item_mc.enabled == true) then
                        checkButtons(event);
                    end
                end
            end
        elseif ( phase == 'moved' ) then
            for i = 1, count do
                for j = 1, count do
                    local item_mc = array[i][j];
                    if (item_mc.enabled == true) then
                        checkButtons(event);
                    end
                end
            end
        elseif ( phase == 'ended' ) then
            if( getCountFreeRect() > 0 ) then
                print( ". . .TouchTurn. . ." )
                for i= 1, count do
                    for j = 1, count do
                        if ( array[i][j].selected and array[i][j].enabled ) then
                            DrawFigure(i, j, "Player")
                            TurnAI()
                            -- for x = 1, count do
                              --     for y = 1, count do
                              --         print(x..","..y..": "..arrayText[x][y]) -- Проверка на работу функции
                              --     end
                              -- end
                        end
                    end
                end
            end
        end
    end

    -- Тута у нас функция рисующая прямоугольники
    local function createRect(_id, _x, _y, arrayX, arrayY)
        rnd1 = math.random(0.0, 1.0) --R
        rnd2 = math.random(0.0, 1.0) --G
        rnd3 = math.random(0.0, 1.0) --B
        if (rnd1 == 0.0 and rnd2 == 0.0 and rnd3 == 0.0) then -- Если цвет квадрата чёрный, то превращаем его в белый
            rnd1 = 1
            rnd2 = 1
            rnd3 = 1
        end

        local rectangle = display.newRect( _x, _y, size, size ) -- Создаём квадрат(Хотя программа его воспринимает как прямоугольник) с шириной size и координатами _x, _y
        rectangle.strokeWidth = 3 -- Указываем ширину линий из которых он состоит
        rectangle:setFillColor( black, 0.01 ) -- Делаем квадратик прозрачным :)
        rectangle:setStrokeColor( rnd1, rnd2, rnd3 ) -- Делаем рандомный цвет квадратику
        rectangle.selected = false;
        rectangle.enabled = true;
        mainGroup.parent:insert(rectangle)-- Добавляем наш прямоугольник на сцену
        array[arrayX][arrayY] = rectangle -- привязываем массив к нашему квадратику
        rectangle:addEventListener( "touch", touchTurn )
    end

    ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- Делаем циклы, необходимые для прорисовки поля и обозначния клеток в массиве
    ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    local function drawField()
        for i = 1, count do
            for j = 1, count do
                createRect( i,  startX + (i-1)*size, startY + (j-1)*size, i, j ); -- тут чистая математика, просто надо разобраться и всё
            end
        end

        for i = 1, count do
            arrayText[i] = {};
            for j = 1, count do
                arrayText[i][j] = 0;
            end
        end
    end
    drawField()
    -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------


end


-- show()
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)

    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen

    end
end


-- hide()
function scene:hide( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)

    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen

    end
end


-- destroy()
function scene:destroy( event )

    local sceneGroup = self.view
    -- Code here runs prior to the removal of scene's view

end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene
