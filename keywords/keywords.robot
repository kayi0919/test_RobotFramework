*** Settings ***
Documentation       Template keyword resource.
Library        DateTime
Library        RPA.Browser.Selenium

*** Keywords ***
Get Taiwain Date String
    [Arguments]    ${daydiff}
    ${CUR_DATE}    Get Current Date
    IF    $daydiff != 0
        ${CUR_DATE}    Add Time To Date    ${CUR_DATE}    ${daydiff} days    #result_format=%Y-%m-%d
    END
    ${Year}    Convert Date    ${CUR_DATE}    result_format=%Y
    ${MonthDay}    Convert Date    ${CUR_DATE}    result_format=%m/%d
    ${intY}    Convert To Integer    ${Year}
    ${intY}    Evaluate    ${intY} - 1911
    ${tmpS}    Catenate    民國${intY}/${MonthDay}
    [Return]    ${tmpS}

Get Taiwain Current Date String
    ${CUR_DATE}    Get Current Date
    ${Year}    Convert Date    ${CUR_DATE}    result_format=%Y
    ${MonthDay}    Convert Date    ${CUR_DATE}    result_format=%m/%d
    ${intY}    Convert To Integer    ${Year}
    ${intY}    Evaluate    ${intY} - 1911
    ${tmpS}    Catenate    民國${intY}/${MonthDay}
    [Return]    ${tmpS}

Login
    [Arguments]    ${element}    ${gotourl}
    Log To Console    TEST ORG TYPE ${element}[ORG], USER ${element}[User]
    Go To    ${gotourl}
    Wait Until Element Is Visible    id=card-hover-3
    # 帳號密碼登入
    Click Element    id=card-hover-3
    Sleep    200ms
    #Click Element    id=txt_user_name
    #Press Keys    None    ${element}[User]
    Input Text    id=txt_user_name    ${element}[User]
    Sleep    100ms
    #Click Element    id=txt_user_password
    #Press Keys    None    ${element}[Password]
    Input Text    id=txt_user_password    ${element}[Password]
    Click Element   xpath=/html/body/main/div[1]/div[6]/div/div/div[2]/button
    Wait Until Page Contains    通報單查詢管理

Logout
    Click Button    //*[@id="header"]/ul/li[4]/button
    Wait Until Page Contains    您確定要登出本系統？
    Sleep    100ms
    # xpath無效, 改full xpath
    Click Button    xpath=/html/body/div[5]/div/div/div[3]/div/button[1]