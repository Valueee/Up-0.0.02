type Item1_MappingSounds = any | {
    Dadbattle : Instance | ModuleScript
};
type Item2_PlayersInService = any | {
    PlayerLeft : Player,
    PlayerRight : Player
};
type Item3_TemplatesTypes = any | {
    Up : Instance | Frame,
    Down : Instance | Frame,
    Right : Instance | Frame,
    Left : Instance | Frame,
};
type Dictionary<any> =  {[any]: any} | {any} | {Item1_MappingSounds | Item2_PlayersInService | Item3_TemplatesTypes};

local Import = require
local ConvertForString : string = tostring

local InsertService: InsertService = game:GetService("InsertService")
local ReplicatedStorage: InsertService = game:GetService("ReplicatedStorage")
local Workspace: Workspace = game:GetService("Workspace")
local ServerStorage: ServerStorage = game:GetService("ServerStorage")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService: TweenService = game:GetService('TweenService')
local SoundService: SoundService = game:GetService("SoundService")

local TableBody: Folder = ServerStorage:WaitForChild("Table")
local Packages: Folder = ReplicatedStorage.Packages

local Promise = require(Packages.Promise)
local Signal = require(Packages.Signal)

local TableConfig, Path = {
    [1] = {Position = Vector3.One, Body = TableBody:Clone(), Players = {['PlrL'] = nil, ['PlrR'] = 'NGC7380'}, Votes = {['PlrL'] = nil, ['PlrR'] = nil}, gameStarted = false, Points = {['Left'] = 0, ['Right'] = 0}, Music = {Name = nil, Speed = nil}}
}, Workspace

-- @Mapping:

local MappingSongs: Dictionary<any | Item1_MappingSounds> = {
    [1] = HttpService:JSONDecode(Import(InsertService:LoadAsset(8486500831).Dadbattle).JSONString),
    [2] = HttpService:JSONDecode(Import(InsertService:LoadAsset(8486586552).Pico).JSONString),
    [3] = HttpService:JSONDecode(Import(InsertService:LoadAsset(8487140411).High).JSONString)
}

local Knit = Import(ReplicatedStorage.Packages.Knit)

local ServerManager = Knit.CreateService {
    Name = "ServerManager";
    Client = {
        ClientExit = Knit.CreateSignal();
        ClientEntered = Knit.CreateSignal();

        -- @Map Song :

        MappingSongsConvertion = Knit.CreateSignal();
        MapSignalForConvertion = Knit.CreateSignal();

        VoteSong = Knit.CreateSignal();
        PlayLocalSound  = Knit.CreateSignal();

        -- @Input Key :

        Input = Knit.CreateSignal();

    };
}

local TimeInit = os.clock()

ServerManager.Settings = {
    TimeVoting = 5
}
ServerManager.TableConfig = TableConfig;
ServerManager.ModeDev = true;

function ServerManager:TweenStateChanger(BoolValue: BoolValue, State: boolean): any
    if BoolValue then BoolValue.Value = State end
    if (ServerManager.ModeDev) then print('[ModeDev Print]: BoolValue is state: ' .. ConvertForString(State) .. ".") end
end

function ServerManager:AddPunctuation(Table, ...): any
    local PlayerLeftPoints, PlayerRightPoints, Arrow = ...;
    if (PlayerLeftPoints > 0) then Table.Points["Left"] += PlayerLeftPoints end
    if (PlayerRightPoints > 0) then Table.Points["Right"] += PlayerRightPoints end
    Arrow:Destroy();
end

function ServerManager:KnitStart()
    
end


function ServerManager:KnitInit()

    local ServerInit : (any) -> (any) = function(): any
        return Promise.new(function(resolve, reject, onCancel)
            
            Knit.Start():await()

            -- @Tables cloning:

            Promise.try(function()

                local function _WaitForChild(instance, childName, timeout)
                    return Promise.defer(function(resolve_, reject__)
                      local child = instance:WaitForChild(childName, timeout)
                  
                      ;(child and resolve_ or reject__)(child)
                    end)
                end

                self.Client.VoteSong:Connect(function(PlayerFired_: Player, NameSong: string)
                    for i = 1, #TableConfig do
                        local Table = TableConfig[i]
                        if (PlayerFired_.Name == Table.Players.PlrL) then
                            Table.Votes.PlrL = NameSong;
                            print('Voted: ', NameSong)
                        elseif (PlayerFired_.Name == Table.Players.PlrR) then
                            Table.Votes.PlrR = NameSong;
                            print('Voted: ', NameSong)
                        end
                    end
                end)

                self.Client.Input:Connect(function(PlayerFired_: Player, __Type)
                    for _, Elements in pairs(TableConfig) do

                        -- @Select PlayerDirection <_?_> Frame Direction:

                        local PlayerDirection: any = nil
                        if (PlayerFired_.Name == Elements.Players["PlrL"]) then
                            PlayerDirection = "Left"
                        elseif (PlayerFired_.Name == Elements.Players["PlrR"]) then
                            PlayerDirection = "Right"
                        else return;
                        end

                        -- @Destroy Arrows:

                        local FrameDirection: Frame = PlayerFired_.PlayerGui.SettingsMain.GameFrame[PlayerDirection]

                        Promise.try(function()
                            local Reached: boolean = false
                            for Index, Arrows in ipairs(PlayerFired_.PlayerGui.SettingsMain.GameFrame[PlayerDirection].Arrows.IncomingArrows[__Type]:GetChildren()) do
                                if (not Reached) then
                                    if (Arrows.Name == __Type) and (Arrows.SliderbarValue.Value == false) then
                                        local MagnitudeCalculated: number = math.abs(Arrows.Position.Y.Scale)
                                        if MagnitudeCalculated <= 0.075 then
                                            if (PlayerDirection == "Left") then ServerManager:AddPunctuation(Elements, 350, 0, Arrows) elseif (PlayerDirection == "Right") then ServerManager:AddPunctuation(Elements, 0, 350, Arrows) end
                                            Reached    = true
                                        elseif MagnitudeCalculated <= 0.25 then
                                            if (PlayerDirection == "Left") then ServerManager:AddPunctuation(Elements, 150, 0, Arrows) elseif (PlayerDirection == "Right") then ServerManager:AddPunctuation(Elements, 0, 150, Arrows) end
                                            Reached    = true
                                        elseif MagnitudeCalculated <= 0.5 then
                                            if (PlayerDirection == "Left") then ServerManager:AddPunctuation(Elements, 100, 0, Arrows) elseif (PlayerDirection == "Right") then ServerManager:AddPunctuation(Elements, 0, 100, Arrows) end
                                            Reached    = true
                                        elseif MagnitudeCalculated <= 1 then
                                            if (PlayerDirection == "Left") then ServerManager:AddPunctuation(Elements, 50, 0, Arrows) elseif (PlayerDirection == "Right") then ServerManager:AddPunctuation(Elements, 0, 50, Arrows) end
                                            Reached    = true
                                        end
                                    elseif (Arrows.Name == __Type) and (Arrows.SliderbarValue.Value == true) and (not Arrows.HasPressed.Value) then
                                        
                                        ServerManager:TweenStateChanger(Arrows:WaitForChild("HasPressed"), true)

                                        local MagnitudeCalculated: number = math.abs(Arrows.Position.Y.Scale)
                                        local PointsAwaiting: number = 0 or nil;
                                        if MagnitudeCalculated <= 0.075 then
                                            PointsAwaiting = 350;
                                            Reached    = true
                                        elseif MagnitudeCalculated <= 0.25 then
                                            PointsAwaiting = 150;
                                            Reached    = true
                                        elseif MagnitudeCalculated <= 0.5 then
                                            PointsAwaiting = 100;
                                            Reached    = true
                                        elseif MagnitudeCalculated <= 1 then
                                            PointsAwaiting = 50;
                                            Reached    = true
                                        end
                                        local SliderbarFrame: Frame = Arrows.Frame.Bar
                                        local Time: number = Elements.Music.Speed;
                                        local Table = {}
                                        Table.Size = UDim2.fromScale(SliderbarFrame.Size.X.Scale, 0)
                                        local Interpolate = TweenService:Create(SliderbarFrame, TweenInfo.new(Time, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), Table)
                                        Interpolate.Completed:Connect(function(): any
                                            if (PlayerDirection == "Left") then ServerManager:AddPunctuation(Elements, PointsAwaiting, 0, Arrows) elseif (PlayerDirection == "Right") then ServerManager:AddPunctuation(Elements, 0, PointsAwaiting, SliderbarFrame) end
                                        end)
                                        Interpolate:Play()
                                        --ServerManager:TweenStateChanger(Arrows:WaitForChild("TweenState"), false)
                                    end
                                end
                            end
                        end)

                    end
                end)
                

                for i = 1, #ServerManager.TableConfig do
                    local TableConfigUsing = ServerManager.TableConfig[i]
                    local ProximityPrompt: ProximityPrompt = Instance.new("ProximityPrompt", ServerManager.TableConfig[i].Body.Main.Block)
                    self.Client.ClientExit:Connect(function(PlayerFired_, PlayerDirection)
                        -- @Interpolate
                        local Table1_ = {}
                        Table1_.Position = UDim2.new(0.299, 0, 1.1, 0)
                        TweenService:Create(PlayerFired_.PlayerGui:WaitForChild("SettingsMain")['SongsFrame'], TweenInfo.new(1.75, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), Table1_):Play()
                        -- [@CFrame Character]
                        local Body = TableConfigUsing.Body
                        local Character: Model = PlayerFired_.Character or PlayerFired_.CharacterAdded:Wait()
                        Character.PrimaryPart.CFrame = Body.Paths.Out.CFrame;
                        Character.PrimaryPart.Anchored = false;
                        -- [@Clean Data]
                        TableConfigUsing.Players[PlayerDirection] = nil;
                        TableConfigUsing.Votes[PlayerDirection] = nil;
                    end)
                    ServerManager.TableConfig[i].Body.Parent = Path
                    ProximityPrompt.Triggered:Connect(function(Player_)
                        if (not TableConfigUsing.gameStarted) then
                            Promise.try(function()
                                local Body = TableConfigUsing.Body
                                local Teleport : (any) -> (any) = function(Player: Player, Localization: Part): any
                                    local Character: Model = Player.Character or Player.CharacterAdded:Wait()
                                    Promise.try(function()
                                        Character.PrimaryPart.Anchored = true
                                        Character.PrimaryPart.CFrame = CFrame.new(Localization.CFrame.X, Localization.CFrame.Y, Localization.CFrame.Z)
                                    end)
                                    Promise.try(function()
                                        self.Client.ClientEntered:Fire(Player_, Body, TableConfigUsing)
                                    end)
                                end
                                if (TableConfigUsing.Players.PlrL == nil and (Player_.Name ~= TableConfigUsing.Players.PlrL)) then
                                    if (ServerManager.ModeDev) then print('You is Player Left!') end
                                    TableConfigUsing.Players.PlrL = Player_.Name
                                    Teleport(Player_, Body.Paths.PlayerLeft)
                                elseif (TableConfigUsing.Players.PlrL ~= nil and TableConfigUsing.Players.PlrR == nil) and (Player_.Name ~= TableConfigUsing.Players.PlrL) then
                                    if (ServerManager.ModeDev) then print('You is Player Right!') end
                                    TableConfigUsing.Players.PlrR = Player_.Name
                                    Teleport(Player_, Body.Paths.PlayerRight)
                                end
                                -- @Init game:
                                if (TableConfigUsing.Players.PlrL and TableConfigUsing.Players.PlrR ~= nil) then
                                    local PlayersInService: Dictionary<Item2_PlayersInService | any> = {
                                        ['PlayerLeft'] = Players:FindFirstChild(TableConfigUsing.Players.PlrL) or Players:WaitForChild(TableConfigUsing.Players.PlrL),
                                        ['PlayerRight'] = Players:FindFirstChild(TableConfigUsing.Players.PlrR) or Players:WaitForChild(TableConfigUsing.Players.PlrR)
                                    }
                                    local VisualizeSongList : (any) -> (any) = function(Turn: boolean): any
                                        assert(type(Turn) == "boolean", "[Warn]: 'Turn' is not a boolean!")
                                        local Types_ = {
                                            TableColection1 = {
                                                [true] = UDim2.new(0.299, 0, 0.106, 0),
                                                [false] = UDim2.new(0.299, 0, 1.1, 0)
                                            },
                                            TableColection2 = {
                                                [true] = UDim2.new(0.012, 0, 0.868, 0),
                                                [false] = UDim2.new(-0.2, 0, 0.868, 0)
                                            },
                                        }
                                        local Table1, Table2, Table3, Table4 = {}, {}, {}, {}
    
                                        Table1.Position     = Types_.TableColection1[Turn];
                                        Table2.Position     = Types_.TableColection1[Turn];
                                        Table3.Position     = Types_.TableColection2[Turn];
                                        Table4.Position     = Types_.TableColection2[Turn];
    
                                        local Tween1, Tween2, Tween3, Tween4 = 
                                                            TweenService:Create(PlayersInService['PlayerLeft'].PlayerGui:WaitForChild("SettingsMain")['SongsFrame'], TweenInfo.new(1.75, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), Table1)
                                                            TweenService:Create(PlayersInService['PlayerRight'].PlayerGui:WaitForChild("SettingsMain")['SongsFrame'], TweenInfo.new(1.75, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), Table2):Play()
    
                                                            TweenService:Create(PlayersInService['PlayerLeft'].PlayerGui:WaitForChild("SettingsMain")['Leave/Out'], TweenInfo.new(1.75, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), Table3):Play()
                                                            TweenService:Create(PlayersInService['PlayerRight'].PlayerGui:WaitForChild("SettingsMain")['Leave/Out'], TweenInfo.new(1.75, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), Table4):Play()
                                        
                                        Tween1:Play()
                                        
                                        return Tween1, Tween2, Tween3, Tween4
                                        
                                    end
    
                                    local Tween1_, Tween2_, Tween3_, Tween4_ = VisualizeSongList(true);
                                    
                                    Promise.delay(ServerManager.Settings.TimeVoting):andThen(function()
    
                                        local Tween1, Tween2, Tween3, Tween4 = VisualizeSongList(false)
    
                                        --@Select Random Music:
    
                                        local SongsOfPlayers = {
                                            [1] = TableConfigUsing.Votes.PlrL,
                                            [2] = TableConfigUsing.Votes.PlrR
                                        }
    
                                        local SongSelected: any | string = nil
                                        print(SongsOfPlayers[1], SongsOfPlayers[2])
                                        if (SongsOfPlayers[1] ~= nil) and (SongsOfPlayers[2] ~= nil) then
                                            SongSelected = SongsOfPlayers[math.random(1, #SongsOfPlayers)]
                                        elseif (SongsOfPlayers[1] ~= nil and SongsOfPlayers[2] == nil) then
                                            SongSelected = SongsOfPlayers[1]
                                        elseif (SongsOfPlayers[1] == nil and SongsOfPlayers[2] ~= nil) then
                                            SongSelected = SongsOfPlayers[2]
                                        elseif (SongsOfPlayers[1] == nil and SongsOfPlayers[2] == nil) then
                                            local SongsCurrent = {'Dadbattle', 'Pico', 'High'}
                                            SongSelected = SongsCurrent[math.random(1, #SongsCurrent)]
                                        end
                                        
                                        if (ServerManager.ModeDev) then print("[ModeDev Print]: Song selected -> " .. SongSelected) end
    
                                        -- @Init Game [Mapping in use] (Ready, Set, Go):
    
                                        local Messages = {
                                            ['PlrL'] = {
                                                [1] = PlayersInService['PlayerLeft'].PlayerGui:WaitForChild("SettingsMain")['Ready'],
                                                [2] = PlayersInService['PlayerLeft'].PlayerGui:WaitForChild("SettingsMain")['Set'],
                                                [3] = PlayersInService['PlayerLeft'].PlayerGui:WaitForChild("SettingsMain")['Go']
                                            },
                                            ['PlrR'] = {
                                                [1] = PlayersInService['PlayerRight'].PlayerGui:WaitForChild("SettingsMain")['Ready'],
                                                [2] = PlayersInService['PlayerRight'].PlayerGui:WaitForChild("SettingsMain")['Set'],
                                                [3] = PlayersInService['PlayerRight'].PlayerGui:WaitForChild("SettingsMain")['Go']
                                            }
                                        }
                                        
                                        Promise.new(function(resolve_, reject_, onCancel_)
                                            if (TableConfigUsing.Players['PlrL'] and TableConfigUsing.Players['PlrR'] ~= nil) then
                                                TableConfigUsing.gameStarted = true
                                                local Time: number = 0.23331;
                                                Tween1.Completed:Wait()
                                                Promise.try(function()
                                                    for k = 1, #Messages.PlrL do
                                                        local Item = Messages.PlrL[k]
                                                        Item.Visible = true;
                                                        task.wait(Time)
                                                        Item.Visible = false;
                                                        if (k >= #Messages.PlrL) then
                                                            resolve_(true)
                                                        end
                                                    end
                                                end)
                                                Promise.try(function()
                                                    for k = 1, #Messages.PlrR do
                                                        local Item = Messages.PlrR[k]
                                                        Item.Visible = true;
                                                        task.wait(Time)
                                                        Item.Visible = false;
                                                        if (k >= #Messages.PlrR) then
                                                            resolve_(true)
                                                        end
                                                    end
                                                end)
                                            end
                                        end):andThen(function()
                                            
                                            -- Quando terminar a música no cliente então ele manda sinal e o jogo termina e eles saem do palco
                                            -- // [Sound Mapping Start]:
    
                                            local InterpolateArrow : (any) -> (any) = function(ArrowUsing: Frame, PointEnd: UDim2 | Frame | Instance, Seconds: number, TimePointOrigin: number, Lenght: number): any
                                                local ForSeconds = ((math.abs(TimePointOrigin) * 10000) / 10000000)
                                                assert(typeof(Seconds) == 'number', "[Seconds] is not a number");
                                                assert(typeof(TimePointOrigin) == 'number', "[TimePointOrigin] is not a number");
                                                Promise.delay(tonumber(ForSeconds - Seconds)):andThenCall(function()
                                                    local Arrow = ArrowUsing:Clone()
                                                    Arrow.Frame.Bar.Size = UDim2.fromScale(Arrow.Frame.Bar.Size.X.Scale, (math.abs(tonumber(Lenght)) * 10000 / 1000000))
                                                    Arrow.Position = UDim2.new(Arrow.Position.X.Scale, 0, 6.74, 0)
                                                    Arrow.Parent = PointEnd:WaitForChild(Arrow.Name)
                                                    
                                                    local TweenState: BoolValue, SliderbarValue: BoolValue, HasPressed: BoolValue = Instance.new("BoolValue"), Instance.new("BoolValue"), Instance.new("BoolValue")

                                                    TweenState.Name = "TweenState"; SliderbarValue.Name = "SliderbarValue"; HasPressed.Name = "HasPressed";
                                                    TweenState.Parent = Arrow; SliderbarValue.Parent = Arrow; HasPressed.Parent = Arrow;
                                                    HasPressed.Value = false; TweenState.Value = true;

                                                    if (Arrow.Frame.Bar.Size.Y.Scale > 0) then SliderbarValue.Value = true elseif (Arrow.Frame.Bar.Size.Y.Scale == 0) then SliderbarValue.Value = false end

                                                    local DoublePosition: number = (PointEnd.Position.Y.Scale - Arrow.Position.Y.Scale)
                                                    local TweenInfo_ = TweenInfo.new(Seconds, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                                                    local Table_: Frame | any = {}
                                                    Table_.Position = UDim2.new(Arrow.Position.X.Scale, 0, PointEnd.Position.Y.Scale, 0)
                                                    local Inter = TweenService:Create(Arrow, TweenInfo_, Table_)
                                                    
                                                    -- //- [Pause & Play Tween Service] -\\ --

                                                    Inter.Completed:Connect(function()
                                                        local Table2_ = {}
                                                        Table2_.Position = UDim2.new(Arrow.Position.X.Scale, 0, math.abs(DoublePosition) * -1, 0)
                                                        local Inter2 = TweenService:Create(Arrow, TweenInfo_, Table2_)
                                                        Inter2.Completed:Connect(function()
                                                            Arrow:Destroy()
                                                        end)
                                                        Inter2:Play()
                                                    end)
                                                    
                                                    Inter:Play()

                                                    TweenState.Changed:Connect(function(Propertie: any): any
                                                        if (Propertie == true) then Inter:Play() elseif (Propertie == false) then Inter:Pause() end
                                                    end)

                                                end)
                                            end
    
                                            local Templates: Folder = ReplicatedStorage:WaitForChild("Templates")
                                            local SongJSON: any | string = nil;
    
                                            local TemplatesTypes: Dictionary<Item3_TemplatesTypes> = {
                                                Up = Templates['Up'] or Templates:WaitForChild('Up'),
                                                Down = Templates['Down'] or Templates:WaitForChild('Down'),
                                                Right = Templates['Right'] or Templates:WaitForChild('Right'),
                                                Left = Templates['Left'] or Templates:WaitForChild('Left')
                                            }
    
                                            for q_ = 1, #MappingSongs do
                                                local SongJSONSelector = MappingSongs[q_]
                                                if (SongJSONSelector.song.song == SongSelected) then
                                                    SongJSON = SongJSONSelector
                                                end
                                            end
                                            
                                            TableConfigUsing.Music.Speed = SongJSON.song.speed; TableConfigUsing.Music.Name = SongJSON.song.song

                                            -- [TimePoints and Arrow]:
                                            
                                            local MapSelectPlayer : (any | string) -> (any | string) = function(PlayerDirection__: string): any
                                                self.Client.PlayLocalSound:Fire(PlayersInService[PlayerDirection__], SongJSON.song.song)
                                                for n = 1, #SongJSON.song.notes do
                                                    local NotesUsing = SongJSON.song.notes[n]
                                                    local Speed: number = SongJSON.song.speed
                                                    for Sections_ = 1, #NotesUsing.sectionNotes do
                                                        local Section = NotesUsing.sectionNotes[Sections_]
                                                        local Point, Type, Lenght = Section[1], Section[2], Section[3]
    
                                                        if (NotesUsing.sectionNotes[Sections_] ~= nil) then
    
                                                            local function Convert(Type__)
                                                                if tonumber(Type__) then
                                                                    if Type__ == 0 then return "Left" end
                                                                    if Type__ == 1 then return "Down" end
                                                                    if Type__ == 2 then return "Up" end
                                                                    if Type__ == 3 then return "Right" end
                                                                    if Type__ > 3 then 
                                                                        return Convert( Type__ -4 ), true
                                                                    end
                                                                end
                                                            end
                                                            
                                                            local TypeNote, MustHitSection = Convert(Type)
    
                                                            local MustHitSectionDictionary = {
                                                                [true] = "Right",
                                                                [false] = "Left"
                                                            }
    
                                                            if MustHitSection ~= nil then
                                                                InterpolateArrow(ReplicatedStorage.Templates[TypeNote], PlayersInService[PlayerDirection__].PlayerGui:WaitForChild("SettingsMain").GameFrame[ConvertForString(MustHitSectionDictionary[MustHitSection])].Arrows.IncomingArrows, Speed, Point, Lenght)
                                                            elseif MustHitSection == nil then
                                                                InterpolateArrow(ReplicatedStorage.Templates[TypeNote], PlayersInService[PlayerDirection__].PlayerGui:WaitForChild("SettingsMain").GameFrame[ConvertForString(MustHitSectionDictionary[NotesUsing.mustHitSection])].Arrows.IncomingArrows, Speed, Point, Lenght)
                                                            end
                                                            
                                                        end
    
                                                    end
                                                end
                                            end
    
                                            for p_ = 1, 2 do
                                                if (p_ <= 1) then
                                                    Promise.new(function(Resolve, Reject, OnCancel)
                                                        MapSelectPlayer('PlayerLeft');
                                                        Resolve('M\t');
                                                    end):andThen(function()
                                                        if (ServerManager.ModeDev) then print('[ModeDev Print]: Mapping completed! (PlayerLeft)') end
                                                    end)
                                                elseif (p_ >= 2) then
                                                    Promise.new(function(Resolve, Reject, OnCancel)
                                                        if (not ServerManager.ModeDev) then
                                                            MapSelectPlayer('PlayerRight');
                                                            Resolve('M\t');
                                                        end
                                                    end):andThen(function()
                                                        if (ServerManager.ModeDev) then print('[ModeDev Print]: Mapping completed! (PlayerRight)') end
                                                    end)
                                                end
                                            end
    
                                        end)
    
    
                                    end)
                                end
                                if (ServerManager.ModeDev) then print(Player_.Name .. " Entered at place: " .. ("PlaceLeft: " .. ConvertForString(TableConfigUsing.Players.PlrL) .. ". PlaceRight: " .. ConvertForString(TableConfigUsing.Players.PlrR)), ("PlaceSelected: " .. Player_.Name) ) end
                            end)
                        end
                    end)
                end
            end)

            self.Client.MapSignalForConvertion:Connect(function(PlayerFired_)
                if (ServerManager.ModeDev) then print('[Proccess-Game]: Mapping songs...') end
                self.Client.MappingSongsConvertion:Fire(PlayerFired_, MappingSongs, 1, TableConfig)
            end)

            resolve(string.format(ServerManager.Name .. ' Finished! [%f0.1s]', tostring(math.abs(TimeInit - os.clock()) * 1)))

        end)
    end

    ServerInit():andThen(print)

end


return ServerManager
