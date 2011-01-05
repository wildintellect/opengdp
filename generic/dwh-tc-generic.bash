#!/bin/bash
# Copyright (c) 2010, Brian Case
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

function print_res {
    maxResolution=156543.0339 
    for (( zoom=0; zoom<=24; ++zoom ))
    do
        bc -l <<<"$maxResolution / 2^${zoom}"
    done
}

function dotc {


    res=$(print_res | tr "\n" "," | sed -r 's/,$//')
(
    for map in $(find $outdir -name "*.map" | sort )
    do
        if [[ "$doovr" == "yes" ]]
        then
            layer=$(grep "$map" -e GROUP | cut -d "'" -f 2 | uniq )
        else
            layer=$(grep "$map" -e NAME  | cut -d "'" -f 2 | uniq )
        fi
        
        read w s e n < <(getextent $(echo "$layer" | sed 's:.*_\([0-9]*\):\1:'))
	
        if float_cmp "$n < 86" && float_cmp "$s > -86"
        then
            read gw gs junk < <(gdaltransform -s_srs EPSG:4326 -t_srs EPSG:900913 <<< "$w $s")
            read ge gn junk < <(gdaltransform -s_srs EPSG:4326 -t_srs EPSG:900913 <<< "$e $n")
        
            cat << EOF

[${layer}]
type=WMS
url=${urlcgibin}?
layers=${layer}
extension=png
tms_type=google
levels=24
spherical_mercator=true
resolutions=${res}
bbox=${gw},${gs},${ge},${gn}
EOF

        else    
            cat << EOF

[${layer}]
type=WMS
url=${urlcgibin}?
layers=${layer}
extension=png
tms_type=google
levels=24
spherical_mercator=true
EOF
       fi



    done
) > ${basedir}/${dsname}.tilecache.conf

}
