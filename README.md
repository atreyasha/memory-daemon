## Memory Daemon

This project documents a memory daemon cron service that tracks the used RAM in a server and terminates a dominant user process to conserve memory. Additionally, this service sends an email to the user to inform her/him about the termination of a memory-consuming service. 

This service is not meant as a replacement for server management programs, but is rather meant for situations where servers are not managed by root users and where users want to manage their own memory consuming processes to prevent annoying server crashes.

### Installation

This project offers a simple shell-based installation process.

1. Log into your remote server and clone this repository.

```shell
$ git clone https://github.com/atreyasha/memory-daemon.git && cd memory-daemon
```
    
2. Run the memory-daemon wizard in `md_wizard` and select `1` to install the service:

```
$ ./md_wizard

1) Install memory daemon		  3) Test memory daemon with dummy trigger  5) Uninstall memory daemon
2) Edit mail.conf			  4) Add crontab for memory daemon
#? 1
```
