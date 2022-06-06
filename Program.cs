namespace Index
{
    internal class Program
    {
        public static void Main(string[] args)
        {
            Task.Run(() => new MainFunctions().GetTable()).GetAwaiter().GetResult();
        }
    }

    class MainFunctions
    {
        private readonly List<String> result = new List<String>();
        public MainFunctions()
        {
            if (File.Exists("database.dat")) return;
            FileStream a = new FileStream("database.dat", FileMode.OpenOrCreate);
            a.Close();
            if (File.Exists("temp.dat")) return;
            FileStream t = new FileStream("temp.dat", FileMode.OpenOrCreate);
            t.Close();
        }
        private bool GetChoice(string str)
        {
            Console.Write(str + " (y/n): ");
            string d = Convert.ToString(Console.ReadLine()) ?? "n";
            while (d.ToLower() != "y" && d.ToLower() != "n")
            {
                Console.WriteLine("Wrong input, please try again.");
                Console.Write(str + " (y/n): ");
                d = Convert.ToString(Console.ReadLine()) ?? "n";
            }
            return d.ToLower() == "y";
        }
        private string GetInput(string str)
        {
            Console.Write(str);
            string? m = Console.ReadLine();
            return m ?? "null";
        }
        private int FileLines()
        {
            return File.ReadAllLines("database.dat").Length;
        }
        private async Task<bool> CheckExist(string key, bool directDisplay)
        {
            bool exist = false;
            string[] b = File.ReadAllLines("database.dat");
            foreach(var a in b)
            {
                if (a.ToLower().Contains(key.ToLower()))
                {
                    exist = true;
                    if (directDisplay)
                    {
                        string[] tok = a.Split(",");
                        result.Add(tok[0]);
                        result.Add(tok[1]);
                        result.Add(tok[2]);
                    }
                }
            }
            return await Task.Run(() =>exist);
        }
        private void Clsr() { result .Clear(); }
        private List<String> GetResult() { return result; }
        private int GetNumber(string key)
        {
            int no = 0;
            using (FileStream f = new FileStream("database.dat", FileMode.Open))
            {
                using (StreamReader sr = new StreamReader(f))
                {
                    string? l;
                    while ((l = sr.ReadLine()) != null)
                    {
                        try
                        {
                            if (Convert.ToString(l).ToLower().Contains(key.ToLower()))
                            {
                                string[] d = l.Split(",");
                                no = Convert.ToInt32(d[0]);
                            }
                        }catch(Exception e)
                        {
                            Console.WriteLine(e.Data);
                            return 0;
                        }
                    }
                };
            }

                return no;
        }

        private void CreateData(string name, string hobby)
        {
            int startNo = this.FileLines() != 0 ? this.FileLines() + 1 : 1;
            if (this.CheckExist(name, false).Result)
            {
                Console.WriteLine("Data already existed");
                return;
            }
            FileStream fs = new FileStream("database.dat", FileMode.Append);
            using(StreamWriter sw = new StreamWriter(fs))
            {
                sw.Write(startNo + "," + name + "," + hobby);
                sw.Write(Environment.NewLine);
                sw.Flush();
            }
            fs.Close();
            Console.WriteLine("Data created successfully");
        }
        private void ReadData()
        {
            FileStream a = new FileStream("database.dat", FileMode.Open);
            using(StreamReader sr =new StreamReader(a))
            {
                string? line = "";
                while((line = sr.ReadLine()) != null)
                {
                    string[] dt = line.Split(",");
                    if (dt.Length < 0) continue;
                    else Console.WriteLine(dt[0] + ": " + dt[1] + ", " + dt[2]);
                }
            }
            a.Close();
        }
        public async Task GetTable()
        {
            Console.Write("Menu:\n1. Create\n2. Read\n3. Update\n4. Delete\n5. Find \n6. Reset \n7. Exit\nChoose: ");
            int choice = Convert.ToInt32(Console.ReadLine());
            while(choice < 1 || choice > 7)
            {
                Console.WriteLine("Invalid Input, try again.");
                Console.Write("Menu:\n1. Create\n2. Read\n3. Update\n4. Delete\n5. Find \n6. Reset \n7. Exit\nChoose: ");
                choice = Convert.ToInt32(Console.ReadLine());
            }
            switch (choice)
            {
                case 1:
                    this.CreateData(this.GetInput("Name: "), this.GetInput("Hobby: "));
                break;
                case 2:
                    this.ReadData();
                    break;
                case 3:
                    await this.UpdateData(this.GetInput("Name: "),
                    this.GetInput("New name: "), this.GetInput("New hobby: "));
                    break;
                case 4:
                    await this.DeleteData(this.GetInput("Name: "));
                    break;
                case 5:
                    if(await this.CheckExist(this.GetInput("Name: "), true))
                    {
                        string f = String.Format("{0}: {1}, {2}", result[0], result[1], result[2]);
                        Console.WriteLine(f);
                        this.Clsr();
                    }
                    else
                    {
                        Console.WriteLine("Data not found.");
                    }
                    break;
                case 6:
                    if (this.GetChoice("Are you sure want to reset? your previous data will be gone"))
                    {
                        this.ResetDb();
                    }
                    else Console.WriteLine("Abort.");
                    break;
                default:
                    Console.WriteLine("Not yet implemented.");
                    break;
            }
            if(this.GetChoice("Do you want to continue?"))
            {
                await this.GetTable();
            }
            else
            {
                Environment.Exit(0);
            }
        }
        private void ResetDb()
        {
            new FileStream("database.dat", FileMode.Truncate).Close();
        }
        private async Task UpdateData(string oname, string nname, string nhobby)
        {
            if (!await this.CheckExist(oname, false))
            {
                Console.WriteLine("Data \"" + oname + "\" Not found");
                return;
            }
            int no = this.GetNumber(oname), count = 0;
            string[] db_r = File.ReadAllLines("database.dat");
            foreach(var d in db_r)
            {
                count++;
                if (count == no)
                {
                    string[] a = d.Split(",");
                    string ab = String.Format("Data to be updated:\n {0}: {1}, {2}", a[0], a[1], a[2]);
                    Console.WriteLine(ab);
                    ab = String.Format("New data:\n {0}, {1}", nname, nhobby);
                    Console.WriteLine(ab);
                    if (GetChoice("Do you want to continue?"))
                    {
                        if (await CheckExist(nname, false))
                        {
                            Console.WriteLine("Name already exist");
                            File.AppendAllText("temp.dat", d + Environment.NewLine);
                        }
                        else
                        {
                            File.AppendAllText("temp.dat", a[0] + "," + nname + "," + nhobby + Environment.NewLine);
                        }
                    }
                    else File.AppendAllText("temp.dat",d + Environment.NewLine);
                }
                else
                {
                    File.AppendAllText("temp.dat", d + Environment.NewLine);
                }
            }
            new FileStream("database.dat", FileMode.Truncate).Close();
            string[] tmp_r = File.ReadAllLines("temp.dat");
            foreach(var b in tmp_r)
            {
                File.AppendAllText("database.dat", b + Environment.NewLine);
            }
            new FileStream("temp.dat", FileMode.Truncate).Close();
            Console.WriteLine("Data updated.");
        }
        private async Task DeleteData(string name)
        {
            if(!await CheckExist(name, false))
            {
                Console.WriteLine("Data \"" + name + "\" does not exist on database.");
                return;
            }
            int no = this.GetNumber(name), count = 0, offset=0;
            string[] db_r = File.ReadAllLines("database.dat");
            foreach(var o in db_r)
            {
                count++;
                if(count == no)
                {
                    string[] tok = o.Split(",");
                    string d = String.Format("Data to be deleted:\n{0}: {1}, {2}", tok[0], tok[1], tok[2]);
                    Console.WriteLine(d);
                    if(GetChoice("Are you sure want to delete the data?"))
                    {
                        offset++;
                        Console.WriteLine("Skipped as it's marked to be deleted.");
                        continue;
                    }
                    else
                    {
                        File.AppendAllText("temp.dat",o + Environment.NewLine);
                    }
                }
                else
                {
                    string[] tok = o.Split(",");
                    int num = Convert.ToInt32(tok[0]);
                    string str = String.Format("{0},{1},{2}", num - offset, tok[1], tok[2]);
                    File.AppendAllText("temp.dat", str + Environment.NewLine);
                }
            }
            new FileStream("database.dat", FileMode.Truncate).Close();
            string[] tmp_r = File.ReadAllLines("temp.dat");
            foreach(var ob in tmp_r)
            {
                File.AppendAllText("database.dat", ob + Environment.NewLine);
            }
            new FileStream("temp.dat", FileMode.Truncate).Close();
            Console.WriteLine("Data deleted.");
        }
    }
}
