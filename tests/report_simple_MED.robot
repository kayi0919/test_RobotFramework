*** Comments ***

*** Settings ***
Documentation    醫療院所通報測試-簡單病
Library          RPA.Browser.Selenium
Library          RPA.Excel.Files
Library          Collections
Library          RPA.Desktop
Library          RPA.Robocorp.WorkItems
Library          String
Library          OperatingSystem
Resource         keywords.robot

*** Variables ***
${NIDRS_WEB_URL}    https://localhost:44395/login
${test_users}
${test_reports}
${test_result}    ${False}

*** Keywords ***
Read Excel
    Open Workbook    testdata\\robot_CDC_NIDRS_report_simple.xlsx
    # 讀取Excel資料
    ${sheet1}=    Read Worksheet    name=login   header=True
    ${sheet2}=    Read Worksheet    name=report   header=True    start=3    #第一二行是說明, 第三行是標頭
    Log To Console   \r\n${sheet1}\r\n${sheet2}
    Close Workbook
    Set Global Variable    ${test_users}    ${sheet1}
    Set Global Variable    ${test_reports}    ${sheet2}

Login
    [Arguments]    ${element}
    Log To Console    TEST ORG TYPE ${element}[ORG], USER ${element}[User]
    Go To    ${NIDRS_WEB_URL}
    Wait Until Element Is Visible    xpath=/html/body/main/div[1]/div[5]/div/div
    Click Element    xpath=/html/body/main/div[1]/div[5]/div/div
    Sleep    200ms
    Log To Console    login
    Click Element When Visible    xpath=/html/body/main/div[1]/div[6]/div/div/div[2]/div/input[1]
    Input Text    id=txt_user_name    ${element}[User]
    Sleep    20ms
    Input Text    id=txt_user_password    ${element}[Password]
    Click Element   xpath=/html/body/main/div[1]/div[6]/div/div/div[2]/button
    Wait Until Page Contains    通報單查詢管理

Logout
    Click Button    //*[@id="header"]/ul/li[4]/button
    Wait Until Page Contains    您確定要登出本系統？
    Sleep    500ms
    # xpath無效, 改full xpath
    #Click Button    //*[@id="logoutModal"]/div/div/div[3]/div/button[1]
    Click Button    xpath=/html/body/div[5]/div/div/div[3]/div/button[1]

COMMON REPORT
    [Arguments]    ${element}
    
    Set Global Variable    ${test_result}    ${False}
    # 區域變數: 日期
    ${tmpday}    Get Taiwain Date String    -2

    Sleep    100ms
    Log To Console    點擊新增通報單
    Click Element    id=101
    Sleep    200ms
    Input Text    id=reporter_DiagDoctor    ${element}[DIAGNOSTICIAN]
    Input Text    id=casePatient_Idno    ${element}[IDNO]
    Input Text    id=casePatient_Name    ${element}[NAME]
    Log To Console    ${element}[BIRTHDAY]
    Input Text    id=casePatient_Birthdate    ${element}[BIRTHDAY]
    #手機/聯絡電話欄位因為有重複定義的element id, 改以xpath處理
    #Input Text    id=casePatient_MobilePhone_0    ${element}[CELLPHONE]
    Input Text    //input[@id="casePatient_MobilePhone_0"]    ${element}[CELLPHONE]
    Input Text    //input[@id="casePatient_ContactPhone_0"]    ${element}[CONTACTPHONE]
    
    Wait Until Element Contains    id=casePatient_Living_County    ${element}[COUNTY]
    Select From List By Label    id=casePatient_Living_County    ${element}[COUNTY]
    # 在第二張通報的時候會出現list無內容的異常
    # 這邊click是為了觸發list重新更新
    Click Element    id=casePatient_Living_Town
    Wait Until Element Contains    id=casePatient_Living_Town    ${element}[TOWN]
    Select From List By Label    id=casePatient_Living_Town    ${element}[TOWN]
    
    # 是否死亡
    # 要先focus在此區域,選是否才沒有出現異常
    Click Element    //*[@id="casePatient_isDead"]
    IF    ${element}[DEATH] == $True
        Click Element    //label[@for="casePatient_isDead_True"]
        ${tmpday}    Get Taiwain Date String    ${element}[DEATH_DAY]
        Input Text    //*[@id="casePatient_DateOfDead"]   ${tmpday}
    ELSE
        Click Element    //label[@for="casePatient_isDead_False"]
    END

    # 選擇疾病
    # 畫面dialog跳動頻繁, 中間sleep以確保畫面切換
    Click Button    //*[@id="choose_diseases"]
    Wait Until Page Contains    依法定傳染病
    Sleep    100ms
    Click Element    //*[@id="nav-category-${element}[DISEASE_CATEGORY]"]
    Sleep    100ms
    Click Element    //label[@for="category_disease_${element}[DISEASE]"]
    Sleep    100ms
    # 確認
    Click Button    //*[@id="modalDiseaseSelector"]/div/div/div[3]/button[1]
    Sleep    300ms
    # 下一步
    Click Button    id=selectedDiseaseNextStep
    Sleep    200ms

    # 發病日/無發病日區塊
    IF    ${element}[NO_SICKDAY] == $True
        Click Element    //*[@id="ReportRelateDate"]/div[2]/div[2]/div/label
    ELSE
        ${tmpday}    Get Taiwain Date String    ${element}[SICK_DAY]
        Input Text    //*[@id="ReportDisease_onsetDate"]    ${tmpday}
    END
    
    # 診斷日期
    ${tmpday}    Get Taiwain Date String    ${element}[DIAGNOSE_DAY]
    Input Text    //*[@id="ReportDisease_diagDate"]    ${tmpday}
    # 報告日期
    ${tmpday}    Get Taiwain Date String    ${element}[REPORTED_DAY]
    Input Text    //*[@id="ReportDisease_reportDate"]    ${tmpday}

    # 有無症狀
    Click Element    //*[@id="diseaseReportData"]/div[3]/div/div
    Sleep    20ms
    IF    ${element}[HAS_SYMPTOM] == $True
        Click Element    //*[@id="ReportDisease_symp"]/div[1]/label
        Sleep    200ms
        # 注意, 以@類型接收
        @{symptoms}    Split String    ${element}[SYMPTOMS]    ,
        FOR    ${smp}    IN    @{symptoms}
            Log To Console    ${smp}
            Click Element    //label[contains(text(), '${smp}')]
        END
    ELSE
        Click Element    //*[@id="ReportDisease_symp"]/div[2]/label
    END
    
    # 職業
    Select From List By Label    id=ReportDisease_mainProfSel    ${element}[OCCUPATION]

    # 旅遊史
    Click Element    //*[@id="ReportDisease_mainTrav"]/div[2]/label



    # 確定通報
    Click Button    //*[@id="buttonReportSend"]
    Wait Until Page Contains    確認是否送出通報單
    Sleep    200ms
    Click Button    //*[@id="_dialog"]/div/div/div[3]/div[1]/button
    
    # 通報完成頁
    Wait Until Page Contains    法定傳染病個案通報完成
    ${report_id}    Get Text    xpath=/html/body/div[2]/div[2]/main/div[2]/div/div/div[1]/div[1]/span[1]/a
    # 透過等待畫面出現縣市, 以確保資料讀取完成, 再進行截圖
    Wait Until Page Contains    ${element}[COUNTY]
    # 截圖佐證
    Capture Page Screenshot    testresult\\simple_report_MED_${element}[DISEASE].png

    Log To Console    ${report_id}
    Set Global Variable    ${test_result}    ${True}

*** Tasks ***
Smoke Test Report Simple
    [Tags]    Smoke
    Open Available Browser    maximized=${True}    browser_selection=edge
    Read Excel
    #${first_element}=    Get From List    ${test_users}    0
    # 清除截圖路徑
    Remove Directory    testresult    resource=true
    FOR    ${element}    IN    @{test_users}
        Login    ${element}
        FOR    ${report}    IN    @{test_reports}
            Run Keyword And Continue On Failure    COMMON REPORT    ${report}
            
            # 異常時截圖
            Run Keyword If    ${test_result} == ${False}
            ...    Capture Page Screenshot    testresult\\simple_report_MED_${report}[DISEASE]_Error.png
        END
        Logout
    END

    