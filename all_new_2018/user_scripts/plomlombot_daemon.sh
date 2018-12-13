#!/bin/sh
set -e

# Repeatedly parse config file for GPG key and bot screen configs.
path=~/.plomlombot
db_dir="${HOME}/plomlombot_db"
irclogs_dir=/var/www/html/irclogs
irclogs_pw_dir=/var/www/irclogs_pw
while true; do
    if [ -f "${path}" ]; then
        cat "${path}" | while read line; do
    	    first_word=$(echo -n "${line}" | cut -d' ' -f1)

    	    # Read "bot:" line, start bot screen session from it if not yet existing,
    	    # set up irclogs dir if not yet existing.
    	    if [ "${first_word}" = "bot:" ]; then
    	        session_name=$(echo -n "${line}" | cut -d' ' -f2)
    	        bot_name=$(echo -n "${line}" | cut -d' ' -f3)
    	        channel_name=$(echo -n "${line}" | cut -d' ' -f4)
                shortened_channel_name="${channel_name}"
                first_char=$(echo -n "${channel_name}" | cut -c1)
                if [ "${first_char}" = "#" ]; then
                    shortened_channel_name=$(echo -n "${channel_name}" | cut -c2-)
                fi
    	        server_name=$(echo -n "${line}" | cut -d' ' -f5)
                login_user=$(echo -n "${line}" | cut -d' ' -f6)
                login_pw=$(echo -n "${line}" | cut -d' ' -f7)
    	        set +e
    	        screen -S "${session_name}" -Q select . > /dev/null
    	        start_screen=$?
    	        set -e
    	        if [ "${start_screen}" -eq "1" ]; then
    	    	cd ~/plomlombot-irc
    	    	screen -d -m -S "${session_name}" ./run.sh -n "${bot_name}" -s "${server_name}" "${channel_name}"
    	        fi
    	        md5_server=$(echo -n "${server_name}" | md5sum | cut -d' ' -f1)
    	        md5_channel=$(echo -n "${channel_name}" | md5sum | cut -d' ' -f1)
    	        logs_dir="${db_dir}/${md5_server}/${md5_channel}/logs"
    	        # FIXME: Note the trouble we will have if we have the same channel
    	        # name on different servers …
                ln -sfn "${logs_dir}" "${irclogs_dir}/${shortened_channel_name}"
                echo "${login_user}":'{PLAIN}'"${login_pw}" > "${irclogs_pw_dir}/${shortened_channel_name}"

    	    # If "key:" line, encrypt old raw logs to that GPG key.
    	    elif [ "${first_word}" = "gpg_key": ]; then
    	        key=$(echo -n "${line}" | cut -d' ' -f2)
                mkdir -p ~/plomlombot_db
    	        cd ~/plomlombot_db
    	        find . -path '*/*/raw_logs/*.txt' -mtime +1 -type f -exec gpg --recipient "${key}" --trust-model always --encrypt {} \; -exec rm {} \;
    	    fi

        done
        sleep 1
    fi
done
