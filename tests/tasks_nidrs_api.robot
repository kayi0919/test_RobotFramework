*** Settings ***
Library    RequestsLibrary
Library    Collections
Library    RPA.JSON
Library    RPA.FileSystem
Library    RPA.Windows
Library    RPA.Robocorp.WorkItems
Resource    db_handle.robot
Resource    ../keywords/keywords.robot
Suite Setup    API TEST Setup
Suite Teardown    API TEST Teardown

*** Variables ***
${baseurl}    https://localhost:44334
${token}
${reports}

*** Keywords ***
API TEST Setup
    Create Session    nidrsapi    ${baseurl}    verify=False
    ${output}   Read file  testNIDRSAPI\\token
    Set Global Variable    ${token}    ${output}
    ${reports}    Create Dictionary
    Set Global Variable    ${reports}

API TEST Teardown
    Delete All Sessions
    # 刪除產生的資料
    FOR    ${report}    ${disease}    IN    &{reports}
        Run Keyword And Ignore Error    Clean up Report    ${report}    ${disease}
    END

NIDRS API Request
    [Arguments]    ${apiuri}    ${json}
    ${headers}    Create Dictionary    Content-Type=application/json    Authorization=Bearer ${token}
    # 加上expected_status避免在此中斷
    ${response}    POST On Session    nidrsapi    ${apiuri}    json=${json}    headers=${headers}    expected_status=anything
    [Return]    ${response}

*** Test Cases ***
TEST API 0101
    [Tags]    Smoke    API
    [Documentation]    測試NDIRS API: IDA_0101    帳號地區/疾病查詢
    ${jsonfile}    Load JSON from file    testNIDRSAPI\\IDA_0101.json
    ${response}    NIDRS API Request    /api/IDA_0101   ${jsonfile}
    Status Should Be    OK    ${response}

TEST API 0301
    [Tags]    Smoke    API
    [Documentation]    測試NDIRS API: IDA_0301    通報定義查詢
    ${jsonfile}    Load JSON from file    testNIDRSAPI\\IDA_0301.json
    ${response}    NIDRS API Request    /api/IDA_0301   ${jsonfile}
    Status Should Be    OK    ${response}

TEST API 0302
    [Tags]    Smoke    API
    [Documentation]    測試NDIRS API: IDA_0302    法傳通報單新增
    ${jsonfile}    Load JSON from file    testNIDRSAPI\\IDA_0302.json
    ${response}    NIDRS API Request    /api/IDA_0302   ${jsonfile}
    Status Should Be    OK    ${response}
    ${json}    Set Variable    ${response.json()}
    Set To Dictionary    ${reports}    ${json["REPORT"][0]["REPORT_ID"]}    ${json["REPORT"][0]["DISEASE_ID"]}
    Log To Console    Create Reprot ID: ${json["REPORT"][0]["REPORT_ID"]}, Disease: ${json["REPORT"][0]["DISEASE_ID"]}

TEST API 0302 LIMS 19CVS
    [Tags]    Smoke    API
    [Documentation]    測試NDIRS API: IDA_0302    法傳通報單新增, 以LIMS通報19CVS
    ${jsonfile}    Load JSON from file    testNIDRSAPI\\IDA_0302_19CVS_LIMS.json
    ${response}    NIDRS API Request    /api/IDA_0302   ${jsonfile}
    Status Should Be    OK    ${response}
    ${json}    Set Variable    ${response.json()}
    Set To Dictionary    ${reports}    ${json["REPORT"][0]["REPORT_ID"]}    ${json["REPORT"][0]["DISEASE_ID"]}
    Log To Console    Create Reprot ID: ${json["REPORT"][0]["REPORT_ID"]}, Disease: ${json["REPORT"][0]["DISEASE_ID"]}

TEST API 0302 SQMS 061
    [Tags]    Smoke    API
    [Documentation]    測試NDIRS API: IDA_0302    法傳通報單新增, 以SQMS通報061
    ${jsonfile}    Load JSON from file    testNIDRSAPI\\IDA_0302_061_SQMS.json
    ${response}    NIDRS API Request    /api/IDA_0302   ${jsonfile}
    Status Should Be    OK    ${response}
    ${json}    Set Variable    ${response.json()}
    Set To Dictionary    ${reports}    ${json["REPORT"][0]["REPORT_ID"]}    ${json["REPORT"][0]["DISEASE_ID"]}
    Log To Console    Create Reprot ID: ${json["REPORT"][0]["REPORT_ID"]}, Disease: ${json["REPORT"][0]["DISEASE_ID"]}

TEST API 0303 QINV
    [Tags]    Smoke    API
    [Documentation]    測試NDIRS API: IDA_0303    法傳通報單查詢
    ${jsonfile}    Load JSON from file    testNIDRSAPI\\IDA_0303_QINV.json
    #變更JSON查詢內容
    # list是python的函式
    #${reportlist}    Evaluate    list(${reports})
    ${reportlist}    Convert To List    ${reports.keys()}
    ${jsonfile}    Update value to JSON    ${jsonfile}    $.REPORT_ID    ${reportlist}
    ${response}    NIDRS API Request    /api/IDA_0303   ${jsonfile}
    Status Should Be    OK    ${response}
    ${json}    Set Variable    ${response.json()}
    # 簡單內容檢查
    # 通報單數量1
    ${expLength}    Get Length    ${reports}
    Should Be Equal As Integers    ${json["COUNT"]}    ${expLength}
    ## 通報單號
    #Should Be Equal As Strings    ${json["REPORT"][0]["REPORT_ID"]}    ${reportid}
    ## 通報疾病
    #Should Be Equal As Strings    ${json["REPORT"][0]["DISEASE"]["DISEASE_ID"]}    ${diseaseid}

TEST API 0303 TRACE
    [Tags]    Smoke    API
    [Documentation]    測試NDIRS API: IDA_0303    法傳通報單查詢
    ${jsonfile}    Load JSON from file    testNIDRSAPI\\IDA_0303_TRACE.json
    # 變更JSON查詢內容
    FOR    ${report}    ${disease}    IN    &{reports}
        Append To List    ${jsonfile["DISEASE_ID"]}    ${disease}
    END
    ${startdate}    Get DateTime String    -1
    ${enddate}    Get DateTime String    0
    
    ${jsonfile}    Update value to JSON    ${jsonfile}    $.START    ${startdate}
    ${jsonfile}    Update value to JSON    ${jsonfile}    $.END    ${enddate}

    ${response}    NIDRS API Request    /api/IDA_0303   ${jsonfile}
    Status Should Be    OK    ${response}
    ${json}    Set Variable    ${response.json()}
    # 簡單內容檢查
    # 通報單數量
    ${expLength}    Get Length    ${reports}
    Should Be True    ${json["COUNT"]} >= ${expLength}
    # 通報單號應包含
    ${id_list}    Evaluate    [item['REPORT_ID'] for item in ${json['REPORT']}]    json
    FOR    ${report}    ${disease}    IN    &{reports}
        List Should Contain Value    ${id_list}    ${report}
    END
    
#TEST CLEAN UP REPORT
#    Clean up Report    ${reportid}    ${diseaseid}

#Extra data
    #Status Should Be    OK    ${response}
    #Run Keyword If    '${response.status_code}' == '200'
    #...    Log To Console    ${response.json()}
    ##...    Log To Console    ${response.content}
    #...  ELSE IF    '${response.reason}' == 'Bad Request'
    #       # 400錯誤預期格式為json
    #...    Log To Console    ${response.reason}-${response.status_code}-${response.json()}
    #...  ELSE
    #...    Log To Console    ${response.reason}-${response.status_code}-${response.Content}
    
    #[Teardown]    Delete All Sessions

