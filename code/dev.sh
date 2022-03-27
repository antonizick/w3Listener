#!/bin/bash

# https://stackoverflow.com/questions/893585/how-to-parse-xml-in-bash
# https://gist.github.com/mralexgray/1209534



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

# dev_getfeed
# dev_getValue

:'
var_change () {
            local var1='local 1'
            echo Inside function: var1 is $var1 : var2 is $var2
            var1='changed again'
            var2='2 changed again'
            }

var1='global 1'
var2='global 2'

echo Before function call: var1 is $var1 : var2 is $var2

var_change

echo After function call: var1 is $var1 : var2 is $var2
'