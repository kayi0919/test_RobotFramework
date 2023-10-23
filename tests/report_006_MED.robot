*** Settings ***
Documentation    醫療院所通報測試-阿米巴性痢疾
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
    # 診斷醫師
    Diagnostician    ${element}
    # 身分證統一編號
    IDNO    ${element}
    # 個案姓名
    Name    ${element}
    # 羅馬拼音    
    Romanization    ${element}
    # 性別
    Gender    ${element}
    # 出生日期
    Birthday    ${element}
    # 本國籍
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

    # 檢驗資料
    IF    '${element}[CHECK_DATA]' != 'None'
        @{check_data}    Split String    ${element}[CHECK_DATA]    ,
        FOR    ${data}    IN    @{check_data}
            IF    ${data} == 1
                Click Element    //label[@for="ReportDisease_006_S_Q000060001_AS00000017"]                
            END
            IF    ${data} == 2
                Click Element    //label[@for="ReportDisease_006_S_Q000060002_AS00000018"]
                IF    '${element}[SPECIALIST]' != 'None'
                    Input Text    //*[@id="ReportDisease_006_S_Q000060003_A000000295"]    ${element}[SPECIALIST]
                END
            END
            IF    ${data} == 3
                Click Element    //label[@for="ReportDisease_006_S_Q000060004_AS00000019"]
                IF    '${element}[FIRST_ANTIBODY_TITER]' != 'None'
                    Input Text    //*[@id="ReportDisease_006_S_Q000060016_A000000117"]    ${element}[FIRST_ANTIBODY_TITER]
                    ${tmpday}    Get Taiwain Date String    ${element}[FIRST_TEST_DATE]
                    Input Text    //*[@id="ReportDisease_006_S_Q000060016_A000000118"]    ${tmpday}
                    Input Text    //*[@id="ReportDisease_006_S_Q000060016_A000000295"]    ${element}[FIRST_TEST_METHOD]
                END
                IF    '${element}[SECOND_ANTIBODY_TITER]' != 'None'
                    Input Text    //*[@id="ReportDisease_006_S_Q000060017_A000000117"]    ${element}[SECOND_ANTIBODY_TITER]
                    ${tmpday}    Get Taiwain Date String    ${element}[SECOND_TEST_DATE]
                    Input Text    //*[@id="ReportDisease_006_S_Q000060017_A000000118"]    ${tmpday}
                    Input Text    //*[@id="ReportDisease_006_S_Q000060017_A000000295"]    ${element}[SECOND_TEST_METHOD]
                END
            END
            IF    ${data} == 4
                Click Element    //label[@for="ReportDisease_006_S_Q000060005_AS00000020"]
                IF    '${element}[ANTIBODY_TITER]' != 'None'
                    Input Text    //*[@id="ReportDisease_006_S_Q000060020_A000000212"]    ${element}[ANTIBODY_TITER]
                    
                    Input Text    //*[@id="ReportDisease_006_S_Q000060020_A000000295"]    ${element}[TEST_METHOD]
                END
            END
            IF    ${data} == 5
                Click Element    //label[@for="ReportDisease_006_S_Q000060014_AS00000029"]
                IF    '${element}[REASON]' != 'None'
                    Input Text    id=ReportDisease_006_S_Q000060015_A000000295    ${element}[REASON]
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
        END
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
        Capture Page Screenshot    ${screenshot}\\006_report_MED_${element}[DISEASE]_${element}[Num].png
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
    Capture Page Screenshot    ${screenshot}\\006_report_MED_Update_${element}[Num].png
    Set Global Variable    ${item_result}    ${True}


*** Tasks ***
Smoke_WEB_MED_006_NEWREPORT_01
    [Documentation]    煙霧測試:醫療院所阿米巴性痢疾通報
    [Tags]    Smoke
    [Setup]    Set Global Variable    ${screenshot}    testresult\\${TEST_NAME}

    Open Available Browser    maximized=${True}    browser_selection=${BROWSER}
    Clean Excel    Data_ID.xlsx
    Clean Excel    Data_Result.xlsx
    Read Report Excel    Smoke_WEB_MED_006_NEWREPORT_01.xlsx
    # 清除截圖路徑
    Remove Directory    ${screenshot}    resource=true

    FOR    ${element}    IN    @{test_users}
        Login    ${element}    ${NIDRS_WEB_URL}

        # 測試1 新增
        FOR    ${report}    IN    @{test_reports}
            Run Keyword And Continue On Failure    COMMON REPORT    ${report}
            
            Run Keyword If    ${item_result} == ${False}
            ...    Capture Page Screenshot    ${screenshot}\\006_report_MED_${report}[DISEASE]_${report}[Num]_Error.png

            Clear Error
            Write Result Excel    ${item_function}    ${item_num}    ${item_result}    Data_Result.xlsx
        END
        
        # 測試2 增修
        Read ID Excel    Data_ID.xlsx
        Read Update Excel    Smoke_WEB_MED_006_NEWREPORT_01.xlsx
        FOR    ${update}    IN    @{test_update}
            FOR    ${id}    IN    @{test_id}
                IF    ${id}[Num] == ${update}[Num]
                    Run Keyword And Continue On Failure    Update Report    ${update}    ${id}
                    
                    Run Keyword If    ${item_result} == ${False}
                    ...    Capture Page Screenshot    ${screenshot}\\006_report_MED_UPDATE_${update}[Num]_Error.png

                    Clear Error
                    Write Result Excel    ${item_function}    ${item_num}    ${item_result}    Data_Result.xlsx
                END
                
            END
            
        END

        # 測試3 研判
        Run Keyword And Ignore Error    Logout
    END
    


    [Teardown]    Close All Browsers

