#!/bin/bash

gum style --border normal --margin "1" --padding "1 2" --border-foreground 212 "Welcome to $(gum style --foreground 212 'Postgres Table Exporter')."

HOST=$(gum input --header "Enter host" --placeholder "localhost" --value "localhost")
USERNAME=$(gum input --header "Enter user name" --placeholder "postgres" --value "postgres")
PASSWORD=$(gum input --header "Enter user password" --password --placeholder "password" --value "password")
DATABASE=$(gum input --header "Enter database name" --placeholder "dump" --value "dump")

export PGPASSWORD=$PASSWORD

IMPORTFILE=$(ls *.sql| gum choose --header "Choose the SQL file to import into the database $DATABASE")
if [ $? -ne 0 ]; then
    echo "No files with .sql extension found in the current directory."
    exit 1
fi

gum confirm "Do you want to import the $(gum style --foreground 212 "$IMPORTFILE") into postgres database $(gum style --foreground 212 "$DATABASE") on $(gum style --foreground 212 "$HOST") as $(gum style --foreground 212 "$USERNAME")? (This will drop the database if it already exists)"
if [ $? -ne 0 ]; then
  exit 0
fi

psql -U $USERNAME -h $HOST -c "DROP DATABASE IF EXISTS $DATABASE" > /dev/null 2>&1
echo "Dropped database $(gum style --foreground 212 "$DATABASE")"
if [ $? -ne 0 ]; then
  exit 1
fi

psql -U $USERNAME -h $HOST -c "CREATE DATABASE $DATABASE" > /dev/null
echo "Created database $(gum style --foreground 212 "$DATABASE")" 
if [ $? -ne 0 ]; then
  exit 1
fi

gum spin --title "Importing file $(gum style --foreground 212 "$IMPORTFILE") into database $(gum style --foreground 212 "$DATABASE")..." -- psql -U $USERNAME -d $DATABASE -h $HOST --file $IMPORTFILE
if [ $? -ne 0 ]; then
  exit 1
fi

echo "Imported file $(gum style --foreground 212 "$IMPORTFILE") into database $(gum style --foreground 212 "$DATABASE") successfully."

#EXPORTHEADERS=$(gum confirm "Do you want to export table headers?")

gum confirm "Do you want to export the tables now? (This will export all tables in the database $(gum style --foreground 212 "$DATABASE") to the output directory $(gum style --foreground 212 "./$DATABASE")"
if [ $? -ne 0 ]; then
    exit 0
fi

echo
echo "Exporting tables from $(gum style --foreground 212 "$DATABASE") to directory $(gum style --foreground 212 "./$DATABASE")"
echo

TABLENAMES=$(grep -Eo 'CREATE TABLE [^[:space:]]+' "$IMPORTFILE" | awk '{print $3}')

for TABLENAME in $TABLENAMES; do
    SANITIZEDTABLENAME=$(echo "$TABLENAME" | sed 's/[^a-zA-Z0-9]//g')
    OUTPUTFILE="$SANITIZEDTABLENAME.txt"

    mkdir $DATABASE > /dev/null 2>&1

    gum spin --title "Exporting table $(gum style --foreground 212 "$TABLENAME") to $(gum style --foreground 212 "./$DATABASE/$OUTPUTFILE")..." -- psql -U $USERNAME -d $DATABASE -h $HOST -c "\copy $TABLENAME TO './$DATABASE/$OUTPUTFILE' WITH (FORMAT 'csv', DELIMITER '|', ESCAPE '\"', QUOTE '\"', NULL 'NULL')" > /dev/null

    echo "Exported table $(gum style --foreground 212 "$TABLENAME") to $(gum style --foreground 212 "./$DATABASE/$OUTPUTFILE")..." 
done

echo
echo "All tables exported successfully."

gum confirm "Do you want to delete the database $(gum style --foreground 212 "$DATABASE")?"
if [ $? -ne 0 ]; then
    exit 0
fi

psql -U $USERNAME -h $HOST -c "DROP DATABASE $DATABASE" > /dev/null
echo
echo "Dropping database $(gum style --foreground 212 "$DATABASE")..."
if [ $? -ne 0 ]; then
    exit 1
fi
