require "./operations.rb"

def createData(name, hobby)
    db = FDatabase.new "database.dat", true
    if db.check_exist "#{name}" then
        puts "User already existed"
        return
    end
    fmt = "#{db.index_at},#{name},#{hobby}\n"
    db.write(fmt)
end

def readData()
    FDatabase.new("database.dat", true).read_file.each {|ln| 
    tok = ln.split ","
    puts "#{tok[0]}: #{tok[1]}, #{tok[2]}"
}
end

def updateData(name, nname, nhobby)
    if !FDatabase.new("database.dat", false).check_exist(name) then
        puts "Data not found"
        return
    end
    db = FDatabase.new("database.dat", true)
    tmp = FDatabase.new("temp.dat", true)

    db.read_file.each {|ln|
        tokz = ln.split ","
        getI = tokz[0].to_i
        getN = tokz[1].chomp
        getH = tokz[2].chomp

        if getN.casecmp? name then
            puts "Data to be updated\n (#{getN}, #{getH}) -> (#{nname}, #{nhobby})"
            if getchoice "Continue?" then
                if db.check_exist "#{nname},#{nhobby}" then
                    puts "Data already existed."
                else
                    getN = nname
                    getH = nhobby
                end
            else
                puts "Abort."
            end
        end

        fmt = "#{getI},#{getN},#{getH}\n"
        tmp.write fmt
    }

    FDatabase.new("database.dat", false).write ""
    tmp.read_file.each {|ln|
    db.write ln
}
    puts "Success."

    FDatabase.new("temp.dat", false).write ""
end

def deleteData(named)
    db = FDatabase.new "database.dat", true
    tmp = FDatabase.new "temp.dat", true
    if !db.check_exist named then
        puts "Data not found"
        return
    end
    counter = 1
    db.read_file.each {|ln|
        tok = ln.split ","
        if tok[1].casecmp? named then
            puts "Data summary\nfrom db: -( #{tok[0]}, #{tok[1].chomp}, #{tok[2].chomp} )"
            if getchoice("Are you sure?") then
                puts "skipped"
                next
            else
                puts "abort"
            end
        end
        fmt = "#{counter},#{tok[1]},#{tok[2]}"
        tmp.write fmt
        counter += 1
}
    FDatabase.new("database.dat", false).write ""
    tmp.read_file.each {|ln|
    db.write ln
}
    FDatabase.new("temp.dat", false).write ""
    puts "Success."
end

cont = true
while cont do
    print "Data Menu:\n1. Create\n2. Read\n3. Update\n4. Delete\n5. Find\n6. Reset\n7. Exit\nChoose: "
    pick = $stdin.gets.chomp.to_i
    case pick
    when 1
        namecr = input("Name: ")
        hobbycr = input("Hobby: ")
        createData(namecr, hobbycr)
    when 2
        readData()
    when 3
        namefi = input("Name: ")
        nname = input("New Name: ")
        nhobby = input("New Hobby: ")
        updateData(namefi, nname, nhobby)
    when 4
        namedl = input("Name: ")
        deleteData(namedl)
    when 5
        namef = input("Name: ")
        db = FDatabase.new "database.dat", true 
        if !db.check_exist namef then
            puts "Data #{namef} do not exist at database."
        else
            tok = db.check_exist(namef, "data")
            puts "#{tok[0]}: #{tok[1]}, #{tok[2]}"
        end
    when 6
        if getchoice "Are you sure you want to erase database data?" then
            FDatabase.new("database.dat", false).write("")
            puts "Success."
        else
            puts "Abort."
        end
    when 7
        exit
    else
        puts "Implementation for #{pick} not found"
    end
    cont = getchoice "Do you want to continue?"
end