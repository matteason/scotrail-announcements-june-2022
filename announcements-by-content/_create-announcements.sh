#!/usr/bin/env bash
# 
# _create-announcements.sh
# 
# This bash shell script will parse the MP3 files found in ../announcements
# and use the transcription text from the Google Sheet (well done, those
# volunteers btw, great job transcribing!) to generate file names made up
# from the transcription text. Note that this script is really only useful
# to generate or regnerate copies of files from ../announcements within 
# a local copy of the git repository to then be committed back to the repo.
# 
# Example: 
#   0749.mp3 becomes a-broken-rail-0749.mp3
# 
# William Anderson <neuro@well.com> 

# define and check our environment
# CONTENT_PATH is where this script is located
CONTENT_PATH="$(dirname "$(realpath "${0}")")"
cd "${CONTENT_PATH}"
# CONTENT_DATA is an export of the Google Sheet as a tab separated file (TSV)
CONTENT_DATA="${CONTENT_PATH}/_announcements-transcripts.tsv"
if [ ! -s "${CONTENT_DATA}" ]; then echo "$(basename "${0}"): can't find $(basename "${CONTENT_DATA}")" >&2; exit 1; fi

# empty fields in TSVs are hard to parse in a bash loop, so 
# the 'tail' command at the end of the loop parses out the tabs
# and replaces them with a character very unlikely to be used,
# and the IFS variable sets separation based on that unlikely char
while IFS=$'\037' read FILE_ID NRE_ID TRANSCRIPT_TEXT TRANSCRIPT_CATEGORY NOTES TIMESTAMP TRANSCRIPT_MP3_FILENAME EMPTY1 EMPTY2 EMPTY3 EMPTY4 EMPTY5 EMPTY6 EMPTY7 EMPTY8 EMPTY9
do
	# let's parse the text transcription from the sheet and transform into
	# a filename that most operating systems should be OK with - wait, 
	# are you still using MS-DOS? whoops.
	CONTENT_TEXT="$(echo ${TRANSCRIPT_TEXT} | sed -e 's/ /-/ig' | tr -cd '[:alnum:][:cntrl:],_-' | tr '[:upper:]' '[:lower:]' | tr ',_' '-')"
	# if there is an NRE ID, i.e., this item being parsed is the name
	# of a station on the National Rail network, add the NRE ID to the
	# end of the filename
	if [ "${NRE_ID}" != "" ]
	then
		FILE_SUFFIX="${NRE_ID}-${FILE_ID}.mp3"
	else
		FILE_SUFFIX="${FILE_ID}.mp3"
	fi
	CONTENT_MP3_FILENAME="${CONTENT_TEXT}-${FILE_SUFFIX}"
	# this is the bit that might restrict where and how you run this
	# script; we're creating a hard link here, so the local files in
	# the git repo clone won't use double the disk space, but when
	# committed to the repo, they will be separate files, easy to
	# grab or use later.
	ln -vf "../announcements/${TRANSCRIPT_MP3_FILENAME}" "${CONTENT_PATH}/${CONTENT_MP3_FILENAME}"
done < <(tail -n +2 "${CONTENT_DATA}" | tr \\t \\037)

# "why didn't you do this in python or rust or [insert shiny here]?"
# because i've been hacking in bash since the '90s and some habits 
# are hard to break :)
