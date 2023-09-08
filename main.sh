#!/usr/bin/bash
shopt -s extglob
function main {
    if [ -e "Databases" ]
    then
        cd ./Databases
        echo $'WELCOME TO OUR DBMS \n'
    else 
        mkdir Databases
        if [ -d "Databases" ]
        then
            cd ./Databases
            echo $'WELCOME TO OUR DBMS \n'
        else
            echo "There's a Problem, Please try again"
            exit
        fi
    fi  
    echo $'Choose an Option: \n'
    PS3="Main Select=# "
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
            echo "You Enter Invalid Choice!!, Try Again"
            PS3="Main Menu=# "
        esac
    done
}

function exitFromDB {
    echo $'Good Bye, See You Again \n'
    exit
}
#*****************************************************************************#

# Database Implementation

# Create Database
function createDatabase {
    read -p "Enter The Databse Name: " DBName
    if [[ -e $DBName ]]
    then
        echo "This Database Name Is Already Used"
        echo "**********************************"
    else
        if [[ $DBName =~ ^[a-zA-Z][a-zA-Z_0-9]*$ ]]
        then
        mkdir $DBName
        echo "Your Database Created Successfully !!!!!"
        
    else
        echo "Invalid Name !!!!!"
    fi
fi
}

# List Database
function listDatabase {
    echo $'Your Databases Are:\n'
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
                        echo "You Enter Invalid Choice!!, Try Again"
                esac
            done
        else
            echo "Database Dosen't Exist!!"
        fi
    else
        echo "Your Entered Invalid Database Name!!, Try Again"
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
                echo "$DBName Database Deleted Successfully !!"
            elif [ $confirm == 'n' -o $confirm == "N" ]
            then
                echo "Thank You !!" 
            else 
                echo "You Enter Invalid Choice!!, Try Again" 
            fi
        else
            echo "The Database Doesn't Exit!"
        fi
    else
        echo "Your Entered Invalid Database Name!!, Try Again"
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
            echo "You Entered Invalid value, Please Enter Integer value!!"
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
			echo "You Entered Invalid value, Please Enter String value!!"
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
        echo $'\nPrimary Key Already Exists, No Duplicates Allowed!'
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
                echo -e "\033[0;32mNote That The First Element You Will Enter Will Be The Primary Key\033[0m"
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
                            echo "The Column Already Exist, Can't Make Duplicate Columns, Try Again!!"
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
                                        echo "Table Created Successfully"
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
                                        echo "Table Created Successfully"
                                    else
                                        echo -n ":" >> $tableName
                                    fi
                                    PS3="Table Option=# "
                                    break
                                    ;;
                                *)
                                    echo "Invalid Choice!!, Try Again"
                            esac
					    done
                    else
                        i=$(($i-1))
                        echo "Invalid Column Name!!, Try Again"
                    fi
                done
            else
                if [[ $fieldsNumber -eq 0 ]]
                then
                    echo "Cannot Create A Table Without Columns"
                else
                    echo "Invalid Entry"
                fi
            fi
        else
            echo "This Table Is Exsit!!, Please Enter Another Name."
            PS3="Main Menu=# "
        fi
    else
        echo "Invalid Table Name!!, Try Again"
    fi
}

# List Tables
function listTables {
    PS3="Table Option=# "
    echo $'Your Tables Are:\n'
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
                echo "Table $tableName Deleted Successfully !!"
            elif [ $confirm == 'n' -o $confirm == "N" ]
            then
                echo "Thank You !!" 
            else 
                echo "You Enter Invalid Choice!!, Try Again" 
        fi
    else
        echo "The Table Doesn't Exit!"	
	fi
}

# Insert Data To Table
function insertData {
    PS3="Table Option=# "
    read -p "Enter The Table Name You want To Insert Into: " tableName
    if [[ -f $tableName ]]
    then
        fieldsNumber=`head -1 $tableName | awk -F: '{print NF}'`
        echo -e "\033[0;32mNote That The First Element You Will Enter Has Constrain Primary[Unique & Not Null]\033[0m"
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
		            echo "Successfully Insert Into Table $tableName"
                else
                echo -n ":" >> $tableName
                fi
            fi
        done
    else
        echo "The Table Doesn't Exit!"
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
                echo "------------------------------------------------------------"
                head -1 $tableName | awk 'BEGIN{ RS = ":"; FS = "-" } {print $2}' | awk 'BEGIN{ORS="\t"} {print $0}'
                echo -e "\n------------------------------------------------------------"
                sed '1d' $tableName | awk -F: 'BEGIN{OFS="\t"} {for(i = 1; i <= NF; i++) $i=$i; print}'
                PS3="Table Option=# "
                break
                ;;
            2)
                columnsNum=`head -1 "$tableName" | awk -F: '{print NF}'`
                for (( i = 1; i <= columnsNum; i++ )) 
                do
                    fieldName=`head -1 $tableName | cut -d: -f$i | awk -F "-" '{print $2}'`
                    fieldType=`head -1 $tableName | cut -d: -f$i | awk -F "-" '{print $3}'`
                    echo "\"$fieldName\" Of Type $fieldType"
                done
                read -p "Enter Column Name You Want To Select By It: " field
                fieldNumber=`head -1 $tableName | awk 'BEGIN{ RS = ":"; FS = "-" } {print $2}' | grep -x -n $field | cut -d: -f1`
                if [[ $fieldNumber == "" ]]
                then
                    echo "This Column Doesn't Exist"
                    PS3="Table Option=# "
                else
                    read -p "Enter Value for Specific Row: " value
                    echo "------------------------------------------------------------"
                    head -1 $tableName | awk 'BEGIN{ RS = ":"; FS = "-" } {print $2}' | awk 'BEGIN{ORS="\t"} {print $0}'
                    echo -e "\n------------------------------------------------------------"
                    sed '1d' $tableName | awk -F':' 'BEGIN{OFS="\t"} {if($('$fieldNumber')=="'$value'") {for(i = 1; i <= NF; i++) $i=$i; print}}'
                fi
                break
                ;;
            3)
                columnsNum=`head -1 "$tableName" | awk -F: '{print NF}'`
                for (( i = 1; i <= columnsNum; i++ )) 
                do
                    fieldName=`head -1 $tableName | cut -d: -f$i | awk -F "-" '{print $2}'`
                    fieldType=`head -1 $tableName | cut -d: -f$i | awk -F "-" '{print $3}'`
                    echo "\"$fieldName\" Of Type $fieldType"
                done
                read -p "Enter Column Name You Want To Select: " field
                fieldNumber=`head -1 $tableName | awk 'BEGIN{ RS = ":"; FS = "-" } {print $2}' | grep -x -n $field | cut -d: -f1`
                if [[ $fieldNumber == "" ]]
                then
                    echo "This Column Doesn't Exist"
                    PS3="Table Option=# "
                else
                    echo "------------------------------------------------------------"
                    head -1 $tableName | cut -d: -f$fieldNumber | awk -F "-" 'BEGIN{ORS="\t"} {print $2}'
                    echo -e "\n------------------------------------------------------------"
                    awk '{if(NR != 1) print $0}' $tableName | cut -d: -f$fieldNumber
                fi
                break
                ;;
            *)
                PS3="Select Option=# "
                echo "You Enter Invalid Choice!!, Try Again"
            esac
        done
    else
        echo "The Table Doesn't Exit!"   
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
                        echo "All Records Has Been Deleted Successfully"
                        PS3="Table Option=# "
                        break
                    elif [ $confirm == 'n' -o $confirm == "N" ]
                    then
                        echo "Thank You !!"
                        PS3="Table Option=# "
                        break 
                    else 
                        echo "You Enter Invalid Choice!!, Try Again" 
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
                        echo "You Should Enter A Value"
                    elif [[ $recordNum == '' ]]
                    then
                        echo "This Primary Key Doesn't Exist"
                    else
                        recordNum=$(($recordNum+1)) # Grep Start From 0
                        sed -i ''$recordNum'd' $tableName
                        echo "Record Deleted Successfully"
                    fi
                    PS3="Table Option=# "
                    break
                    ;;
                *) 
                    echo "Invalid Choice!!, Try Again"
            esac
        done
    else
        echo "This Table Doen't Exist"
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
            echo "You Should Enter A Value"
        elif [[ $recordNum == '' ]]
        then
            echo "This Primary Key Doesn't Exist"
        else
            recordNum=$(($recordNum+1))
            columnsNum=`head -1 "$tableName" | awk -F: '{print NF}'`
            echo "**********************************"
            echo "Fields In This Record And Value of That Field"
            for (( i = 1; i <= columnsNum; i++ )) 
            do
                fieldName=`head -1 $tableName | cut -d: -f$i | awk -F "-" '{print $2}'`
                fieldType=`head -1 $tableName | cut -d: -f$i | awk -F "-" '{print $3}'`
                fieldValue=`sed -n ''$recordNum'p' $tableName | cut -d: -f$i`
                echo "\"$fieldName\" Of Type $fieldType: $fieldValue"
			done
            echo "**********************************"
            read -p "Enter Field Name You Want To Update: " field
            fieldNumber=`head -1 "$tableName" | awk 'BEGIN{ RS = ":"; FS = "-" } {print $2}' | grep -x -n "$field" | cut -d: -f1`
            if [[ $fieldNumber == "" ]]
            then
                echo "This Column Doesn't Exist"
                PS3="Table Option=# "
            else
                read -p "Enter New Value: " newValue
                check_dataType $tableName $fieldNumber $newValue
                if [[ $? == 0 ]]
                then
                    NR=`cut -d: -f1 "$tableName" | awk '{print $0}' | grep -x -n -e $value | cut -d: -f1`
                    oldValue=`awk 'BEGIN{FS=":"}{if(NR=='$NR'){for(i=1;i<=NF;i++){if(i=='$fieldNumber') print $i}}}' $tableName`
                    sed -i ''$NR's/'$oldValue'/'$newValue'/g' $tableName
                    echo "Row Updated Successfully"
                    PS3="Table Option=# "
                fi
            fi
        fi
    else
        PS3="Table Option=# "
        echo "This Table Doesn't Exsit !!, Try Again"
    fi
}

main