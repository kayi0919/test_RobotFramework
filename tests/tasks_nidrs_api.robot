*** Settings ***
Library    RequestsLibrary
Library    Collections
Library    RPA.JSON
Library    RPA.FileSystem
Library    RPA.Windows
Library    RPA.Robocorp.WorkItems
Resource    db_handle.robot
#Resource         keywords.robot
Resource    ../keywords/keywords.robot
Suite Setup    API TEST Setup
Suite Teardown    API TEST Teardown

*** Variables ***
${baseurl}    https://localhost:44334
${token}
${reports}
${clusters}
# 以下為最後一筆通報資料
${last_report}
${report_disease}
${barcode}

*** Keywords ***
API TEST Setup
    Create Session    nidrsapi    ${baseurl}    verify=False
    ${output}   Read file  testNIDRSAPI\\token_LIMS
    Set Global Variable    ${token}    ${output}
    ${reports}    Create Dictionary
    Set Global Variable    ${reports}
    ${clusters}    Create Dictionary
    Set Global Variable    ${clusters}

API TEST Teardown
    Delete All Sessions
    # 刪除產生的法傳資料
    FOR    ${report}    ${disease}    IN    &{reports}
        Run Keyword And Ignore Error    Clean up Report    ${report}    ${disease}
    END

    # 刪除產生的群聚資料
    FOR    ${c}    ${cid}    IN    &{clusters}
        Run Keyword And Ignore Error    Clean up Cluster    ${cid}
    END
    

NIDRS API Request
    [Arguments]    ${apiuri}    ${json}
    ${headers}    Create Dictionary    Content-Type=application/json    Authorization=Bearer ${token}
    # 加上expected_status避免在此中斷
    ${response}    POST On Session    nidrsapi    ${apiuri}    json=${json}    headers=${headers}    expected_status=anything
    [Return]    ${response}

*** Tasks ***
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
    Log To Console    Created Reprot ID: ${json["REPORT"][0]["REPORT_ID"]}, Disease: ${json["REPORT"][0]["DISEASE_ID"]}

TEST API 0302 LIMS 19CVS
    [Tags]    Smoke    API
    [Documentation]    測試NDIRS API: IDA_0302    法傳通報單新增, 以LIMS通報19CVS
    ${jsonfile}    Load JSON from file    testNIDRSAPI\\IDA_0302_19CVS_LIMS.json
    ${response}    NIDRS API Request    /api/IDA_0302   ${jsonfile}
    Status Should Be    OK    ${response}
    ${json}    Set Variable    ${response.json()}
    Set To Dictionary    ${reports}    ${json["REPORT"][0]["REPORT_ID"]}    ${json["REPORT"][0]["DISEASE_ID"]}
    Log To Console    Created Reprot ID: ${json["REPORT"][0]["REPORT_ID"]}, Disease: ${json["REPORT"][0]["DISEASE_ID"]}

TEST API 0302 SQMS 061
    [Tags]    Smoke    API
    [Documentation]    測試NDIRS API: IDA_0302    法傳通報單新增, 以SQMS通報061
    ${jsonfile}    Load JSON from file    testNIDRSAPI\\IDA_0302_061_SQMS.json
    ${response}    NIDRS API Request    /api/IDA_0302   ${jsonfile}
    Status Should Be    OK    ${response}
    ${json}    Set Variable    ${response.json()}
    Set To Dictionary    ${reports}    ${json["REPORT"][0]["REPORT_ID"]}    ${json["REPORT"][0]["DISEASE_ID"]}
    Log To Console    Created Reprot ID: ${json["REPORT"][0]["REPORT_ID"]}, Disease: ${json["REPORT"][0]["DISEASE_ID"]}

TEST API 0303 QINV
    [Tags]    Smoke    API
    [Documentation]    測試NDIRS API: IDA_0303    法傳通報單查詢(QINV)
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
    [Documentation]    測試NDIRS API: IDA_0303    法傳通報單查詢(TRACE)
    ${jsonfile}    Load JSON from file    testNIDRSAPI\\IDA_0303_TRACE.json
    # 變更JSON查詢內容
    FOR    ${report}    ${disease}    IN    &{reports}
        Append To List    ${jsonfile["DISEASE_ID"]}    ${disease}
    END
    ${startdate}    Get DateTime String    -1
    # 放寬 避免時間未同步問題
    ${enddate}    Get DateTime String    1
    
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
    ${report_list}    Evaluate    [item['REPORT_ID'] for item in ${json['REPORT']}]    json
    FOR    ${report}    ${disease}    IN    &{reports}
        List Should Contain Value    ${report_list}    ${report}
    END
    
TEST API 0304 REPORT SAMPLE
    [Tags]    Smoke    API
    [Documentation]    測試NDIRS API: IDA_0304    通報單-送驗單關聯(REPORT SAMPLE)
    ${jsonfile}    Load JSON from file    testNIDRSAPI\\IDA_0304_REPORT_SAMPLE.json

    # 取得最後一筆通報單, 掛此送驗單
    ${report_ids}    Get Dictionary Keys    ${reports} 
    ${last_report_id}    Get From List    ${report_ids}    -1
    ${last_disease_id}    Get From Dictionary    ${reports}     ${last_report_id}

    ${jsonfile}    Update value to JSON    ${jsonfile}    $.REPORT_SAMPLE[0].REPORT_ID    ${last_report_id}
    ${jsonfile}    Update value to JSON    ${jsonfile}    $.REPORT_SAMPLE[0].DISEASE_ID    ${last_disease_id}

    ${response}    NIDRS API Request    /api/IDA_0304   ${jsonfile}
    Status Should Be    OK    ${response}
    ${json}    Set Variable    ${response.json()}
    # 補強檢查查詢通報單是否關聯
    Set Global Variable    ${barcode}    ${json["REPORTED_SAMPLE"][0]["SAMPLE_ID"]}
    Set Global Variable    ${report_disease}    ${last_disease_id}
    Set Global Variable    ${last_report}    ${last_report_id}
    
TEST API 0305 SQMS
    [Tags]    Smoke    API
    [Documentation]    測試NDIRS API: IDA_0305    法傳通報單-研判結果的設定與查詢(SQMS)
    ${jsonfile}    Load JSON from file    testNIDRSAPI\\IDA_0305_SQMS.json

    # 變更JSON查詢內容
    FOR    ${report}    ${disease}    IN    &{reports}
        Append To List    ${jsonfile["REPORT_ID"]}    ${report}
    END

    ${response}    NIDRS API Request    /api/IDA_0305   ${jsonfile}
    Status Should Be    OK    ${response}
    ${json}    Set Variable    ${response.json()}
    # 簡單內容檢查
    # 通報單號應包含
    ${report_list}    Evaluate    [item['REPORT_ID'] for item in ${json['REPORT_DETERMINED_RESULT']}]    json
    FOR    ${report}    ${disease}    IN    &{reports}
        List Should Contain Value    ${report_list}    ${report}
    END

TEST API 0305 TRACE
    [Tags]    Smoke    API
    [Documentation]    測試NDIRS API: IDA_0305    法傳通報單-研判結果的設定與查詢(TRACE)
    ${jsonfile}    Load JSON from file    testNIDRSAPI\\IDA_0305_TRACE.json

    ${startdate}    Get DateTime String    -1
    # 放寬 避免時間未同步問題
    ${enddate}    Get DateTime String    1

    ${jsonfile}    Update value to JSON    ${jsonfile}    $.MODIFIED.START    ${startdate}
    ${jsonfile}    Update value to JSON    ${jsonfile}    $.MODIFIED.END    ${enddate}

    ${response}    NIDRS API Request    /api/IDA_0305   ${jsonfile}
    Status Should Be    OK    ${response}
    ${json}    Set Variable    ${response.json()}
    # 簡單內容檢查
    # 通報單號應包含
    ${report_list}    Evaluate    [item['REPORT_ID'] for item in ${json['REPORT_DETERMINED_RESULT']}]    json
    FOR    ${report}    ${disease}    IN    &{reports}
        List Should Contain Value    ${report_list}    ${report}
    END

TEST API 0306 QINV
    [Tags]    Smoke    API
    [Documentation]    測試NDIRS API: IDA_0306    法傳通報單轉介查詢(QINV)
    ${jsonfile}    Load JSON from file    testNIDRSAPI\\IDA_0306_QINV.json

    ${startdate}    Get DateTime String    -1
    # 放寬 避免時間未同步問題
    ${enddate}    Get DateTime String    1

    ${jsonfile}    Update value to JSON    ${jsonfile}    $.CREATED.START    ${startdate}
    ${jsonfile}    Update value to JSON    ${jsonfile}    $.CREATED.END    ${enddate}

    ${jsonfile}    Update value to JSON    ${jsonfile}    $.MODIFIED.START    ${startdate}
    ${jsonfile}    Update value to JSON    ${jsonfile}    $.MODIFIED.END    ${enddate}

    ${response}    NIDRS API Request    /api/IDA_0306   ${jsonfile}
    Status Should Be    OK    ${response}
    # 補強檢查查詢通報單是否關聯

TEST API 0308
    [Tags]    Smoke    API
    [Documentation]    測試NDIRS API: IDA_0308    主子單
    ${jsonfile}    Load JSON from file    testNIDRSAPI\\IDA_0308.json

    ${startdate}    Get DateTime String    -1
    # 放寬 避免時間未同步問題
    ${enddate}    Get DateTime String    1

    ${jsonfile}    Update value to JSON    ${jsonfile}    $.MODIFIED.START    ${startdate}
    ${jsonfile}    Update value to JSON    ${jsonfile}    $.MODIFIED.END    ${enddate}

    ${response}    NIDRS API Request    /api/IDA_0308   ${jsonfile}
    Status Should Be    OK    ${response}
    # 補強檢查查詢通報單是否關聯

TEST API 0309
    [Tags]    Smoke    API
    [Documentation]    測試NDIRS API: IDA_0309    流行案例
    ${jsonfile}    Load JSON from file    testNIDRSAPI\\IDA_0309.json

    ${startdate}    Get DateTime String    -1
    # 放寬 避免時間未同步問題
    ${enddate}    Get DateTime String    1

    ${jsonfile}    Update value to JSON    ${jsonfile}    $.START    ${startdate}
    ${jsonfile}    Update value to JSON    ${jsonfile}    $.END    ${enddate}

    ${response}    NIDRS API Request    /api/IDA_0309   ${jsonfile}
    Status Should Be    OK    ${response}
    # 補強檢查查詢通報單是否關聯

TEST API 0312
    [Tags]    Smoke    API
    [Documentation]    測試NDIRS API: IDA_0312    法傳通報單修改(HAS)
    ${jsonfile}    Load JSON from file    testNIDRSAPI\\IDA_0312_HAS.json

    ${report_ids}    Get Dictionary Keys    ${reports} 
    
    ${last_report_id}    Get From List    ${report_ids}    -1
    ${jsonfile}    Update value to JSON    ${jsonfile}    $.REPORT_ID    ${last_report_id}
    ${last_disease_id}    Get From Dictionary    ${reports}     ${last_report_id}
    ${jsonfile}    Update value to JSON    ${jsonfile}    $.DISEASE[0].DISEASE_ID    ${last_disease_id}

    ${response}    NIDRS API Request    /api/IDA_0312   ${jsonfile}
    Status Should Be    401    ${response}

    #變更token
    ${lims_Token}    Set Variable    ${token}
    ${output}   Read file  testNIDRSAPI\\token_HAS
    Set Global Variable    ${token}    ${output}

    ${response}    NIDRS API Request    /api/IDA_0312   ${jsonfile}
    Status Should Be    OK    ${response}

    # 回復token
    Set Global Variable    ${token}    ${lims_Token}
    # 補強檢查查詢通報單是否關聯

TEST API 0351
    [Tags]    Smoke    API
    [Documentation]    測試NDIRS API: IDA_0351    群聚事件新增
    ${jsonfile}    Load JSON from file    testNIDRSAPI\\IDA_0351.json

    #變更token
    ${lims_Token}    Set Variable    ${token}
    ${output}   Read file  testNIDRSAPI\\token_SQMS
    Set Global Variable    ${token}    ${output}

    ${response}    NIDRS API Request    /api/IDA_0351   ${jsonfile}
    Status Should Be    OK    ${response}
    # 取得群聚編號
    ${json}    Set Variable    ${response.json()}
    #Set Global Variable    ${cluster}    
    Set To Dictionary    ${clusters}    ${json["ADD_CLUSTER_RESULT"]["CLUSTER_ID"]}    ${json["ADD_CLUSTER_RESULT"]["CLUSTER_ID"]}
    Log To Console    0351產生群聚單號:${json["ADD_CLUSTER_RESULT"]["CLUSTER_ID"]}

TEST API 0352
    [Tags]    Smoke    API
    [Documentation]    測試NDIRS API: IDA_0352    群聚個案新增
    ${jsonfile}    Load JSON from file    testNIDRSAPI\\IDA_0352.json

    ${cluster_ids}    Get Dictionary Keys    ${clusters} 
    ${last_cluster_id}    Get From List    ${cluster_ids}    -1

    ${jsonfile}    Update value to JSON    ${jsonfile}    $.ADD_CLUSTER_INDIVIDUALS.CLUSTER_ID    ${last_cluster_id}

    ${response}    NIDRS API Request    /api/IDA_0352   ${jsonfile}
    Status Should Be    OK    ${response}
    # 進一步檢查
    
TEST API 0353
    [Tags]    Smoke    API
    [Documentation]    測試NDIRS API: IDA_0353    群聚個案查詢
    ${jsonfile}    Load JSON from file    testNIDRSAPI\\IDA_0353.json

    ${cluster_ids}    Get Dictionary Keys    ${clusters} 
    ${last_cluster_id}    Get From List    ${cluster_ids}    -1

    ${jsonfile}    Update value to JSON    ${jsonfile}    $.CLUSTER_REPORT_ID[0]    ${last_cluster_id}

    ${response}    NIDRS API Request    /api/IDA_0353   ${jsonfile}
    Status Should Be    OK    ${response}
    ${json}    Set Variable    ${response.json()}
    # 簡單內容檢查
    # 通報單號應包含
    ${cluster_list}    Evaluate    [item['CLUSTER_ID'] for item in ${json['CLUSTER_REPORTS']}]    json
    
    List Should Contain Value    ${cluster_list}    ${last_cluster_id}

TEST API 0361
    [Tags]    Smoke    API
    [Documentation]    測試NDIRS API: IDA_0361    群聚事件通知單新增
    ${jsonfile}    Load JSON from file    testNIDRSAPI\\IDA_0361.json

    #變更token
    ${lims_Token}    Set Variable    ${token}
    ${output}   Read file  testNIDRSAPI\\token_SSI
    Set Global Variable    ${token}    ${output}

    ${response}    NIDRS API Request    /api/IDA_0361   ${jsonfile}
    Status Should Be    OK    ${response}
    # 取得群聚編號
    ${json}    Set Variable    ${response.json()}
    #Set Global Variable    ${cluster}    ${json["ADD_CLUSTER_RESULT"]["CLUSTER_ID"]}
    Set To Dictionary    ${clusters}    ${json["ADD_CLUSTER_RESULT"]["CLUSTER_ID"]}    ${json["ADD_CLUSTER_RESULT"]["CLUSTER_ID"]}
    Log To Console    0361產生群聚單號:${json["ADD_CLUSTER_RESULT"]["CLUSTER_ID"]}

TEST API 0401
    [Tags]    Smoke    API
    [Documentation]    測試NDIRS API: IDA_0401    檢驗結果接收
    ${jsonfile}    Load JSON from file    testNIDRSAPI\\IDA_0401.json

    ${jsonfile}    Update value to JSON    ${jsonfile}    $.SAMPLE_RESULT[0].BARCODE    ${barcode}
    ${jsonfile}    Update value to JSON    ${jsonfile}    $.SAMPLE_RESULT[0].DISEASE_ID    ${report_disease}

    #變更token
    ${lims_Token}    Set Variable    ${token}
    ${output}   Read file  testNIDRSAPI\\token_LIMS
    Set Global Variable    ${token}    ${output}

    ${response}    NIDRS API Request    /api/IDA_0401   ${jsonfile}
    Status Should Be    OK    ${response}
    # 取得群聚編號
    ${json}    Set Variable    ${response.json()}
    Should Be Equal As Strings    ${barcode}    ${json["SAMPLE_RESULT_RCV"][0]["BARCODE"]}

TEST API 0403
    [Tags]    Smoke    API
    [Documentation]    測試NDIRS API: IDA_0403    未完成再採檢
    ${jsonfile}    Load JSON from file    testNIDRSAPI\\IDA_0403.json

    ${jsonfile}    Update value to JSON    ${jsonfile}    $.REPORT_ID    ${last_report}
    ${jsonfile}    Update value to JSON    ${jsonfile}    $.BARCODE    ${barcode}
    ${jsonfile}    Update value to JSON    ${jsonfile}    $.DISEASE_ID    ${report_disease}

    #變更token
    ${lims_Token}    Set Variable    ${token}
    ${output}   Read file  testNIDRSAPI\\token_LIMS
    Set Global Variable    ${token}    ${output}

    ${response}    NIDRS API Request    /api/IDA_0403   ${jsonfile}
    Status Should Be    OK    ${response}
    # 取得群聚編號
    ${json}    Set Variable    ${response.json()}
    Should Be Equal As Strings    OK    ${json["RESULT"]}

TEST API 0411
    [Tags]    Smoke    API
    [Documentation]    測試NDIRS API: IDA_0411    檢驗結果異動
    ${jsonfile}    Load JSON from file    testNIDRSAPI\\IDA_0411.json

    ${jsonfile}    Update value to JSON    ${jsonfile}    $.REPORT_ID    ${last_report}
    ${jsonfile}    Update value to JSON    ${jsonfile}    $.BARCODE    ${barcode}
    ${jsonfile}    Update value to JSON    ${jsonfile}    $.DISEASE_ID    ${report_disease}

    #變更token
    ${lims_Token}    Set Variable    ${token}
    ${output}   Read file  testNIDRSAPI\\token_LIMS
    Set Global Variable    ${token}    ${output}

    ${response}    NIDRS API Request    /api/IDA_0411   ${jsonfile}
    Status Should Be    OK    ${response}
    # 取得群聚編號
    ${json}    Set Variable    ${response.json()}
    Should Be Equal As Strings    OK    ${json["RESULT"]}

TEST API 0402
    [Tags]    Smoke    API
    [Documentation]    測試NDIRS API: IDA_0402    檢驗狀態異動
    
    ${jsonfile}    Load JSON from file    testNIDRSAPI\\IDA_0402.json

    # 刪除送驗單
    ${jsonfile}    Update value to JSON    ${jsonfile}    $.BARCODE    ${barcode}
    ${jsonfile}    Update value to JSON    ${jsonfile}    $.DISEASE_ID    ${report_disease}
    #${jsonfile}    Update value to JSON    ${jsonfile}    $.DELETED    ${True}

    #變更token
    ${lims_Token}    Set Variable    ${token}
    ${output}   Read file  testNIDRSAPI\\token_LIMS
    Set Global Variable    ${token}    ${output}

    ${response}    NIDRS API Request    /api/IDA_0402   ${jsonfile}
    Log To Console    ${response.json()}
    Status Should Be    OK    ${response}
    # 取得群聚編號
    ${json}    Set Variable    ${response.json()}
    Should Be Equal As Strings    OK    ${json["RESULT"]}
