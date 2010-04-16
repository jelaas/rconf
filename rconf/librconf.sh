ROUTER="Bifrost"

# selections <base> <nr fields>
function selections {
    local f n
    
    for f in $(find $RCONF $OPT -name $1'-*[^~]'); do
	n=$(basename $f|cut -d '-' -f 1-$2)
	echo $(dirname $f)/$n
    done | sort |uniq
}

# selections_basename <base> <nr fields>
# sets nsel, sel_scipt, sel_desc, sel_value
function selections_basename {
    local f i
    i=0
    for f in $(selections $1 $2) EOF; do
	[ "$f" = EOF ] && break
	i=$[ i+1 ]
	sel_script[$i]="$f"
	sel_desc[$i]="$($f --description)"
	sel_value[$i]="$(basename $f|cut -d '-' -f $2)"
    done
    nsel=$i
}

# selections_linkinfo <ifname> <base> <nr fields> [<base> <nr fields>]*
# sets nsel, sel_scipt, sel_desc, sel_value
function selections_linkinfo {
    local f i ifname
    ifname="$1"
    shift
    i=0
    while [ "$1" ]; do
	for f in $(selections $1 $2) EOF; do
	    [ "$f" = EOF ] && break
	    i=$[ i+1 ]
	    sel_script[$i]="$f"
	    sel_desc[$i]="$($f --description)"
	    sel_value[$i]="$($f --linkinfo $ifname)"
	done
	shift 2
    done
    nsel=$i
}

# create_dialog_file
# sets F
function create_dialog_file {
    F=/tmp/rconf.$$
    trap "rm -f $F" EXIT
    cp /dev/null $F
}

# needs: nsel, sel_desc
# adds lines to $F
function populate_dialog_file_desc {
    local j
    for (( j=1; j <= nsel; j++ )); do
	echo \"${sel_desc[$j]}\" - >> $F
    done
}

# needs: nsel, sel_desc, sel_value
# adds lines to $F
function populate_dialog_file_value {
    local j
    for (( j=1; j <= nsel; j++ )); do
	echo \"${sel_desc[$j]}\" \"${sel_value[$j]}\" >> $F
    done
}

# run_if_script <string> [<param>]
# needs: nsel, sel_desc, sel_script
function run_if_script {
    local j
    for (( j=1; j <= nsel; j++ )); do
	if [ "$1" = "${sel_desc[$j]}" ]; then
	    ${sel_script[$j]} $2 $3
	    return
	fi
    done
}

# configapply <file> <key1> <value1> <key2> <value2> ..
function configapply {
    local i j f tmp keys values LINE match
    f=$1
    shift

    tmp="$f.tmp"

    if [ -f $f ]; then
	if ! cp $f $tmp; then
	    return 1
	fi
    else
	cp /dev/null $tmp
    fi
    
    i=0
    while [ "$1" ]; do
	i=$[ i+1 ]
	keys[$i]="$1"
	values[$i]="$2"
	shift 2
    done
    
    cat $tmp|while read LINE; do
    match=0
    for (( j=1; j <= i; j++ )); do
	# deprecated stuff
	if [[ $LINE =~ ^export\ IP4MASK= ]]; then
	    match=1
	    break
	fi
	
	if [[ $LINE =~ ^${keys[$j]}= ]]; then
	    match=1
	    break
	fi
	if [[ $LINE =~ ^export\ ${keys[$j]}= ]]; then
	    match=1
	    break
	fi
    done
    if [ $match = 0 ]; then
	echo "$LINE"
    fi
    done > $f

    for (( j=1; j <= i; j++ )); do
	echo "export ${keys[$j]}=\"${values[$j]}\"" >> $f
    done

    rm -f $tmp
    return
}