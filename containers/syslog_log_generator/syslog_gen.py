#!/usr/bin/env python3
"""
Syslog Generator

Had a need to generate generic syslog messages to
test open source logging solutions.
"""
from __future__ import annotations

import argparse
import logging
import random
import socket
import sys
import time

from logging.handlers import SysLogHandler


# Modify these variables to change the hostname, domainame, and tag
# that show up in the log messages.

hostname: str = "host"
domain_name: str = ".example.com"
tag: list[str] = ["kernel", "python", "ids", "ips"]
syslog_level: list[str] = ["info", "error", "warn", "critical"]


def raw_udp_sender(message: str, host: str, port: int) -> None:
    """Send a UDP message to a specified host and port.

    Args:
        message: The message to send
        host: The target host address
        port: The target port number
    """
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        message = bytes(message, "UTF-8")
        send = sock.sendto(message, (host, port))
    finally:
        sock.close()


def open_sample_log(sample_log: str) -> str:
    """Open and return a random line from a sample log file.

    Args:
        sample_log: Path to the sample log file

    Returns:
        A randomly selected log line

    Raises:
        FileNotFoundError: If the specified file cannot be found
        SystemExit: If file is invalid
    """
    try:
        with open(sample_log) as sample_log_file:
            random_logs = random.choice(list(sample_log_file))  # noqa: S311
            return random_logs
    except FileNotFoundError:
        print("[+] ERROR: Please specify valid filename")
        return sys.exit()


def syslogs_sender() -> None:
    """Send syslog messages based on command line arguments.

    Uses the global args object to determine:
    - Target host and port
    - Input file for messages
    - Number of messages to send

    Generates randomized fields for each message including:
    - Hostname
    - Tag
    - Syslog level
    - Process ID
    """
    # Initialize SysLogHandler
    logger = logging.getLogger()
    logger.setLevel(logging.INFO)
    syslog = SysLogHandler(address=(args.host, args.port))
    logger.addHandler(syslog)

    for message in range(1, args.count + 1):
        # Randomize some fields
        time_output = time.strftime("%b %d %H:%M:%S")
        random_host = random.choice(range(1, 11))  # noqa: S311
        random_tag = random.choice(tag)  # noqa: S311
        random_level = random.choice(syslog_level)  # noqa: S311
        fqdn = f"{hostname}{random_host}{domain_name}"
        random_pid = random.choice(range(500, 9999))  # noqa: S311

        message = open_sample_log(args.file)
        fields = {
            "host_field": fqdn,
            "date_field": time_output,
            "tag_field": random_tag,
        }

        format = logging.Formatter(
            f"%(date_field)s %(host_field)s {random_tag}[{random_pid}]: %(message)s"
        )
        syslog.setFormatter(format)

        # Create the complete formatted message
        complete_message = format.format(
            logging.LogRecord(
                name="",
                level=0,
                pathname="",
                lineno=0,
                msg=message,
                args=(),
                exc_info=None,
                extra=fields,
            )
        )

        print(f"[+] Complete message: {complete_message}")
        print(f"[+] Sent: {time_output}: {message}", end="")

        getattr(logger, random_level)(message, extra=fields)

    logger.removeHandler(syslog)
    syslog.close()


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--host", required=True, help="Remote host to send messages")
    parser.add_argument(
        "--port", type=int, required=True, help="Remote port to send messages"
    )
    parser.add_argument("--file", required=True, help="Read messages from file")
    parser.add_argument(
        "--count", type=int, required=True, help="Number of messages to send"
    )
    parser.add_argument(
        "--sleep",
        type=float,
        help="Use with count flag to \
                        send X messages every X seconds, sleep being seconds",
    )

    args = parser.parse_args()

    if args.sleep:
        print(
            f"[+] Sending {args.count} messages every {args.sleep} seconds to {args.host} on port {args.port}"
        )
        try:
            while True:
                syslogs_sender()
                time.sleep(args.sleep)
        except KeyboardInterrupt:
            # Use ctrl-c to stop the loop
            print("[+] Stopping syslog generator...")
    else:
        print(
            f"[+] Sending {args.count} messages to {args.host} on port {args.port}"
        )
        syslogs_sender()
