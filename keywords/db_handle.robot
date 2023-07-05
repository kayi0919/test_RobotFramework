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
Library    RPA.FileSystem
Library    String

*** Variables ***
${DB_HOST}       localhost
${DB_PORT}       1522
${DB_NAME}       ORCLCDB
${DB_USERNAME}   smartida
${DB_PASSWORD}   oracle

*** Keywords ***
End db handle
    [Arguments]    ${tempSqlScript}
    Clean tmep file    ${tempSqlScript}
    Disconnect From Database

Clean up Report
    [Arguments]    ${report}    ${disease}
    Connect To Database    cx_Oracle    ${DB_NAME}    ${DB_USERNAME}    ${DB_PASSWORD}    ${DB_HOST}    ${DB_PORT}
    
    ${script}    Get SQL SCRIPT    clean_up_report
    ${script}    Replace String    ${script}    {{REPORT_ID}}    ${report}
    ${script}    Replace String    ${script}    {{DISEASE_ID}}    ${disease}
    ${sqlstring}    Set Variable    SELECT SYSTEM_ID FROM REPORT WHERE ID='${report}' AND REVISE_HISTORY=1
    ${query_rlt}    Query    ${sqlstring}
    ${first_row}    Set Variable    ${query_rlt[0]}    # 取得第一筆資料
    ${system_id}    Set Variable    ${first_row[0]}    # 取得第一個欄位值

    #-- 通報單
    Query    DELETE FROM REPORT WHERE SYSTEM_ID = '${system_id}'
    Query    DELETE FROM REPORT_ANIMAL WHERE SYSTEM_ID = '${system_id}'
    Query    DELETE FROM REPORT_TRAVEL WHERE SYSTEM_ID = '${system_id}'
    Query    DELETE FROM REPORT_CONTACT_INFO WHERE SYSTEM_ID = '${system_id}'
    Query    DELETE FROM REPORT_SYMPTOMS WHERE SYSTEM_ID = '${system_id}'
    # 直接嘗試刪除
    Run Keyword And Ignore Error    Query    DELETE FROM REPORT_SUPPLEMENT_${disease} WHERE SYSTEM_ID = '${system_id}'
    Log To Console    deleted row(s) from REPORT、REPORT_SYMPTOMS、REPORT_ANIMAL、REPORT_TRAVEL、REPORT_CONTACT_INFO、REPORT_SUPPLEMENT_${disease} (if existed)
    #-- 研判結果
    Query    DELETE FROM REPORT_DETERMINED WHERE SYSTEM_ID = '${system_id}'
    Log To Console    deleted row(s) from REPORT_DETERMINED
    #-- 送驗資料
    Query    DELETE FROM SAMPLE_RESULT WHERE BARCODE IN (SELECT SAMPLE_ID FROM REPORT_SAMPLE WHERE SYSTEM_ID = '${system_id}')
    Query    DELETE FROM SAMPLE_RESULT_PATHOGEN WHERE BARCODE IN (SELECT SAMPLE_ID FROM REPORT_SAMPLE WHERE SYSTEM_ID = '${system_id}')
    Query    DELETE FROM SAMPLE_RESULT_ANTIBODY WHERE BARCODE IN (SELECT SAMPLE_ID FROM REPORT_SAMPLE WHERE SYSTEM_ID = '${system_id}')
    Query    DELETE FROM REPORT_SAMPLE WHERE SYSTEM_ID = '${system_id}'
    Log To Console    deleted row(s) from REPORT_SAMPLE、SAMPLE_RESULT、SAMPLE_RESULT_PATHOGEN、SAMPLE_RESULT_ANTIBODY
    #-- 刪除通報單異動紀錄
    Query    DELETE FROM REPORT_FIELD_DIFF WHERE ID IN (SELECT LOG_ID FROM REPORT_FIELD_DIFF_SUMMARY WHERE SYSTEM_ID = '${system_id}')
    Query    DELETE FROM REPORT_FIELD_DIFF_SUMMARY WHERE SYSTEM_ID = '${system_id}'
    Log To Console    deleted row(s) from REPORT_FIELD_DIFF、REPORT_FIELD_DIFF_SUMMARY

    Disconnect From Database

Clean up Cluster
    [Arguments]    ${_cluster}
    Connect To Database    cx_Oracle    ${DB_NAME}    ${DB_USERNAME}    ${DB_PASSWORD}    ${DB_HOST}    ${DB_PORT}
    
    #${script}    Get SQL SCRIPT    clean_up_cluster
    #${script}    Replace String    ${script}    {{CLUSTER_ID}}    ${_cluster}
    #${query_rlt}    Query    ${sqlstring}
    
    # 刪除通報單異動紀錄
    Query    DELETE FROM CLUSTER_REPORT_FIELD_DIFF WHERE LOG_ID IN (SELECT LOG_ID FROM CLUSTER_REPORT_FIELD_DIFF_SUM WHERE CLUSTER_REPORT_ID = '${_cluster}')
    Query    DELETE FROM CLUSTER_REPORT_FIELD_DIFF_SUM WHERE CLUSTER_REPORT_ID = '${_cluster}'
    
    # 個案症狀
    Query    DELETE FROM CLUSTER_IDV_REPORT_SYMPTOMS WHERE CLUSTER_IDV_REPORT_ID IN (SELECT ID FROM CLUSTER_IDV_REPORT WHERE CLUSTER_REPORT_ID = '${_cluster}' AND REVISE_HISTORY = 1)

    # 個案送驗
    Query    DELETE FROM CLUSTER_IDV_REPORT_SAMPLE WHERE IDV_REPORT_ID IN (SELECT ID FROM CLUSTER_IDV_REPORT WHERE CLUSTER_REPORT_ID = '${_cluster}' AND REVISE_HISTORY = 1)

    # 個案聯絡
    Query    DELETE FROM CLUSTER_IDV_RPT_CONTACT_INFO WHERE CLUSTER_IDV_REPORT_ID IN (SELECT ID FROM CLUSTER_IDV_REPORT WHERE CLUSTER_REPORT_ID = '${_cluster}' AND REVISE_HISTORY = 1)

    # 個案
    Query    DELETE FROM CLUSTER_IDV_REPORT WHERE CLUSTER_REPORT_ID = '${_cluster}'

    # 通報單
    Query    DELETE FROM CLUSTER_REPORT WHERE ID = '${_cluster}'

    # 研判結果
    Query    DELETE FROM CLUSTER_REPORT_DETERMINED WHERE CLUSTER_REPORT_ID = '${_cluster}'

    # 待成案
    Query    DELETE FROM CLUSTER_REPORT_TOBE WHERE CLUSTER_REPORT_ID = '${_cluster}'

    Log To Console    deleted row(s) from CLUSTER TABLES

    Disconnect From Database


Clean up Report with script
    [Arguments]    ${report}    ${disease}
    #Connect To Database    oracledb    ${DB_NAME}    ${DB_USERNAME}    ${DB_PASSWORD}    ${DB_HOST}    ${DB_PORT}
    Connect To Database    cx_Oracle    ${DB_NAME}    ${DB_USERNAME}    ${DB_PASSWORD}    ${DB_HOST}    ${DB_PORT}
    ${script}    Get SQL SCRIPT    clean_up_cluster
    ${script}    Replace String    ${script}    {{REPORT_ID}}    ${report}
    ${script}    Replace String    ${script}    {{DISEASE_ID}}    ${disease}
    ${tempSqlScript}    Write tmep file    ${script}
    Execute Sql Script    ${tempSqlScript}
    [Teardown]    End db handle    ${tempSqlScript}

Get SQL SCRIPT
    [Arguments]    ${sqlfile}
    ${output}   Read file  testNIDRSAPI\\${sqlfile}.sql    
    [Return]    ${output}

Write tmep file
    [Arguments]    ${content}
    ${tempName}    Generate Random String    10    [LETTERS][NUMBERS]
    ${tempPath}    set Variable    testNIDRSAPI\\${tempName}
    Create File    ${tempPath}
    Append To File    ${tempPath}    ${content}
    [Return]    ${tempPath}

Clean tmep file
    [Arguments]    ${filepath}
    Remove File    ${filepath}
