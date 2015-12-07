#!/usr/bin/bash

set -e
set -o pipefail
set -u

function usage {
echo "Usage: $0 [options] path
Options:
 -c : only show files to convert (safe run)
 -d : print diff size between converted and original files
 -D : remove original files
 -h : display this help"
}

do_convert=true
do_diff=false

while getopts ":cdDh" opt; do
	case $opt in
		c)
			do_convert=false
			;;
		d)
			do_diff=true
			;;
		D)
			do_diff=true
			do_rm_orig=true
			;;
		h)
			usage
			exit
			;;
		\?)
			echo "Invalid option: -$OPTARG" >&2
			exit 1
			;;
		:)
			echo "Option -$OPTARG requires an argument." >&2
			exit 1
			;;
	esac
done

path=${@:$OPTIND}

total_size=0

if [[ -z $path ]] ; then
	echo "path is not specified"
	usage
	exit 1
fi

if [[ $do_diff == true ]]; then
	echo "File: original_size converted_size ratio"
fi

#SAFE while loop doesn't work, do just one iteration.
#SAFE while IFS= read -d $'\0' -r input ; do
IFS=$'\n'
for input in $(find $path -iname 'mvi*.mov') ; do

	i_without_ext="${input%.*}"
	tmp_output="${i_without_ext}_tmp.mp4"
	tocheck_output="${i_without_ext}_check.mp4"
	final_output="${i_without_ext}.mp4"

	if [[ $do_diff == true ]]; then
		if [ -f "${tocheck_output}" ]; then
			orig_size=$(stat -c %s $input)
			orig_hsize=$(du -h ${input} | awk '{print $1}')
			tocheck_size=$(stat -c %s $tocheck_output)
			tocheck_hsize=$(du -h ${tocheck_output} | awk '{print $1}')
			echo "$input: $orig_hsize	$tocheck_hsize	$(printf "%.2f" $(bc -l <<< "(1-$tocheck_size/$orig_size)*100"))%"
			if [[ $do_rm_orig == true ]]; then
				rm -i $input
			fi
		fi
	else
		if [ ! -f "${tocheck_output}" ] && [ ! -f "${final_output}" ]; then
			if [[ $do_convert == true ]]; then
				echo "================ Encoding \"$input\" ================"
				ffmpeg -y -i "$input" -strict experimental -preset slow -crf 21 -acodec aac -vcodec libx264 "${tmp_output}"
				echo "================ mv \"${tmp_output}\" \"${tocheck_output}\" ================"
				mv "${tmp_output}" "${tocheck_output}"
			else
				size=$(du -h ${input} | awk '{print $1}')
				#total_size=$(($total_size + $size))
				echo "$input	$size"
			fi
		fi
	fi
	#SAFE done < <(find $path -iname 'mvi*.mov' -print0)
done
if [[ $do_convert == false ]]; then
	echo "Total size to convert: $total_size"
fi
