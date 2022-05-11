-- DISCLAIMER! if you're using Roblox Lua Implementation, please use DataStore (can be found in https://developer.roblox.com/)
-- as roblox disabled global table 'io'

-- start of String class

String = {x="nil"}

function String:new (str, o)
   o = o or {}
   setmetatable(o, self)
   self.__index = self
   self.x = str or "nil"
   return o
end
function String:split(delim)
    local result = {}
    local from = 1
    local delim_from, delim_to = string.find(self.x, delim, from)
    while delim_from do
        table.insert(result, string.sub(self.x, from, delim_from-1))
        from = delim_to + 1
        delim_from, delim_to = string.find(self.x, delim, from)
    end
    table.insert(result, string.sub(self.x, from))
    return result
end
-- end of String class
function file_exists(f)
    local a = io.open(f, "r")
    return a ~= nil and a:close()
end

CRUD = {isinitialized=false}
function CRUD.new(o)
    local self = o or CRUD
    setmetatable(self, CRUD)
    self.__index = self
    self.isinitialized = true
    if not file_exists("database.dat") then
        local file = io.open("database.dat", "w")
        file:close()
    elseif not file_exists("temp.dat") then
        local file = io.open("temp.dat", "w")
        file:close()
    end
    return self
end
function CRUD:getChoice(a)
    io.write(a .. " (Y/N): ")
    local choice = io.read()
    while choice:lower() ~= "y" and choice:lower() ~= "n" do
        io.write(a .. " (Y/N): ")
        choice = io.read()
    end
    return choice:lower() == "y"
end
function CRUD:getInput(a)
    io.write(a)
    return io.read()
end
function CRUD:getNumber(key)
    return tonumber(self:checkExist(key, true) ~= nil and self:checkExist(key, true)[1]) or 0
end
function CRUD:checkExist(key, directDisplay)
    local file = io.open("database.dat", "r")
    local d = file:read()
    local exist = false
    local tab  = {}
    while d do
        if d:lower():find(key:lower()) then
            exist=true
            if directDisplay then 
                tab = String:new(d):split(",")
            end
        end
        d = file:read()
    end
    file:close()
    if directDisplay then return tab end
    return exist
end
function CRUD:createData(name, hobby)
    local file = io.open("database.dat", "a")
    local no = self:fileLines() ~= 0 and self:fileLines()+1 or 1
    if self:checkExist(name, false) then
        io.write("Data already exists!\n")
        return
    end
    file:write(tostring(no) .. "," .. name .. "," .. hobby .. "\n")
    print("Data created.")
    file:close()
end
function CRUD:fileLines()
    local file = io.open("database.dat", "r")
    local data = {}
    local line = file:read()
    while line do
        table.insert(data, line)
        line = file:read()
    end
    file:close()
    return #data
end
function CRUD:readData()
    local file = io.open("database.dat", "r")
    local line = file:read()
    print("-----------------------------------------------------------------------------------------")
    print("| No. \t\t|\t\t Name \t\t|\t\t Hobby \t\t\t|")
    print("-----------------------------------------------------------------------------------------")
    while line do
        local str = String:new(line):split(",")
        print("| " .. str[1] .. " \t\t|\t\t " .. str[2] .. " \t\t|\t\t " .. str[3] .. " \t\t|")
        line = file:read()
    end
    print("-----------------------------------------------------------------------------------------")
    file:close()
end
function CRUD:updateData(name, nname, nhobby)
    if not self:checkExist(name, false) then
        print("Data \"" .. name .. "\" Not found")
        return
    end
    local entry = self:getNumber(name)
    local start = 1
    local file = io.open("database.dat", "r")
    local temp = io.open("temp.dat", "a")
    local d = file:read()
    while d do
        if entry == start then
            local m = String:new(d):split(",")
            print("Data to be updated:")
            print(
                m[2] .. "\n" .. m[3]
            )
            print("New data:")
            print(
                nname .. "\n" .. nhobby
            )
            if self:getChoice("Are you sure want to update this data?") then
                if self:checkExist(nname) then
                    print("data already existed")
                    temp:write(d)
                    temp:write("\n")
                else
                temp:write(m[1] .. "," .. nname .. "," .. nhobby)
                temp:write("\n")
                end
            else
                temp:write(d)
            end
        else
            temp:write(d)
            temp:write("\n")
        end
        d = file:read()
        start = start + 1
    end
    file:close()
    temp:close()
    io.open("database.dat", "w"):write():close()
    local db_new = io.open("database.dat", "a")
    local temp_new = io.open("temp.dat", "r")
    d = temp_new:read()
    while d do
        db_new:write(d)
        db_new:write("\n")
        d = temp_new:read()
    end
    print("Successfully updated data")
    db_new:close()
    temp_new:close()
    io.open("temp.dat", "w"):write():close()
end
function CRUD:deleteData(name)
    if not self:checkExist(name, false) then
        print("Data \"" .. name .. "\" Not found")
        return
    end
    local entry = self:getNumber(name)
    local start = 1
    local file = io.open("database.dat", "r")
    local temp = io.open("temp.dat", "a")
    local d = file:read()
    local offset = 0
    while d do
        if entry == start then
            print("Data to be deleted:")
            local m = String:new(d):split(",")
            print(
                m[2] .. "\n" .. m[3]
            )
            if self:getChoice("Are you sure want to delete this data?") then
                print("Skipped as the data will be deleted")
                offset = offset + 1
            else
                temp:write(d)
                temp:write("\n")
            end
        else
            local mba = String:new(d):split(",")
            local stringified = tostring(tonumber(mba[1]) - offset)
            .. "," .. mba[2] .. "," .. mba[3]
            temp:write(stringified)
            temp:write("\n")
        end
        d = file:read()
        start = start + 1
    end
    file:close()
    temp:close()
    io.open("database.dat", "w"):write():close()
    local db_new = io.open("database.dat", "a")
    local temp_new = io.open("temp.dat", "r")
    d = temp_new:read()
    while d do
        db_new:write(d)
        db_new:write("\n")
        d = temp_new:read()
    end
    print("Successfully deleted data")
    db_new:close()
    temp_new:close()
    io.open("temp.dat", "w"):write():close()
end
function CRUD:getTable()
    io.write(
        "Menu\n" ..
        "1. Create data\n" ..
        "2. Read data\n" ..
        "3. Update data\n" ..
        "4. Delete data\n" ..
        "5. Find data\n" ..
        "6. Reset data\n" ..
        "7. Exit\n"..
        "Choose: "
    )
    local choice = io.read()
    while tonumber(choice) < tonumber("1") or tonumber(choice) > tonumber("7") do
        io.write("Invalid choice. Please try again.\n")
        io.write(
        "Menu\n" ..
        "1. Create data\n" ..
        "2. Read data\n" ..
        "3. Update data\n" ..
        "4. Delete data\n" ..
        "5. Find data\n" ..
        "6. Reset data\n" ..
        "7. Exit\n"..
        "Choose: "
    )
        choice = io.read()
    end
    local num = tonumber(choice)
    if num == 1 then
        self:createData(self:getInput("Name: "), self:getInput("Hobby: "))
    elseif num == 2 then
        self:readData()
    elseif num == 3 then
        self:updateData(self:getInput("Name: "), self:getInput("New name: "), self:getInput("New hobby: "))
    elseif num == 4 then
        self:deleteData(self:getInput("Name: "))
    elseif num == 5 then
        local m = self:getInput("Name: ")
        if not self:checkExist(m, false) then
            print("Data \"" .. m .. "\" Not found")
        else
            local str = self:checkExist(m, true)
        print("-----------------------------------------------------------------------------------------")
        print("| No. \t\t|\t\t Name \t\t|\t\t Hobby \t\t\t|")
        print("-----------------------------------------------------------------------------------------")
        print("| " .. str[1] .. " \t\t|\t\t " .. str[2] .. " \t\t|\t\t " .. str[3] .. " \t\t|")
        print("-----------------------------------------------------------------------------------------")
        end
    elseif num == 6 then
        if self:getChoice("Are you sure want to reset data?") then
            io.open("database.dat", "w"):write():close()
            print("Data reset successfully.")
        else
            print("Abort")
        end
    elseif num == 7 then
        os.exit(0)
    else
        print("Not yet implemented.")
    end
    local isContinue = self:getChoice("Do you want to continue?")
    if isContinue then
        self:getTable()
    else
        os.exit()
    end
end

local c = CRUD.new()
c:getTable()
