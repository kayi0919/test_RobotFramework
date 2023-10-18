*** Settings ***
Documentation    醫療院所通報測試-結核病
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
    IF    ${element}[DIAGNOSE_DAY] != 'None'
        ${tmpday}    Get Taiwain Date String    ${element}[DIAGNOSE_DAY]
        Input Text    //*[@id="ReportDisease_diagDate"]    ${tmpday}        
    END
    
    # 報告日期
    IF    '${element}[REPORTED_DAY]' != 'None'
        ${tmpday}    Get Taiwain Date String    ${element}[REPORTED_DAY]
        Input Text    //*[@id="ReportDisease_reportDate"]    ${tmpday}        
    END

    # 登記類別
    IF    '${element}[INFECTED_STATUS]' != 'None'
        IF    ${element}[INFECTED_STATUS] == 1
            Click Element    //label[@for="ReportDisease_010_S_INFECTED_STATUS_0"]
            IF    '${element}[LUNG_BASIS]' != 'None'
                Click Element    id=ReportDisease_010_S_LUNG_BASIS_ID
                Select From List By Label    id=ReportDisease_010_S_LUNG_BASIS_ID    ${element}[LUNG_BASIS]
                    
            END        
        END
        IF    ${element}[INFECTED_STATUS] == 2
            Click Element    //label[@for="ReportDisease_010_S_INFECTED_STATUS_1"]
            Click Element    id=ReportDisease_010_S_LUNG_BASIS_ID
            Select From List By Label    id=ReportDisease_010_S_LUNG_BASIS_ID    ${element}[LUNG_BASIS]
            
        END
        IF    ${element}[INFECTED_STATUS] == 3
            Click Element    //label[@for="ReportDisease_010_S_INFECTED_STATUS_2"]
            Click Element    id=ReportDisease_010_S_LUNG_BASIS_ID
            Select From List By Label    id=ReportDisease_010_S_LUNG_BASIS_ID    ${element}[LUNG_BASIS]                
        END        
    END
    
    
    # 肋膜積水
    IF    '${element}[PLUERA_ACCUMULATE]' != 'None'
        IF    ${element}[PLUERA_ACCUMULATE] == $True
            Click Element    //label[@for="ReportDisease_010_S_PLUERA_ACCUMULATE_1"]
        ELSE
            Click Element    //label[@for="ReportDisease_010_S_PLUERA_ACCUMULATE_0"]
        END
        
    END

    # X光診斷日
    IF    '${element}[XRAY_DIAGNOSIS_TYPE]' != 'None'
        IF    ${element}[XRAY_DIAGNOSIS_TYPE] == 1
            ${tmpday}    Get Taiwain Date String    ${element}[XRAY_DIAGNOSIS_DATE]
            Input Text    //*[@id="ReportDisease_010_S_XRAY_DIAGNOSIS_DATE"]    ${tmpday}
        ELSE
            Click Element    id=ReportDisease_010_S_010_sameDiagnoseDay
        END    
    END

    # X光診斷結果
    IF    '${element}[XRAY_DIAGNOSIS_RESULT]' != 'None'
        Click Element    id=ReportDisease_010_S_XRAY_RESLUT_ID
        Select From List By Label    id=ReportDisease_010_S_XRAY_RESLUT_ID    ${element}[XRAY_DIAGNOSIS_RESULT]
    END

    # X光診斷單位 
    IF    '${element}[XRAY_DIAGNOSIS_CHOICE]' != 'None'
        IF    ${element}[XRAY_DIAGNOSIS_CHOICE] == 1
            Click Element    id=ReportDisease_010_S_XRAY_DIAGNOSIS_UNIT_name
            
            Search Type    ${element}[XRAY_SEARCH_TYPE]    ${element}[XRAY_KEYWORD_SEARCH]    ${element}[XRAY_APARTMENT_CITY]    ${element}[XRAY_APARTMENT_TYPE]
        ELSE
            Click Element    //*[@id="diseaseReportData"]/div[3]/div[1]/div[7]/div/div/div/div/div/a
            
        END
        
    END

    # 檢體種類
    IF    '${element}[SAMPLE_TYPE]' != 'None'
        Click Element    id=ReportDisease_010_S_ReportTBSample_F_SAMPLE_TYPE_0
        Select From List By Label    id=ReportDisease_010_S_ReportTBSample_F_SAMPLE_TYPE_0    ${element}[SAMPLE_TYPE]
        IF    '${element}[SAMPLE_TYPE_DESC]' != 'None'
            Input Text    id=ReportDisease_010_S_ReportTBSample_F_SAMPLE_TYPE_DESC_0    ${element}[SAMPLE_TYPE_DESC]
        END        
        IF    ${element}[SAMPLE_TYPE_CHOICE] == 1
            ${tmpday}    Get Taiwain Date String    ${element}[SAMPLE_TYPE_DATE]
            Input Text    //*[@id="ReportDisease_010_S_ReportTBSample_F_SAMPLE_CHK_DATE_0"]    ${tmpday}
        ELSE
            Click Element    //*[@id="ReportTBSample_0"]/div[2]/div/div/div/div/a
            
        END
        
        
    END

    # 病理報告單位 
    IF    '${element}[PLGYCHK_DIAGNOSIS_CHOICE]' != 'None'
        IF    ${element}[PLGYCHK_DIAGNOSIS_CHOICE] == 1
            Click Element    id=ReportDisease_010_S_ReportTBSample_F_PLGYCHK_UNIT_0_name
            
            Search Type    ${element}[PLGYCHK_SEARCH_TYPE]    ${element}[PLGYCHK_KEYWORD_SEARCH]    ${element}[PLGYCHK_APARTMENT_CITY]    ${element}[PLGYCHK_APARTMENT_TYPE]
        ELSE
            Click Element    //*[@id="ReportTBSample_0"]/div[3]/div[1]/div/div/div/div/a
            
        END
        
    END

    # 病理報告結果
    IF    '${element}[PLGYCHK_RESULT]' != 'None'
        Click Element    id=ReportDisease_010_S_ReportTBSample_F_PLGYCHK_RESULT_0
        Select From List By Label    id=ReportDisease_010_S_ReportTBSample_F_PLGYCHK_RESULT_0    ${element}[PLGYCHK_RESULT]

    END

    # 塗片檢驗單位 
    IF    '${element}[SMEAR_CHK_DIAGNOSIS_CHOICE]' != 'None'
        IF    ${element}[SMEAR_CHK_DIAGNOSIS_CHOICE] == 1
            Click Element    id=ReportDisease_010_S_ReportTBSample_F_SMEAR_CHK_UNIT_0_name
            
            Search Type    ${element}[SMEAR_CHK_SEARCH_TYPE]    ${element}[SMEAR_CHK_KEYWORD_SEARCH]    ${element}[SMEAR_CHK_APARTMENT_CITY]    ${element}[SMEAR_CHK_APARTMENT_TYPE]
        ELSE
            Click Element    //*[@id="ReportTBSample_0"]/div[4]/div[1]/div/div/div/div/a
            
        END
        
    END

    # 塗片結果
    IF    '${element}[SMEAR_CHK_RESULT]' != 'None'
        Click Element    id=ReportDisease_010_S_ReportTBSample_F_SMEAR_CHK_RESULT_0
        Select From List By Label    id=ReportDisease_010_S_ReportTBSample_F_SMEAR_CHK_RESULT_0    ${element}[SMEAR_CHK_RESULT]
          
    END

    # PCR檢驗單位 
    IF    '${element}[PCR_DIAGNOSIS_CHOICE]' != 'None'
        IF    ${element}[PCR_DIAGNOSIS_CHOICE] == 1
            Click Element    id=ReportDisease_010_S_ReportTBSample_F_PCR_CHK_UNIT_0_name
            
            Search Type    ${element}[PCR_SEARCH_TYPE]    ${element}[PCR_KEYWORD_SEARCH]    ${element}[PCR_APARTMENT_CITY]    ${element}[PCR_APARTMENT_TYPE]
        ELSE
            Click Element    //*[@id="ReportTBSample_0"]/div[5]/div[1]/div/div/div/div/a
            
        END
        
    END

    # PCR結果
    IF    '${element}[PCR_RESULT]' != 'None'
        Click Element    id=ReportDisease_010_S_ReportTBSample_F_PCR_CHK_RESULT_0
        Select From List By Label    id=ReportDisease_010_S_ReportTBSample_F_PCR_CHK_RESULT_0    ${element}[PCR_RESULT]
          
    END


    # 培養檢驗單位 
    IF    '${element}[CULTURE_CHK_DIAGNOSIS_CHOICE]' != 'None'
        IF    ${element}[CULTURE_CHK_DIAGNOSIS_CHOICE] == 1
            Click Element    id=ReportDisease_010_S_ReportTBSample_F_CULTURE_CHK_UNIT_0_name
            
            Search Type    ${element}[CULTURE_CHK_SEARCH_TYPE]    ${element}[CULTURE_CHK_KEYWORD_SEARCH]    ${element}[CULTURE_CHK_APARTMENT_CITY]    ${element}[CULTURE_CHK_APARTMENT_TYPE]
        ELSE
            Click Element    //*[@id="ReportTBSample_0"]/div[6]/div[1]/div/div/div/div/a            
        END
        
    END

    # 培養結果
    IF    '${element}[CULTURE_CHK_RESULT]' != 'None'
        Click Element    id=ReportDisease_010_S_ReportTBSample_F_CULTURE_RESULT_0
        Select From List By Label    id=ReportDisease_010_S_ReportTBSample_F_CULTURE_RESULT_0    ${element}[CULTURE_CHK_RESULT]
          
    END

    # 菌種鑑定單位 
    IF    '${element}[TBTEST_IDENTIFY_DIAGNOSIS_CHOICE]' != 'None'
        IF    ${element}[TBTEST_IDENTIFY_DIAGNOSIS_CHOICE] == 1
            Click Element    id=ReportDisease_010_S_ReportTBSample_F_TBTEST_IDENTIFY_UNIT_0_name
            
            Search Type    ${element}[TBTEST_IDENTIFY_SEARCH_TYPE]    ${element}[TBTEST_IDENTIFY_KEYWORD_SEARCH]    ${element}[TBTEST_IDENTIFY_APARTMENT_CITY]    ${element}[TBTEST_IDENTIFY_APARTMENT_TYPE]
        ELSE
            Click Element    //*[@id="ReportTBSample_0"]/div[7]/div[1]/div/div/div/div/a
            
        END
        
    END

    # 菌種鑑定結果
    IF    '${element}[TBTEST_IDENTIFY_RESULT]' != 'None'
        Click Element    id=ReportDisease_010_S_ReportTBSample_F_TBTEST_IDENTIFY_RESULT_0
        Select From List By Label    id=ReportDisease_010_S_ReportTBSample_F_TBTEST_IDENTIFY_RESULT_0    ${element}[TBTEST_IDENTIFY_RESULT]
          
    END

    
    # 檢體院內檢體編號
    IF    '${element}[SAMPLE_HOSP_SEQID]' != 'None'
        Input Text    id=ReportDisease_010_S_ReportTBSample_F_SAMPLE_HOSP_SEQID_0    ${element}[SAMPLE_HOSP_SEQID]
    END
    # Bar-Code編號
    IF    '${element}[BAR_CODE_NO]' != 'None'
        Input Text    id=ReportDisease_010_S_ReportTBSample_F_BAR_CODE_NO_0    ${element}[BAR_CODE_NO]        
    END

    # 治療方式
    IF    '${element}[CURE_TYPE]' != 'None'
        IF    ${element}[CURE_TYPE] == 1
            Click Element    //label[@for="ReportDisease_010_S_CURE_TYPE_0"]
        END
        IF    ${element}[CURE_TYPE] == 2
            Click Element    //label[@for="ReportDisease_010_S_CURE_TYPE_1"]
        END
        IF    ${element}[CURE_TYPE] == 3
            Click Element    //label[@for="ReportDisease_010_S_CURE_TYPE_2"]
        END
        IF    ${element}[CURE_TYPE] == 4
            Click Element    //label[@for="ReportDisease_010_S_CURE_TYPE_3"]
        END
    END
    Sleep    1s

    # 多重抗藥
    IF    '${element}[MULTIPLE_DRUG_RESISTANCE]' != 'None'
        IF    ${element}[MULTIPLE_DRUG_RESISTANCE] == 1
            Click Element    //label[@for="ReportDisease_010_S_MULTIPLE_DRUG_RESISTANCE_1"]
        ELSE
            IF    ${element}[MULTIPLE_DRUG_RESISTANCE] == 2
                Click Element    //label[@for="ReportDisease_010_S_MULTIPLE_DRUG_RESISTANCE_0"]
            ELSE
                Click Element    //label[@for="ReportDisease_010_S_MULTIPLE_DRUG_RESISTANCE_2"]
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
    Travel_History    ${element}

    # 接觸史
    IF    '${element}[ANIMAL_CONTACT_HISTORY]' != 'None'
        IF    ${element}[ANIMAL_CONTACT_HISTORY] == $True
            Click Element    //label[@for="ReportDisease_mainContact_Y"]
            Sleep    200ms
            Click Element    id=ReportDisease_mainContact_type
            Select From List By Label    id=ReportDisease_mainContact_type    ${element}[ANIMAL_TYPE]
        ELSE
            Click Element    //label[@for="ReportDisease_mainContact_N"]
        END
    END

    # HIV檢驗
    IF    '${element}[HIV_TEST]' != 'None'
        IF    ${element}[HIV_TEST] == $True
            Click Element    //*[@for="ReportDisease_010_S_HAS_HIV_TEST_1"]
        ELSE
            Click Element    //*[@for="ReportDisease_010_S_HAS_HIV_TEST_0"]
        END        
    END
        

    # HIV檢驗日期
    IF    '${element}[HIV_TEST_DATE]' != 'None'
        ${tmpday}    Get Taiwain Date String    ${element}[HIV_TEST_DATE]
        Input Text    //*[@id="ReportDisease_010_S_HIV_TEST_DATE"]    ${tmpday}        
    END
    


    # 過去結核病史
    IF    '${element}[GET_TB]' != 'None'
        IF    ${element}[GET_TB] == $True
            Click Element    //*[@for="ReportDisease_010_S_HAS_GET_TB_1"]
        ELSE
            Click Element    //*[@for="ReportDisease_010_S_HAS_GET_TB_0"]
        END        
    END
    

    # 結核病接觸史
    IF    '${element}[FAMILY_TB]' != 'None'
        IF    ${element}[FAMILY_TB] == $True
            Click Element    //*[@for="ReportDisease_010_S_IS_FAMILY_TB_1"]
        ELSE
            Click Element    //*[@for="ReportDisease_010_S_IS_FAMILY_TB_0"]
        END        
    END
        

    # TB開始用藥日
    IF    '${element}[TB_MEDICINE_USE_DATE]' != 'None'
        ${tmpday}    Get Taiwain Date String    ${element}[TB_MEDICINE_USE_DATE]
        Input Text    //*[@id="ReportDisease_010_S_TB_MEDICINE_USE_DATE"]    ${tmpday}        
    END

    # 歷史用藥情形
    IF    '${element}[TB_MEDICINE_USE_FLG]' != 'None'
        IF    ${element}[TB_MEDICINE_USE_FLG] == $True
            Click Element    //*[@for="ReportDisease_010_S_TB_MEDICINE_USE_FLG_1"]
        ELSE
            Click Element    //*[@for="ReportDisease_010_S_TB_MEDICINE_USE_FLG_0"]
        END
    END
        

    # 通報時體重
    IF    '${element}[WEIGHT]' != 'None'
        Input Text    id=ReportDisease_010_S_WEIGHT    ${element}[WEIGHT]        
    END
    

    # 症狀起始日
    IF    '${element}[TB_SYMPTOM_START_DATE]' != 'None'
        ${tmpday}    Get Taiwain Date String    ${element}[TB_SYMPTOM_START_DATE]
        Input Text    //*[@id="ReportDisease_010_S_TB_SYMPTOM_START_DATE"]    ${tmpday} 
    END
    
    #增修原因
    IF    '${element}[UPDATE_REASON]' != 'None'
        Input Text    //textarea[@id="casePatient_ModifyReason"]    ${element}[UPDATE_REASON]
    END

    # 新增通報
    IF    ${element}[FUNCTION] == 1
        Create Data
        ${report_id}    Get Text    xpath=/html/body/div[2]/div[2]/main/div[2]/div/div/div[1]/div[1]/span[1]/a
        # 透過等待畫面出現縣市, 以確保資料讀取完成, 再進行截圖
        Wait Until Page Contains    ${element}[COUNTY]
        # 截圖佐證
        Capture Page Screenshot    ${screenshot}\\010_report_MED_${element}[DISEASE]_${element}[Num].png
        Log To Console    ${report_id}

        Set Global Variable    ${item_result}    ${True}
        #讀取編號
        Write Excel    ${report_id}    ${element}[Num]    Smoke_WEB_MED_010_NEWREPORT_01.xlsx
        Set Global Variable    ${report_id}
    END

Update Report
    #增修資料(不修改地址)
    [Arguments]    ${element}    ${element_id}
    
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
    Capture Page Screenshot    ${screenshot}\\010_report_MED_Update_${element}[Num].png
    Set Global Variable    ${item_result}    ${True}



*** Tasks ***
Smoke_WEB_MED_010_NEWREPORT_01
    [Documentation]    煙霧測試:醫療院所結核病通報
    [Tags]    Smoke
    [Setup]    Set Global Variable    ${screenshot}    testresult\\${TEST_NAME}

    Open Available Browser    maximized=${True}    browser_selection=${BROWSER}
    Clean ID Excel    Data_ID.xlsx
    Read Report Excel    Smoke_WEB_MED_010_NEWREPORT_01.xlsx
    # 清除截圖路徑
    Remove Directory    ${screenshot}    resource=true

    FOR    ${element}    IN    @{test_users}
        Login    ${element}    ${NIDRS_WEB_URL}

        # 測試1 新增
        FOR    ${report}    IN    @{test_reports}
            Run Keyword And Continue On Failure    COMMON REPORT    ${report}
            
            Run Keyword If    ${item_result} == ${False}
            ...    Capture Page Screenshot    ${screenshot}\\010_report_MED_${report}[DISEASE]_${report}[Num]_Error.png

            Clear Error
            
        END
        
        # 測試2 增修
        Read ID Excel    Data_ID.xlsx
        Read Update Excel    Smoke_WEB_MED_010_NEWREPORT_01.xlsx
        FOR    ${update}    IN    @{test_update}
            FOR    ${id}    IN    @{test_id}
                IF    ${id}[Num] == ${update}[Num]
                    Run Keyword And Continue On Failure    Update Report    ${update}    ${id}
                    
                    Run Keyword If    ${item_result} == ${False}
                    ...    Capture Page Screenshot    ${screenshot}\\010_report_MED_UPDATE_${update}[Num]_Error.png

                    Clear Error
                
                END
                
            END
        END

        # 測試3 研判
        Run Keyword And Ignore Error    Logout
    END
    


    [Teardown]    Close All Browsers

