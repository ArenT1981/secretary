#!/bin/sh

# Some error checking
ERROR_FILE=$HOME/.secretary/errorlog
FILE_YEAR=-1
FILE_MONTH=-1
FILE_DAY=-1

# Grab the parameters
FIRST=$1
SRC=$2
DEST=$3
LOG=$4
DIRLOG=$5
OPERATION=$6

# Check that we've got the necessary parameters
if [ -z "$FIRST" ]; then
    exit 1
fi

if [ -z "$SRC" ]; then
    exit 1
fi

if [ -z "$DEST" ]; then
    exit 1
fi

if [ -z "$LOG" ]; then
    exit 1
fi

if [ -z "$DIRLOG" ]; then
    exit 1
fi

if [ -z "$OPERATION" ]; then
    exit 1
fi

echo -n "."

FILE_DATE=$(stat -c %y "$1"| cut -d ' ' -f 1)
FILE_YEAR=`echo $FILE_DATE | cut -d '-' -f 1`
FILE_MONTH=`echo $FILE_DATE | cut -d '-' -f 2`
FILE_DAY=`echo $FILE_DATE | cut -d '-' -f 3`

# Check we've successfully stat'd the file
if [ $FILE_YEAR -eq -1 ]; then
	echo "Invalid file parameter passed: $1" >> "$ERROR_FILE"
	exit 1
fi

if [ $FILE_MONTH -eq -1 ]; then
	echo "Invalid file parameter passed: $1" >> "$ERROR_FILE"
	exit 1;
fi

if [ $FILE_DAY -eq -1 ]; then
	echo "Invalid file parameter passed: $1" >> "$ERROR_FILE" 
	exit 1;
fi

# Which month?
case $FILE_MONTH in
	01)
		MONTH="01-january"
	;;
	02)
		MONTH="02-february"
		;;
	03)
		MONTH="03-march"
		;;
	04)
		MONTH="04-april"
		;;
	05)
		MONTH="05-may"
		;;
	06)
		MONTH="06-june"
		;;
	07)
		MONTH="07-july"
		;;
	08)
		MONTH="08-august"
		;;
	09)
		MONTH="09-september"
		;;
	10)
		MONTH="10-october"
		;;
	11)
		MONTH="11-november"
		;;
	12)
		MONTH="12-december"
		;;
	*)
		exit 1
		;;
esac

# Build the destination path
DEST_DIR="$DEST/$FILE_YEAR/$MONTH"

# Ensure that the destination directory exists; create if necessary
echo "mkdir -pv $DEST_DIR" >> $DIRLOG
# Now add the actual copy/move operation to the script
echo "$OPERATION \"$1\" \"$DEST_DIR\"" >> $LOG

