#!/bin/sh
# python3 syslog_gen.py --host 127.0.0.1 --port 5514 --file sample_logs.txt --count 100000
set -x
python3 syslog_gen.py --host ${REMOTE_HOSTNAME_LOGS} --port 5514 --file sample_logs.txt --count 100000
