## memory-daemon

This project documents a memory daemon cron service that tracks the used RAM in a server and terminates a dominant user process if a defined used RAM threshold is exceeded. Additionally, this service sends an email to the user to inform her/him about the termination of a memory-consuming service.

This service is not meant as a replacement for server management programs, but is rather meant for situations where servers are not well managed by admins and where users want to manage their own memory consuming processes to prevent annoying server crashes.

**Important:** This service only has permissions to terminate processes from the user which installed/uses it. It cannot terminate other users' processes. In the case that another user's process results in high RAM usage, an email will be sent to registered users warning them about the high RAM usage.

### Installation

This project offers a simple shell-based installation script.

1. Log into your remote server and clone this repository.

    ```shell
    $ git clone https://github.com/atreyasha/memory-daemon.git && cd memory-daemon
    ```
    
2. Run the memory-daemon wizard in `md_wizard` and select `1` to install the service:

    ```
    $ ./md_wizard

    1) Install memory daemon
    2) Edit md.conf
    3) Test memory daemon with dummy trigger
    4) Add crontab for memory daemon
    5) Uninstall memory daemon
    #? 1
    ```

3. If all goes well, run `md_wizard` again and select `2` to edit the config file `~/.config/mem_daemon/md.conf`

    ```
    $ ./md_wizard

    1) Install memory daemon
    2) Edit md.conf
    3) Test memory daemon with dummy trigger
    4) Add crontab for memory daemon
    5) Uninstall memory daemon
    #? 2
    ```

    The following options must be configured in the configuration file in order to use this service:

    a. `receiver`: receiver's email address regarding RAM warnings/termination notifications. Multiple emails can be configured if they are all comma-separated.

    b. `sender`: the sender's email address (a dummy one can be made with an email service)

    c. `pass`: plaintext password for the sender's email address (poses security risk; advisable to use a non-critical email address)

    d. `threshold`: percentage of total memory used must cross this threshold in order to trigger the memory daemon into killing the most ram intensive process and sending the user an email

    e. `smtp`: smtp address of the SMTP server for the sender's email provider

    f. `port`: port of the above-defined smtp address

    An example of a valid `md.conf` is shown below:

    ```
    receiver receiver@somemail.com
    sender sender@anothermail.com
    pass somepass
    threshold 90
    smtp smtp.anothermail.com
    port 587
    ```

4. Once all the above options have been configured, run `md_wizard` and select `3` to run a dummy test. An email will be sent to your specified account and no process will be killed. Please check your spam folder in case nothing appears.

    ```
    $ ./md_wizard

    1) Install memory daemon
    2) Edit md.conf
    3) Test memory daemon with dummy trigger
    4) Add crontab for memory daemon
    5) Uninstall memory daemon
    #? 3
    ```

    Below is an example of the dummy email:
    
    <kbd>
    <img src="/img/screenshot.png" width="600">
    </kbd>

5. Finally, in order to set up the memory daemon as a regular service, we would need to install a `crontab` for it. Run `md_wizard` and select `4`. You will be prompted to input the periodicity (in minutes) with which the memory daemon checks your server. 

    ```
    $ ./md_wizard

    1) Install memory daemon
    2) Edit md.conf
    3) Test memory daemon with dummy trigger
    4) Add crontab for memory daemon
    5) Uninstall memory daemon
    #? 4
    ```

    Now, the memory daemon is activated. In order to test out its utility, you can manually set the threshold in `~/.config/mem_daemon/md.conf` to a low value, such as `30`. Then, run a RAM intensive script and check if it gets terminated by `mem_daemon` and if you receive an email notification about it.

    **Note:** The output of the crontab will be appended to `~/.config/mem_daemon/tmp.log` for debugging purposes.

### Uninstallation

In order to uninstall `mem_daemon`, simply run `md_wizard` within the cloned git repository and select `5`.

```
$ ./md_wizard

1) Install memory daemon
2) Edit md.conf
3) Test memory daemon with dummy trigger
4) Add crontab for memory daemon
5) Uninstall memory daemon
#? 5
```

This will remove the transferred binaries and will prompt the user to decide if the relevant `crontab` should be removed.
