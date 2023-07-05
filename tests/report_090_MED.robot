*** Settings ***
Documentation    醫療院所通報測試-梅毒
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
    Open Workbook    testdata\\Smoke_WEB_MED_090_NEWREPORT_01.xlsx
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
        Sleep    1s        
    END
        

    #通報時檢驗資料
    IF    '${element}[TEST_OPTION]' != 'None'
        #1 未曾接受梅毒治療或病史不清楚者
        IF    '${element}[TEST_OPTION]' == '1'
            Click Element    //label[@for="ReportDisease_090_S_ONEOFFOUR90_ONE"]
            Sleep    200ms
            #RPR
            IF    '${element}[RPR]' != 'None'
                Click Element    id=ReportDisease_090_S_QS09001030_AS09001030
                Select From List By Label    id=ReportDisease_090_S_QS09001030_AS09001030    ${element}[RPR]                
            END
            #VDRL
            IF    '${element}[VDRL]' != 'None'
                Click Element    id=ReportDisease_090_S_QS09001040_AS09001040
                Select From List By Label    id=ReportDisease_090_S_QS09001040_AS09001040    ${element}[VDRL]                
            END
            #TPHA
            IF    '${element}[TPHA]' != 'None'
                Click Element    id=ReportDisease_090_S_QS09001050_AS09001050
                Select From List By Label    id=ReportDisease_090_S_QS09001050_AS09001050    ${element}[TPHA]               
            END
            
            #TPPA
            IF    '${element}[TPPA]' != 'None'
                Click Element    id=ReportDisease_090_S_QS09001060_AS09001060
                Select From List By Label    id=ReportDisease_090_S_QS09001060_AS09001060    ${element}[TPPA]              
            END            
            IF    '${element}[OTHER_SPECIAL_TEST]' != 'None'
                @{other_test}    Split String    ${element}[OTHER_SPECIAL_TEST]    ,
                FOR    ${other}    IN    @{other_test}
                    Log To Console    ${other}
                    Click Element    //label[contains(text(), '${other}')]
                END                
            END
            
        END


        # 2 臨床檢體
        IF    '${element}[TEST_OPTION]' != 'None'
            IF    '${element}[TEST_OPTION]' == '2'
                Click Element    //label[@for="ReportDisease_090_S_ONEOFFOUR90_TWO"]
                IF    '${element}[CLINICAL_SPECIMEN]' != 'None'
                    @{clinical_specimen}    Split String    ${element}[CLINICAL_SPECIMEN]    ,
                    FOR    ${specimen}    IN    @{clinical_specimen}
                        Log To Console    ${specimen}
                        Click Element    //label[contains(text(), '${specimen}')]
                    END                    
                END                
            END            
        END
            

        # 3 腦脊髓液性病研究實驗室試驗
        IF    '${element}[TEST_OPTION]' != 'None'
            IF    '${element}[TEST_OPTION]' == '3'
                Click Element    //label[@for="ReportDisease_090_S_ONEOFFOUR90_THREE"]
                Select From List By Label    id=ReportDisease_090_S_QS09001070_AS09001070    ${element}[CSF-VDRL]
            END
        END
        

        # 4 曾經接受梅毒治療者
        IF    '${element}[TEST_OPTION]' != 'None'
            IF    '${element}[TEST_OPTION]' == '4'
                Click Element    //label[@for="ReportDisease_090_S_ONEOFFOUR90_FOUR"]
                @{non_specific}    Split String    ${element}[NON-SPECIFIC]    ,
                FOR    ${specific}    IN    @{non_specific}
                    Log To Console    ${specific}
                    #Click Element    //label[contains(text(), '${specific}')]
                END
            END            
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
    
    

    #個案狀況維護與補充資料
    #愛滋篩檢
    IF    '${element}[AIDS_TEST]' != 'None'
    
        IF    ${element}[AIDS_TEST] == $True
            Click Element    //label[@for="ReportDisease_090_S_QS09001090_AS09001091"]
            ${tmpday}    Get Taiwain Date String    ${element}[AIDS_TEST_DATE]
            Input Text    //*[@id="ReportDisease_090_S_QS09001100_AS09001100"]    ${tmpday}
        ELSE
            Click Element    //label[@for="ReportDisease_090_S_QS09001090_AS09001092"]
        END
    END
    
    

    #懷孕
    IF    '${element}[PREGNANT]' != 'None'
    
        IF    ${element}[PREGNANT] == $True
            
            Click Element    //label[@for="ReportDisease_090_S_QS09001110_AS09001111"]
            
            Input Text    //*[@id="ReportDisease_090_S_QS09001120_AS09001120"]    ${element}[PREGNANT_WEEK]
        ELSE
            Click Element    //label[@for="ReportDisease_090_S_QS09001110_AS09001112"]
        END
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
    
    Capture Page Screenshot    ${screenshot}\\090_report_MED_${element}[DISEASE]_${element}[Num].png

    Log To Console    ${report_id}

    Set Global Variable    ${item_result}    ${True}





*** Tasks ***
Smoke_WEB_MED_090_NEWREPORT_01
    [Documentation]    煙霧測試:醫療院所梅毒通報
    [Tags]    Smoke
    [Setup]    Set Global Variable    ${screenshot}    testresult\\${TEST_NAME}

    Open Available Browser    maximized=${True}    browser_selection=${BROWSER}
    Read Excel
    # 清除截圖路徑
    #Remove Directory    ${screenshot}    resource=true

    FOR    ${element}    IN    @{test_users}
        Login    ${element}    ${NIDRS_WEB_URL}
        FOR    ${report}    IN    @{test_reports}
            Run Keyword And Continue On Failure    COMMON REPORT    ${report}
            
            Run Keyword If    ${item_result} == ${False}
            ...    Capture Page Screenshot    ${screenshot}\\090_report_MED_${report}[DISEASE]_${num}Error.png

            Clear Error
        END
        Run Keyword And Ignore Error    Logout
    END
    


    [Teardown]    Close All Browsers

