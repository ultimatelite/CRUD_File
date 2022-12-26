#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <stdio.h>

#define BUF_MIN 1024
#define READ_BUF_MIN 100
#define READ_BUF_MAX 10240

void err(char* s){
    perror(s);
    exit(1);
}

void free_string(char** x, size_t sz){
    for(int i = 0; i < sz; i++){
        free(x[i]);
    }
    free(x);
}

char* strlwr(const char* str){
    size_t sz = strlen(str);
    char* all = (char*)malloc(sz + 1);
    for(int i = 0; i < sz; i++){
        all[i] = tolower(str[i]);
    }
    all[sz] = '\0';
    return all;
}

void init_strings(size_t size, size_t buf, char*** arg){
    *arg = (char**)calloc(size, sizeof(char*));
    for(int i = 0; i < size; i++){
        (*arg)[i] = (char*)calloc(buf, sizeof(char));
    }
}

char** tokenize(char* str, char* delim, size_t rep){
    char** arrays;
    init_strings(rep, BUF_MIN, &arrays);
    
    char *token = (char *)malloc(strlen(str) + 1);
    strcpy(token, str);
    token[strlen(str)] = '\0';

    char *tok = strtok(token, delim);
    size_t i = 0;
    while(tok != NULL){
            memcpy((char*)arrays[i++], tok, strlen(tok));
            tok = strtok(NULL, delim);
    }
    free(token);
    return arrays;
}

typedef struct Db{
    size_t buffer;
    FILE* file;
} Database;

Database* database_init(char* fname, int app){
    Database* db = (Database*)malloc(sizeof(Database));
    db->buffer = BUF_MIN;

    FILE* f = fopen(fname, (app) ? "a+" : "w+");
    if(f == NULL)err("File creation failed");
    db->file = f;
    return db;
}
void database_write(Database* db, char* content){
    fprintf(db->file, content);
    fflush(db->file);
    rewind(db->file);
}

void database_destroy(Database* db){
    fclose(db->file);
    free(db);
}

size_t database_index(Database* db){
    size_t i = 0;
    char* s = (char*)malloc(db->buffer);
    FILE* fp = db->file;
    while(fgets(s, db->buffer, fp) != NULL)i++;
    free(s);
    rewind(db->file);
    return i;
}

char* database_read(Database* db){
    char* str = (char*)malloc(db->buffer);
    char* ret = (char*)malloc(db->buffer);
    strcpy(ret, "");
    FILE* fp = db->file;
    while(fgets(str, db->buffer, fp) != NULL){
        strcat(ret, str);
    }
    free(str);
    rewind(db->file);
    return ret;
}

int database_data_exist(Database* db, char* key){
    size_t sz = database_index(db);
    char* x = database_read(db);
    char** fz = tokenize(x, "\n", sz);
    char* lwr = strlwr(key);
    int exist = 0;
    for(int i = 0; i < sz; i++){
        char* lwrz = strlwr(fz[i]);
        if(strstr(lwrz, lwr) != NULL)exist = 1;
        free(lwrz);
    }
    free(lwr);
    free_string(fz, sz);
    free(x);
    return exist;
}
void flush_stdin(){
    char th;
    while((th = getchar()) != '\n' && th != EOF){}
}

char getch(){
    char c;
    c = getchar();
    flush_stdin();
    return c;
}

int getchoice(char* str){
    printf("%s (Y/N): ", str);
    int c = getch();
    while(tolower(c) != 'y' && tolower(c) != 'n'){
        printf("Invalid input, please try again.\n%s (Y/N): ", str);
        c = getch();
    }
    c = tolower(c);
    return c == 'y';
}
void input(char* str, char* out, size_t size){
    printf("%s", str);
    fgets(out, size, stdin);
    size_t getlen = strcspn(out, "\n");
    out[getlen] = '\0';
}

size_t get_digits(int x){
    int i = 0;
    for(; x > 0; x /= 10)i++;
    return i;
}

void create_data(Database* db, char* name, char* hobby){
    size_t idx = database_index(db);
    if(database_data_exist(db, name)){
        printf("That name already existed\n");
        return;
    }
    size_t dig = get_digits(idx);
    char* fmt = (char*)malloc(dig + strlen(name) + strlen(hobby) + 3);
    sprintf(fmt, "%zu,%s,%s\n", idx+1, name, hobby);
    database_write(db, fmt);
    printf("Successfully write data");
    free(fmt);
}
void read_data(Database* db){
    size_t size = database_index(db);
    char* lines = database_read(db);
    char** line = tokenize(lines, "\n", size);
    
    for(int i = 0; i < size; i++){
        char* ln = line[i];
        char** tok = tokenize(ln, ",", 3);
        printf("%s: %s, %s\n", tok[0], tok[1], tok[2]);
        free_string(tok, 3);
    }
    free_string(line, size);
    free(lines);
}
void update_data(Database* db, Database* tmp, char* name, char* nname, char* nhobby) {
    if(!database_data_exist(db, name)){
        printf("Data not found.\n");
        return;
    }
    char* lwrx = strlwr(name);

    char* getnn = (char*)malloc(strlen(nname));
    strcpy(getnn, nname);
    char* getnh = (char*)malloc(strlen(nhobby));
    strcpy(getnh, nhobby);

    size_t size = database_index(db);
    char* str = database_read(db);
    char** lines = tokenize(str, "\n", size);
    for(int i = 0; i < size; i++){
        char** tok = tokenize(lines[i], ",", 3);
        int idx = atoi(tok[0]);
        char* nn = tok[1];
        char* nh = tok[2];
        char* lwr = strlwr(nn);
        
        if(strcmp(lwr, lwrx) == 0){
            printf("Data Summary\n (%s, %s) -> (%s, %s)\n", nn, nh, nname, nhobby);
            if(getchoice("Continue?")){
                if(!database_data_exist(db, getnn)){
                    nn = getnn;
                    nh = getnh;
                    printf("Data updated.\n");
                }else{
                    printf("Data existed\n");
                }
            }else{
                printf("Abort.\n");
            }
        }

        char* fmt = (char*)malloc(get_digits(idx) + 3 + strlen(nn) + strlen(nh));
        sprintf(fmt, "%d,%s,%s\n", idx, nn, nh);
        database_write(tmp, fmt);
        free(fmt);
        free(lwr);
        free_string(tok, 3);
    }
    fclose(db->file);
    fclose(tmp->file);

    if(remove("database.dat") != 0)err("Fail to erase data");
    if(rename("temp.dat", "database.dat") != 0)err("Fail to move data");
    db->file = fopen("database.dat", "a+");
    tmp->file = fopen("temp.dat", "a+");

    free_string(lines, size);
    free(str);
    free(lwrx);
    free(getnn);
    free(getnh);
}

void find_data(Database* db, char* name){
    if(!database_data_exist(db, name)){
        printf("Data not found\n");
        return;
    }
    size_t sz = database_index(db);
    char* x = database_read(db);
    char** fz = tokenize(x, "\n", sz);
    char* lwr = strlwr(name);
    for(int i = 0; i < sz; i++){
        if(strstr(fz[i], lwr) != NULL){
            char** tok = tokenize(fz[i], ",", 3);
            printf("%s: %s, %s", tok[0], tok[1], tok[2]);
            free_string(tok, sz);
        }
    }
    free(lwr);
    free_string(fz, sz);
    free(x);
}

void delete_data(Database* db, Database* tmp, char* name){
    if(!database_data_exist(db, name)){
        printf("Data not existed.\n");
        return;
    }
    size_t size = database_index(db);
    int count = 1;

    char* str = database_read(db);
    char** lines = tokenize(str, "\n", size);
    char* lwr = strlwr(name);

    for(int i = 0; i < size; i++){
        char** tok = tokenize(lines[i], ",", 3);
        char* nn = tok[1];
        char* nh = tok[2];
        int dig = get_digits(count);
        char* lwrn = strlwr(nn);

        if(strcmp(lwrn, lwr) == 0){
            printf("Data summary\n (Position: %d, Name: %s, Hobby: %s)\n", count, nn, nh);
            if(getchoice("Continue?")){
                printf("Deleted.\n");
                free(lwrn);
                free_string(tok, 3);
                continue;
            }else printf("Abort.\n");
        }

        size_t ll = strlen(nn), lh = strlen(nh);
        char* fmt = (char*)malloc(dig + 3 + ll + lh);
        sprintf(fmt, "%d,%s,%s\n", count, nn, nh);
        database_write(tmp, fmt);
        count++;
        free(fmt);
        free_string(tok, 3);
        free(lwrn);
    }
    fclose(db->file);
    fclose(tmp->file);

    if(remove("database.dat") != 0)err("Failed to erase data");
    if(rename("temp.dat", "database.dat") != 0)err("Failed to move data");

    db->file = fopen("database.dat", "a+");
    tmp->file = fopen("temp.dat", "a+");

    free(str);
    free_string(lines, size);
    free(lwr);
}
