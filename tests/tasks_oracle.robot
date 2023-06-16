*** Settings ***
Library    RPA.Database
#Library    OperatingSystem
#Library    OracleLib
#Library    MyLibrary

*** Variables ***
${DB_HOST}       localhost
${DB_PORT}       1522
${DB_NAME}       ORCLDB
${DB_USERNAME}   smartida
${DB_PASSWORD}   oracle

#*** Test Cases ***
#Connect to Oracle Database
#    Connect To Database    cx_Oracle    database=${DB_NAME}    username=${DB_USERNAME}    password=${DB_PASSWORD}    host=${DB_HOST}    port=${DB_PORT}    

