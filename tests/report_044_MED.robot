*** Settings ***
Documentation    醫療院所通報測試-人類免疫缺乏病毒感染(含母子垂直感染及孕產婦疑似個案)18歲以上
Library    RPA.Browser.Selenium
Library    RPA.Excel.Files
Library    String
Library    RPA.FileSystem
Resource    keywords.robot
Resource    Variables.robot

*** Variables ***
${screenshot}
${test_users}
${test_reports}
${item_result}
${num}



*** Keywords ***
Read Excel
    Open Workbook    testdata\\Smoke_WEB_MED_044_NEWREPORT_02.xlsx
    ${sheet1}    Read Worksheet    name=login    header=True
    ${sheet2}=    Read Worksheet    name=report   header=True    start=3    #第一二行是說明, 第三行是標頭
    Log To Console    \r\n${sheet1}\r\n${sheet2}
    Close Workbook
    Set Global Variable    ${test_users}    ${sheet1}
    Set Global Variable    ${test_reports}    ${sheet2}





COMMON REPORT
    [Arguments]    ${element}
    ${tmpday}    Get Taiwain Date String    -2
    
    Set Global Variable    ${num}    ${element}[Num]
    Set Global Variable    ${item_result}    ${False}
    Sleep    1s
    Log To Console    點擊新增通報單
    Click Element    id=101
    Sleep    1s
    Input Text    id=reporter_DiagDoctor    ${element}[DIAGNOSTICIAN]
    Input Text    id=casePatient_Idno    ${element}[IDNO]
    Input Text    id=casePatient_Name    ${element}[NAME]

    #羅馬拼音    
    Romanization    ${element}

    #性別
    Gender    ${element} 
    
    #生日
    Log To Console    ${element}[BIRTHDAY]
    Input Text    id=casePatient_Birthdate    ${element}[BIRTHDAY]
    
    #本國籍
    Nationality    ${element}
    
    
    #手機/聯絡電話欄位因為有重複定義的element id, 改以xpath處理
    #Input Text    id=casePatient_MobilePhone_0    ${element}[CELLPHONE]
    Input Text    //input[@id="casePatient_MobilePhone_0"]    ${element}[CELLPHONE]
    Input Text    //input[@id="casePatient_ContactPhone_0"]    ${element}[CONTACTPHONE]
    
    Wait Until Element Contains    id=casePatient_Living_County    ${element}[COUNTY]
    Select From List By Label    id=casePatient_Living_County    ${element}[COUNTY]

    
    # 出現list無內容的異常
    # 這邊click是為了觸發list重新更新
    Click Element    id=casePatient_Living_Town
    Wait Until Element Contains    id=casePatient_Living_Town    ${element}[TOWN]
    
    Select From List By Label    id=casePatient_Living_Town    ${element}[TOWN]
    
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
    IF    ${element}[DIAGNOSE_DAY] != 'None'
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
    

    
    # 確定通報
    Click Button    //*[@id="buttonReportSend"]
    Wait Until Page Contains    確認是否送出通報單
    Sleep    200ms
    Click Button    //*[@id="_dialog"]/div/div/div[3]/div[1]/button
    Sleep    100ms

    # 通報完成頁
    Wait Until Page Contains    法定傳染病個案通報完成
    ${report_id}    Get Text    xpath=/html/body/div[2]/div[2]/main/div[2]/div/div/div[1]/div[1]/span[1]/a
    # 透過等待畫面出現縣市, 以確保資料讀取完成, 再進行截圖
    Wait Until Page Contains    ${element}[COUNTY]
    # 截圖佐證
    
    Capture Page Screenshot    ${screenshot}\\044_report_MED_${element}[DISEASE]_${element}[Num].png

    Log To Console    ${report_id}

    Set Global Variable    ${item_result}    ${True}





*** Tasks ***
Smoke_WEB_MED_044_NEWREPORT_02
    [Documentation]    煙霧測試:醫療院所人類免疫缺乏病毒感染(含母子垂直感染及孕產婦疑似個案)18歲以上通報
    [Tags]    Smoke
    [Setup]    Set Global Variable    ${screenshot}    testresult\\${TEST_NAME}

    Open Available Browser    maximized=${True}    browser_selection=${BROWSER}
    Read Excel
    # 清除截圖路徑
    Remove Directory    ${screenshot}    resource=true

    FOR    ${element}    IN    @{test_users}
        Login    ${element}    ${NIDRS_WEB_URL}
        FOR    ${report}    IN    @{test_reports}
            Run Keyword And Continue On Failure    COMMON REPORT    ${report}
            
            Run Keyword If    ${item_result} == ${False}
            ...    Capture Page Screenshot    ${screenshot}\\044_report_MED_${report}[DISEASE]_${num}Error.png

            Clear Error
        END
        Run Keyword And Ignore Error    Logout
    END
    


    [Teardown]    Close All Browsers

