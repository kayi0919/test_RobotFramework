*** Settings ***
Documentation    登入 & 快速查詢測試
Library          RPA.Browser.Selenium
Library          RPA.Excel.Files
Library          RPA.FileSystem
Library    webdriver.py
# Resource         ../keywords/keywords.robot
# Resource         ../keywords/Variables.robot
Resource   ..\\keywords\\keywords.robot
Resource   ..\\keywords\\Variables.robot

*** Variables ***
${screenshot}
${test_users}
${test_result}    ${False}

*** Keywords ***
Read Excel
    # Open Workbook    ../testdata/robot_CDC_NIDRS_login.xlsxk
    Open Workbook    testdata\\robot_CDC_NIDRS_login.xlsx
    ${sheet1}    Read Worksheet    name=login   header=True
    Log To Console   \r\n${sheet1}
    Close Workbook
    Set Global Variable    ${test_users}    ${sheet1}

Report Search
    [Arguments]    ${element}
    
    # 等待使用者單位顯示
    Run Keyword And Ignore Error    Wait Loading Status
    Run Keyword And Ignore Error    Wait Security Statement
    Wait Until Page Contains Element    id=104
    
    # 點擊通報單查詢管理
    Click Element    id=104
    Sleep    1s
    
    Wait Until Page Contains Element    id=cdcMainContent
    Run Keyword And Ignore Error    Wait Loading Status
    
    # 點擊查詢
    Click Button    id=btn_query
    Sleep    500ms
    Wait Until Page Contains Element    id=cdcMainHeader
    Sleep    300ms
    Capture Page Screenshot    ${screenshot}/login_and_search_${element}[Num].png
    # 驗證資料?
    # 處理查無資料
    Sleep    1s
    ${element_exists}    Run Keyword And Return Status    Page Should Contain Element    xpath=/html/body/div[8]/div/div/div[3]
    Log To Console    是否無資料?${element_exists}
    Run Keyword If    ${element_exists}    Sleep    1s
    Run Keyword If    ${element_exists}    Click Element    xpath=/html/body/div[8]/div/div/div[3]/div/a
    Wait Until Element Contains    id=navbarDropdownUser2    ${element}[Expected]


*** Tasks ***
Smoke Test Login And Query
    [Documentation]    煙霧測試:登入與通報單查詢
    [Tags]    Smoke
    # [Setup]    Set Global Variable    ${screenshot}    testresult\\${TEST_NAME}
    [Setup]    Set Global Variable    ${screenshot}    ${TEST_NAME}
    Open Available Browser    maximized=${True}    browser_selection=${BROWSER}    options=add_argument("--ignore-certificate-errors")
    Read Excel
    # 路徑不見處理 新增路徑
    Create Directory    ${screenshot}    resource=false
    # 清除截圖路徑
    Remove Directory    ${screenshot}    resource=true

    FOR    ${element}    IN    @{test_users}
        Login    ${element}    ${NIDRS_WEB_URL}
        TRY
            Report Search    ${element}
        EXCEPT
            Run Keyword And Continue On Failure    Fail    ${element}預期錯誤 
        END
        Logout
    END

    [Teardown]    Close All Browsers
    
