## memory-daemon

This project documents a memory-daemon cron service that tracks the used RAM in a server and terminates a dominant user process if a defined used RAM threshold is exceeded. Additionally, this service sends an email to the user to inform her/him about the termination of a memory-consuming service.

This service is not meant as a replacement for server management programs, but is rather meant for situations where users want to manage their own memory consuming processes to prevent annoying server crashes.

**Important:** This service only has permissions to terminate processes from the user which installed/uses it. It cannot terminate other users' processes. In the case that another user's process results in high RAM usage, an email will be sent to registered users warning them about the high RAM usage.

### Installation

This project offers a simple shell-based installation script.

1. Install `mem_daemon`:

    ```
    $ make install
    ```

2. If all goes well, edit the default configuration file `~/.config/mem_daemon/md.conf`

    The following options must be configured in order to use this service:

    a. `receiver`: receiver's email address regarding RAM warnings/termination notifications. Multiple emails can be configured if they are all comma-separated.

    b. `sender`: the sender's email address (a dummy one can be made with an email service)

    c. `pass`: plaintext password for the sender's email address (poses security risk; advisable to use a non-critical email address)

    d. `threshold`: percentage of total memory used must cross this `integer` threshold in order to trigger the memory-daemon into killing the most ram intensive process and sending the user an email

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

3. Once all the above options have been configured, we can test the service. An email will be sent to your specified account and no process will be killed. Please check your spam folder in case nothing appears. For this, execute the following:

    ```
    $ make test
    ```

    Below is an example of the dummy email:
    
    <kbd>
    <img src="/img/screenshot.png" width="600">
    </kbd>

4. Finally, in order to set up the memory-daemon as a regular service, we would need to install a `crontab` for it. You will be prompted to input the periodicity (in minutes) with which the memory-daemon checks your server. Execute the following: 

    ```
    $ make cronjob
    ```
    
    **Troubleshooting:** If an error is thrown that crontabs are not installed for the user, simply run `crontab -e`. Then, a prompt should appear requesting for the text editor that should be used to edit the crontab, for which you can choose your most preferred text editor. Next, you can enter a dummy crontab (which prints `hello world`) to initialize the service, such as:
    
    ```
    *\1 * * * * /bin/echo "hello world"
    ```
    
    Then, exit the editor and the following output should be received: `crontab: installing user crontab`. Now, you can proceed back with step 4. You can also safely remove the line containing the `/bin/echo` command after step 4.

    Now, the memory-daemon is activated. In order to test out its utility, you can manually set the threshold in `~/.config/mem_daemon/md.conf` to a low value, such as `30`. Then, run a RAM intensive script and check if it gets terminated by `mem_daemon` and if you receive an email notification about it.

    **Note:** The output of the crontab will be appended to `~/.config/mem_daemon/md.log` for debugging purposes.

### Uninstallation

In order to uninstall `mem_daemon`, execute the following:

```
$ make uninstall
```

This will remove the transferred executables, as well as any installed `crontab`.
