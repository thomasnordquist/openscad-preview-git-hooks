#!/bin/bash

README="README.md"
IMAGE_DIRECTORY="images"

function prepare() {
  if [ -d $IMAGE_DIRECTORY  ]; then
    # Clear previous previews
    rm $IMAGE_DIRECTORY/*.scad.png
  else
    mkdir -p $IMAGE_DIRECTORY
  fi

  rm $README
}

function createPreview() {
  PREVIEW=$1
  openscad \
    -o $PREVIEW \
    --autocenter --preview \
    --imgsize=1600,1600 \
    --colorscheme=Tomorrow \
    --viewall \
    "$FILE"

   postProcessPreview $PREVIEW
}

# Do some supersampling
function postProcessPreview() {
  convert "$1" -filter triangle -scale 50% -strip "$1"
  optipng -o3 "$1"
}

prepare

for FILE in `ls -1 *.scad`; do 
  PREVIEW="$IMAGE_DIRECTORY/$FILE.png"
  createPreview "$PREVIEW" &
done;

# Wait for threads to finish
wait


COUNT=0
TITLEBUFFER="|"
IMAGEBUFFER="|"
SEPERATORBUFFER="|"
DONTSENDSEPERATORAGAIN=""
for FILE in `ls -1 *.scad`; do
  PREVIEW="$IMAGE_DIRECTORY/$FILE.png"
  COUNT=$((COUNT + 1))

  if [ "$COUNT" == 4 ]; then
    echo $TITLEBUFFER >> $README
    if [ "$DONTSENDSEPERATORAGAIN" == "" ]; then
      echo $SEPERATORBUFFER >> $README
      DONTSENDSEPERATORAGAIN="yes"
    fi;
    
    echo $IMAGEBUFFER >> $README
    COUNT=1
    TITLEBUFFER="|"
    IMAGEBUFFER="|"
    SEPERATORBUFFER="|"
  fi;

  TITLEBUFFER="$TITLEBUFFER$FILE|"
  SEPERATORBUFFER="$SEPERATORBUFFER---|"
  IMAGEBUFFER="$IMAGEBUFFER![$FILE]($PREVIEW)|"
done;

if [ "$COUNT" != 0 ]; then 
  echo $TITLEBUFFER >> $README
  if [ "$DONTSENDSEPERATORAGAIN" == "" ]; then
    echo $SEPERATORBUFFER >> $README
  fi;
  echo $IMAGEBUFFER >> $README
fi;

git add $IMAGE_DIRECTORY/ $README


