local args = {...}

local b = {}
b.test = "e"
b.a = "a"
b.s = {}
b.s.e = "1"
b.s.f = 5

local a = fs.open("temp")
a.write(b)
a.close()



local function install(RESP_URL,NAME)
    --get data
    print("fetching repository info")
    local resp_data_url = http.get(RESP_URL)
    local resp_data = nil
    if resp_data_url ~= nil then
        resp_data = resp_data_url.readAll()
    end
    if resp_data_url == nil or resp_data == nil then
        error("failed to get data from server")
    end
    --convert to vaild format
    local JsonData = textutils.unserialiseJSON(resp_data_url)
    if JsonData == nil then 
        error("server returned invaild data")
    end
    --script to pre install stuff
    if resp_data_url[NAME].pre_install ~= nil then
        print("running pre install script")
        shell.run("wget run " .. resp_data_url[NAME].pre_install)
    end
    --apps to install
    if resp_data_url[NAME].files ~= nil then
        print("installing files")
        local amtToInstall = #resp_data_url[NAME].files
        local CurX, CurY = term.getCursorPos()
        --one day i will make this fancy
        for k,v in pairs(resp_data_url[NAME].files) do
            term.setCursorPos(CurX,CurY)
            term.write(k .. "/" .. amtToInstall)
        end
    end
    --script to post install stuff
    if resp_data_url[NAME].post_install ~= nil then
        print("running post install script")
        shell.run("wget run " .. resp_data_url[NAME].post_install)
    end
end

local function Help()
    print("Usage:")
    print("cam install <name>")
    --print("cam update")
    print("cam add <resp>")


end






if args[1] == "install" then
    --get repo
    local PossableAppsToInstall = {}
    for v in io.lines("REPOS") do
        if v ~= nil and v ~= "" then
            --look if its a vaild website
            local WS = http.get(v)
            if WS == nil then error("failed to get website") end
            local Data = WS.readAll()
            WS.close()
            if Data == nil then error("data returned is invaild") end
            Data = textutils.unserialiseJSON(Data) 
            if Data == nil then error("data returned is invaild") end

            if Data[args[2]] ~= nil then
                local DataJson = Data[args[2]]
                DataJson.REPO = v
                table.insert(PossableAppsToInstall, DataJson)
            end
        end
    end
    if #PossableAppsToInstall == 0 then
        error("failed to find any packages with that name")
    else
        print("found the following apps")
        print("")
        for k,v in pairs(PossableAppsToInstall) do
            print(k)
            print(textutils.serialise(v))
            print("REPO : " .. v.REPO)
            print("DESC : " .. v.desc)
            print()
        end
        print("which app would you like to install?")
        term.write("> ")
        local UserData = tonumber(read())
        install(PossableAppsToInstall[UserData].REPO, args[2])

    end

elseif args[1] == "add" then
    --add Resp to file
    local RespListFile = fs.open("REPOS","a")
    if RespListFile == nil then error("failed to open file") end
    if http.get(args[2]) == nil then error("not a vaild url") end
    RespListFile.write(args[2] .. "\n")
    RespListFile.close()
else
    Help()
end
