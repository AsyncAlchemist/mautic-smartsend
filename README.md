# MauticSmartSend 1.0

An intelligent script designed to send Mautic emails in a controlled manner, ensuring efficient email delivery and providing real-time feedback. Created and maintained by [Taylor Selden](https://x.com/tselden).

`MauticSmartSend` is designed to enhance the way Mautic sends emails by giving you more control and feedback in real-time. While Mautic comes with its own built-in method for sending emails through the `mautic:emails:send` command/cron job, our script offers an intelligent alternative with several advantages.

**Why use MauticSmartSend?**
1. **Granular Control**: Decide exactly how many emails are sent in each batch (via `MESSAGE_LIMIT`), and define the pause duration between batches (using `SLEEP_TIME`).
2. **Real-time Feedback**: Get live updates on the number of emails in the spool, the ones currently being sent, remaining emails, and an estimated finish time.
3. **Flexibility**: You can schedule this script to run as frequently as you desire, even every minute, using a cron job. This ensures that emails are sent out promptly and efficiently, and Mautic will only be invoked if there are mails that need to be sent.

**Intended Use**:
Replace Mautic's default `mautic:emails:send` cron job with `MauticSmartSend`. By doing so, you'll optimize the email delivery process, reduce the chances of server overloads, avoid getting rate limited, and get immediate feedback on the email sending status.

---

## Table of Contents
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
- [Features](#features)
- [FAQs](#faqs)
- [Changelog](#changelog)
- [Contributions](#contributions)
- [License](#license)
- [Acknowledgments](#acknowledgments)


## Installation

1. **Download the Script**:  
   Use `wget` to download the script directly from the GitHub repository.
   ```bash
   wget https://raw.githubusercontent.com/mrlazycoder/mautic-smartsend/main/mautic_smartsend.sh
   ```

2. Ensure you have the necessary dependencies installed:
    - PHP (version 7.4 or above is recommended)
    - Mautic (tested with version 4.4.1)

3. **Make the Script Executable**:  
   Once the script is downloaded, you'll need to make it executable.
   ```bash
   chmod +x mautic_smartsend.sh
   ```

4. **Configuration**:  
   Before you can run the script, you'll need to open it in your favorite text editor and configure some settings at the top of the script. See details below in the [Configuration](#configuration) section.

   ```bash
   nano mautic_smartsend.sh
   ```

5. Move it to your desired directory.

## Configuration

Inside the script, there are some constants which you should modify based on your environment:

- `PHP_EXEC`: The path to the PHP executable on your server. This is used to run PHP commands from the script.  
  Default: `/usr/local/bin/php`

- `SPOOL_DIR`: This is the directory where Mautic spools or queues the emails. It specifies the location from which the script will fetch the emails and process them.  
  Default: `/home/username/public_html/mautic/var/spool`

- `BIN_DIR`: This is the directory containing the Mautic console. The Mautic console is used by the script to send the emails, among other tasks.  
  Default: `/home/username/public_html/mautic/bin`

- `LOCK_FILE`: This is a temporary lock file's location. It is used to ensure that only one instance of the script runs at any given time, preventing any potential conflicts or errors.  
  Default: `/tmp/mautic_email_sender.lock`

- `MESSAGE_LIMIT`: This constant defines the maximum number of emails the script will process and send in a single cycle or iteration. 14 is the rate limit for Amazon SES.
  Default: `14`

- `SLEEP_TIME`: After sending a batch of emails, the script will wait or "sleep" for a certain period (in seconds) before proceeding to the next batch. This is to prevent exceeding the email service's rate limit.
  Default: `1`

## Usage

Execute the script from the terminal and get live feedback:

```bash
./mautic_smartsend.sh
```

Run in silent mode (i.e. for a cron job):

```bash
./mautic_smartsend.sh -s
```

## Features

- **Silent Mode**: Run the script without any terminal output.
- **Rate Limiting**: Adjust the sending rate based on your mail server's performance.
- **Locking Mechanism**: Ensures only one instance of the script is running. You can run as often as you like via cron and multiple executions will be avoided.

## FAQs

**Q:** Why am I seeing an error regarding the lock file?  
**A:** Ensure that the lock file directory is writable by the user running the script.

## Changelog

For a detailed history of changes made to this project, see the [CHANGELOG.md](CHANGELOG.md) file.

## Contributions

Feel free to fork the repository and submit pull requests. All contributions are welcome!

## License

This project is licensed under the GNU General Public License v3.0 (GPLv3) - see the [LICENSE.txt](LICENSE.txt) file for details.

The GNU GPLv3 is a free, copyleft license for software and other kinds of works. This license ensures that the software remains free and open-source, and any derivative works must also be under the same license. It promotes the distribution and modification of the software while ensuring that it remains free.

For more information about the GNU GPLv3, please visit the official [GNU website](https://www.gnu.org/licenses/gpl-3.0.en.html).

## Acknowledgments

- The entire [Mautic community](https://www.mautic.org/) for their amazing software that I use on a daily basis.