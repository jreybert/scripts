#!/usr/bin/bash

set -e
set -o pipefail
set -u

function usage {
echo "Usage: $0 [options] check_path backup_path
without option, dry run
Options:
 -f : move coprrupted files
 -h : display this help"
}

move_corrupt_files=false

while getopts ":fh" opt; do
	case $opt in
		f)
			move_corrupt_files=true
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

shift $(($OPTIND - 1))

check_path=$1
backup_path=$2

if [[ -z $check_path || -z $backup_path ]] ; then
	echo "check_path or backup_path is not specified"
	usage
	exit 1
fi

mkdir -p $backup_path

if [ ! -d $backup_path ]; then
	echo "can't create '$backup_path'"
fi

echo "check jpg integrity in '$check_path'"
echo "corrupted files are backup'd in '$backup_path'"

find $check_path -type f -iname "*.jpg" -print0 | while IFS= read -r -d $'\0' file; do
	if ! jpeginfo -c "$file" > /dev/null; then
		if [[ $move_corrupt_files == true ]]; then
			echo "===== $file =====" >> $backup_path/log
			echo "$(date)" >> $backup_path/log
			jpeginfo -c "$file" >> $backup_path/log || true
			echo "" >> $backup_path/log
			mv "$file" "$backup_path/${file//\//_}"
		else
			echo "===== $file ====="
			echo "$(date)"
			jpeginfo -c "$file"
		fi
	fi
done
			
		
