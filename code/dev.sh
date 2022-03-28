#!/bin/bash

# https://stackoverflow.com/questions/893585/how-to-parse-xml-in-bash
# https://gist.github.com/mralexgray/1209534
# https://www.banjocode.com/post/bash/replace-text-bash/



dev_getfeed () {
                XMLFeed=$(curl https://www.bleepingcomputer.com/feed/)
                # echo "$XMLFeed"
                }

dev_getValue () {
                echo "$XMLFeed" | sed -e 's%(^<title>|</title>$)%%g'
                }

read_dom () {
            local IFS=\>
            echo "$XMLFeed" | read -d \< ENTITY CONTENT
            }

dev () {
        dataSample="It is quite possible <that> the characters of <the> nematocysts might afford data as useful to the systematist in this group as do the spicules of sponges, for instance."
        # echo $dataSample
        # $dataSample | awk -F"[<>]" '{print $2}' 
        echo "Number of characters in the string is ${#dataSample}"
        echo "--------------------"
        echo ${dataSample[@]}
        echo ${dataSample[0]}
        echo ${dataSample[1]}
        echo ${dataSample[2]}
        echo ${dataSample[3]}
        echo ${dataSample[4]}

        echo "--------------------"
        echo ${dataSample:0:1}
        }

dev

# ### Load File find-replace with line inserts, store in variable
# ----------------------------------------------------------
# XMLFeed='cat feed4.xml'
# result=$($XMLFeed | sed -e 's/<description>/\n\n<description>/g')
# echo -e "-------------- \n"
# echo $result

# ### Load File then find-replace with line inserts
# ----------------------------------------------------------
# XMLFeed='cat feed4.xml'
# $XMLFeed | sed -e 's/<description>/\n\n<description>/g'

# ### run functions
# ----------------------------------------------------------
# dev_getfeed
# dev_getValue

# ### replacement examples and inserting line breaks
# ----------------------------------------------------------
# sed 's/first/second/g' <<< "aaa This is the first sentence  bbb This is the first sentence ccc"
# echo "ddd This is the first sentence eee This is the first sentence fff" | sed 's/first/second/g'
# echo "ddd This is the first sentence eee This is the first sentence fff" | sed 's/first/seco\nd/g'
# sed "s/${old}/${new}/g" <<<"$sentence"