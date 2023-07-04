*** Comments ***
需安裝cx_Oracle套件
1. robocorp
    conda.yaml需加入以下設定
    - pip:
      - cx_Oracle==8.3.0

2. ps
    pip install cx_Oracle

*** Settings ***
Library    RPA.Database

*** Variables ***
${DB_HOST}       localhost
${DB_PORT}       1522
${DB_NAME}       ORCLCDB
${DB_USERNAME}   smartida
${DB_PASSWORD}   oracle

*** Tasks ***
Connect to Oracle Database
    Connect To Database    cx_Oracle    database=${DB_NAME}    username=${DB_USERNAME}    password=${DB_PASSWORD}    host=${DB_HOST}    port=${DB_PORT}
    ${animals}    Query    Select * FROM animal
    FOR    ${animal}    IN    @{animals}
        Log To Console    ${animal}[ID] - ${animal}[NAME]
    END
    [Teardown]    Disconnect From Database

