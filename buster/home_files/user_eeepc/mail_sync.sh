#!/bin/sh
set -e

# Ensure all "dir:*"-tagged mails are in proper directories.
basedir="/home/plom/test_mbsync/maildir/"
for tag in $(notmuch search --output=tags '*'); do
    if [ ! $(echo "${tag}" | cut -c-4) = "dir:" ]; then
        continue
    fi
    target_dir="${basedir}"$(echo "${tag}" | cut -c5-)"/cur/"
    for f in $(notmuch search --output=files tag:"${tag}"); do
         new_name=$(basename "${f}" | sed -e 's/,U=[0-9]*//')
         target_path="${target_dir}${new_name}"
         if [ ! "${target_path}" = "${f}" ]; then
             echo "Moving ${f} to ${target_path}."
             mv "${f}" "${target_path}"
         fi
    done
done

# Remove all "deleted"-tagged files from maildirs.
notmuch search --output=files tag:deleted | while read f; do
    echo "Deleting ${f}"
    rm "${f}"
done

# Sync changes back to server and update notmuch index.
mbsync -a
notmuch new
