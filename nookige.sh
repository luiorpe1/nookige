#!/bin/bash

# =====================================================
# VARIABLES
# =====================================================

PROGRAMNAME="Nookige"
TMPDIR=$(mktemp -d --tmpdir=`pwd`)
DEBUG=false

# This script arguments and Imagemagick's arguments relationship
#   (GRAYSCALE TRIM  RESIZE)
OPT=(false     false false)
ARG=("-colorspace Gray"\
     "-trim"\
     "-resize 600x730")
CMDARGS=""

# =====================================================
# Usage: Print usage message and exit
# =====================================================
usage()
{
  echo "Usage: `basename "$0"` [-gtr] dirname"
  echo "Usage: `basename "$0"` [-h]"
  echo "   -h           This help"
  echo "   -g           Convert to grayscale"
  echo "   -t           Trim image borders"
  echo "   -r           Resize image to predefined Nook Touch size"
  
  cleanup
  exit 1
}

# =====================================================
# CleanUp: Remove temporary files. Call at exit
# =====================================================
function cleanup
{
  rm -Rf "$TMPDIR"
}


# =====================================================
# CleanTMP: Clean temporary directory
# =====================================================
function cleantmp
{
  rm -Rf "$TMPDIR/"*
}

# =====================================================
# IsImage: Return True if file is an image, False otherwise
# =====================================================
function isimage
{
  local EXT=`echo ${1##*.} | tr [A-Z] [a-z]`
  local i # Local variable, otherwise visible from anywhere.
          # It can get nasty when the same name is used elsewhere.
  for i in 'jpg' 'jpeg' 'png' 'bmp'; do
    if [ $i = $EXT ]; then
      return 0
    fi
  done
  return 1
}

# ======================================================
# build_convert_args: Compose the commnad line arguments
#                     for convert command
# ======================================================
build_convert_args()
{
  let len=${#OPT[@]} # let creates GLOBAL variable
  for i in $(seq 0 $(($len-1))); do
  #echo "OPT[$i] = ${OPT[$i]}"
    if ${OPT[$i]}; then
      if [ ${#CMDARGS} -eq 0 ]; then
        CMDARGS="${ARG[$i]}"
      else
        CMDARGS="$CMDARGS ${ARG[$i]}"
      fi
    fi
  done
}


# ======================================================
# rotate: Rotates an image when its wider than taller
# - 1st argument: Source file name
# - 2nd argument: output file name
# ======================================================
rotate()
{
  local SOURCE=$1
  local TARGET=$2
  
  local W=$(identify "$SOURCE" | awk '{print $3}' | awk -Fx '{print $1}')
  local H=$(identify "$SOURCE" | awk '{print $3}' | awk -Fx '{print $2}')
  
  if [ $W -gt $H ]; then
    echo "$SOURCE" is "$W"Wx"$H"H... Rotating
    convert "$SOURCE" -rotate 90 "$TARGET"
    return 0
  fi
  
  return 1
}


# ======================================================
# makepdf: Create a pdf with the images found
#          in a directory and subdirectories
# ======================================================
makepdf()
{
  local DIR="${1%/}" # Remove trailing '/'EXT=${f##*.}
  local DIRNAME=`basename $1`
  
  local NFILES=$(ls -R "$DIR" | wc -l) # Upper bound >= num files
  N=($(seq -w $NFILES))
  
  cleantmp
  convert_dir "$DIR" 0
  
  echo -n "Creating $DIRNAME.pdf..."
  convert "$TMPDIR"/* ./"$DIRNAME".pdf
  echo "   done"
}


# ======================================================
# convert_dir: Travel directories recursively converting
#              the images it finds
# - 1st argument: Directory to explore
# - 2nd argument: Current index for array N (Name for converted files)
# ======================================================
convert_dir()
{
  local DIR=$1
  local i=$2
  
  $DEBUG && echo "Entering $DIR, i: $i N: ${#N[@]}"
  
  local f
  for f in $(ls "$DIR"); do
    if [ -d "$DIR/$f" ]; then
      convert_dir "$DIR/$f" $i
      i=$?
      #echo "i: $i"
    fi
    
    isimage "$DIR/$f"
    if [ $? -eq 0 ]; then
      EXT=${f##*.}
      $DEBUG && echo "  Converting $DIR/$f to ${N[$i]}.$EXT i: $i"
      
      rotate "$DIR/$f" "$TMPDIR/${N[$i]}.$EXT"
      if [ $? -eq 0 ]; then
        convert "$TMPDIR/${N[$i]}.$EXT" $CMDARGS "$TMPDIR/${N[$i]}.$EXT"
      else
        # Fail silently
        convert "$DIR/$f" $CMDARGS "$TMPDIR/${N[$i]}.$EXT"
      fi
      
      i=$(($i + 1))
    fi
  done
  
  $DEBUG && echo "Leaving $DIR i: $i"
  return $i
}


# ======================================================
# convert_file: Convert file
# ======================================================
# convert_file(){
#  FILE="$1"
#  echo "$FILE"
# }


# =====================================================
# Main
# =====================================================

# Check for convert program
command -v convert >/dev/null 2>&1 || { echo >&2 "The following command cannot be found: convert.\\
                                                  Check that the package imagemagick is installed.";
                                                  cleanup;
                                                  exit 1; }

if [ $# -lt 1 ]; then
  usage
fi

# Set up traps for events
trap cleanup EXIT

# Read command line arguments
NARGS=0
while getopts 'gtrh' argv; do
  case "$argv" in
    h) usage ;;
    g) OPT[0]=true; NARGS=$(($NARGS + 1)) ;;
    t) OPT[1]=true; NARGS=$(($NARGS + 1)) ;;
    r) OPT[2]=true; NARGS=$(($NARGS + 1)) ;;
    *) usage ;;
  esac
  #shift
done

# Build command line for the convert utility
build_convert_args

# Consume command arguments
for i in $(seq $NARGS); do shift; done

# Make pdf
for i in $@; do
  if [ -d "$i" ]; then echo "$i"; makepdf "$i" #convert_dir
  #elif [ -f $i ]; then convert_file "$i"
  else echo "ERROR: $i does not exist or not a directory"; cleanup; exit 1
  fi
done
exit 0


# # VARIBALES
# FILENAME=${1%.*}
# EXT=${1##*.}
# 
# echo "Filename: $FILENAME"
# echo "Extension: $EXT"


