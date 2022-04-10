import "dart:io";

class CRUD extends Object {
  static List<String> _resultOfCheck = [];
  static List<String> getResult() {
    return _resultOfCheck;
  }

  static void createRequiredFiles() {
    File db = new File("database.dat");
    if (!db.existsSync()) {
      db.createSync();
    }
    File temp = new File("temp.dat");
    if (!temp.existsSync()) {
      temp.createSync();
    }
  }

  static void resetDb() {
    File db = new File("database.dat");
    if (!db.existsSync()) {
      db.createSync();
    } else {
      db.deleteSync();
      db.createSync();
    }
  }

  static bool getChoice(String text) {
    stdout.write(text + " (y/n): ");
    String? choice = stdin.readLineSync();
    while (choice.toString().toLowerCase() != "y" &&
        choice.toString().toLowerCase() != "n") {
      stdout.write(text + " (y/n): ");
      choice = stdin.readLineSync();
    }
    return choice.toString().toLowerCase() == "y";
  }

  static int getNumber(List<String> key) {
    int number = 0;
    File db = new File("database.dat");
    if (db.existsSync()) {
      List<String> data = db.readAsLinesSync();
      for (int i = 0; i < data.length; i++) {
        for (String k in key) {
          if (data[i].toLowerCase().contains(k.toLowerCase())) {
            List<String> num = data[i].split(",");
            number = int.parse(num[0]);
          }
        }
      }
    } else {
      number = 0;
    }
    return number;
  }

  static bool checkData(List<String> key, bool directDisplay) {
    bool exist = false;
    File db = new File("database.dat");
    if (db.existsSync()) {
      List<String> data = db.readAsLinesSync();
      for (int i = 0; i < data.length; i++) {
        for (String k in key) {
          if (data[i].toLowerCase().contains(k.toLowerCase())) {
            if (directDisplay) {
              List<String> amplifier = data[i].split(",");
              for (int j = 0; j < amplifier.length; j++) {
                _resultOfCheck.add(amplifier[j]);
              }
            }
            exist = true;
          }
        }
      }
    } else {
      exist = false;
    }
    return exist;
  }

  static int fileLines(String filename) {
    File file = new File(filename);
    return file.readAsStringSync().split("\n").length;
  }

  static void createData(String name, String hobby) {
    int index = fileLines("database.dat");

    File db = new File("database.dat");
    List<String> k = [name];
    if (CRUD.checkData(k, false)) {
      stdout.writeln("Data already exist!");
      return;
    } else {
      db.writeAsStringSync(index.toString() + "," + name + "," + hobby + "\n",
          mode: FileMode.append);
      print("data created successfully!");
    }
  }

  static String getInput(String text) {
    stdout.write(text);
    String input = stdin.readLineSync().toString();
    return input;
  }

  static void readData() {
    File db = new File("database.dat");
    if (db.existsSync()) {
      List<String> data = db.readAsLinesSync();
      print(
          "--------------------------------------------------------------------------------------------------------");
      print("No \t\t|\t Name \t\t|\t Hobby \t\t\t|");
      print(
          "--------------------------------------------------------------------------------------------------------");
      for (int i = 0; i < data.length; i++) {
        List<String> amplifier = data[i].split(",");
        print(
            "${amplifier[0]} \t\t|\t ${amplifier[1]} \t\t|\t ${amplifier[2]} \t\t|");
      }
      print(
          "--------------------------------------------------------------------------------------------------------");
    } else {
      print("No data found!");
    }
  }

  static void updateData(int no, String nName, String nHobby) {
    File db = new File("database.dat");
    File temp = new File("temp.dat");
    if (db.existsSync()) {
      List<String> data = db.readAsLinesSync();
      for (int i = 0; i < data.length; i++) {
        if (i == no) {
          List<String> amplifier = data[i].split(",");
          print(
              "data to be updated:\n${amplifier[0]}\n${amplifier[1]}\n${amplifier[2]}\n");
          print("new data:\n$nName\n$nHobby\n");
          if (getChoice("Are you sure?")) {
            if (CRUD.checkData([nName + "," + nHobby], false)) {
              stdout.writeln("Data already exist!");
              return;
            }
            temp.writeAsStringSync("${amplifier[0]},$nName,$nHobby\n",
                mode: FileMode.append);
          } else {
            temp.writeAsStringSync(
                "${amplifier[0]},${amplifier[1]},${amplifier[2]}\n",
                mode: FileMode.append);
          }
        } else {
          temp.writeAsStringSync(data[i] + "\n", mode: FileMode.append);
        }
      }
      db.writeAsStringSync("", mode: FileMode.write);
      List<String> tempLines = temp.readAsLinesSync();
      for (int i = 0; i < tempLines.length; i++) {
        db.writeAsStringSync(tempLines[i] + "\n", mode: FileMode.append);
      }
      print("data updated successfully");
      temp.writeAsStringSync("", mode: FileMode.write);
    } else {
      db.createSync();
      print("database not found creating new instance");
    }
  }

  static void deleteData(int no) {
    File db = new File("database.dat");
    File temp = new File("temp.dat");
    int offset = 0;
    if (db.existsSync()) {
      List<String> data = db.readAsLinesSync();
      for (int i = 0; i < data.length; i++) {
        if (i == no) {
          List<String> ampl = data[i].split(",");
          print("data to be deleted:\n${ampl[0]}\n${ampl[1]}\n${ampl[2]}\n");
          if (getChoice("Are you sure?")) {
            print("Skipped as it will be deleted.");
            offset++;
            continue;
          } else {
            temp.writeAsStringSync("${ampl[0]},${ampl[1]},${ampl[2]}\n",
                mode: FileMode.append);
          }
        } else {
          List<String> amp = data[i].split(",");
          int n = int.parse(amp[0]) - offset;
          String s = n.toString() + "," + amp[1] + "," + amp[2] + "\n";
          temp.writeAsStringSync(s, mode: FileMode.append);
        }
      }
      db.writeAsStringSync("", mode: FileMode.write);
      List<String> tempLines = temp.readAsLinesSync();
      for (int i = 0; i < tempLines.length; i++) {
        db.writeAsStringSync(tempLines[i] + "\n", mode: FileMode.append);
      }
      print("data deleted successfully");
      temp.writeAsStringSync("", mode: FileMode.write);
    } else {
      db.createSync();
      print("database not found creating new instance");
    }
  }

  static void findData(String name) {
    if (CRUD.checkData([name], true)) {
      print("data found, collecting data...");
      List<String> data = getResult();
      print(
          "--------------------------------------------------------------------------------------------------------");
      print("No \t\t|\t Name \t\t|\t Hobby \t\t\t|");
      print(
          "--------------------------------------------------------------------------------------------------------");
      print("${data[0]} \t\t|\t ${data[1]} \t\t|\t ${data[2]} \t\t|");
      print(
          "--------------------------------------------------------------------------------------------------------");
      _resultOfCheck.clear();
    } else {
      print("data not found");
    }
  }

  static void getTable() {
    int choice = 0;
    stdout.write(
        "Options:\n1. Create \n2. Read \n3. Update \n4. Delete \n5. Search \n6. Reset \n7. Exit\nchoose: ");
    try {
      choice = int.parse(stdin.readLineSync().toString());
    } catch (e) {
      stdout.writeln("Invalid input, expected number but got string");
      getTable();
    }
    switch (choice) {
      case 1:
        String name = getInput("Put name: ");
        String hobby = getInput("Put hobby: ");
        createData(name, hobby);
        break;
      case 2:
        readData();
        break;
      case 3:
        String name = getInput("Put name: ");
        String nName = getInput("Put new name: ");
        String nHobby = getInput("Put new hobby: ");
        int no = getNumber([name]) - 1;
        updateData(no, nName, nHobby);
        break;
      case 4:
        String name = getInput("Put name: ");
        int no = getNumber([name]) - 1;
        deleteData(no);
        break;
      case 5:
        String name = getInput("Put name: ");
        findData(name);
        break;
      case 6:
        if (getChoice(
            "Do you want to reset database? (your previous data will be lost)")) {
          resetDb();
          stdout.writeln("Database reset successfully!");
        } else {
          stdout.writeln("Database reset aborted!");
        }
        break;
      case 7:
        exit(0);
      default:
        print("No matching case for: \"${choice}\"");
        break;
    }
    bool isContinue = CRUD.getChoice("Continue?");
    if (isContinue) {
      getTable();
    } else {
      return;
    }
  }
}

void main(List<String> args) {
  CRUD.getTable();
}
