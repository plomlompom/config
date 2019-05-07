#!/bin/sh
set -e

standard_repo="borg"
config_file="${HOME}/.borgrepos"

usage() {
    echo "Need operation as argument, one of:"
    echo "init"
    echo "store"
    echo "check"
    echo "export_keyfiles"
    echo "orgpush"
    echo "orgpull"
    false
}

read_pw() {
    eval $(ssh-agent)
    echo "ssh-add"
    ssh-add
    if [ "${#BORG_PASSPHRASE}" -eq 0 ]; then
        stty -echo
        printf "Borg passphrase: "
        read password
        stty echo
        printf "\n"
        export BORG_PASSPHRASE="${password}"
    fi
}

if [ ! -f "${config_file}" ]; then
    echo '# file read ends at last newline' >> "${config_file}"
fi
if [ "$#" -lt 1 ]; then
    usage
fi
first_arg="$1"
shift
if [ "${first_arg}" = "init" ]; then
    if [ ! "$#" -eq 1 ]; then
        echo "Need exactly one argument: target of form user@server"
        false
    fi
    target="$1"
    echo "Initializing: ${target}"
    borg init --verbose --encryption=keyfile "${target}:${standard_repo}"
    tmp_file="/tmp/new_borgrepos"
    echo "${target}" > "${tmp_file}"
    cat "${config_file}" >> "${tmp_file}"
    cp "${tmp_file}" "${config_file}"
elif [ "${first_arg}" = "store" ]; then
    if [ ! "$#" -eq 2 ]; then
        echo "Need precisely two arguments: archive name and path to archive."
        false
    fi
    archive_name=$1
    shift
    to_backup="$@"
    read_pw
    cat "${config_file}" | while read line; do
        first_char=$(echo "${line}" | cut -c1)
        if [ "${first_char}" = "#" ]; then
            continue
        fi
        repo="${line}:${standard_repo}"
        archive="${repo}::${archive_name}-{utcnow:%Y-%m-%dT%H:%M}"
        echo "Creating archive: ${archive}"
        borg create --verbose --list "${archive}" "${to_backup}"
    done
elif [ "${first_arg}" = "check" ]; then
    if [ ! "$#" -eq 0 ]; then
        echo "Need no arguments"
        false
    fi
    read_pw
    cat "${config_file}" | while read line; do
        first_char=$(echo "${line}" | cut -c1)
        if [ "${first_char}" = "#" ]; then
            continue
        fi
        repo="${line}:${standard_repo}"
        echo "Checking repo: ${repo}"
        borg check --verbose "${repo}"
    done
elif [ "${first_arg}" = "export_keyfiles" ]; then
    if [ ! "$#" -eq 1 ]; then
        echo "Need output tar file name."
        false
    fi
    tar_target="${1}"
    tmp_dir="${HOME}/.borgtmp"
    keyfiles_dir="${tmp_dir}/borg_keyfiles"
    mkdir -p "${keyfiles_dir}"
    cat "${config_file}" | while read line; do
        first_char=$(echo "${line}" | cut -c1)
        if [ "${first_char}" = "#" ]; then
            continue
        fi
        repo="${line}:${standard_repo}"
        borg key export "${repo}" "${keyfiles_dir}/${line}"
    done
    cur_dir="$(pwd)"
    cd "${tmp_dir}"
    target=$(basename "${keyfiles_dir}")
    tar cf "${tar_target}" "${target}"
    mv "${tar_target}" "${cur_dir}"
    cd
    rm -rf "${tmp_dir}"
elif [ "${first_arg}" = "orgpush" ]; then
    archive_name="orgdir"
    to_backup=~/org
    read_pw
    cat "${config_file}" | while read line; do
        first_char=$(echo "${line}" | cut -c1)
        if [ "${first_char}" = "#" ]; then
            continue
        fi
        repo="${line}:${standard_repo}"
        archive="${repo}::${archive_name}-{utcnow:%Y-%m-%dT%H:%M}"
        echo "Creating archive: ${archive}"
        borg create --verbose --list "${archive}" "${to_backup}" --exclude ~/org/.git
    done
elif [ "${first_arg}" = "orgpull" ]; then
    archive_name="orgdir"
    read_pw
    cd /
    cat "${config_file}" | while read line; do
        first_char=$(echo "${line}" | cut -c1)
        if [ "${first_char}" = "#" ]; then
            continue
        fi
        repo="${line}:${standard_repo}"
        archive=$(borg list "${repo}" | grep "${orgdir}" | tail -1 | cut -f1 -d' ')
        echo "Pulling archive: ${archive}"
        borg extract --verbose "${repo}::${archive}"
        break
    done
else
    usage
fi
