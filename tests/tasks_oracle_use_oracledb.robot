*** Comments ***
需安裝oracledb套件
1. robocorp
    conda.yaml需加入以下設定
    - pip:
      - oracledb==1.3.2

2. ps
    pip install oracledb

*** Settings ***
Library    RPA.Database

*** Variables ***
${DB_HOST}       localhost
${DB_PORT}       1522
${DB_NAME}       ORCLCDB
${DB_USERNAME}   smartida
${DB_PASSWORD}   oracle

#*** Tasks ***
#Get Orders From Database
#    Connect To Database    oracledb    ${DB_NAME}    ${DB_USERNAME}    ${DB_PASSWORD}    ${DB_HOST}    ${DB_PORT}
#    ${animals}    Query    Select * FROM animal
#    FOR    ${animal}    IN    @{animals}
#        Log To Console    ${animal}[ID] - ${animal}[NAME]
#    END
#    [Teardown]    Disconnect From Database
