#!/bin/bash

INDIR=/compressed
OUTDIR=/extracted

MODE=${MODE:-move}

echo "user: $(id)"
echo "watching $INDIR, delete: $DELETE, mode: $MODE"

delopt=''
mvcmd='cp'
if [ -n "$DELETE" ] && $DELETE; then
    delopt='--rm-source'
    mvcmd='mv'
fi
export delopt
export mvcmd

# $1 input
# $2 output
# $3 mvcmd
function move() {
    MVCMD=${3:-${mvcmd}}
    echo "moving $1 to $2"
    mkdir -p "$(dirname "$2")"
    ${MVCMD} "$1" "$2"
}

# $1 input
# $2 output_prefix
function extract() {
    echo "unpacking $1 into $2"
    outf=$(nsz -D -V ${delopt} -w "$1" | grep 'Decompressing ' | grep ' -> ' | sed -e 's/Decompressing .* -> //')
    move "$outf" "$2" mv
}

# $1 input
# $2 output_prefix
function compress() {
    echo "packing $1 into $2"
    outf=$(nsz -C -V ${delopt} -w "$1" | grep 'Solid compressing ' | grep ' -> ' | sed -e 's/Solid compressing .* -> //')
    move "$outf" "$2" mv
}

# $1 file.nsz
function process() {
    outpref="$OUTDIR/$(echo "$1" | sed -e "s%^${INDIR}%%" -e 's/\.nsz$//' -e 's/\.nsp$//')"
    if [[ "$1" = *.nsz ]]; then
        case "$MODE" in
            "move")
                move "$1" "${outpref}.nsz"
                ;;
            "compress")
                move "$1" "${outpref}.nsz"
                ;;
            "extract")
                extract "$1" "${outpref}.nsp"
                ;;
        esac
    elif [[ $1 = *.nsp ]]; then
        case "$MODE" in
            "move")
                move "$1" "${outpref}.nsp"
                ;;
            "compress")
                compress "$1" "${outpref}.nsz"
                ;;
            "extract")
                move "$1" "${outpref}.nsp"
                ;;
        esac
    fi
    rmdir --ignore-fail-on-non-empty -p "$(dirname "$1")"
}

# $1 file/dir
function findextract() {
    sleep 0.2
    find "$1" -type f -iname '*.nsz' -or -iname '*.nsp' 2> /dev/null | while read file; do
        process "$file"
    done
}

echo "searching for preexisting files in the background"
(findextract "$INDIR") &

echo "start loop..."

inotifywait -e create -e close_write -e moved_to --format "%w%f" -m -r -q "$INDIR" | while read file; do
    findextract "$file"
done
