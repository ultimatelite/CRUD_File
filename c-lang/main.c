#include "tools.h"

int main(){
    int cont = 1;
    Database* db = database_init("database.dat", 1);
    Database* tmp = database_init("temp.dat", 1);
    int limit = READ_BUF_MIN;
    while(cont){
        printf("Choice:\n1. Create Data\n2. Read Data\n3. Update Data\n4. Delete Data\n");
        printf("5. Find Data\n6. Reset Database\n7. Set Buffer\n8. Exit\n> ");
        int choice = getch();
        switch(choice){
            case '1':
            
            char* name = (char*)malloc(limit);
            char* hobby = (char*)malloc(limit);

            input("Name: ", name, limit);
            input("Hobby: ", hobby, limit);
            create_data(db, name, hobby);

            free(name);
            free(hobby);
            break;

            case '2':
            read_data(db);
            break;
            case '3':
            char* name2 = (char*)malloc(limit);
            char* nname = (char*)malloc(limit);
            char* nhobby = (char*)malloc(limit);

            input("Name: ", name2, limit);
            input("New Name: ", nname, limit);
            input("New Hobby: ", nhobby, limit);

            update_data(db, tmp, name2, nname, nhobby);

            free(name2);
            free(nname);
            free(nhobby);
            break;
            case '4':
            char* name3 = (char*)malloc(limit);

            input("Name: ", name3, limit);
            delete_data(db, tmp, name3);
            free(name3);
            break;
            case '5':
            char* name1 = (char*)malloc(limit);
            input("Name: ", name1, limit);
            find_data(db, name1);
            free(name1);
            break;

            case '6':
            if(getchoice("Are you sure you want to erase data? (this change cannot be reverted)")){
                database_destroy(db);
                database_destroy(database_init("database.dat", 0));
                db = database_init("database.dat", 1);
            }else printf("Abort.\n");
            break;

            case '7':
            int x;
            printf("Input buffer (100-10240): ");
            scanf("%d", &x);
            if(x < READ_BUF_MIN || x > READ_BUF_MAX)printf("Buffer must be in range of 100 to 10240.");
            else{
                char nm[4];
                printf("Give to (data, buff): ");
                scanf("%4s", &nm);
                char* lwr = strlwr(nm);
                if(strcmp(lwr, "data") == 0){
                    printf("Set new limit to hobby and name (changes: %d -> %d)", limit, x);
                    limit = x;
                }else{
                    printf("Set new buffer to database and temp (changes: %zu -> %d)", db->buffer, x);
                    db->buffer = x;
                    tmp->buffer = x;
                }
                flush_stdin();
                free(lwr);
            }
            break;

            case '8':
            database_destroy(db);
            database_destroy(tmp);
            exit(0);
            break;
            default:
            printf("Invalid entry: %c\n", choice);
            break;
        }
        cont = getchoice("\nDo you want to continue?");
    }
    database_destroy(db);
    database_destroy(tmp);
    return 0;
}
