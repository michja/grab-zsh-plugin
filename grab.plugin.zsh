GRABDIR="$HOME/.local/share/grab"

function grab() {
  GRABFILE="$GRABDIR"/"$1"
  if ! { [[ -f "$GRABFILE" ]] || [[ -d "$GRABFILE" ]]; }; then
    echo "Unknown alias"
    return 1
  fi

  if [[ -L "$GRABFILE" ]]; then
    # handle symlinks
    cp -r $(readlink -f "$GRABFILE") .
    echo Grabbed $(basename $GRABFILE)

  else
    # handle web resource
    GRABLINK=$(cat $GRABFILE | jq -r .link)
    wget -q $GRABLINK
    echo Grabbed $(basename $GRABLINK)
  fi
}

function grabchkconflict() {
  local GRABALIAS
  GRABALIAS=$GRABDIR/"$1"
  # check for conflicts
  if [[ -f "$GRABALIAS" ]] || [[ -d "$GRABALIAS" ]]; then
    local confirm
    vared -p 'Overwrite [y/N]?: ' -c confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || return 1
    # remove conflicting file
    rm -rf "$GRABALIAS"
  fi
  return 0
}

function galias() {
  # make dir if doesnt exist
  if ! [[ -d $GRABDIR ]]; then
    mkdir $GRABDIR
  fi

  

  ## web resource
  if [[ "$2" = "http:"* ]] || [[ "$2" = "https:"* ]]; then
    
    if ! grabchkconflict "$1"; then
      return 1
    fi

    jq -n --arg link "$2" '{link: $link}' > $GRABDIR/"$1"
    return 0
  fi

  ## local filesystem
  # ensure path is full
  if [[ "$2" = /* ]]; then
    GRABFILE=$2
  else
    GRABFILE=$(pwd)/$2
  fi

  if ! grabchkconflict "$1"; then
    return 1
  fi
  
  $(cd $GRABDIR; ln -s "$GRABFILE" "$1")
  return 0
}

function gunalias() {
  if ! [[ -z $1 ]]; then
    rm $GRABDIR/"$1"
  else
    echo No alias given
  fi
}

function glist() {
  { 
    echo " "    
    echo $(tput bold)"local"$(tput sgr0)
    ls -l $GRABDIR | grep ^l | tr -s ' ' | cut -d " " -f 9-
    echo " "    
    echo $(tput bold)"web"$(tput sgr0)
    find $GRABDIR -type f | while read res;do echo "$(basename $res) -> $(cat $res | jq -r .link)"; done 
    echo " "    
  } | column -e -t -s " "
}
