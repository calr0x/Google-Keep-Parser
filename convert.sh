#!/bin/bash

DIR="Archive"

for f in *\ *; do mv -v "$f" "${f// /_}"; done

for FILENAME in $(ls -v | grep .json)
do
    NOTE_TITLE=$(jq '.title' $FILENAME | sed 's|\"||g')
    NOTE_TEXT_CONTENT=$(jq '.textContent' $FILENAME)
    NOTE_DATE_CREATED_SERIAL=$(jq '.createdTimestampUsec' $FILENAME)
    NOTE_CREATED_TIMESTAMP=$(date -d @$NOTE_DATE_CREATED_SERIAL)

    HAS_IMAGES=$(jq '.' $FILENAME | grep attachments | wc -l)
    if [[ $HAS_IMAGES -ge "1" ]]; then
      NOTE_IMAGE_ARRAY=($(jq '.attachments[].filePath' $FILENAME | sed 's|"||g' | sed 's|jpeg|jpg|' | sed 's|png|jpg|'))
    fi

    NOTE_DIRNAME=$(echo $FILENAME | sed 's|.json||g' | sed 's|(||' | sed 's|)||')
    mkdir -pv $DIR/"$NOTE_DIRNAME"

    if [[ $? -eq 1 ]];then
        exit
    fi

    # Copy html file
    FILENAME_HTML=$(echo $FILENAME | sed 's|json|html|')
    mv -v $FILENAME_HTML $DIR/$NOTE_DIRNAME
    mv -v $FILENAME $DIR/$NOTE_DIRNAME

    # Copy images

    if [[ $HAS_IMAGES -ge "1" ]]; then
        echo "Copy images"

        for i in "${NOTE_IMAGE_ARRAY[@]}"
        do
            mv -v $i $DIR/$NOTE_DIRNAME
        done
    fi
done