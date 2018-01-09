#!/bin/bash

search_dir=$1
prefix_from=$2
prefix_to=$3

if [[ $# -ne 3 ]]; then
    echo 'parameters with search directory, from prefix, to prefix'
    return 0;
fi

echo echo "search_dir: '${search_dir}'"
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

function function_replace_text() {
    pbxproj_files=`/usr/bin/find ${search_dir} -name project.pbxproj`
    if [[ "${pbxproj_files}" != "" ]]; then
        function_replace_text_in_array ${pbxproj_files} $1 $2
    fi

    file_contain_prefix=`/usr/bin/grep -lr $1 $search_dir`;
    if [[ "${file_contain_prefix}" != "" ]]; then
        function_replace_text_in_array ${file_contain_prefix} $1 $2
    fi
}

function function_rename() {
    file_full_path=$1;
    filename=`/usr/bin/basename ${file_full_path}`;
    directory=`/usr/bin/dirname ${file_full_path}`;

    filename_no_ext=${filename%.h};
    new_filename_no_ext=${filename_no_ext//$prefix_from/$prefix_to};
    new_h_file_full_path="${directory}/${new_filename_no_ext}.h";
    mv ${file_full_path} "${directory}/${new_filename_no_ext}.h"

    m_file_full_path="${directory}/${filename_no_ext}.m";
    if [[ -f ${m_file_full_path} ]]; then
        new_m_file_full_path="${directory}/${new_filename_no_ext}.m";
        mv $m_file_full_path $new_m_file_full_path
    fi

    function_replace_text $filename_no_ext $new_filename_no_ext;
    return 0;
}

headers=`/usr/bin/find $search_dir -name $prefix_from*.h`;

if [[ "$headers" != "" ]]; then
    echo $headers | while read line
    do
        function_rename ${line};
    done
fi


