#!/bin/bash

name_search_dir=$1
asset_search_dir=$2
prefix_from=$3
prefix_to=$4

if [[ $# -ne 4 ]]; then
    echo 'parameters with name search directory, asset search directory, from prefix, to prefix'
    return 0;
fi

echo echo "name_search_dir: '${name_search_dir}'"
echo echo "asset_search_dir: '${asset_search_dir}'"
echo echo "prefix_from: '${prefix_from}'"
echo echo "prefix_to: '${prefix_to}'"
echo 'press any key to continue'
read


function function_replace_text_in_array() {
    file_lines=$1;
    name_from=$2;
    name_to=$3;
    echo ${file_lines} | while read line
    do
        /usr/bin/sed -i '' "s/${name_from}/${name_to}/g" $line
    done
}


function function_rename() {
    images=`/usr/bin/find $1 -depth 1 -name '*.png'`;
    if [[ "${images}" != "" ]]; then
        echo ${images} | while read line
        do
            file_full_path=${line};
            filename=`/usr/bin/basename ${file_full_path}`;
            directory=`/usr/bin/dirname ${file_full_path}`;

            new_filename=${filename//$prefix_from/$prefix_to};
            mv ${file_full_path} "${directory}/${new_filename}"

            function_replace_text_in_array "$1/Contents.json" $filename $new_filename;
        done
    fi

    file_full_path=$1;
    filename=`/usr/bin/basename ${file_full_path}`;
    directory=`/usr/bin/dirname ${file_full_path}`;
    new_filename=${filename//$prefix_from/$prefix_to};
    mv ${file_full_path} "${directory}/${new_filename}"

    extendname='.imageset'
    name="@\""${filename//${extendname}/}"\""
    new_anme="@\""${new_filename//${extendname}/}"\""
    echo $name;
    echo $new_anme

    file_contain_prefix=`/usr/bin/grep -lr $name $name_search_dir`;
    if [[ "${file_contain_prefix}" != "" ]]; then
        function_replace_text_in_array ${file_contain_prefix} $name $new_anme
    fi

    return 0;
}


headers=`/usr/bin/find ${asset_search_dir} -name "${prefix_from}*.imageset"`;

if [[ "$headers" != "" ]]; then
    echo $headers | while read line
    do
        function_rename ${line};
    done
fi
