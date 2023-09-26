#!/usr/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'
shopt -s extglob
function main {
    if [ -e "Databases" ]
    then
        cd ./Databases
        echo -e $"${BLUE}WELCOME TO OUR DBMS${NC}"
        echo $'\n'
    else 
        mkdir Databases
        if [ -d "Databases" ]
        then
            cd ./Databases
            echo -e $"${BLUE}WELCOME TO OUR DBMS${NC}"
            echo $'\n'
        else
            echo -e $"${RED}There's a Problem, Please try again${NC}"
            exit
        fi
    fi  
    echo $'Choose an Option: \n'
    PS3="Main Menu=# "
    select option in 'Create Database' 'List Database' 'Connect to Database' 'Drop Database' 'Exit'
    do
        case $REPLY in 
        1)
            echo "**********************************"
            createDatabase
            ;;
        2) 
            echo "**********************************"
            listDatabase 
            ;;
        3) 
            echo "**********************************"
            connectDatabase 
            ;;
        4) 
            echo "**********************************"
            dropDatabase 
            ;;
        5)
            echo "**********************************"
            exitFromDB
            ;;
        *)
            echo -e $"${RED}You Enter Invalid Choice!!, Try Again${NC}"
            PS3="Main Menu=# "
        esac
    done
}

function exitFromDB {
    echo -e $"${BLUE}Good Bye, See You Again${NC}"
    echo $'\n'
    exit
}
#*****************************************************************************#

# Database Implementation

# Create Database
function createDatabase {
    read -p "Enter The Databse Name: " DBName
    if [[ -e $DBName ]]
    then
        echo -e $"${RED}This Database Name Is Already Used${NC}"
        echo "**********************************"
    else
        if [[ $DBName =~ ^[a-zA-Z][a-zA-Z_0-9]*$ ]]
        then
        mkdir $DBName
        echo -e $"${GREEN}Your Database Created Successfully !!!!!${NC}"
        
    else
        echo -e $"${RED}Invalid Name !!!!!${NC}"
    fi
fi
}

# List Database
function listDatabase {
    echo -e $"${BLUE}Your Databases Are:${NC}"
    echo $'\n'
    ls -F | grep '/' | sed 's|/||'
}

# Connect Database
function connectDatabase  {
    read -p "Enter Databse Name: " DBName
    if [[ $DBName =~ ^[a-zA-Z][a-zA-Z_0-9]*$ ]]
    then
        if [[ -e $DBName ]]
        then
            cd ./$DBName
            echo "Now You Are Connect to $DBName Database! "
            PS3="Table Option=# "
            select choice in "Create Table" "List Table" "Drop Table" "Insert Table" "Select From Table" "Delete From Table" "Update Table" "MainMenu" "Exit"
            do
                case $REPLY in
                    1)
                        echo "**********************************"
                        createTable
                        ;;
                    2)
                        echo "**********************************"
                        listTables
                        ;;
                    3)
                        echo "**********************************"
                        dropTable
                        ;;
                    4)
                        echo "**********************************"
                        insertData
                        ;;
                    5)
                        echo "**********************************"
                        selectData
                        ;;
                    6)
                        echo "**********************************"
                        deleteData
                        ;;
                    7)
                        echo "**********************************"
                        updateData
                        ;;
                    8)
                        cd ../..
                        main
                        ;;
                    9)
                        echo "**********************************"
                        exitFromDB
                        ;;
                    *)
                        echo -e $"${RED}You Enter Invalid Choice!!, Try Again${NC}"
                esac
            done
        else
            echo -e $"${RED}Database Dosen't Exist!!${NC}"
        fi
    else
        echo -e $"${RED}Your Entered Invalid Database Name!!, Try Again${NC}"
    fi
}

# Drop Database
function dropDatabase {
    read -p "Please Enter DataBase You Want to Remove it: " DBName
    if [[ $DBName =~ ^[a-zA-Z][a-zA-Z_0-9]*$ ]]
    then
        if [[ -e $DBName ]]
        then
            read -p "Are You Sure You Want Drop $DBName Database[Y\N]? " confirm
            if [ $confirm == 'y' -o  $confirm == "Y" ]
            then
                rm -r $DBName
                echo -e $"${GREEN}${DBName} Database Deleted Successfully !!${NC}"
            elif [ $confirm == 'n' -o $confirm == "N" ]
            then
                echo -e $"${BLUE}Thank You !!${NC}" 
            else 
                echo -e $"${RED}You Enter Invalid Choice!!, Try Again${NC}" 
            fi
        else
            echo -e $"${RED}The Database Doesn't Exit!${NC}"
        fi
    else
        echo -e $"${RED}Your Entered Invalid Database Name!!, Try Again${NC}"
    fi
}
#*****************************************************************************#

# Check Data Type [Integer | String]

function check_dataType {
    datatype=`head -1 $1 | cut -d: -f$2 | awk -F "-" 'BEGIN { RS = ":" } {print $3}'`
    if [[ $datatype == "integer" ]]
    then
        if ! [[ $3 =~ ^[0-9]+$ ]]
        then
            echo -e $"${RED}You Entered Invalid value, Please Enter Integer value!!${NC}"
            return 1
        else
            if [[ $2 -eq 1 ]]
            then
			    check_primaryKey $1 $2 $3
            fi
        fi
    elif [[ $datatype == "string" ]]
    then 
        if ! [[ $3 =~ ^[a-zA-Z]+$ ]]
		then
			echo -e $"${RED}You Entered Invalid value, Please Enter String value!!${NC}"
			return 1
		else
            if [[ $2 -eq 1 ]]
            then
			    check_primaryKey $1 $2 $3
            fi
        fi
    fi
}

# Check Primary Key
function check_primaryKey {
    if [[ `cut -d ':' -f1 $1 | awk '{if(NR != 1) print $0}' | grep -x -e $3` ]]
    then
        echo $'\n'
        echo -e $"${RED}Primary Key Already Exists, No Duplicates Allowed!${NC}"
        return 1
    fi
}
#*****************************************************************************#

# Table Implementation 

# Create Table
function createTable {
    PS3="Table Option=# "
    read -p "Enter Table Name You Want To Create: " tableName
    if [[ $tableName =~ ^[a-zA-Z][a-zA-Z_0-9]*$ ]]
    then 
        if ! [[ -f $tableName ]]
        then
            touch $tableName
            read -p "How Many Columns You Want To Create? " fieldsNumber
            if [[ $fieldsNumber = +([1-9])*([0-9]) ]]
            then
                echo -e $"${YELLOW}Note That The First Element You Will Enter Will Be The Primary Key${NC}"
                for (( i=1; i<=$fieldsNumber; i++ ))
                do
                    read -p "Enter The Name of The Field Number $i: " columnName
                    if [[ $columnName =~ ^[a-zA-Z][a-zA-Z_0-9]*$ ]]
                    then
                        if [[ $i == 1 ]]
                        then
                            echo -n "PK-" >> $tableName
                        else
                            echo -n "NoConstrain-" >> $tableName
                        fi 
                        while [[ `head -1 $tableName` == *"-$columnName-"* ]]
                        do        
                            echo -e $"${RED}The Column Already Exist, Can't Make Duplicate Columns, Try Again!!${NC}"
                            read -p "Enter The Name of The Field Number $i Again: " columnName
                        done
                        echo -n "$columnName-" >> $tableName
                        echo "Enter The Data Type Of Feild Number $i"
                        PS3="Data Type=# "
                        select choice in "integer" "string"
                        do
                            case $REPLY in
                                1) 
                                    echo -n "$choice" >> $tableName
                                    if [[ i -eq $fieldsNumber ]] 
                                    then
                                        echo $'\n' >> $tableName
                                        echo -e $"${GREEN}Table Created Successfully${NC}"
                                    else
                                        echo -n ":" >> $tableName
                                    fi
                                    PS3="Table Option=# "
                                    break
                                    ;;
                                2)
                                    echo -n "$choice" >> $tableName
                                    if [[ i -eq $fieldsNumber ]] 
                                    then
                                        echo $'\n' >> $tableName
                                        echo -e $"${GREEN}Table Created Successfully${NC}"
                                    else
                                        echo -n ":" >> $tableName
                                    fi
                                    PS3="Table Option=# "
                                    break
                                    ;;
                                *)
                                    echo -e $"${RED}Invalid Choice!!, Try Again${NC}"
                            esac
					    done
                    else
                        i=$(($i-1))
                        echo -e $"${RED}Invalid Column Name!!, Try Again${NC}"
                    fi
                done
            else
                if [[ $fieldsNumber -eq 0 ]]
                then
                    echo -e $"${RED}Cannot Create A Table Without Columns${NC}"
                else
                    echo -e $"${RED}Invalid Entry${NC}"
                fi
            fi
        else
            echo -e $"${RED}This Table Is Exsit!!, Please Enter Another Name.${NC}"
            PS3="Main Menu=# "
        fi
    else
        echo -e $"${RED}Invalid Table Name!!, Try Again${NC}"
    fi
}

# List Tables
function listTables {
    PS3="Table Option=# "
    echo -e $"${BLUE}Your Tables Are:${NC}"
    echo $'\n'
    ls -F | grep -v '/'
}

# Drop Table
function dropTable {
    read -p "Enter Table Name You Want To Delete: " tableName
	if [[ -f $tableName ]]
	then 
        read -p "Are You Sure You Want Drop Table $tableName [Y\N]? " confirm
        if [ $confirm == 'y' -o  $confirm == "Y" ]
            then
                rm $tableName
                echo -e $"${GREEN}Table ${tableName} Deleted Successfully !!${NC}"
            elif [ $confirm == 'n' -o $confirm == "N" ]
            then
                echo -e $"${BLUE}Thank You !!${NC}" 
            else 
                echo -e $"${RED}You Enter Invalid Choice!!, Try Again${NC}" 
        fi
    else
        echo -e $"${RED}The Table Doesn't Exit!${NC}"	
	fi
}

# Insert Data To Table
function insertData {
    PS3="Table Option=# "
    read -p "Enter The Table Name You want To Insert Into: " tableName
    if [[ -f $tableName ]]
    then
        fieldsNumber=`head -1 $tableName | awk -F: '{print NF}'`
        echo -e $"${YELLOW}Note That The First Element You Will Enter Has Constrain Primary[Unique & Not Null${NC}"
        for (( i=1; i<=$fieldsNumber; i++ ))
        do
            fieldName=`head -1 $tableName | cut -d: -f$i | awk -F "-" '{print $2}'`
            read -p "Enter The Data For Field Number $i [$fieldName]: " data
            check_dataType $tableName $i $data
            if [[ $? != 0 ]]
            then
                (( i = $i - 1 ))
            else	
                echo -n $data >> $tableName
                if [[ i -eq $fieldsNumber ]] 
                then
                    echo $'\n' >> $tableName
		            echo -e $"${GREEN}Successfully Insert Into Table ${tableName}${NC}"
                else
                echo -n ":" >> $tableName
                fi
            fi
        done
    else
        echo -e $"${RED}The Table Doesn't Exit!${NC}"
    fi
}

function selectData {
    read -p "Enter The Table Name You Want Select From It: " tableName
    if [[ -f $tableName ]]
    then
        PS3="Select Option=# "
        select choice in "Select All" "Select Specific Row" "Select Specific Column"
        do 
            case $REPLY in 
            1)
                echo -e $"${BLUE}------------------------------------------------------------"
                head -1 $tableName | awk 'BEGIN{ RS = ":"; FS = "-" } {print $2}' | awk 'BEGIN{ORS="\t"} {print $0}'
                echo -e "\n------------------------------------------------------------"
                sed '1d' $tableName | awk -F: 'BEGIN{OFS="\t"} {for(i = 1; i <= NF; i++) $i=$i; print}'
                echo -e $"${NC}"
                PS3="Table Option=# "
                break
                ;;
            2)
                columnsNum=`head -1 "$tableName" | awk -F: '{print NF}'`
                for (( i = 1; i <= columnsNum; i++ )) 
                do
                    fieldName=`head -1 $tableName | cut -d: -f$i | awk -F "-" '{print $2}'`
                    fieldType=`head -1 $tableName | cut -d: -f$i | awk -F "-" '{print $3}'`
                    echo -e $"${BLUE}\"${fieldName}\" Of Type ${fieldType}${NC}"
                done
                read -p "Enter Column Name You Want To Select By It: " field
                fieldNumber=`head -1 $tableName | awk 'BEGIN{ RS = ":"; FS = "-" } {print $2}' | grep -x -n $field | cut -d: -f1`
                if [[ $fieldNumber == "" ]]
                then
                    echo -e $"${RED}This Column Doesn't Exist${NC}"
                else
                    read -p "Enter Value for Specific Row: " value
                    echo -e $"${BLUE}------------------------------------------------------------"
                    head -1 $tableName | awk 'BEGIN{ RS = ":"; FS = "-" } {print $2}' | awk 'BEGIN{ORS="\t"} {print $0}'
                    echo -e "\n------------------------------------------------------------"
                    sed '1d' $tableName | awk -F':' 'BEGIN{OFS="\t"} {if($('$fieldNumber')=="'$value'") {for(i = 1; i <= NF; i++) $i=$i; print}}'
                    echo -e $"${NC}"
                fi
                PS3="Table Option=# "
                break
                ;;
            3)
                columnsNum=`head -1 "$tableName" | awk -F: '{print NF}'`
                for (( i = 1; i <= columnsNum; i++ )) 
                do
                    fieldName=`head -1 $tableName | cut -d: -f$i | awk -F "-" '{print $2}'`
                    fieldType=`head -1 $tableName | cut -d: -f$i | awk -F "-" '{print $3}'`
                    echo -e $"${BLUE}\"${fieldName}\" Of Type ${fieldType}${NC}"
                done
                read -p "Enter Column Name You Want To Select: " field
                fieldNumber=`head -1 $tableName | awk 'BEGIN{ RS = ":"; FS = "-" } {print $2}' | grep -x -n $field | cut -d: -f1`
                if [[ $fieldNumber == "" ]]
                then
                    echo -e $"${RED}This Column Doesn't Exist${NC}"
                else
                    echo -e $"${BLUE}------------------------------------------------------------"
                    head -1 $tableName | cut -d: -f$fieldNumber | awk -F "-" 'BEGIN{ORS="\t"} {print $2}'
                    echo -e "\n------------------------------------------------------------"
                    awk '{if(NR != 1) print $0}' $tableName | cut -d: -f$fieldNumber
                    echo -e $"${NC}"
                fi
                PS3="Table Option=# "
                break
                ;;
            *)
                echo -e $"${RED}You Enter Invalid Choice!!, Try Again${NC}"
            esac
        done
    else
        echo -e $"${RED}The Table Doesn't Exit!${NC}"   
    fi
}

function deleteData {
    read -p "Enter Table You Want to Delete From: " tableName
    if [[ -f $tableName ]]
    then
        PS3="Delete Option=# "
        select choice in "Delete All Records" "Delete A Specific Record"
        do
            case $REPLY in
                1) 
                    read -p "Are You Sure You Want Delete All Data From Table $tableName [Y\N]? " confirm
                    if [ $confirm == 'y' -o  $confirm == "Y" ]
                    then
                        sed -i '2,$d' $tableName
                        echo -e $"${GREEN}All Records Has Been Deleted Successfully${NC}"
                        PS3="Table Option=# "
                        break
                    elif [ $confirm == 'n' -o $confirm == "N" ]
                    then
                        echo -e $"${BLUE}Thank You !!${NC}"
                        PS3="Table Option=# "
                        break 
                    else
                        echo -e $"${RED}You Enter Invalid Choice!!, Try Again${NC}" 
                    fi
                    ;;
                2)
                    pkname=`head -1 $tableName | cut -d ':' -f1 | awk -F "-" '{print $2}'`
                    pkType=`head -1 $tableName | cut -d ':' -f1 | awk -F "-" '{print $3}'`
                    read -p "Enter The Value Of Primary Key $pkName of Type $pkType To Delete Row By It: " value
                    recordNum=`cut -d ':' -f1 "$tableName" | awk '{if(NR != 1) print $0}' | grep -x -n -e "$value" | cut -d':' -f1`
                    # -x => Exact , -e => Pattern , -n Record Number
                    if [[ $value == '' ]]
                    then
                        echo -e $"${RED}You Should Enter A Value${NC}"
                    elif [[ $recordNum == '' ]]
                    then
                        echo -e $"${RED}This Primary Key Doesn't Exist${NC}"
                    else
                        recordNum=$(($recordNum+1)) # Grep Start From 0
                        sed -i ''$recordNum'd' $tableName
                        echo -e $"${GREEN}Record Deleted Successfully${NC}"
                    fi
                    PS3="Table Option=# "
                    break
                    ;;
                *) 
                    echo -e $"${RED}Invalid Choice!!, Try Again${NC}"
            esac
        done
    else
        echo -e $"${RED}This Table Doen't Exist${NC}"
    fi
}  

function updateData {
    read -p "Enter Table You Want To Update in It: " tableName
    if [[ -f $tableName ]]
    then
        pkname=`head -1 $tableName | cut -d ':' -f1 | awk -F "-" '{print $2}'`
        pkType=`head -1 $tableName | cut -d ':' -f1 | awk -F "-" '{print $3}'` 
        read -p "Enter The Value Of Primary Key $pkName of Type $pkType To Update Row By It: " value
        recordNum=`cut -d ':' -f1 "$tableName" | awk '{if(NR != 1) print $0}' | grep -x -n -e "$value" | cut -d':' -f1`
        if [[ $value == '' ]]
        then
            echo -e $"${RED}You Should Enter A Value${NC}"
        elif [[ $recordNum == '' ]]
        then
            echo -e $"${RED}This Primary Key Doesn't Exist${NC}"
        else
            recordNum=$(($recordNum+1))
            columnsNum=`head -1 "$tableName" | awk -F: '{print NF}'`
            echo "**********************************"
            echo -e $"${BLUE}Fields In This Record And Value of That Field${NC}"
            for (( i = 1; i <= columnsNum; i++ )) 
            do
                fieldName=`head -1 $tableName | cut -d: -f$i | awk -F "-" '{print $2}'`
                fieldType=`head -1 $tableName | cut -d: -f$i | awk -F "-" '{print $3}'`
                fieldValue=`sed -n ''$recordNum'p' $tableName | cut -d: -f$i`
                echo -e $"${BLUE}\"${fieldName}\" Of Type ${fieldType}: ${fieldValue}${NC}"
			done
            echo "**********************************"
            read -p "Enter Field Name You Want To Update: " field
            fieldNumber=`head -1 "$tableName" | awk 'BEGIN{ RS = ":"; FS = "-" } {print $2}' | grep -x -n "$field" | cut -d: -f1`
            if [[ $fieldNumber == "" ]]
            then
                echo -e $"${RED}This Column Doesn't Exist${NC}"
                PS3="Table Option=# "
            else
                read -p "Enter New Value: " newValue
                check_dataType $tableName $fieldNumber $newValue
                if [[ $? == 0 ]]
                then
                    NR=`cut -d: -f1 "$tableName" | awk '{print $0}' | grep -x -n -e $value | cut -d: -f1`
                    oldValue=`awk 'BEGIN{FS=":"}{if(NR=='$NR'){for(i=1;i<=NF;i++){if(i=='$fieldNumber') print $i}}}' $tableName`
                    sed -i ''$NR's/'$oldValue'/'$newValue'/g' $tableName
                    echo -e $"${GREEN}Row Updated Successfully${NC}"
                    PS3="Table Option=# "
                fi
            fi
        fi
    else
        PS3="Table Option=# "
        echo -e $"${RED}This Table Doesn't Exsit !!, Try Again${NC}"
    fi
}

main