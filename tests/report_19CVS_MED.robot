*** Settings ***
Documentation    醫療院所通報測試-嚴重特殊傳染性肺炎(併發症)
Library    RPA.Browser.Selenium
Library    RPA.Excel.Files
Library    String
Library    RPA.FileSystem
Library    RequestsLibrary
Resource   ..\\keywords\\keywords.robot
Resource   ..\\keywords\\Variables.robot

*** Variables ***
${screenshot}
${test_users}
${test_reports}
${test_update}
${item_result}
${num}
${report_id}



*** Keywords ***
COMMON REPORT
    [Arguments]    ${element}
    ${tmpday}    Get Taiwain Date String    -2
    
    Set Global Variable    ${num}    ${element}[Num]
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
        # 注意, 以@類型接收
        @{symptoms}    Split String    ${element}[SYMPTOMS]    ,
        
        FOR    ${smp}    IN    @{symptoms}
            Log To Console    ${smp}
            Click Element    //label[contains(text(), '${smp}')]
            # 點選'其他新冠感染相關併發症'
            IF    '${smp}' == '其他新冠感染相關併發症'
                @{other_symtoms}    Split String    ${element}[OTHER_SYMPTOM]    ,
                FOR    ${other_smp}    IN    @{other_symtoms}
                    Log To Console    ${other_smp}
                    Click Element    //label[contains(text(), '${other_smp}')]
                END
            END
        END
        ELSE
        Click Element    //*[@id="ReportDisease_symp"]/div[2]/label
        END
        Sleep    1s
    END
    
    
    
    #快篩結果
    Click Element    //*[@id="diseaseReportData"]/div[7]/div[1]/div[2]
    Sleep    1s
    IF    '${element}[RAPID_TEST]' != 'None'
        IF    ${element}[RAPID_TEST] == $True
            Click Element    //*[@id="ReportDisease_19CVS_S_QS19CVS330"]/div[1]/label        
        ELSE
            Click Element    //*[@id="ReportDisease_19CVS_S_QS19CVS330"]/div[2]/label        
        END
            ${tmpday}    Get Taiwain Date String    ${element}[RAPID_TEST_DATE]
            Input Text    //*[@id="ReportDisease_19CVS_S_19CVS_00053"]    ${tmpday}
            Input Text    //input[@id="ReportDisease_19CVS_S_QS19CVS334_AS19CVS334"]    ${element}[RAPID_TEST_COMPANY]
            ${tmpday}    Get Taiwain Date String    ${element}[RAPID_TEST_REPORT_DATE]
            Input Text    //*[@id="ReportDisease_19CVS_S_QS19CVS335_AS19CVS335"]    ${tmpday}
        
    END
            

    #PCR結果
    Click Element    //*[@id="diseaseReportData"]/div[7]/div[2]/div[2]
    IF    '${element}[PCR_TEST]' != 'None'
        IF    ${element}[PCR_TEST] == $True
        Click Element    //*[@id="ReportDisease_19CVS_S_QS19CVS340"]/div[1]/label
    ELSE
        Click Element    //*[@id="ReportDisease_19CVS_S_QS19CVS340"]/div[2]/label
    END
        ${tmpday}    Get Taiwain Date String    ${element}[PCR_DATE]
        Input Text    //*[@id="ReportDisease_19CVS_S_19CVS_00054"]    ${tmpday}
        Input Text    //input[@id="ReportDisease_19CVS_S_QS19CVS344_AS19CVS344"]    ${element}[PCR_TEST_COMPANY]
        ${tmpday}    Get Taiwain Date String    ${element}[PCR_REPORT_DATE]
        Input Text    //*[@id="ReportDisease_19CVS_S_QS19CVS345_AS19CVS345"]    ${tmpday}
        Sleep    2s        
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


    # 慢性病
    IF    '${element}[CHRONIC]' != 'None'
        IF    ${element}[CHRONIC] == $True
        Click Element    //*[@id="ReportDisease_19CVS_S_19CVS_00004_select"]/div[1]/label
        Sleep    200ms
        IF    '${element}[CHRONIC_SYMPTOMS]' != 'None'
            # 注意, 以@類型接收
            @{chronic_symptoms}    Split String    ${element}[CHRONIC_SYMPTOMS]   ,
            FOR    ${chronic_smp}    IN    @{chronic_symptoms}
                Log To Console    ${chronic_smp}
                Click Element    //label[contains(text(), '${chronic_smp}')]            
            END
            ELSE
                Click Element    //*[@id="ReportDisease_19CVS_S_19CVS_00004_select"]/div[2]/label
            END            
        END
    END
    

    # 侵入性治療
    # 僅測試首日
    IF    '${element}[INTUBATION]' != 'None'
        IF    ${element}[INTUBATION] == $True
            Click Element    //label[@for="ReportDisease_19CVS_S_19CVS_00023"]
            ${tmpday}    Get Taiwain Date String    ${element}[FIRST_INTUBATION]
            Input Text    //*[@id="ReportDisease_19CVS_S_19CVS_00025"]    ${tmpday}
        ELSE
            Click Element    //label[@for="ReportDisease_19CVS_S_19CVS_00024"]
        END
    END

    IF    '${element}[ECMO]' != 'None'
        IF    ${element}[ECMO] == $True
            Click Element    //label[@for="ReportDisease_19CVS_S_19CVS_00027"]
            ${tmpday}    Get Taiwain Date String    ${element}[FIRST_ECMO]
            Input Text    //*[@id="ReportDisease_19CVS_S_19CVS_00029"]    ${tmpday}
        ELSE
            Click Element    //label[@for="ReportDisease_19CVS_S_19CVS_00028"]
        END
    END
        


    # 氧治療
    IF    '${element}[O2CURE]' != 'None'
        IF    ${element}[O2CURE] == $True
            Click Element    //*[@id="ReportDisease_19CVS_S_19CVS_00031_section"]/div[1]/label
        ELSE
            Click Element    //*[@id="ReportDisease_19CVS_S_19CVS_00031_section"]/div[2]/label
        END        
    END
    
    #增修原因
    IF    '${element}[UPDATE_REASON]' != 'None'
        Input Text    //textarea[@id="casePatient_ModifyReason"]    ${element}[UPDATE_REASON]
    END


    # 新增
    # 確定通報
    IF    ${element}[FUNCTION] == 1
        Create Data
        ${report_id}    Get Text    xpath=/html/body/div[2]/div[2]/main/div[2]/div/div/div[1]/div[1]/span[1]/a
        # 透過等待畫面出現縣市, 以確保資料讀取完成, 再進行截圖
        Wait Until Page Contains    ${element}[COUNTY]
        # 截圖佐證
        Capture Page Screenshot    ${screenshot}\\19CVS_report_MED_${element}[DISEASE]_${element}[Num].png
        Log To Console    ${report_id}

        Set Global Variable    ${item_result}    ${True}
        #讀取編號
        Write Excel    ${report_id}    Smoke_WEB_MED_19CVS_NEWREPORT_01.xlsx
        Set Global Variable    ${report_id}
    END

    #增修
    IF    ${element}[FUNCTION] == 2
        Update Data
        Wait Until Page Contains    ${element}[REPORT_ID]
        Sleep    1s
        Capture Page Screenshot    ${screenshot}\\19CVS_report_MED_Update_${element}[Num].png
        Set Global Variable    ${item_result}    ${True}
    END


Update Report
    #增修資料(不修改地址)
    [Arguments]    ${element}
    
    #成功頁面複製編號
    #Click Element    //div[@id="report_complete_disease_area"]/div/div[1]/div/a    #只執行增修功能 此行需註解
    #Press Keys    id=quick_search_field    CTRL+v
    
    Click Element    id=quick_search_field
    Input Text    id=quick_search_field    ${element}[REPORT_ID]
    
    Click Element    //*[@id="headersearch"]/div
    Sleep    2s
    #點選增修功能
    Click Element    //tbody[@id="searchResult"]/tr/td[last()]/a
    Sleep    2s
    #資料增修
    COMMON REPORT    ${element}


*** Tasks ***
Smoke_WEB_MED_19CVS_NEWREPORT_01
    [Documentation]    煙霧測試:醫療院所嚴重特殊傳染性肺炎(併發症)通報
    [Tags]    Smoke
    [Setup]    Set Global Variable    ${screenshot}    testresult\\${TEST_NAME}

    Open Available Browser    maximized=${True}    browser_selection=${BROWSER}
    Read Report Excel    Smoke_WEB_MED_19CVS_NEWREPORT_01.xlsx
    # 清除截圖路徑
    Remove Directory    ${screenshot}    resource=true
    
    FOR    ${element}    IN    @{test_users}
        Login    ${element}    ${NIDRS_WEB_URL}

        # 測試1 新增
        # FOR    ${report}    IN    @{test_reports}
        #     Run Keyword And Continue On Failure    COMMON REPORT    ${report}
            
        #     Run Keyword If    ${item_result} == ${False}
        #     ...    Capture Page Screenshot    ${screenshot}\\19CVS_report_MED_${report}[DISEASE]_${report}[Num]_Error.png

        #     Clear Error
            
        # END
        
        # 測試2 增修
        Read Update Excel    Smoke_WEB_MED_19CVS_NEWREPORT_01.xlsx
        FOR    ${update}    IN    @{test_update}
            Run Keyword And Continue On Failure    Update Report    ${update}
            
            Run Keyword If    ${item_result} == ${False}
            ...    Capture Page Screenshot    ${screenshot}\\19CVS_report_MED_UPDATE_${update}[Num]_Error.png

            Clear Error
        END

        # 測試3 研判
        Run Keyword And Ignore Error    Logout
    END
    


    [Teardown]    Close All Browsers

