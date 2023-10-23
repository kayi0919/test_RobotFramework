*** Settings ***
Documentation    醫療院所通報測試-人類免疫缺乏病毒感染(含母子垂直感染及孕產婦疑似個案)
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
    Sleep    1s
    IF    ${element}[FUNCTION] == 1
        Log To Console    點擊新增通報單
        Click Element    id=101        
    END   
    Sleep    1s
    Diagnostician    ${element}
    IDNO    ${element}
    Name    ${element}

    #羅馬拼音    
    Romanization    ${element}

    #性別
    Gender    ${element} 
    
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
    Sleep    2s

    # 是否死亡
    # 要先focus在此區域,選是否才沒有出現異常
    Death    ${element}

    # 選擇疾病
    # 畫面dialog跳動頻繁, 中間sleep以確保畫面切換
    IF    '${element}[DISEASE_CATEGORY]' != 'None'
        Click Button    //*[@id="choose_diseases"]
        Wait Until Page Contains    依法定傳染病
        Sleep    1s
        Click Element    //*[@id="nav-category-${element}[DISEASE_CATEGORY]"]
        Sleep    1s
        Click Element    //label[@for="category_disease_${element}[DISEASE]"]
        Sleep    1s
        # 確認
        Click Button    //*[@id="modalDiseaseSelector"]/div/div/div[3]/button[1]
        Sleep    1s
        # 下一步
        Click Button    id=selectedDiseaseNextStep
        Sleep    1s   
    END

    # 發病日/無發病日區塊
    IF    '${element}[NO_SICKDAY]' != 'None'
        IF    ${element}[NO_SICKDAY] == $True
            Click Element    //*[@id="ReportRelateDate"]/div[2]/div[2]/div/label
        ELSE
            ${tmpday}    Get Taiwain Date String    ${element}[SICK_DAY]
            Input Text    //*[@id="ReportDisease_onsetDate"]    ${tmpday}
        END        
    END

    # 診斷日期
    IF    '${element}[DIAGNOSE_DAY]' != 'None'
        ${tmpday}    Get Taiwain Date String    ${element}[DIAGNOSE_DAY]
        Input Text    //*[@id="ReportDisease_diagDate"]    ${tmpday}        
    END
    
    # 報告日期
    IF    '${element}[REPORTED_DAY]' != 'None'
        ${tmpday}    Get Taiwain Date String    ${element}[REPORTED_DAY]
        Input Text    //*[@id="ReportDisease_reportDate"]    ${tmpday}        
    END

    # 有無症狀
    Click Element    //*[@id="diseaseReportData"]/div[3]/div/div
    Sleep    20ms
    IF    '${element}[HAS_SYMPTOM]' != 'None'
        IF    ${element}[HAS_SYMPTOM] == $True
            Click Element    //*[@id="ReportDisease_symp"]/div[1]/label
            Sleep    200ms       
            IF    '${element}[OTHER_SYMPTOM]' != 'None'
                Input Text    //*[@id="ReportDisease_symptom_otherSymp"]    ${element}[OTHER_SYMPTOM]
            END        
        ELSE
        Click Element    //*[@id="ReportDisease_symp"]/div[2]/label
        END
        Sleep    1s
    END
    

    # HIV通報
    IF    '${element}[HIV_REPORT]' != 'None'
        @{hiv_report}    Split String    ${element}[HIV_REPORT]    ,
        FOR    ${hiv}    IN    @{hiv_report}
            IF    ${hiv} == 1
                Click Element    //label[@for="ReportDisease_044_S_044_00001"]                                
                IF    '${element}[ANTIBODY_METHODS]' != 'None'
                    @{anti_methods}    Split String    ${element}[ANTIBODY_METHODS]    ,
                    FOR    ${anti}    IN    @{anti_methods}
                        IF    ${anti} == 1
                            Click Element    //label[@for="ReportDisease_044_S_044_00002"]
                            IF    '${element}[COMPOSITE_REPORT]' != 'None'
                                ${tmpday}    Get Taiwain Date String    ${element}[COMPOSITE_REPORT]
                                Input Text    //*[@id="ReportDisease_044_S_044_00003"]    ${tmpday}
                                Click Element    id=ReportDisease_044_S_044_00004_name                                
                                Search Type    ${element}[HIV_SEARCH_TYPE]    ${element}[HIV_KEYWORD_SEARCH]    ${element}[HIV_APARTMENT_CITY]    ${element}[HIV_APARTMENT_TYPE] 
                            END
                        ELSE
                            Click Element    //label[@for="ReportDisease_044_S_044_00005"]
                            IF    '${element}[ANTIBODY_REPORT]' != 'None'
                                ${tmpday}    Get Taiwain Date String    ${element}[ANTIBODY_REPORT]
                                Input Text    //*[@id="ReportDisease_044_S_044_00006"]    ${tmpday}
                                Click Element    id=ReportDisease_044_S_044_00007_name                                
                                Search Type    ${element}[HIV_SEARCH_TYPE]    ${element}[HIV_KEYWORD_SEARCH]    ${element}[HIV_APARTMENT_CITY]    ${element}[HIV_APARTMENT_TYPE] 
                            END
                        END                                      
                    END
                END                
            END
            IF    ${hiv} == 2
                Click Element    //label[@for="ReportDisease_044_S_044_00008"]
                IF    '${element}[HIV_TEST]' != 'None'
                    IF    ${element}[HIV_TEST] == 1
                        Click Element    //label[@for="ReportDisease_044_S_044_00009"]
                    ELSE
                        Click Element    //label[@for="ReportDisease_044_S_044_00010"]
                    END
                    IF    '${element}[HIV_TEST_DATE]' != 'None'
                        ${tmpday}    Get Taiwain Date String    ${element}[HIV_TEST_DATE]
                        Input Text    //*[@id="ReportDisease_044_S_044_00011"]    ${tmpday}
                        Click Element    id=ReportDisease_044_S_044_00012_name                        
                        Search Type    ${element}[HIV_SEARCH_TYPE]    ${element}[HIV_KEYWORD_SEARCH]    ${element}[HIV_APARTMENT_CITY]    ${element}[HIV_APARTMENT_TYPE] 
                    END                    
                END
            END
            IF    ${hiv} == 3
                Click Element    //label[@for="ReportDisease_044_S_044_00013"]
                IF    '${element}[ACID_TEST_DATE]' != 'None'
                    ${tmpday}    Get Taiwain Date String    ${element}[ACID_TEST_DATE]
                    Input Text    //*[@id="ReportDisease_044_S_044_00014"]    ${tmpday}
                    Click Element    id=ReportDisease_044_S_044_00015_name                    
                    Search Type    ${element}[HIV_SEARCH_TYPE]    ${element}[HIV_KEYWORD_SEARCH]    ${element}[HIV_APARTMENT_CITY]    ${element}[HIV_APARTMENT_TYPE] 
                END
            END
            IF    ${hiv} == 4
                Click Element    //label[@for="ReportDisease_044_S_044_00016"]
                IF    '${element}[P24_TEST_DATE]' != 'None'
                    ${tmpday}    Get Taiwain Date String    ${element}[P24_TEST_DATE]
                    Input Text    //*[@id="ReportDisease_044_S_044_00017"]    ${tmpday}
                    Click Element    id=ReportDisease_044_S_044_00018_name                    
                    Search Type    ${element}[HIV_SEARCH_TYPE]    ${element}[HIV_KEYWORD_SEARCH]    ${element}[HIV_APARTMENT_CITY]    ${element}[HIV_APARTMENT_TYPE] 
                END
                IF    '${element}[NEUTRAL_TEST_DATE]' != 'None'
                    ${tmpday}    Get Taiwain Date String    ${element}[NEUTRAL_TEST_DATE]
                    Input Text    //*[@id="ReportDisease_044_S_044_00019"]    ${tmpday}
                    Click Element    id=ReportDisease_044_S_044_00020_name                    
                    Search Type    ${element}[HIV_SEARCH_TYPE]    ${element}[HIV_KEYWORD_SEARCH]    ${element}[HIV_APARTMENT_CITY]    ${element}[HIV_APARTMENT_TYPE] 
                END
            END
            
        END
        
    END

    # 急性感染
    IF    '${element}[ACUTE_INFECTION]' != 'None'
        IF    ${element}[ACUTE_INFECTION] == $True
            Click Element    //label[@for="ReportDisease_044_S_044_00021"]
            IF    '${element}[PROJECT_INSPECTION]' != 'None'                
                ${tmpday}    Get Taiwain Date String    ${element}[INSPECTION_DATE]
                Input Text    //*[@id="ReportDisease_044_S_044_000${element}[PROJECT_DATA1]"]    ${tmpday}
                Click Element    id=ReportDisease_044_S_044_000${element}[PROJECT_DATA2]_name                    
                Search Type    ${element}[HIV_SEARCH_TYPE]    ${element}[HIV_KEYWORD_SEARCH]    ${element}[HIV_APARTMENT_CITY]    ${element}[HIV_APARTMENT_TYPE]
                
                Click Element    id=ReportDisease_044_S_044_000${element}[PROJECT_DATA3]
                Wait Until Element Contains    id=ReportDisease_044_S_044_000${element}[PROJECT_DATA3]    ${element}[INSPECTION_RESULT]
                Select From List By Label    id=ReportDisease_044_S_044_000${element}[PROJECT_DATA3]    ${element}[INSPECTION_RESULT]
                                
            END
        ELSE
            Click Element    //label[@for="ReportDisease_044_S_044_00043"]
        END                
    END
        
    # CD4
    IF    '${element}[CD4]' != 'None'
        Input Text    //*[@id="ReportDisease_044_S_044_00044"]    ${element}[CD4]        
    END

    # CD4比例
    IF    '${element}[CD4_PERCENT]' != 'None'
        Input Text    //*[@id="ReportDisease_044_S_044_00045"]    ${element}[CD4_PERCENT]        
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
    Travel_History    ${element}

    # 感染危險因子
    IF    '${element}[INFECTION_RISK]' != 'None'
        @{infection_risk}    Split String    ${element}[INFECTION_RISK]    ,
        FOR    ${risk}    IN    @{infection_risk}
            Click Element    //label[contains(text(), '${risk}')]
            IF    '${risk}' == '性行為'
                Click Element    //label[@for="ReportDisease_044_S_044_000${element}[SEX_PERSON]"]
            END
            IF    '${risk}' == '不詳'
                Input Text    //*[@id="ReportDisease_044_S_044_00055"]    ${element}[UNKNOWN_DATA]
            END
            # IF    '${risk}' == '其他'
            #     Input Text    //*[@id="ReportDisease_044_S_044_00057"]    ${element}[OTHER_DATA]
            # END
        END
    END

    #懷孕週數
    IF    '${element}[PREGNANT_WEEK]' != 'None'                
        Input Text    //*[@id="ReportDisease_044_S_044_00058"]    ${element}[PREGNANT_WEEK]
    END

    #預產期
    IF    '${element}[DUE_DATE]' != 'None'        
        ${tmpday}    Get Taiwain Date String    ${element}[DUE_DATE]
        Input Text    //*[@id="ReportDisease_044_S_044_00059"]    ${tmpday}
    END
    
    #增修原因
    IF    '${element}[UPDATE_REASON]' != 'None'
        Input Text    //textarea[@id="casePatient_ModifyReason"]    ${element}[UPDATE_REASON]
    END
    
    # 新增通報
    Set Global Variable    ${item_function}    ${element}[FUNCTION]
    IF    ${element}[FUNCTION] == 1
        Create Data
        ${report_id}    Get Text    xpath=/html/body/div[2]/div[2]/main/div[2]/div/div/div[1]/div[1]/span[1]/a
        # 透過等待畫面出現縣市, 以確保資料讀取完成, 再進行截圖
        Wait Until Page Contains    ${element}[COUNTY]
        # 截圖佐證
        Capture Page Screenshot    ${screenshot}\\044_report_MED_${element}[DISEASE]_${element}[Num].png
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
    Sleep    2s
    #點選增修功能
    Click Element    //tbody[@id="searchResult"]/tr/td[last()]/a
    Sleep    2s
    #資料增修
    COMMON REPORT    ${element}
    #增修通報
    Update Data
    Wait Until Page Contains    ${element_id}[REPORT_ID]
    Sleep    1s
    Capture Page Screenshot    ${screenshot}\\044_report_MED_Update_${element}[Num].png
    Set Global Variable    ${item_result}    ${True}




*** Tasks ***
Smoke_WEB_MED_044_NEWREPORT_01
    [Documentation]    煙霧測試:醫療院所人類免疫缺乏病毒感染(含母子垂直感染及孕產婦疑似個案)
    [Tags]    Smoke
    [Setup]    Set Global Variable    ${screenshot}    testresult\\${TEST_NAME}

    Open Available Browser    maximized=${True}    browser_selection=${BROWSER}
    #Clean Excel    Data_ID.xlsx
    Clean Excel    Data_Result.xlsx
    Read Report Excel    Smoke_WEB_MED_044_NEWREPORT_01.xlsx
    # 清除截圖路徑
    #Remove Directory    ${screenshot}    resource=true

    FOR    ${element}    IN    @{test_users}
        Login    ${element}    ${NIDRS_WEB_URL}

        # 測試1 新增
        FOR    ${report}    IN    @{test_reports}
            Run Keyword And Continue On Failure    COMMON REPORT    ${report}
            
            Run Keyword If    ${item_result} == ${False}
            ...    Capture Page Screenshot    ${screenshot}\\044_report_MED_${report}[DISEASE]_${report}[Num]_Error.png

            Clear Error
            Write Result Excel    ${item_function}    ${item_num}    ${item_result}    Data_Result.xlsx
            
        END
        
        # 測試2 增修
        Read ID Excel    Data_ID.xlsx
        Read Update Excel    Smoke_WEB_MED_044_NEWREPORT_01.xlsx
        FOR    ${update}    IN    @{test_update}
            FOR    ${id}    IN    @{test_id}
                IF    ${id}[Num] == ${update}[Num]
                    Run Keyword And Continue On Failure    Update Report    ${update}    ${id}
                    
                    Run Keyword If    ${item_result} == ${False}
                    ...    Capture Page Screenshot    ${screenshot}\\044_report_MED_UPDATE_${update}[Num]_Error.png

                    Clear Error
                    Write Result Excel    ${update}[FUNCTION]    ${update}[Num]    ${item_result}    Data_Result.xlsx
                END
                
            END
        END

        # 測試3 研判
        Run Keyword And Ignore Error    Logout
    END
    


    [Teardown]    Close All Browsers

