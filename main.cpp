#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <sstream>


using std::cout, std::cin, std::endl, std::string;
using std::ifstream, std::ofstream;
using std::vector;
using std::ios;
using std::stringstream;

static vector<string> results;
vector<string> tokenize(string str, string delim){
    vector<string> tokens;
    size_t pos = 0;
    string token;
    while ((pos = str.find(delim)) != string::npos) {
        token = str.substr(0, pos);
        tokens.push_back(token);
        str.erase(0, pos + delim.length());
    }
    tokens.push_back(str);
    return tokens;
}
bool contains(string initializer, string a){
        for(int i = 0; i < initializer.length(); i++){
            if(initializer[i] == a[0]){
                if(initializer.substr(i, a.length()) == a){
                    return true;
                }
            }
        }
        return false;
    }
string to_lower(string initializer){
        string lowerCase = "";
        for(int i = 0; i < initializer.length(); i++){
            if(initializer[i] >= 'A' && initializer[i] <= 'Z'){
                lowerCase += initializer[i] + 32;
            }
            else{
                lowerCase += initializer[i];
            }
        }
        return lowerCase;
    }

void createRequiredFiles();
void createData(string name, string hobby);
int fileLines(){
    ifstream data;
    data.open("database.dat", ios::in | ios::binary);
    int lines = 0;
    string line;
    while(std::getline(data, line)){
        lines++;
    }
    data.close();
    return lines;
}
bool checkExist(string key, bool directDisplay);
void clsr();
string getInput(string msg);
bool getChoice(string msg);
int getNumber(string name);
void getTable();
void readData();
void updateData(string oname,string name, string hobby);
void deleteData(string oname);
void resetDb(){
    if(remove("database.dat") == 0){
        cout << "Database reset successfully" << endl;
    }
    else{
        cout << "Database reset failed" << endl;
    }
}

int main(int argc, const char* argv[]){
    createRequiredFiles();
    getTable();
    return 0;
}



void createRequiredFiles(){
    ofstream m;
    ofstream e;
     m.open("database.dat", ios::out | ios::in | ios::binary);
        if (m.is_open()){
        m.close();
        } else {
                m.close();
                m.open("database.dat", ios::trunc | ios::out | ios::in | ios::binary);
        m.close();
        }
e.open("temp.dat", ios::out | ios::in | ios::binary);
        if (e.is_open()){
        e.close();
        } else {
                e.close();
                e.open("temp.dat", ios::trunc | ios::out | ios::in | ios::binary);
        e.close();
        }
}
bool checkExist(string key, bool directDisplay){
    ifstream data;
    data.open("database.dat", ios::in | ios::binary);
    string line;
    bool exist;
    while(std::getline(data, line)){
        if(to_lower(line).find(to_lower(key)) != string::npos){
            exist = true;
            if (directDisplay){
                results = tokenize(line, ",");
            }
        }
    }
    data.close();
 return exist;
}
void clsr(){results.clear();}; 
void createData(string name, string hobby){
    if(checkExist(name, false)){
        cout << "Data already exist" << endl;
    }else{
    ofstream data;
    int no = (fileLines() != 0) ? fileLines()+1 : 1;
    data.open("database.dat", ios::app | ios::binary);
    data << no << "," << name << "," << hobby << endl;
    data.close();
    cout << "Data created." << endl;
    }
}
string getInput(string msg){
    string input;
    cout << msg;
    cin >> input;
    cin.clear();
    cin.ignore();
    return input;
}
bool getChoice(string msg){
    string input;
    cout << msg << " (y/n): ";
    cin >> input;
    while (to_lower(input) != "y" && to_lower(input) != "n"){
        cout << "Invalid input. Please try again." << endl;
        cout << msg << " (y/n): ";
        cin >> input;
    }
    return to_lower(input) == "y";
}
void getTable(){
    cout << "Menu:\n1. Create";
    cout << "\n2. Read\n3. Update\n4. Delete\n5. Find\n6. Reset\n7. Exit\nchoose: ";
    string input;
    cin >> input;
    stringstream d(input);
    int choice;
    d >> choice;
    while(choice < 1 || choice > 7){
        cout << "Invalid input. Please try again." << endl;
        cout << "Menu:\n1. Create";
        cout << "\n2. Read\n3. Update\n4. Delete\n5. Find\n6. Reset\n7. Exit\nchoose: ";
        cin >> input;
        d = stringstream(input);
        d >> choice;
    }
    switch(choice){
        case 1:
        {
                string n = getInput("Name: "), h = getInput("Hobby: ");
                createData(n, h);
        }
        break;
        case 2:
        readData();
        break;
        case 3:
       {
           string name = getInput("Name to search: ");
           string nname = getInput("New name: ");
           string nhobby = getInput("New hobby: ");
            updateData(name, nname, nhobby);
       }
        break;
        case 4:
        {
            string name = getInput("Name to search: ");
            deleteData(name);
        }
        break;
        case 5:
        {
            string name = getInput("Name to search: ");
            if(checkExist(name, true)){
                cout << "Number: "  << results[0] << endl;
                cout << "Name: " << results[1] << endl;
                cout << "Hobby: " << results[2] << endl;
            }
            clsr(); 
        }
        break;
        case 6:
        if(getChoice("Are you sure you want to reset the database?")){
            resetDb();
        }else cout << "abort." << endl;
        break;
        case 7:
        exit(0);
        break;
        default:
        cout << "No matching cases for \"" << choice << "\"" << endl;
        break;
    }
    if(!getChoice("Do you want to continue?"))return;
    getTable();
}
void readData(){
    ifstream data;
    data.open("database.dat", ios::in | ios::binary);
    string line;
    while(std::getline(data, line)){
        results = tokenize(line, ",");
        cout << results[0] << ": " << results[1] << " " << results[2] << endl;
    }
    data.close();
}
int getNumber(string name){
    ifstream data;
    data.open("database.dat", ios::in | ios::binary);
    string line;
    int no = 0;
    while(std::getline(data, line)){
        if(to_lower(line).find(to_lower(name)) != string::npos){
            results = tokenize(line, ",");
            stringstream d(results[0]);
            d >> no;
        }
    }
    data.close();
    clsr();
    return no;
}
void updateData(string oname,string name, string hobby){
    ifstream data; ofstream wr;
    if(checkExist(oname, false)){
        data.open("database.dat", ios::in | ios::binary);
        wr.open("temp.dat", ios::out | ios::in | ios::binary);
        string line;
        int no = getNumber(oname), count = 0;
        while(std::getline(data, line)){
            count++;
            if(count == no){
                vector<string> tok = tokenize(line, ",");
                cout << "Data to be updated: " << tok[1] << " " << tok[2] << endl;
                cout << "New data: " << name << " " << hobby << endl;
                if(getChoice("Are you sure want to update the data?")){
                    if(checkExist(name, false)){
                        cout << "Data already exist" << endl;
                        wr << line << endl;
                    }else{
                    wr << no << "," << name << "," << hobby << endl;
                    }
                }else{
                    wr << line << endl;
                }
                tok.clear();
            }else{
                wr << line << endl;
            }
        }
        data.close();
        wr.close();
        ofstream("database.dat", ios::trunc | ios::out | ios::in | ios::binary).close();
        ifstream tmp; ofstream db;
        tmp.open("temp.dat", ios::in | ios::binary);
        db.open("database.dat", ios::out | ios::in | ios::binary);
        while(std::getline(tmp, line)){
            db << line << endl;
        }
        tmp.close();
        db.close();
        ofstream("temp.dat", ios::trunc | ios::out | ios::in | ios::binary).close();
        cout << "Data updated." << endl;
    }else cout << "Data not found." << endl;
}
void deleteData(string oname){
    ifstream data; ofstream wr;
    if(checkExist(oname, false)){
        data.open("database.dat", ios::in | ios::binary);
        wr.open("temp.dat", ios::out | ios::in | ios::binary);
        string line;
        int no = getNumber(oname), count = 0, offset = 0;
        while(std::getline(data, line)){
            count++;
            if(count == no){
                vector<string> tok = tokenize(line, ",");
                cout << "Data to be deleted: " << tok[1] << " " << tok[2] << endl;
                if(getChoice("Are you sure want to delete the data?")){
                    tok.clear();
                    offset++;
                }else{
                    wr << line << endl;
                }
            }else{
                int num = 0;
                vector<string>tok = tokenize(line, ",");
                stringstream d(tok[0]);
                d >> num;
                wr << num - offset << "," << tok[1] << "," << tok[2] << endl;
                tok.clear();
            }
        }
        data.close();
        wr.close();
        ofstream("database.dat", ios::trunc | ios::out | ios::in | ios::binary).close();
        ifstream tmp; ofstream db;
        tmp.open("temp.dat", ios::in | ios::binary);
        db.open("database.dat", ios::out | ios::in | ios::binary);
        while(std::getline(tmp, line)){
            db << line << endl;
        }
        tmp.close();
        db.close();
        ofstream("temp.dat", ios::trunc | ios::out | ios::in | ios::binary).close();
        cout << "Data deleted." << endl;
    }else cout << "Data not found." << endl;
}
