*** Settings ***
Documentation    醫療院所通報測試-鉤端螺旋體病
Library    RPA.Browser.Selenium
Library    RPA.Excel.Files
Library    String
Library    RPA.FileSystem
Resource   ..\\keywords\\keywords.robot
Resource   ..\\keywords\\Variables.robot

*** Variables ***
${screenshot}
${test_users}
${test_reports}
${test_id}
${test_update}
${item_result}
${item_function}
${item_num}
${report_id}

*** Keywords ***
COMMON REPORT
    [Arguments]    ${element}
    ${tmpday}    Get Taiwain Date String    -2
    
    Set Global Variable    ${item_num}    ${element}[Num]
    Set Global Variable    ${item_result}    ${False}
    
    IF    ${element}[FUNCTION] == 1
        Log To Console    點擊新增通報單
        Click Element    id=101        
    END
    Wait Until Page Contains Element    id=casePatient_Idno   
    # 診斷醫師
    Diagnostician    ${element}
    # 身分證統一編號
    IDNO    ${element}
    # 個案姓名
    Name    ${element}
    #羅馬拼音    
    Romanization    ${element}
    #性別
    Gender    ${element} 
    #生日
    Birthday    ${element}
    #本國籍
    Nationality    ${element}

    #手機/聯絡電話欄位因為有重複定義的element id, 改以xpath處理
    #Input Text    id=casePatient_MobilePhone_0    ${element}[CELLPHONE]
    CellPhone    ${element}
    ContactPhone    ${element}

    County    ${element}    
    # 出現list無內容的異常
    # 這邊click是為了觸發list重新更新
    Town    ${element}
    
    #居住村里    
    Village    ${element}
    #街道地址
    Address    ${element}
    #人口密集機構
    Institutions    ${element}
    #機構類別
    Ins_Catrgory    ${element}
    #婚姻狀況
    Marriage    ${element}
    #病患動向   
    CasePatient    ${element}
    # 是否死亡
    # 要先focus在此區域,選是否才沒有出現異常
    Death    ${element}

    # 選擇疾病
    # 畫面dialog跳動頻繁, 中間sleep以確保畫面切換
    Disease Category    ${element}
    # 發病日/無發病日區塊
    Sick Date    ${element}
    # 診斷日期
    Diagnose Day    ${element}
    # 報告日期
    Report Day    ${element}

    # 有無症狀
    Click Element    //*[@id="diseaseReportData"]/div[3]/div/div
    Sleep    20ms
    IF    '${element}[HAS_SYMPTOM]' != 'None'
        IF    ${element}[HAS_SYMPTOM] == $True
            Click Element    //*[@id="ReportDisease_symp"]/div[1]/label
            Sleep    200ms
            IF    '${element}[SYMPTOMS]' != 'None'
                # 注意, 以@類型接收
                @{symptoms}    Split String    ${element}[SYMPTOMS]    ,
                
                FOR    ${smp}    IN    @{symptoms}
                    Log To Console    ${smp}
                    Click Element    //label[contains(text(), '${smp}')]
                    # 點選'其他症狀'
                    IF    '${smp}' == '其他症狀'
                        Input Text    id=ReportDisease_symptom_otherSymp    ${element}[OTHER_SYMPTOM]
                    END
                END
            END   
        ELSE
            Click Element    //*[@id="ReportDisease_symp"]/div[2]/label
        END        
    END
    
    
    # 職業
    IF    '${element}[OCCUPATION]' != 'None'
        Select From List By Label    id=ReportDisease_mainProfSel    ${element}[OCCUPATION]        
    END
    # 職業說明
    IF    '${element}[OCCUPATION_DESCRIPTION]' != 'None'
        Click Element    id=ReportDisease_mainProfdetail
        Input Text    id=ReportDisease_mainProfdetail    ${element}[OCCUPATION_DESCRIPTION]
    END

    # 旅遊史
    # 旅遊史無法複選 國外旅遊及居住的國家id會持續變動
    Travel_History    ${element}

    #接觸史
    IF    '${element}[ANIMAL_CONTACT_HISTORY]' != 'None'
        IF    '${element}[ANIMAL_CONTACT_HISTORY]' != $True
            Click Element    //label[@for="ReportDisease_mainContact_Y"]
            Sleep    200ms
            Click Element    id=ReportDisease_mainContact_type
            Select From List By Label    id=ReportDisease_mainContact_type    ${element}[ANIMAL_TYPE]
        ELSE
            Click Element    //label[@for="ReportDisease_mainContact_N"]
        END

        # 注意, 以@類型接收
        @{contact_history}    Split String    ${element}[CONTACT_HISTORY]    ,
        
        FOR    ${history}    IN    @{contact_history}
            Log To Console    ${history}
            Click Element    //label[contains(text(), '${history}')]

            # 接觸動物 野外活動 污染的環境text未在label內 這裡獨立寫程式碼
            IF    '${history}' == '接觸動物'
                #label contains不會點選
                Click Element    //*[@for="ReportDisease_100_S_Q010000021_AS01000001"]
                IF    '${element}[ANIMAL_CONTACT_DATE]' != 'None'                    
                    Click Element    id=ReportDisease_100_S_Q010000022_AS01000002
                    Transfer Taiwan Date    ${element}[ANIMAL_CONTACT_DATE]    //*[@id="ReportDisease_100_S_Q010000022_AS01000002"]
                END                                
            END
            IF    '${history}' == '野外活動'
                IF    '${element}[ACTIVITY_DATE]' != 'None'
                    Click Element    id=ReportDisease_100_S_Q010000024_AS01000004
                    Transfer Taiwan Date    ${element}[ACTIVITY_DATE]    //*[@id="ReportDisease_100_S_Q010000024_AS01000004"]
                END                               
            END
            IF    '${history}' == '污染的環境'
                IF    '${element}[POLLUTE_ENV_DATE]' != 'None'
                    Click Element    id=ReportDisease_100_S_Q010000026_AS01000006
                    Transfer Taiwan Date    ${element}[POLLUTE_ENV_DATE]    //*[@id="ReportDisease_100_S_Q010000026_AS01000006"]
                END               
            END
        END
    END

    #增修原因
    IF    '${element}[UPDATE_REASON]' != 'None'
        Input Text    //textarea[@id="casePatient_ModifyReason"]    ${element}[UPDATE_REASON]
    END
    
    # 新增
    # 確定通報
    Set Global Variable    ${item_function}    ${element}[FUNCTION]
    IF    ${element}[FUNCTION] == 1
        Create Data
        ${report_id}    Get Text    xpath=/html/body/div[2]/div[2]/main/div[2]/div/div/div[1]/div[1]/span[1]/a
        # 透過等待畫面出現縣市, 以確保資料讀取完成, 再進行截圖
        Wait Until Page Contains    ${element}[COUNTY]
        # 截圖佐證
        Capture Page Screenshot    ${screenshot}\\100_report_MED_${element}[DISEASE]_${element}[Num].png
        Log To Console    ${report_id}

        Set Global Variable    ${item_result}    ${True}
        #讀取編號
        Write ID Excel    ${report_id}    ${element}[Num]    Data_ID.xlsx
        Set Global Variable    ${report_id}
    END


Update Report
    #增修資料(不修改地址)
    [Arguments]    ${element}    ${element_id}
    Set Global Variable    ${item_result}    ${False}
    
    #成功頁面複製編號
    #Click Element    //div[@id="report_complete_disease_area"]/div/div[1]/div/a    #只執行增修功能 此行需註解
    #Press Keys    id=quick_search_field    CTRL+v
    
    Click Element    id=quick_search_field
    Input Text    id=quick_search_field    ${element_id}[REPORT_ID]
    
    Click Element    //*[@id="headersearch"]/div
    Wait Until Page Contains    ${element_id}[REPORT_ID]
    #點選增修功能
    Click Element    //tbody[@id="searchResult"]/tr/td[last()]/a
    #資料增修
    COMMON REPORT    ${element}
    #增修通報
    Update Data
    Wait Until Page Contains    ${element_id}[REPORT_ID]
    Capture Page Screenshot    ${screenshot}\\100_report_MED_Update_${element}[Num].png
    Set Global Variable    ${item_result}    ${True}



*** Tasks ***
Smoke_WEB_MED_100_NEWREPORT_01
    [Documentation]    煙霧測試:醫療院所鉤端螺旋體病通報
    [Tags]    Smoke
    [Setup]    Set Global Variable    ${screenshot}    testresult\\${TEST_NAME}

    Open Available Browser    maximized=${True}    browser_selection=${BROWSER}
    Clean Excel    Data_ID.xlsx
    Clean Excel    Data_Result.xlsx
    Read Report Excel    Smoke_WEB_MED_100_NEWREPORT_01.xlsx

    # 路徑不見處理 新增路徑
    Create Directory    ${screenshot}    resource=false
    # 清除截圖路徑
    Remove Directory    ${screenshot}    resource=true

    FOR    ${element}    IN    @{test_users}
        Login    ${element}    ${NIDRS_WEB_URL}

        # 測試1 新增
        FOR    ${report}    IN    @{test_reports}
            TRY
                Run Keyword And Continue On Failure    COMMON REPORT    ${report}
                Write Result Excel    ${item_function}    ${item_num}    ${report}[EXPECTED]    ${item_result}    Data_Result.xlsx
                Run Keyword If    ${item_result} == ${False}
                ...    Capture Page Screenshot    ${screenshot}\\100_report_MED_${report}[DISEASE]_${report}[Num]_Error.png

                # 預期False 結果Pass
                # 若這裡錯誤會再執行except一次
                IF    ${item_result} != ${report}[EXPECTED]
                    Run Keyword And Continue On Failure    Fail    功能:${report}[FUNCTION] 序號:${report}[Num]預期錯誤
                END
            EXCEPT
                # 預期Pass 結果False
                IF    ${item_result} != ${report}[EXPECTED]
                    Run Keyword And Continue On Failure    Fail    功能:${report}[FUNCTION] 序號:${report}[Num]預期錯誤
                END                
            END
            Clear Error
        END
        
        # 測試2 增修
        Read ID Excel    Data_ID.xlsx
        Read Update Excel    Smoke_WEB_MED_100_NEWREPORT_01.xlsx
        FOR    ${update}    IN    @{test_update}
            FOR    ${id}    IN    @{test_id}
                IF    ${id}[Num] == ${update}[Num]
                    TRY
                        Run Keyword And Continue On Failure    Update Report    ${update}    ${id}
                        Write Result Excel    ${item_function}    ${item_num}    ${update}[EXPECTED]    ${item_result}    Data_Result.xlsx
                        Run Keyword If    ${item_result} == ${False}
                        ...    Capture Page Screenshot    ${screenshot}\\100_report_MED_UPDATE_${update}[Num]_Error.png
                    
                        # 預期False 結果Pass
                        # 若這裡錯誤會再執行except一次
                        IF    ${item_result} != ${update}[EXPECTED]                            
                            Run Keyword And Continue On Failure    Fail    功能:${update}[FUNCTION] 序號:${update}[Num]預期錯誤                            
                        END
                    EXCEPT
                        # 預期Pass 結果False
                        IF    ${item_result} != ${update}[EXPECTED]                            
                            Run Keyword And Continue On Failure    Fail    功能:${update}[FUNCTION] 序號:${update}[Num]預期錯誤
                        END                        
                    END
                    Clear Error
                END
                
            END
        END

        # 測試3 研判
        Run Keyword And Ignore Error    Logout
        
    END
    

    [Teardown]    Close All Browsers
