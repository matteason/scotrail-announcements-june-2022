#!/usr/bin/env bash
# 
CONTENT_PATH="$(dirname "$(realpath "${0}")")"
cd "${CONTENT_PATH}"
CONTENT_DATA="${CONTENT_PATH}/_announcements-transcripts.tsv"
if [ ! -s "${CONTENT_DATA}" ]; then echo "$(basename "${0}"): can't find $(basename "${CONTENT_DATA}")" >&2; exit 1; fi

while IFS=$'\037' read FILE_ID NRE_ID TRANSCRIPT_TEXT TRANSCRIPT_CATEGORY NOTES TIMESTAMP TRANSCRIPT_MP3_FILENAME EMPTY1 EMPTY2 EMPTY3 EMPTY4 EMPTY5 EMPTY6 EMPTY7 EMPTY8 EMPTY9
do
	CONTENT_TEXT="$(echo ${TRANSCRIPT_TEXT} | sed -e 's/ /-/ig' | tr -cd '[:alnum:][:cntrl:],_-' | tr '[:upper:]' '[:lower:]' | tr ',_' '-')"
	if [ "${NRE_ID}" != "" ]
	then
		FILE_SUFFIX="${NRE_ID}-${FILE_ID}.mp3"
	else
		FILE_SUFFIX="${FILE_ID}.mp3"
	fi
	CONTENT_MP3_FILENAME="${CONTENT_TEXT}-${FILE_SUFFIX}"
	ln -svf "../announcements/${TRANSCRIPT_MP3_FILENAME}" "${CONTENT_PATH}/${CONTENT_MP3_FILENAME}"
done < <(tail -n +2 "${CONTENT_DATA}" | tr \\t \\037)
