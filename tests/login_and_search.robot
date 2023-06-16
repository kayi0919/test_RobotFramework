*** Settings ***
Documentation    登入 & 快速查詢測試
Library          RPA.Browser.Selenium
Library          RPA.Excel.Files
Resource         keywords.robot

*** Variables ***
${NIDRS_WEB_URL}    https://localhost:44395/login
${test_users}
${test_result}    ${False}

*** Keywords ***
Read Excel
    Open Workbook    testdata\\robot_CDC_NIDRS_login.xlsx
    ${sheet1}    Read Worksheet    name=login   header=True
    Log To Console   \r\n${sheet1}
    Close Workbook
    Set Global Variable    ${test_users}    ${sheet1}

Report Search
    [Arguments]    ${element}
    # 等待使用者單位顯示
    Wait Until Element Contains    id=navbarDropdownUser2    ${element}[Expected] 
    Sleep    200ms
    # 點擊通報單查詢管理
    Click Element    id=104
    Sleep    500ms
    # 點擊查詢
    Click Button    id=btn_query
    Sleep    1000ms
    # 驗證資料?
    # 處理查無資料
    ${element_exists}    Run Keyword And Return Status    Page Should Contain Element    xpath=/html/body/div[8]/div/div/div[3]
    Log To Console    是否無資料?${element_exists}
    Run Keyword If    ${element_exists}    Click Element    xpath=/html/body/div[8]/div/div/div[3]/div/a

*** Tasks ***
Smoke Test Login And Query
    [Tags]    Smoke
    Open Available Browser    maximized=${True}    browser_selection=edge
    Read Excel

    FOR    ${element}    IN    @{test_users}
        Login    ${element}    ${NIDRS_WEB_URL}
        Report Search    ${element}
        Logout
    END
