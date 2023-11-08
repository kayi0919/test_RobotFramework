*** Settings ***
Library             RPA.Email.ImapSmtp    smtp_server=smtp.gmail.com    smtp_port=587

*** Variables ***
#TODO
#帳號
${USERNAME}     username
#16碼gmail密碼
${PASSWORD}     password
#寄件者 tab分隔可多筆
${RECIPIENT}    recipient
#前一個案測試檔案
@{ATTACHMENTS}    log.html    report.html


*** Tasks ***

Send test email
    Authorize    account=${USERNAME}    password=${PASSWORD}
    Send Message    sender=${USERNAME}
    ...    recipients=${RECIPIENT}
    ...    subject=Result By Robot Framework
    ...    body=Result Robot email.
    ...    attachments=@{ATTACHMENTS}