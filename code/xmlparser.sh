#!/usr/bin/env bash
# https://gist.github.com/markusfisch/f60aac6863fac2c8c0b1
# Read XML from STDIN
read_xml()
{
	# concatenate lines
	local XML

	while read -r
	do
		XML=$XML${REPLY//$'\t'/ }
	done

	# parse XML string
	local TAG NAME DIR ARG VALUE
	local CONTENT='' INDEX=0

	while [[ $XML == *'<'* ]]
	do
		TAG=${XML#*<}
		TAG=${TAG%%>*}
		NAME=${TAG%% *}

		# skip comments
		case $NAME in
			'!--'*)
				XML=${XML#*-->}
				continue
				;;
		esac

		XML=${XML#*>}

		# skip special tags
		case ${NAME:0:1} in
			'/')
				echo $CONTENT > =cdata
				CONTENT=
				cd ..
				continue
				;;
			'?'|'!')
				continue
				;;
		esac

		# skip empty tags
		[[ $NAME == *'/' ]] && continue

		DIR=$NAME-$(( INDEX++ ))
		mkdir "$DIR"
		cd "$DIR" || return 1

		if [[ $TAG == *' '* ]]
		then
			# eval is required to support quoting of values
			eval "for ARG in ${TAG#* }; do echo \"\$ARG\"; done" |
				while read -r ARG
			do
				[ "$ARG" == '/' ] && break

				if [[ $ARG == *'='* ]]
				then
					VALUE=${ARG#*=}
					VALUE=${VALUE%/}

					# remove quotes
					case ${VALUE:0:1} in
						'"')
							VALUE=${VALUE#\"}
							VALUE=${VALUE%\"}
							;;
						"'")
							VALUE=${VALUE#\'}
							VALUE=${VALUE%\'}
							;;
					esac

					echo "$VALUE" > "${ARG%%=*}"
				else
					touch "$ARG"
				fi
			done
		fi

		if [[ $TAG == *'/' ]]
		then
			CONTENT=
			cd ..
			continue
		fi

		CONTENT=$CONTENT${XML%%<*}
	done
}

# Find file KEY and check if contents match VALUE
#
# @param 1 - KEY=VALUE pair
find_xml_arguments()
{
	local ARG

	for ARG in ${1//\&/ }
	do
		# skip arguments without a value
		[[ $ARG == *=* ]] || continue

		# try to match argument value
		[[ $(< "${ARG%%=*}") == "${ARG#*=}" ]] || return 1
	done &>/dev/null
}

# Print matching XML node
#
# @param 1 - XML path
find_xml_path()
{
	local NODE=${1%%/*}
	local DIR

	for DIR in ${NODE%%\?*}-*
	do
		cd "$DIR" &>/dev/null || break

		if [[ "$NODE" == *'?'* ]]
		then
			find_xml_arguments "${NODE#*\?}" || {
				cd ..
				continue
			}
		fi

		# either all arguments were found or no
		# arguments were specified for this node
		if [ "$NODE" == "${1%/}" ]
		then
			pwd
		else
			find_xml_path "${1#*/}"
		fi

		cd ..
	done
}

# Print matching XML nodes
#
# @param ... - XML paths
find_xml_paths()
{
	local IN OUT LAST

	for IN
	do
		LAST=${IN##*/}

		for OUT in $(find_xml_path $IN)
		do
			if [[ $LAST == *\?* ]] && [[ $LAST != *=* ]]
			then
				cat "$OUT/${IN##*\?}"
			else
				cat "$OUT/=cdata"
			fi
		done
	done
}

# Read XML from STDIN and find a node
#
# @param ... - XML path
xml()
{
	local XML_CACHE
	XML_CACHE=$(mktemp -d "${0##*/}.XXXXXXXXXX")

	(cd "$XML_CACHE" && read_xml && find_xml_paths "$@")

	rm -rf "$XML_CACHE"
}

if [ "${BASH_SOURCE[0]}" == "$0" ]
then
	if (( $# < 1 ))
	then
		echo "usage: ${0##*/} PATH/TO?ARGUMENT=VALUE/NODE..."
	else
		xml "$@"
	fi
fi
