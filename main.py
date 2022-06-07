from os.path import exists
class CRUD:
    def __init__(self) -> None:
        if not exists("database.dat"):
            with open("database.dat", "w"):
                pass
        if not exists("temp.dat"):
            with open("temp.dat", "w"):
                pass
    def file_lines(self) -> int:
        with open("database.dat", "r") as f:
            return len(f.readlines())
    def check_exist(self, key: str, directDisplay: bool):
        exist = False
        with open("database.dat", "r") as f:
            for line in f:
                if key.lower() in line.lower():
                    exist = True
                    if directDisplay:
                        tok = line.split(",")
                        return tok
        return exist
    def create_data(self, name, hobby):
        if self.check_exist(name, False):
            print("Data already exist")
            return
        no = self.file_lines() + 1 if self.file_lines() > 0 else 1
        with open("database.dat", "a") as f:
            f.write(f"{no},{name},{hobby}\n")
        print("Data created successfully.")
    def read_data(self):
        with open("database.dat", "r") as f:
            for line in f:
                tok = line.split(",")
                print(f"{tok[0]},{tok[1]},{tok[2]}")
    def get_number(self, name):
        with open("database.dat", "r") as f:
            for line in f:
                tok = line.split(",")
                if name.lower() in tok[1].lower():
                    return tok[0]
        return 0
    def update_data(self, name, nname, nhobby):
        if not self.check_exist(name, False):
            print("Data not found")
            return
        with open("database.dat", "r") as f:
            with open("temp.dat", "a") as f2:
                for line in f:
                    tok = line.split(",")
                    if tok[1].lower() == name.lower():
                        print("""data to be updated:\n
{}: {}, {}
""".format(tok[0], tok[1], tok[2]))
                        print("new data:\n{}, {}".format(nname, nhobby))
                        if self.get_choice("Do you want to update?"):
                            if not self.check_exist(nname, False):
                                f2.write(f"{tok[0]},{nname},{nhobby}\n")
                            else:
                                print("Data already exist")
                                f2.write(line)
                        else:
                            f2.write(line)
                        pass
                    else:
                        f2.write(line)
        with open("database.dat", "w"):
            pass
        with open("temp.dat", "r") as f:
            with open("database.dat", "a") as f2:
                for line in f:
                    f2.write(line)
        with open("temp.dat", "w"):
            pass
    def get_choice(self, t):
        b = input(t + " (y/n): ")
        while b.lower() not in ["y", "n"]:
            print("Invalid input. Please try again.")
            b = input(t + " (y/n): ")
        return b.lower() == "y"

    def delete_data(self, name):
        if not self.check_exist(name, False):
            print("Data {} not found".format(name))
            return
        offset=0
        with open("database.dat", "r") as f:
            with open("temp.dat", "a") as f2:
                for line in f:
                    tok = line.split(",")
                    if tok[1].lower() == name.lower():
                        print("""data to be deleted:\n
{}: {}, {}
""".format(tok[0], tok[1], tok[2]))
                        if self.get_choice("Do you want to delete the data?"):
                            offset+=1
                            print("Skipped as it's marked for deletion.")
                        else:
                            f2.write(line)
                        pass
                    else:
                        a = line.split(",")
                        strFuse = str(int(a[0]) - offset) + "," + a[1] + "," + a[2]
                        f2.write(strFuse)
        with open("database.dat", "w"):
            pass
        with open("temp.dat", "r") as f:
            with open("database.dat", "a") as f2:
                for line in f:
                    f2.write(line)
        with open("temp.dat", "w"):
            pass


    def get_table(self):
        a = input(
            """Menu:
1. Create data
2. Read data
3. Update data
4. Delete data
5. Find data
6. Reset database
7. Exit
choice: """
        )
        no = 0
        try:
            no = int(a)
        except ValueError:
            print("Invalid input")
            self.get_table()
        if no == 1:
            name = input("Name: ")
            hobby = input("Hobby: ")
            self.create_data(name, hobby)
        elif no == 2: self.read_data()
        elif no == 3: self.update_data(input("Name: "), input("New name: "), input("New hobby: "))
        elif no == 4: self.delete_data(input("Name: "))
        elif no == 5:
            name = input("Name: ")
            if self.check_exist(name, False):
                ab = self.check_exist(name, True)
                print("{}: {}, {}".format(ab[0], ab[1], ab[2]))
            else:
                print("Data not found.")
        elif no == 6:
            if self.get_choice("Are you sure?"):
                with open("database.dat", "w"):
                    pass
                print("Database reset successfully.")
            else: print("Database reset cancelled.")
        elif no == 7: exit(0)
        else: print("Not yet implemented.")
        if not self.get_choice("Do you want to continue?"): return
        self.get_table()



def main():
    CRUD().get_table()

if __name__ == "__main__":
    main()
