#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# get dependencies
import re
import smtplib
import datetime
import argparse
from email.utils import formatdate
from email.mime.text import MIMEText

#########################
# define email function
#########################

def getCurrentTime():
    return datetime.datetime.now().strftime("%Y_%m_%d_%H_%M_%S")

def sendMail(receiver,sender,password,text,smtp,port,
             threshold,col_log,selfie):
    # define mail variables
    subject_1 = "[Process Termination Notification] "
    subject_0 = "[RAM Threshold Notification] "
    pre_text_1 = 'Dear User,\n\n`{}` was terminated on {} as the total used RAM threshold of {}% was exceeded.\n\nBelow is a footprint of the process before it was terminated:\n\n'
    pre_text_0 = 'Dear User,\n\nThe total used RAM threshold of {}% was exceeded by a process from another user `{}` on {}.\n\nBelow is a footprint of the process, for your information:\n\n'
    end = "\n\nBest,\n\nYour Memory Daemon"
    # get command information from (assumed) last column
    command = text.split()[(col_log*2)-1]
    if selfie == 1:
        subject = subject_1 + command
        pre_text = pre_text_1.format(command,getCurrentTime(),threshold)
    elif selfie == 0:
        subject = subject_0 + command
        pre_text = pre_text_0.format(threshold,command,getCurrentTime())
    text = pre_text + "```\n" + re.sub("<space>","\n",re.sub(r"\s+"," ",
                                       re.sub(r"\n","<space>",text)))+ "\n```"+ end
    msg = MIMEText(text)
    msg['Subject'] = subject
    msg['From'] = sender
    msg['To'] = receiver
    msg["Date"] = formatdate(localtime=True)
    # connect to SMTP server
    s = smtplib.SMTP(smtp,port)
    # start TLS secure connection
    s.starttls()
    # log into SMTP server
    s.login(sender,password)
    # send email(s) and quit
    receiver=re.split(r"\s*,\s*",receiver)
    for rec in receiver:
        s.sendmail(sender,rec,msg.as_string())
    s.quit()

#########################
# main command call
#########################

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    requiredNamed = parser.add_argument_group('required named arguments')
    requiredNamed.add_argument('--receiver',
                               help='email receipient(s)', required=True)
    requiredNamed.add_argument('--sender',
                               help='email sender', required=True)
    requiredNamed.add_argument('--password',
                               help='email sender password', required=True)
    requiredNamed.add_argument('--smtp', help='smtp address', required=True)
    requiredNamed.add_argument('--port', help='smtp port', type=int, required=True)
    requiredNamed.add_argument('--text', help='raw message to send', required=True)
    requiredNamed.add_argument('--threshold', help='RAM threshold', required=True)
    requiredNamed.add_argument('--columns-log', help='columns in log file',
                               type=int, required=True)
    requiredNamed.add_argument('--selfie', type=int,
                               help='whether own process or from someone else', required=True)
    args = parser.parse_args()
    sendMail(args.receiver,args.sender,args.password,args.text,
             args.smtp,args.port,args.threshold,args.columns_log,
             args.selfie)
