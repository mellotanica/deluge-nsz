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
# $2 output_directory
# $3 mvcmd
function move() {
    MVCMD=${3:-${mvcmd}}
    echo "moving $1 to $2"
    ${MVCMD} "$1" "$2"
}

# $1 input
# $2 output_directory
function extract() {
    echo "unpacking $1 into $2"
    nsz -D -V ${delopt} -o "$2" -w "$1"
}

# $1 input
# $2 output_directory
function compress() {
    echo "packing $1 into $2"
    nsz -C -V ${delopt} -o "$2" -w "$1"
}

# $1 file.nsz
function process() {
    outdir="$(dirname "$OUTDIR/$(echo "$1" | sed -e "s%^${INDIR}%%")")"
    mkdir -p "$outdir"
    if [[ "$1" = *.nsz ]]; then
        case "$MODE" in
            "move")
                move "$1" "$outdir"
                ;;
            "compress")
                move "$1" "$outdir"
                ;;
            "extract")
                extract "$1" "$outdir"
                ;;
        esac
    elif [[ $1 = *.nsp ]]; then
        case "$MODE" in
            "move")
                move "$1" "$outdir"
                ;;
            "compress")
                compress "$1" "$outdir"
                ;;
            "extract")
                move "$1" "$outdir"
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

(
    sleep 5
    echo "trigger compression for preexisting files"
    find "$INDIR" -type f -iname '*.nsz' -or -iname '*.nsp' 2> /dev/null | while read file; do
        touch "$file"
    done
) &

echo "start loop..."

inotifywait -e create -e close_write -e moved_to --format "%w%f" -m -r -q "$INDIR" | while read file; do
    findextract "$file"
done
