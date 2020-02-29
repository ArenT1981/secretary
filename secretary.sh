#!/bin/bash
# Author: Aren Tyr
# Date: 2020-02-29
# aren.unix@yandex.com
#
# Secretary: A command line program to help automatically reorganise your files
#
# Configuration is done by editing/creating a configuration file 
# using "secretary new". If you want everything stored at somewhere other than
# ~/.secretary, then edit "CONF_DIR" below.
#
# Please review the generated operation file before telling it to copy/move
# your files. You could potentially do a lot of damage to your system otherwise!

# --- Globals ---
AUTO="NO"
FILE_ARG="false"
CONF_DIR=$HOME/.secretary
TASK_DIR=$CONF_DIR/tasks
CONF_FILE=$CONF_DIR/secretaryrc
MASTER_LIST=$CONF_DIR/master
FILE_OPS_DIR=$CONF_DIR/fileops
CUSTOM_FILE=/dev/null
DATE_MODE_LOG=$CONF_DIR/filelist-datemode.files
CMD="cp -n"
EDITCOMMAND=vim
# ----------------

showUsage()
{
    echo ""
    echo "secretary"
    echo ""
    echo "A program to automatically reorganise and copy/move particular files based on"
    echo "the file extension, MIME type, and/or creation date, to specified directories"
    echo "according to a configuration file actions."
    echo ""
    echo "-----------------------------------------------------------------------------"
    echo ""
    echo "Usage: secretary [--auto] [configuration file]"
    echo ""
    echo "[configuration file (relative filename or path to file as required)]"
    echo ""
    echo "    Optionally supply a configuration file to use instead of the default which"
    echo "is at ~/.secretary/secretaryrc. This is useful for scripting secretary instances,"
    echo "or maintaining multiple secretary 'profiles' for different use-cases, i.e. a "
    echo "config file for processing files off a digital camera, another one for sorting"
    echo "internet dowloads, another one to sort text files, etc. E.g.:"
    echo ""
    echo "secretary /path/to/my/config/digitalCamera.secretary"
    echo "secretary copyAllPngsAndPerlScripts.secretary"
    echo "secretary ~/configs/sortOutDownloads.secretary"
    echo "secretary \"~/My Music/autoSorter.secretary\""
    echo ""
    echo "[--auto]"
    echo ""
    echo "    Do not produce review file; automatically perform the file operations by"
    echo "calling generated file operations script. Take care with this, as it will be "
    echo "performing mass file operations according to your settings, with no option to"
    echo "review the operations before proceeding. Intended for experienced users for "
    echo "scripting or automating purposes."
    echo ""
    echo "Automatic operation will create a logfile showing the file transactions "
    echo "completed at '~/.secretary/secretary-<date-time>.log' if subsequent review is "
    echo "desired."
    echo ""
    echo "Most users are instead strongly recommended to REVIEW the file operations script"
    echo "in a text editor BEFORE running it. This allows you to check that it will be "
    echo "copying/moving files in the way that you actually want!"
    echo ""
    echo "\"Buyer beware\", \"You have been warned\" etc. etc... ;-) "
    echo ""
    echo "Simply use by prefixing in front of your configuration file, if used, or by"
    echo "itself if you want it to automatically run the contents of"
    echo "~/.secretary/secretaryrc e.g. "
    echo ""
    echo "secretary --auto                          (runs on ~/.secretary/secretaryrc)"
    echo "secretary --auto /path/to/mySecretaryConfig.secretary"
    echo "secretary --auto myAmazingFileArrangement.secretary"
}


createNewFile()
{
    echo "* Creating new secretary task file"
    echo "* Please select option:"
    echo ""
    echo "[1] Create file from scratch"
    echo " - Use file template:"
    echo ""
    echo ""
    echo -n "> "
    read CHOICE
    echo ""
    echo "* Now please enter a filename to use."
    echo "No spaces and without extension."
    echo "(e.g. sort-downloads, my_downloads, sortDocFiles etc.)"
    echo -n "> "
    read FILENAME

    if [ ! -f "$TASK_DIR/$FILENAME" ]; then
        #touch "$TASK_DIR/$FILENAME"
        echo ""
    fi

    $EDITCOMMAND "$TASK_DIR/$FILENAME"
    # check if filename already exists and abort if it does

}


lsTaskFiles()
{

    echo "* Stored secretary task files:"
    declare -i COUNTER=1
    for taskFile in `ls "$CONF_DIR"/tasks 2>/dev/null | grep ".secretary" | cut -d '.' -f 1 | tee "$CONF_DIR"/tasks/.taskfilelist`
    do
        echo "[$COUNTER] $taskFile"
        COUNTER=$COUNTER+1
    done


}

lsOpsFiles()
{
    ls -l "$FILE_OPS_DIR"/*.sh 2>/dev/null
}


cleanFileOps()
{
    echo "* Removing all file operation scripts"
    rm "$FILE_OPS_DIR"/*.sh
}

editTaskFile()
{
    echo "* Edit an existing task file."
    lsTaskFiles
    echo "* Please enter name of task file to edit:"
    echo -n "> "
    read CHOICE
    # do something with choice
    FILENAME="`head -n $CHOICE $TASK_DIR/.taskfilelist | tail -n 1`"
    echo "F: $FILENAME"

    vim "$TASK_DIR/$FILENAME".secretary

}


setEditor()
{
    echo "* Enter desired editor command."
    echo "(e.g. vim, emacs, gedit, xedit, emacsclient -nc, kate, etc. )"
    echo -n "> "
    read CHOICE
    echo "* Editor command now set to:"
    echo "\"$CHOICE\""
    echo "* Simply run this command again if you wish to update editor."

}

if [ ! -z "$EDITOR" ]; then
    EDIT_VIEW="$EDITOR"
else
    EDIT_VIEW="vi"
fi

# Use graphical editor if running under X and they've set $VISUAL
if [ ! -z "$DISPLAY" ]; then # Are we running under X?
    if [ ! -z "$VISUAL" ]; then
        EDIT_VIEW="$VISUAL"
    fi
fi

# Did they even pass a file parameter? Or did they ask for help?
if [ "$1" = "-help" ] || [ "$1" = "--help" ] || [ "$1" = "help" ]; then
	showUsage
	exit 0
fi

# Did they ask for auto mode...?
if [ "$1" = "--auto" ]; then
	AUTO="YES"
	CUSTOM_FILE="$2"
	echo "* '--auto' option selected, using AUTO mode"
else
	CUSTOM_FILE="$1"
fi

# Show stored secretary task files
if [ "$1" = "ls" ]; then
    lsTaskFiles
    exit 0
fi

# Show generated secretary file operation scripts
if [ "$1" = "lso" ]; then
    lsOpsFiles
    exit 0
fi


# Delete old stored secretary file operation scripts
if [ "$1" = "clean" ]; then
    cleanFileOps
    exit 0
fi

# Create a new configuration file
if [ "$1" = "new" ]; then
    createNewFile
    exit 0
fi

# Edit an existing configuration file
if [ "$1" = "edit" ]; then
    editTaskFile
    exit 0
fi

# Change the editor/viewer
if [ "$1" = "editor" ]; then
    setEditor
    exit 0
fi

# Did they pass a secretary configuration file? Or are we using default...
if [ ! -z "$CUSTOM_FILE" ]; then
    if [ ! -f "$CUSTOM_FILE" ]; then
        if [ -f "$CUSTOM_FILE".secretary ]; then
            echo "* Using current directory file $CUSTOM_FILE.secretary"
            CUSTOM_FILE="$CUSTOM_FILE".secretary
            FILE_ARG="true"
        fi
    else
        echo "* Using current directory file $CUSTOM_FILE"
        CONF_FILE="$CUSTOM_FILE"
        FILE_ARG="true"
    fi
fi

# File not found in current directory, is it a stored task file?
if [ "$FILE_ARG" = "false" ]; then
    if [ -f "$TASK_DIR/$CUSTOM_FILE" ]; then
        echo "* Using stored secretary file $CUSTOM_FILE"
        CONF_FILE="$TASK_DIR/$CUSTOM_FILE"
    elif [ -f "$TASK_DIR/$CUSTOM_FILE".secretary ]; then
        echo "* Using stored secretary file $CUSTOM_FILE"
        CONF_FILE="$TASK_DIR/$CUSTOM_FILE".secretary
    else
        echo "* No secretary task file named \"$CUSTOM_FILE\" found."
        echo "(Looked in current directory and task directory)."
        echo "* Please check path/filename. Exiting."
        lsTaskFiles
        exit 0
    fi
fi

echo $CUSTOM_FILE
echo $CONF_FILE

# DEVELOPMENT uncomment here
#exit 0

# Counter for enumerating temporary filenames
declare -i COUNTER=0

echo "* Processing, please wait..."

# Build the filelists, parsing the configuration file line-by-line
while read LINE
do
    echo -n "."

  CMD="cp -n"
  DATE_MODE="DISABLE"

  COMMENT_HASH="`echo $LINE | cut -c 1`"
  [ "$COMMENT_HASH" = "#" ] && continue

  TYPE_FIELD="`echo $LINE | cut -d ':' -f 1`"
  EXT_FIELD="`echo $LINE | cut -d ':' -f 2`"
  SOURCE_FIELD="`echo $LINE | cut -d ':' -f 3`"
  DEST_FIELD="`echo $LINE | cut -d ':' -f 4`"
  DATE_CHECK="`echo $DEST_FIELD | grep ".*DATE#.*" -`"

  FILE_CMD="`echo $LINE | cut -d ':' -f 5 | cut -d '#' -f 1`"

  if [ ! -z "$FILE_CMD" ]; then
      CMD="$FILE_CMD"
  fi

	# See whether DATE mode is active; cut out 'DATE#' text if so
	if [ -n "$DATE_CHECK" ]; then
		DATE_MODE="ENABLE"
		DEST_FIELD=$(echo $DEST_FIELD | cut -d '#' -f 2)
	fi

	# Process a file extension line by each file extension
	if [ "$TYPE_FIELD" = "ext" ]; then

		for EXT in $EXT_FIELD
		do
        echo -n "."
        if [ "$DATE_MODE" = "ENABLE" ]; then
				#echo "# -> [ \*.$EXT files by DATE directories ] " > "$CONF_DIR/datemode-$COUNTER-$EXT.files"

				# Fork off the hierarchical date script
				find "$SOURCE_FIELD" -type f  -iregex \
					".*/*\.$EXT$" \
					-exec secretary-date-handler.sh {} "$SOURCE_FIELD" "$DEST_FIELD" "$CONF_DIR/datemode-$COUNTER-$EXT.files" "$CONF_DIR/datemode-$COUNTER-$EXT.dirlist" "$CMD" \;

        # Insert header or remove empty filelist 
        if [ -s "$CONF_DIR/datemode-$COUNTER-$EXT.files" ]; then
            sed -i "1i# -> [ \*.$EXT files from $SOURCE_FIELD to DATE directories ]" "$CONF_DIR/datemode-$COUNTER-$EXT.files"
        else
            if [ -f "$CONF_DIR/datemode-$COUNTER-$EXT.files" ]; then
                rm "$CONF_DIR/datemode-$COUNTER-$EXT.files"
            fi
        fi

			else
          echo -n "."

          # We will need to create destination directory if it doesn't already exist
          if [ ! -d "$DEST_FIELD" ]; then
              echo "mkdir -pv $DEST_FIELD" >> "filelist-$COUNTER-$EXT.dirlist"
          fi

            # Copy/move the files by file-extension, no date ordering/organisation
            find "$SOURCE_FIELD" -type f >> "$MASTER_LIST.$COUNTER.files"

            echo -n "."
            grep -i ".*\.$EXT.*" "$MASTER_LIST.$COUNTER.files" \
            | grep -i ".*\.$EXT$" \
            | awk  -v b="\"" -v a="$DEST_FIELD" -v c="$CMD" '/$/{ print c":"b$0b":"b a b }' \
            >> "$CONF_DIR/filelist-$COUNTER-$EXT.files"

      # Insert header or remove empty filelist
      if [ -s "$CONF_DIR/filelist-$COUNTER-$EXT.files" ]; then
          sed -i "1i# -> [ \*.$EXT files from $SOURCE_FIELD to $DEST_FIELD ]" "$CONF_DIR/filelist-$COUNTER-$EXT.files"
        #  sed -e "\$$CMD"
      else
          rm "$CONF_DIR/filelist-$COUNTER-$EXT.files"
      fi
			fi
		done
	fi

	# Process a MIME type line per each MIME file-type
	if [ "$TYPE_FIELD" = "mime" ]; then


      echo -n "."
      find "$SOURCE_FIELD" -type f -exec file {} \; >> "$MASTER_LIST.$COUNTER.files"


		for MIME in $EXT_FIELD
		do
        echo -n "."
        # Date mode enabled?
	      if [ "$DATE_MODE" = "ENABLE" ]; then

                grep -i ": $MIME" "$MASTER_LIST.$COUNTER.files" \
			          | cut -d ':' -f 1 \
			          | awk -v a="$DEST_FIELD" '/$/{ print $0":"a }' \
			          >> "$CONF_DIR/filelist-$COUNTER-$MIME.files"

                while read MIMELINE
                do
                    echo -n "."
                #echo "In datemode by MIME"
                MIME_FILE="`echo $MIMELINE | cut -d ':' -f 1`"
                MIME_SRC="`echo $MIME_FILE | rev | cut -d '/' -f 2- | rev`"
                MIME_DEST="`echo $MIMELINE | cut -d ':' -f 2`"

               # Fork off date script
                secretary-date-handler.sh "$MIME_FILE" "$MIME_SRC" "$DEST_FIELD" "$CONF_DIR/datemode-$COUNTER-$MIME.files" "$CONF_DIR/datemode-$COUNTER-$MIME.dirlist" "$CMD"
                done < $CONF_DIR/filelist-$COUNTER-$MIME.files

                # Add header if results found, otherwise purge file 
                if [ -s "$CONF_DIR/datemode-$COUNTER-$MIME.files" ]; then
                    sed -i "1i# -> [ $MIME files from $SOURCE_FIELD by DATE directories ]" "$CONF_DIR/datemode-$COUNTER-$MIME.files"
                else
                    if [ -f "$CONF_DIR/datemode-$COUNTER-$MIME.files" ]; then
                        rm "$CONF_DIR/datemode-$COUNTER-$MIME.files"
                    fi
                fi
                # Avoid duplicate file operations as we have now built a list by date from original search
                rm "$CONF_DIR/filelist-$COUNTER-$MIME.files"
     else
         echo -n "."

         # We will need to create destination directory if it doesn't already exist
         if [ ! -d "$DEST_FIELD" ]; then
             echo "mkdir -pv $DEST_FIELD" >> "filelist-$COUNTER-$MIME.dirlist"
         fi

         grep -i ": $MIME" "$MASTER_LIST.$COUNTER.files" \
			       | cut -d ':' -f 1 \
			       | awk -v b="\"" -v a="$DEST_FIELD" -v c="$CMD" '/$/{ print c":"b$0b":"b a b }' \
			             >> "$CONF_DIR/filelist-$COUNTER-$MIME.files"

            if [ -s "$CONF_DIR/filelist-$COUNTER-$MIME.files" ]; then
                sed -i "1i# -> [ $MIME files from $SOURCE_FIELD to $DEST_FIELD ]" "$CONF_DIR/filelist-$COUNTER-$MIME.files"
            else
                rm "$CONF_DIR/filelist-$COUNTER-$MIME.files"
            fi

fi
 		done
	fi

  COUNTER=$COUNTER+1

done < $CONF_FILE

echo -n "."

# Build the final copying script
TIMESTAMP="`date +%Y-%m-%d-%H_%M`"
echo "#!/bin/bash" > $FILE_OPS_DIR/secretary-file-operations-$TIMESTAMP.sh

# Add an information header
read -d '' FILE_HEADER_TXT << "ENDHEADER"
# ----------------------------------------------------------------------
# ----------------------------------------------------------------------
#
#           [ File operations list generated by secretary ]
#
# ======================================================================
# ======================================================================
#
# PLEASE look through this file carefully BEFORE running it
# to ensure that it will copy/move the correct files to
# your intended destination. Failure to do so may result in data
# loss if you have got your settings wrong in your config file...
#
# ------------------- YOU HAVE BEEN WARNED!!!!! ------------------------
#
# To execute this script, type:
#
#
# If you select the "--auto" option you will bypass this step
# and have the operations script automatically performed. Use with care.
#
# ----------------------------------------------------------------------
ENDHEADER

echo "$FILE_HEADER_TXT" >> $FILE_OPS_DIR/secretary-file-operations-$TIMESTAMP.sh
# Inject dynamically generated file text
sed -i "19i# $ $CONF_DIR/fileops/secretary-file-operations-$TIMESTAMP.sh" "$FILE_OPS_DIR/secretary-file-operations-$TIMESTAMP.sh"

# Gather together the directory creation and throw away duplicate mkdir -pv commands
# for aesthetic and clarity purposes (would still run OK with them all in though)
cat $CONF_DIR/filelist-*.dirlist >> $CONF_DIR/tmp-master.dirlist 2>/dev/null
cat $CONF_DIR/datemode-*.dirlist >> $CONF_DIR/tmp-master.dirlist 2>/dev/null
cat $CONF_DIR/tmp-master.dirlist | sort | uniq >> $CONF_DIR/master.dirlist 2>/dev/null

# Add these directories to the work script
sed -i '1i# -> [ Create necessary directories for subsequent file copying/moving operations ]\n' "$CONF_DIR/master.dirlist"
echo "" >> "$FILE_OPS_DIR/secretary-file-operations-$TIMESTAMP.sh"
echo "" >> "$FILE_OPS_DIR/secretary-file-operations-$TIMESTAMP.sh"
cat "$CONF_DIR/master.dirlist" >> "$FILE_OPS_DIR/secretary-file-operations-$TIMESTAMP.sh"

# Assemble all the non date ordered file lists into the work script
for FILELIST in `ls $CONF_DIR/filelist-*.files 2> /dev/null`
do
    echo -n "."
	if [ -s "$FILELIST" ];
	then
		HEADER_FLAG=1
		while read FILE_LINE
		do
        echo -n "."
			if [ $HEADER_FLAG -eq 1 ]; then

				echo "" >> "$FILE_OPS_DIR/secretary-file-operations-$TIMESTAMP.sh"
				echo "$FILE_LINE" >> "$FILE_OPS_DIR/secretary-file-operations-$TIMESTAMP.sh"
				echo "" >> "$FILE_OPS_DIR/secretary-file-operations-$TIMESTAMP.sh"
				HEADER_FLAG=0
				continue
			fi

      CMD_LINE="`echo $FILE_LINE | cut -d ':' -f 1`"
			FILE="`echo $FILE_LINE | cut -d ':' -f 2`"
			DEST="`echo $FILE_LINE | cut -d ':' -f 3`"
			echo "$CMD_LINE $FILE $DEST" >> $FILE_OPS_DIR/secretary-file-operations-$TIMESTAMP.sh

		done < $FILELIST
	else
		rm $FILELIST
	fi
done

# Now assemble all the date ordered file operations into the work script
for FILELIST in `ls $CONF_DIR/datemode-*.files 2> /dev/null`
do
    echo -n "."
	if [ -s "$FILELIST" ];
	then
		HEADER_FLAG=1
		while read FILE_LINE
		do
			if [ $HEADER_FLAG -eq 1 ]; then

				echo "" >> "$FILE_OPS_DIR/secretary-file-operations-$TIMESTAMP.sh"
				echo "$FILE_LINE" >> "$FILE_OPS_DIR/secretary-file-operations-$TIMESTAMP.sh"
				echo "" >> "$FILE_OPS_DIR/secretary-file-operations-$TIMESTAMP.sh"
				HEADER_FLAG=0
				continue
			fi


			echo "$FILE_LINE" >> $FILE_OPS_DIR/secretary-file-operations-$TIMESTAMP.sh

		done < $FILELIST
	else
		rm $FILELIST
	fi
done

sleep 0.5
# Put footer information at bottom of work script with summary data
OPERATIONS=`egrep -v '^#|^mkdir|^$' "$FILE_OPS_DIR/secretary-file-operations-$TIMESTAMP.sh" | wc -l`
DIRS=`grep '^mkdir' "$FILE_OPS_DIR/secretary-file-operations-$TIMESTAMP.sh" | wc -l`
echo "" >> "$FILE_OPS_DIR/secretary-file-operations-$TIMESTAMP.sh"
echo "#--> $DIRS new directories to create." >> $FILE_OPS_DIR/secretary-file-operations-$TIMESTAMP.sh
echo "#--> $OPERATIONS files to copy/move." >> $FILE_OPS_DIR/secretary-file-operations-$TIMESTAMP.sh

# Clear out the temporary file lists so they don't pollute the filesystem
find "$CONF_DIR" -name "*.files" -delete
find "$CONF_DIR" -name "*.dirlist" -delete

# Present results to user
clear
echo "* Processing complete on $CONF_FILE."
echo "* $OPERATIONS files ready to copy/move."
echo "* File operations script created at:"
echo ""
echo "$FILE_OPS_DIR/secretary-file-operations-$TIMESTAMP.sh"


# Check to see whether they're brave enough for AUTO...
if [ "$AUTO" = "YES" ]; then
    echo ""
	  echo "* Running in AUTO mode, will now execute the file operations..."
	  sleep 1
    bash "$FILE_OPS_DIR/secretary-file-operations-$TIMESTAMP.sh" | tee "$FILE_OPS_DIR/secretary-$TIMESTAMP.log"
    echo ""
    echo "* Complete. File transactions finished."
    echo "* Logfile showing operations performed created at:"
    echo "$FILE_OPS_DIR/secretary-$TIMESTAMP.log"
    rm "$FILE_OPS_DIR/secretary-file-operations-$TIMESTAMP.sh"
else
    echo ""
    echo "* You should now review the proposed file operations."
    echo ""
    echo "Reviewing the file operations script BEFORE operation is STRONGLY "
    echo "RECOMMENDED. PLEASE ENSURE YOU ARE COPYING/MOVING FILES AS INTENDED."
    echo "FAILURE TO DO SO COULD RESULT IN DATA LOSS AS THE SCRIPT IS PERFORMING BATCH"
    echo "FILE OPERATIONS. YOU HAVE BEEN WARNED..."
    echo ""
    echo "------------------------------------------------------------------------"
    echo "If all looks good, to go ahead and actually copy/move the files, exit this prompt"
    echo "('q') and execute the script:"
    echo ""
    echo "$FILE_OPS_DIR/secretary-file-operations-$TIMESTAMP.sh"
    echo "------------------------------------------------------------------------"
    echo ""
    echo "* Press:"
    echo "- <enter> to view it in the terminal pager"
    echo "- <e> to view it in your editor."
    echo "- Any other key to quit this prompt."
    echo -n "> "
    read CHOICE

    if [ "$CHOICE" = "e" ]; then
            "$EDIT_VIEW" "$FILE_OPS_DIR/secretary-file-operations-$TIMESTAMP.sh"
            chmod u+x "$FILE_OPS_DIR/secretary-file-operations-$TIMESTAMP.sh"
            exit 0
    fi

    if [ "$CHOICE" = "" ]; then
        more "$FILE_OPS_DIR/secretary-file-operations-$TIMESTAMP.sh"
        chmod u+x "$FILE_OPS_DIR/secretary-file-operations-$TIMESTAMP.sh"
        exit 0
    fi

 chmod u+x "$FILE_OPS_DIR/secretary-file-operations-$TIMESTAMP.sh"
 exit 0
fi

