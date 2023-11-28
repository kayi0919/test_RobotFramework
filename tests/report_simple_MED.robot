*** Settings ***
Documentation    醫療院所通報測試-簡單病
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
${item_result}
${item_num}

*** Keywords ***
COMMON REPORT
    [Arguments]    ${element}
    # 區域變數: 日期
    ${tmpday}    Get Taiwain Date String    -2
    
    Set Global Variable    ${item_num}    ${element}[Num]
    Set Global Variable    ${item_result}    ${False}

    Log To Console    點擊新增通報單
    Click Element    id=101
    # Wait Until Page Contains Element    id=casePatient_Idno
    Wait Until Page Does Not Contain Element    id=formData_loading
    Wait Until Page Contains Element    id=Menu2
    # 診斷醫師
    Diagnostician    ${element}
    # 身分證統一編號
    IDNO    ${element}
    # 個案姓名
    Name    ${element}
    #生日
    Birthday    ${element}

    #手機/聯絡電話欄位因為有重複定義的element id, 改以xpath處理
    #Input Text    id=casePatient_MobilePhone_0    ${element}[CELLPHONE]
    CellPhone    ${element}
    ContactPhone    ${element}

    County    ${element}
    # 在第二張通報的時候會出現list無內容的異常
    # 這邊click是為了觸發list重新更新
    Town    ${element}

    # 是否死亡
    # 要先focus在此區域,選是否才沒有出現異常
    Click Element    //*[@id="casePatient_isDead"]
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

    # 旅遊史
    Travel_History    ${element}

    # 確定通報
    Create Data
    ${report_id}    Get Text    xpath=/html/body/div[2]/div[2]/main/div[2]/div/div/div[1]/div[1]/span[1]/a
    # 透過等待畫面出現縣市, 以確保資料讀取完成, 再進行截圖
    Wait Until Page Contains    ${element}[COUNTY]
    # 截圖佐證
    Capture Page Screenshot    ${screenshot}\\simple_report_MED_${element}[DISEASE].png

    Log To Console    ${report_id}

    Set Global Variable    ${item_result}    ${True}

*** Tasks ***
Smoke Test Report Simple
    [Documentation]    煙霧測試:醫療院所簡易通報
    [Tags]    Smoke
    [Setup]    Set Global Variable    ${screenshot}    testresult\\${TEST_NAME}

    Open Available Browser    maximized=${True}    browser_selection=${BROWSER}    
    Read Report Excel    robot_CDC_NIDRS_report_simple.xlsx
    # 路徑不見處理 新增路徑
    Create Directory    ${screenshot}    resource=false
    # 清除截圖路徑
    Remove Directory    ${screenshot}    resource=true
    FOR    ${element}    IN    @{test_users}
        Login    ${element}    ${NIDRS_WEB_URL}

        FOR    ${report}    IN    @{test_reports}
            TRY
                Run Keyword And Continue On Failure    COMMON REPORT    ${report}
                Run Keyword If    ${item_result} == ${False}
                ...    Capture Page Screenshot    ${screenshot}\\simple_report_MED_${report}[DISEASE]_Error.png

                # 預期False 結果Pass
                # 若這裡錯誤會再執行except一次
                IF    ${item_result} != ${report}[EXPECTED]
                    Run Keyword And Continue On Failure    Fail    序號:${report}[Num] 疾病:${report}[DISEASE_NAME]預期錯誤
                END
            EXCEPT
                # 預期Pass 結果False
                IF    ${item_result} != ${report}[EXPECTED]
                    Run Keyword And Continue On Failure    Fail    序號:${report}[Num] 疾病:${report}[DISEASE_NAME]預期錯誤
                END                
            END
            Clear Error
        END
        Run Keyword And Ignore Error    Logout
    END

    [Teardown]    Close All Browsers

    