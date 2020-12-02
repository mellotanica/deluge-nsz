#!/bin/bash

INDIR=/compressed
OUTDIR=/extracted

echo "user: $(id)"
echo "watching $INDIR, delete: $DELETE"

delopt=''
mvcmd='cp'
if [ -n "$DELETE" ] && $DELETE; then
    delopt='--rm-source'
    mvcmd='mv'
fi
export delopt
export mvcmd

# $1 file.nsz
function extract() {
    outpath="$OUTDIR/$(echo "$1" | sed -e "s%^${INDIR}%%" -e 's/\.nsz$/.nsp/')"
    if [[ "$1" = *.nsz ]]; then
        echo "unpacking $1 into $outpath"
        mkdir -p "$(dirname "$outpath")"
        outf=$(nsz -D -V ${delopt} -w "$1" | grep 'Decompressing ' | grep ' -> ' | sed -e 's/Decompressing .* -> //')
        mv "$outf" "$outpath"
        echo "done unpacking $1"
    elif [[ $1 = *.nsp ]]; then
        echo "moving $1" to $outpath
        mkdir -p "$(dirname "$outpath")"
        ${mvcmd} "$1" "$outpath"
    fi
    rmdir --ignore-fail-on-non-empty -p "$(dirname "$1")"
}

# $1 file/dir
function findextract() {
    find "$1" -type f -iname '*.nsz' -or -iname '*.nsp' 2> /dev/null | while read file; do
        extract "$file"
    done
}

echo "searching for preexisting files in the background"
(findextract "$INDIR") &

echo "start loop..."

inotifywait -e close_write -e moved_to --format "%w%f" -m -r -q "$INDIR" | while read file; do
    findextract "$file"
done
