package com.project.CRUD;
import java.io.*;
import java.util.*;


public class MainFunctions {
    private static final Scanner sc = new Scanner(System.in);
    private static final String nLine = System.lineSeparator();
    @SuppressWarnings("MismatchedQueryAndUpdateOfCollection")
    private final ArrayList<String> result = new ArrayList<String>();
    public MainFunctions(){
        try {
            File f = new File("database.dat");
            File d = new File("temp.dat");
            if (!f.exists()) //noinspection ResultOfMethodCallIgnored
                f.createNewFile();
            if (!d.exists()) //noinspection ResultOfMethodCallIgnored
                d.createNewFile();
        }catch(Exception e){
            System.err.println("Unable to create required files. Error:");
            e.printStackTrace();
        }
    }

    // StringTokenizer was too complex.
    private String[] tokenize(String t, String delim){
        final ArrayList<String> s = new ArrayList<String>();
        StringTokenizer st = new StringTokenizer(t, delim);
        while(st.hasMoreTokens())s.add(st.nextToken());
        return Arrays.copyOf(s.toArray(), s.toArray().length, String[].class);
    }

    private String getInput(String t){
        System.out.print(t);
        return sc.next();
    }

    private boolean getChoice(String t){
        System.out.print(t + " (y/n): ");
        String choice = sc.next();
        while(!choice.equalsIgnoreCase("y") && !choice.equalsIgnoreCase("n")){
            System.out.println("Invalid input. Try again.");
            System.out.print(t + " (y/n): ");
            choice = sc.next();
        }
        return choice.equalsIgnoreCase("y");
    }

    private boolean checkExist(String key, boolean directDisplay) throws IOException{
        boolean isExist = false;
        BufferedReader br = new BufferedReader(new FileReader("database.dat"));
        String l;
        while((l = br.readLine())!= null){
            if(l.toLowerCase().contains(key.toLowerCase())){
                isExist=true;
                if(directDisplay){
                    String[] b = tokenize(l, ",");
                    result.add(b[0]);
                    result.add(b[1]);
                    result.add(b[2]);
                }
            }
        }
        br.close();
        return isExist;
    }

    private int fileLines() throws IOException{
        BufferedReader br = new BufferedReader(new FileReader("database.dat"));
        int count = 0;
        String l = "";
        while((l = br.readLine()) != null){
            count++;
        }
        return count;
    }

    private void createData(String name, String hobby){
        try {
            if (checkExist(name, false)) {
                System.err.println("That name already existed.");
                return;
            }
            int no = fileLines() != 0 ? fileLines() + 1 : 1;
            BufferedWriter bw = new BufferedWriter(new FileWriter("database.dat", true));
            bw.write(no+","+name+","+hobby);
            bw.newLine();
            bw.flush();
            bw.close();
            System.out.println("Data created.");
        }catch(Exception e){
            System.err.println("Failed to create data, error:");
            e.printStackTrace();
        }
    }

    private void readData(){
        try {
            BufferedReader br = new BufferedReader(new FileReader("database.dat"));
            String l = "";
            while((l = br.readLine()) != null){
                String[] b = tokenize(l, ",");
                System.out.printf("%s: %s, %s", b[0], b[1], b[2]);
                System.out.println();
            }
            br.close();
        }catch(Exception e){
            System.err.println("Unable to read data, error: ");
            e.printStackTrace();
        }
    }

    private void updateData(String name, String nName, String nHobby){
        try {
            if (!checkExist(name, false)) {
                System.out.println("No data found for \"" + name + "\".");
                return;
            }
            int no = getNumber(name), count = 0;
            BufferedReader br_d = new BufferedReader(new FileReader("database.dat"));
            BufferedWriter bw_t = new BufferedWriter(new FileWriter("temp.dat", true));
            String line = "";
            while((line = br_d.readLine()) != null){
                count++;
                if(count == no){
                    String[] b = tokenize(line, ",");
                    System.out.printf(
                            "Data to be updated:%s %s: %s, %s",
                            nLine, b[0], b[1], b[2]
                    );
                    System.out.println();
                    System.out.printf("New data:%s %s, %s", nLine, nName, nHobby);
                    System.out.println();
                    if(getChoice("Are you sure want to update data?")){
                        if(checkExist(nName, false)){
                            System.err.println("Data already existed.");
                            bw_t.write(line);
                            bw_t.newLine();
                        }else{
                            bw_t.write(b[0] + "," + nName + "," + nHobby);
                            bw_t.newLine();
                        }
                    }else{
                        bw_t.write(line);
                        bw_t.newLine();
                    }
                }else{
                    bw_t.write(line);
                    bw_t.newLine();
                }
            }
            bw_t.flush();
            bw_t.close();
            br_d.close();
            new FileWriter("database.dat").close();
            BufferedReader br_t = new BufferedReader(new FileReader("temp.dat"));
            BufferedWriter bw_d = new BufferedWriter(new FileWriter("database.dat", true));
            while((line = br_t.readLine()) != null){
                bw_d.write(line);
                bw_d.newLine();
            }
            bw_d.flush();
            bw_d.close();
            br_t.close();
            new FileWriter("temp.dat").close();
            System.out.println("data updated successfully.");
        }catch(Exception e){
            System.err.println("Failed to read data, error: ");
            e.printStackTrace();
        }
    }

    private int getNumber(String n) throws Exception{
        if(!checkExist(n, true))return 0;
        int a = Integer.parseInt(result.get(0));
        result.clear();
        return a;
    }

    private int resetDb(){
        try{
            new FileWriter("database.dat").close();
        }catch(Exception e){
            e.printStackTrace();
            return 1;
        }
        return 0;
    }

    private void deleteData(String name){
        try {
            if (!checkExist(name, false)) {
                System.out.println("No data found for \"" + name + "\".");
                return;
            }
            int no = getNumber(name), count = 0, offset = 0;
            BufferedReader br_d = new BufferedReader(new FileReader("database.dat"));
            BufferedWriter bw_t = new BufferedWriter(new FileWriter("temp.dat", true));
            String line = "";
            while((line = br_d.readLine()) != null){
                count++;
                if(count == no){
                    String[] b = tokenize(line, ",");
                    System.out.printf(
                            "Data to be deleted:%s %s: %s, %s",
                            nLine, b[0], b[1], b[2]
                    );
                    System.out.println();
                    if(getChoice("Are you sure want to delete data?")){
                        System.out.println("Skipped as it's marked to be deleted.");
                        offset++;
                    }else{
                        bw_t.write(line);
                        bw_t.newLine();
                    }
                }else{
                    String[] tok = tokenize(line, ",");
                    String mStr = Integer.parseInt(tok[0]) - offset + "," + tok[1] + "," + tok[2];
                    bw_t.write(mStr);
                    bw_t.newLine();
                }
            }
            bw_t.flush();
            bw_t.close();
            br_d.close();
            new FileWriter("database.dat").close();
            BufferedReader br_t = new BufferedReader(new FileReader("temp.dat"));
            BufferedWriter bw_d = new BufferedWriter(new FileWriter("database.dat", true));
            while((line = br_t.readLine()) != null){
                bw_d.write(line);
                bw_d.newLine();
            }
            bw_d.flush();
            bw_d.close();
            br_t.close();
            new FileWriter("temp.dat").close();
            System.out.println("data deleted successfully.");
        }catch(Exception e){
            System.err.println("Failed to read data, error: ");
            e.printStackTrace();
        }
    }

    private void searchData(String key){
        try{
            if(!checkExist(key, true)){
                System.out.println("Data \"" + key + "\" not found.");
                return;
            }
            System.out.printf("%s: %s, %s%s", result.get(0), result.get(1), result.get(2), nLine);
            result.clear();
        }catch(Exception e){
            System.err.println("Unable to read data, error:");
            e.printStackTrace();
        }
    }

    public void getTable(){
        System.out.print(
            "Menu:"+nLine
            +"1. Create Data"+nLine+"2. Read Data" +nLine + "3. Update Data" + nLine
            + "4. Delete Data" + nLine + "5. Find Data" + nLine + "6. Reset Database"
            + nLine + "7. Exit" + nLine + "Choose: "
        );
        int no = sc.nextInt();
        while(no < 0 || no > 7){
            System.err.println("Invalid input, try again.");
            System.out.print(
                    "Menu:"+nLine
                            +"1. Create Data"+nLine+"2. Read Data" +nLine + "3. Update Data" + nLine
                            + "4. Delete Data" + nLine + "5. Find Data" + nLine + "6. Reset Database"
                            + nLine + "7. Exit" + nLine + "Choose: "
            );
            no = sc.nextInt();
        }
        switch (no) {
            case 1 -> createData(getInput("Name: "), getInput("Hobby: "));
            case 2 -> readData();
            case 3 -> updateData(getInput("Name: "), getInput("New name: "), getInput("New hobby: "));
            case 4 -> deleteData(getInput("Name: "));
            case 5 -> searchData(getInput("Name: "));
            case 6 -> {
                if (getChoice("Are you sure want to reset database? (any saved data will be lost)")) {
                    if (resetDb() != 0) System.err.println("Failed to reset data.");
                    else System.out.println("Data reset successfully.");
                }else System.out.println("Abort.");
            }

            case 7 -> System.exit(0);
            default -> System.out.println("Not yet implemented.");
        }
        if(!getChoice("Do you want to continue?")){
            return;
        }
        getTable();
    }

}
