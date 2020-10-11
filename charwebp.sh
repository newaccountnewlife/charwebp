#!/usr/bin/env bash

# WebP batch char encoding tool
# make sure you are in a directory containing only subdirectories with char folders
# like so
# 
# phoenix (you should be here)
# |
# normal-a
#   |
#   frame0001.png
#   frame0002.png
# ...

# colors:
# 0 ~> red
# 1 ~> green
# 2 ~> blue
# 3 ~> reset

col=()
for i in 1 2 4;do
    col+=("$(tput setaf "$i")")
done
i=""

col+=("$(tput sgr0)")

# die
die() {
    printf '%s\n' "$1" >&2
    exit 1
}

# help command
# fucking unreadable
helper() {
mandatory='-r <framerate>\n-q <quality>'

optional='-h (help)\n-s (silent)\n-n (nonverbose)\n-f <filter> (specify multiple times if multiple filters needednfilter in ffmpeg syntax e.g. scale=100x100)\n-l <loop> (how many times to loop, defaults to 0 for infinite)\n-y (yes on all questions)\n-x (colorspace fix)'
    
 	echo -e "${col[1]}\nAWebP char file encoding script${col[3]}\n\nHelp:\n\t${col[1]}Mandatory args:${col[3]}\n\n\t\t${col[0]}${mandatory//\\n/\\n\\t\\t}${col[3]}\n\t${col[1]}Optional args:${col[3]}\n\n\t\t${col[2]}${optional//\\n/\\n\\t\\t}${col[3]}\n"
}

# "crop=2000:1200:60:0,scale=640:384"

# vars
filters=()
loop="-loop 0"

# options

while getopts xynhs:r:q:f:l: opt; do
    case "${opt}" in

        h)
            helper
            exit 0
            ;;

        s)
            silent="-loglevel 1 -hide_banner"
            ;;

        r)
            framerate="-framerate ${OPTARG}"
            ;;

        n)
            notverbose="-hide_banner"
            ;;

        f)  filters+=("${OPTARG}")
            ;;

        l)  loop="-loop ${OPTARG}"
            ;;

        q)  quality='-q:v '"${OPTARG}"
            ;;

        x)  fix='-pix_fmt yuva420p'
            ;;

        y)  yes="-y"
            ;;

        *)
            helper >&2
            exit 1
            ;;
    esac
done

# mandatory checks
[[ "${framerate}" == "" ]] && helper >&2 && die "need supply -r "
[[ "${quality}" == "" ]] && helper >&2 && die "need supply arg -q"

# filter function
outputfilters() {    
    i=0

    echo -n '-vf '

	for j in "${filters[@]}";do
        if [[ "${filters[((i+1))]}" == "" ]] 
            then echo -n "$j"
            else echo -n "$j"','
        fi
        ((i=i+1))
    done

}

# for every 'file' (dir) in here, run the appropriate command
for i in *;do
    ffmpeg ${yes} ${framerate} -i "${i}/frame%04d.png" ${silent} ${notverbose} -c:v libwebp_anim ${quality} ${fix} ${loop} $(outputfilters) "${i}"'.webp'
done
