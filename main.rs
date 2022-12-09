use std::io::{self, stdin, Write};
use std::fs::{self, File};
use std::io::Read;
use std::format;

struct CRUDTools{
    fname: String,
}

impl CRUDTools{
    fn new(fname: &str) -> CRUDTools{
        if !std::path::Path::new(fname).exists(){
            File::options().write(true).create(true)
            .open(fname)
            .expect("Failed to create file.");
        }
        CRUDTools { fname: (String::from(fname))}
    }
    fn safe_write(&self, content: &str, app: Option<bool>) -> io::Result<String>{
        let mut msg= String::from("OP_SUCCESS");
        let append = app.unwrap_or(false);
        if append{
            let resf = File::options().append(true).create(true).open(&self.fname);
            match resf{
                Ok(mut fw) => {
                    let resx = fw.write(content.as_bytes());
                    match resx{
                        Ok(_unused) => (),
                        Err(valerr) => msg = valerr.to_string()
                    }
                },
                Err(err) => msg = err.to_string()
            }
        
        }else{
            let resf = fs::write(&self.fname, content);
            match resf{
                Ok(_n) => (),
                Err(data) => msg = data.to_string()
            }
        }
        Ok(msg)
    }

    fn read_data(&self, buffer: &mut String) -> io::Result<String>{
        let mut op_suc = String::from("OP_SUCCESS");
        let fx = File::open(&self.fname);
        let mut buf = String::new();
        match fx{
            Ok(mut fr) => {
                match fr.read_to_string(&mut buf){
                    Ok(_data) => (),
                    Err(dt) => op_suc = dt.to_string()
                }
            },
            Err(n) => op_suc = n.to_string()
        }
        *buffer = buf.to_owned();
        Ok(op_suc)
    }

    fn is_data_exist(&self, key: &str) -> bool{
        let mut data = String::new();
        let mut exist = false;
        self.read_data(&mut data).unwrap();
        for i in data.lines(){
            if i.to_lowercase().contains(&key.to_lowercase()){
                exist = true;
            }
        }
        exist
    }

    fn index_at(&self) -> usize{
        let mut buf = String::new();
        self.read_data(&mut buf).unwrap();
        buf.lines().count() + 1
    }
}

impl CRUDTools{
    #[allow(unused_must_use)]
    fn readline() -> String{
    let mut buff = String::new();
        stdin().read_line(&mut buff);
        buff.trim().to_string()
    }
    fn print_first(text: &str){
        print!("{}", text);
        io::stdout().flush().expect("Flushing failed.");
    }
}

fn main() -> io::Result<()>{
    let mut iscont = true;
    
    while iscont{
        CRUDTools::print_first("Menu
1. Add Data
2. Read Data
3. Update Data
4. Delete Data
5. Find Data
6. Reset Data
7. Non-successful exit
Choose: ");
        let pick = CRUDTools::readline().as_str().parse::<i8>().unwrap_or(7);
        match pick{
            1 => {
                CRUDTools::print_first("Name: ");
                let user = CRUDTools::readline();
                CRUDTools::print_first("Hobby: ");
                let hobby = CRUDTools::readline();
                if !add_data(user, hobby).unwrap(){
                    eprintln!("Problem creating data.");
                }
            },
            2 => {
                show_data();
            },
            3 => {
                CRUDTools::print_first("Name: ");
                let user = CRUDTools::readline();
                CRUDTools::print_first("New Name: ");
                let nuser = CRUDTools::readline();
                CRUDTools::print_first("New Hobby: ");
                let nhobby = CRUDTools::readline();
                update_data(user, nuser, nhobby);
            },
            4 => {
                let checker = CRUDTools::new("temp.dat");
                if checker.index_at().ne(&0){
                    let trunc = checker.safe_write("", None).unwrap();
                    if trunc.ne("OP_SUCCESS"){
                        eprintln!("Problem truncating temp: {trunc}");
                        continue;
                    }
                }
                CRUDTools::print_first("Name: ");
                let user = CRUDTools::readline();
                delete_data(user.as_str());
            },
            5 => {
                CRUDTools::print_first("Name: ");
                let user = CRUDTools::readline();
                let reader = CRUDTools::new("database.dat");
                if !reader.is_data_exist(user.as_str()){
                    println!("Not Found");
                    continue;
                }
                let mut buff = String::new();
                let strx = reader.read_data(&mut buff).unwrap();
                if strx.ne("OP_SUCCESS"){
                    eprintln!("Problem reading data: {strx}");
                }else{
                    for i in buff.lines(){
                        if i.to_lowercase().contains(&user.to_lowercase()){
                        let datax = i.split(",").collect::<Vec<&str>>();
                        println!("{}: {} {}", datax[0], datax[1], datax[2]);
                        }
                    }
                }
            },
            6 => {
                let writer = CRUDTools::new("database.dat");
                CRUDTools::print_first("Are you sure you want to reset database? (Y/N): ");
                if CRUDTools::readline().to_lowercase().chars().nth(0).eq(&Some('y')){
                    let msg = writer.safe_write("", None).unwrap();
                    if !msg.eq("OP_SUCCESS"){
                        eprintln!("Failed to truncate: {msg}");
                    }else{
                        println!("Successfully truncated database.");
                    }
                }else {println!("Abort.");}
            },
            7 => {
                std::process::exit(0);
            },
            _ => eprintln!("Not found for: {pick}")
        }
        CRUDTools::print_first("Do you want to continue? (Y/N): ");
        iscont = !CRUDTools::readline().to_lowercase().chars().nth(0).eq(&Some('n'));
    }
    Ok(())
}
#[allow(unused_assignments)]
fn add_data(user: String, hobby: String) -> io::Result<bool>{
    let mut operation_id = String::from("OP_SUCCESS");
    let writer = CRUDTools::new("database.dat");
    let mut success = true;
    if writer.is_data_exist(format!("{user},{hobby}").as_str()){
        println!("Data already existed.");
    }else{
        let formed = format!("{},{},{}\n", writer.index_at(), user, hobby);
        operation_id = writer.safe_write(formed.as_str(), Some(true)).unwrap();
        if operation_id.ne(&"OP_SUCCESS"){
            eprintln!("Having problem whilst adding data: {operation_id}");
            success = false;
        }else{
            println!("Successfully added new data.");
        }
    }
    Ok(success)
}

fn show_data(){
    let mut buf = String::new();
    let op_id = CRUDTools::new("database.dat").read_data(&mut buf).unwrap();
    if !op_id.eq("OP_SUCCESS"){
        eprintln!("Problem reading: {op_id}");
    }else{
        for i in buf.lines(){
            let spl = i.split(",").collect::<Vec<&str>>();
            println!("{}: {}, {}", spl[0], spl[1], spl[2]);
        }
    }
}

fn update_data(key: String, name: String, hobby: String){
    let iodb = CRUDTools::new("database.dat");
    let iotmp = CRUDTools::new("temp.dat");

    if !iodb.is_data_exist(key.as_str()){
        println!("Not found.");
    }else{
        let mut datadb = String::new();
        let mut datatmp = String::new();
        let msgread1 = iodb.read_data(&mut datadb).unwrap();
        if msgread1 != "OP_SUCCESS"{
            eprintln!("Operation Update failed: {msgread1}");
        }else{
            for i in datadb.lines(){
                if i.to_lowercase().contains(key.to_lowercase().as_str()){
                    let sp = i.split(",").collect::<Vec<&str>>();
                    println!("Data to be updated:\n {}: {} {}\n", sp[0], sp[1], sp[2]);
                    let idx = sp[0].parse::<usize>().unwrap_or(1);
                    CRUDTools::print_first("Continue? (Y/N): ");
                    if CRUDTools::readline().to_lowercase().chars().nth(0).eq(&Some('y')){
                        let fmtd = format!("{idx},{name},{hobby}");
                        if iodb.is_data_exist(fmtd.as_str()){
                            println!("Data existed.");
                            let dx = iotmp.safe_write(format!("{i}\n").as_str(), Some(true)).unwrap();
                            if dx.ne("OP_SUCCESS"){eprintln!("{dx}");}
                        }else{
                            let dx = iotmp.safe_write(fmtd.as_str(), Some(true)).unwrap();
                            if dx.ne("OP_SUCCESS"){eprintln!("{dx}");}
                        }
                    }else {
                        let dx = iotmp.safe_write(format!("{i}\n").as_str(), Some(true)).unwrap();
                        if dx.ne("OP_SUCCESS"){eprintln!("{dx}");}
                    }
                }else {
                let dx = iotmp.safe_write(format!("{i}\n").as_str(), Some(true)).unwrap();
                if dx.ne("OP_SUCCESS"){eprintln!("{dx}");}
            }
            }
            iodb.safe_write("", None).unwrap();
            let msgread2 = iotmp.read_data(&mut datatmp).unwrap();
            if msgread2.ne("OP_SUCCESS"){
                eprintln!("Operation Update failed: {msgread2}");
            }else{
                for i in datatmp.lines(){
                    let dx = iodb.safe_write(format!("{i}\n").as_str(), Some(true)).unwrap();
                    if dx.ne("OP_SUCCESS"){eprintln!("{dx}");}
                }
            }
            iotmp.safe_write("", None).unwrap();
        }
    }
}

fn delete_data(user: &str){
    let iodb = CRUDTools::new("database.dat");
    let iotmp = CRUDTools::new("temp.dat");
    if !iodb.is_data_exist(user){
        println!("Not Found.");
    }else{
        let mut datadb = String::new();
        let mut datatmp = String::new();
        let mut counter: usize = 1;
        
        let op_msg = iodb.read_data(&mut datadb).unwrap();
        if op_msg.ne("OP_SUCCESS"){
            eprintln!("Problem reading data: {op_msg}");
        }else{
            for i in datadb.lines(){
                let kdata = i.split(",").collect::<Vec<&str>>();
                let kidx = counter;
                let kname = kdata[1];
                let khobby = kdata[2];
                if i.to_lowercase().contains(&user.to_lowercase()){
                    println!("Data to be deleted:\n {}: {} {}", kidx, kname, khobby);
                    CRUDTools::print_first("Continue? (Y/N): ");
                    if CRUDTools::readline().to_lowercase().chars().nth(0).eq(&Some('y')){
                        println!("Deleted.");
                        continue;
                    }else{
                        println!("Abort.");
                    }
                }
                counter+=1;
                let wrmsg = iotmp.safe_write(format!("{kidx},{kname},{khobby}\n").as_str(), Some(true)).unwrap();
                if wrmsg.ne("OP_SUCCESS"){
                    eprintln!("Problem writing data: {wrmsg}");
                }
            }
            let wrmsg = iodb.safe_write("", None).unwrap();
            if wrmsg.ne("OP_SUCCESS"){
                eprintln!("Problem truncating data: {wrmsg}");
            }else{
                let rdmsg = iotmp.read_data(&mut datatmp).unwrap();
                if rdmsg.ne("OP_SUCCESS"){
                    eprintln!("Problem reading Temporary file: {rdmsg}");
                }else{
                    for i in datatmp.lines(){
                        let wrdmsg = iodb.safe_write(format!("{i}\n").as_str(), Some(true)).unwrap();
                        if wrdmsg.ne("OP_SUCCESS"){
                            eprintln!("Problem writing to database: {wrdmsg}");
                        }
                    }
                }
                let wrtmsg = iotmp.safe_write("", None).unwrap();
                if wrtmsg.ne("OP_SUCCESS"){
                    eprintln!("Problem truncating data: {wrtmsg}");
                }else{
                    println!("Successfully Deleted data from database.");
                }
            }
        }
    }
}