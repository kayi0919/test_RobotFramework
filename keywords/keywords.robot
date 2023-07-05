*** Settings ***
Documentation       Template keyword resource.
Library        DateTime
Library        RPA.Browser.Selenium

*** Keywords ***
Get Date String
    [Arguments]    ${daydiff}
    ${CUR_DATE}    Get Current Date
    IF    $daydiff != 0
        ${CUR_DATE}    Add Time To Date    ${CUR_DATE}    ${daydiff} days    #result_format=%Y-%m-%d
    END
    ${datestring}    Convert Date    ${CUR_DATE}    result_format=%Y-%m-%d
    [Return]    ${datestring}
    
Get DateTime String
    [Arguments]    ${hourdiff}
    ${CUR_DATE}    Get Current Date
    IF    $hourdiff != 0
        ${CUR_DATE}    Add Time To Date    ${CUR_DATE}    ${hourdiff} hours    #result_format=%Y-%m-%d
    END
    ${datestring}    Convert Date    ${CUR_DATE}    result_format=%Y-%m-%d %H:%M:%S
    [Return]    ${datestring}

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
    Click Element    id=txt_user_name
    #Press Keys    None    ${element}[User]
    Input Text    id=txt_user_name    ${element}[User]
    Sleep    100ms
    Click Element    id=txt_user_password
    #Press Keys    None    ${element}[Password]
    Input Text    id=txt_user_password    ${element}[Password]
    Click Element   xpath=/html/body/main/div[1]/div[6]/div/div/div[2]/button
    Wait Until Page Contains    通報單查詢管理

#非必填: 姓名羅馬拼音
Romanization
    [Arguments]    ${element}
    IF    '${element}[ROMANIZATION_NAME]' != 'None'    
        Input Text    id=casePatient_Spell    ${element}[ROMANIZATION_NAME]
    END

#非必填: 性別
Gender
    [Arguments]    ${element}
    IF    '${element}[GENDER]' != 'None'
        Click Element    //*[@id="casePatient_Gender_area"]
        IF    '${element}[GENDER]' == 1
            Click Element    //label[@for="casePatient_Gender_M"]
        ELSE 
            IF    '${element}[GENDER]' == 3
                Click Element    //label[@for="casePatient_Gender_X"]
            ELSE
                Click Element    //label[@for="casePatient_Gender_F"]
            END
        END
    END

#非必填: 國籍
Nationality
    [Arguments]    ${element}
    IF    '${element}[NATIONALITY]' != 'None'
        IF    ${element}[NATIONALITY] == $True    #非必填 預設非本國籍
            Click Element    //label[@for="casePatient_Nation_Local"]        
        ELSE
            Click Element    //label[@for="casePatient_Nation_Foreigner"]
            Sleep    1s
            Input Text    id=_easyui_textbox_input3    ${element}[COUNTRY]
            Sleep    2s

            #選項有OTH 其他時須填寫            
            IF    '${element}[COUNTRY]' == 'OTH 其他'
                Click Element    id=casePatient_other_Country
                Sleep    1s
                Input Text    id=casePatient_other_Country    ${element}[OTHER_COUNTRY]            
                Sleep    2s
            END

            Select From List By Label    id=casePatient_Foreigner_Type    ${element}[IDENTITY]
            Sleep    2s
            #選項有其他時須填寫
            IF    '${element}[IDENTITY]' == '其他'
                Click Element    id=casePatient_Foreigner_Description
                Input Text    id=casePatient_Foreigner_Description    ${element}[IDENTITY_DESCRIPTION]            
                Sleep    2s
            END
        END
    END

#非必填: 居住村里
Village
    [Arguments]    ${element}
    IF    '${element}[VILLAGE]' != 'None'
        Click Element    id=casePatient_Living_Village
        Wait Until Element Contains    id=casePatient_Living_Village    ${element}[VILLAGE]
        Select From List By Label    id=casePatient_Living_Village    ${element}[VILLAGE]
    END

#非必填: 街道地址
Address
    [Arguments]    ${element}
    IF    '${element}[ADDRESS]' != 'None'
        Input Text    id=casePatient_Living_Address    ${element}[ADDRESS]
    END

#非必填: 人口密集機構
Institutions
    [Arguments]    ${element}
    Click Element    //*[@id="casePatient_Form"]/div[4]/div[1]/div
    IF    '${element}[INSTITUTIONS]' != 'None'        
        IF    ${element}[INSTITUTIONS] == $True    
            Click Element    //label[@for="casePatient_DenseFacility_True"]        
        ELSE        
            Click Element    //label[@for="casePatient_DenseFacility_False"]U                    
        END
    END

#非必填: 機構類別
Ins_Catrgory
    [Arguments]    ${element}
    IF    '${element}[INSTITUTIONS_CATEGORY]' != 'None'
        Click Element    id=casePatient_FacilityType
        Wait Until Element Contains    id=casePatient_FacilityType    ${element}[INSTITUTIONS_CATEGORY]
        Select From List By Label    id=casePatient_FacilityType    ${element}[INSTITUTIONS_CATEGORY]
    END

#非必填: 婚姻狀況
Marriage
    [Arguments]    ${element}
    IF    '${element}[MARRIAGE]' != 'None'
        Click Element    id=casePatient_Marriage
        Wait Until Element Contains    id=casePatient_Marriage    ${element}[MARRIAGE]
        Select From List By Label    id=casePatient_Marriage    ${element}[MARRIAGE]
    END


#非必填: 病患動向 
CasePatient
    [Arguments]    ${element}
    IF    '${element}[CASEPATIENT]' != 'None'
        IF    '${element}[CASEPATIENT]' == '1'
            Click Element    //label[@for="casePatient_StatusWhenReport_A"]      
        END
        IF    '${element}[CASEPATIENT]' == '2'
            Click Element    //label[@for="casePatient_StatusWhenReport_B"]      
        END        
        IF    '${element}[CASEPATIENT]' == '3'
            Click Element    //label[@for="casePatient_StatusWhenReport_C"]
            ${tmpday}    Get Taiwain Date String    ${element}[FIRST_GENERAL_WARD]
            Input Text    //*[@id="casePatient_AdmissionDate"]    ${tmpday}            
        END
        IF    '${element}[CASEPATIENT]' == '4'
            Click Element    //label[@for="casePatient_StatusWhenReport_D"]
            ${tmpday}    Get Taiwain Date String    ${element}[FIRST_ICU]
            Input Text    //*[@id="casePatient_FirstICUWardDate"]    ${tmpday}            
        END
        IF    '${element}[CASEPATIENT]' == '5'
            Click Element    //label[@for="casePatient_StatusWhenReport_E"]
            ${tmpday}    Get Taiwain Date String    ${element}[FIRST_ISOLATION_WARD]
            Input Text    //*[@id="casePatient_FirstIsolateWardDate"]    ${tmpday}            
        END
        IF    '${element}[CASEPATIENT]' == '6'
            Click Element    //label[@for="casePatient_StatusWhenReport_F"]
            ${tmpday}    Get Taiwain Date String    ${element}[DISCHARGE_DATE]
            Input Text    //*[@id="casePatient_DischargedDate"]    ${tmpday}            
        END
        IF    '${element}[CASEPATIENT]' == '7'
            Click Element    //label[@for="casePatient_StatusWhenReport_G"]
            Click Element    id=casePatient_ReferHospName_SearchModal

            #醫院搜尋視窗            
            Wait Until Page Contains    關鍵字查詢
            IF    '${element}[SEARCH_TYPE]' != 'None'
                Search Type    ${element}[SEARCH_TYPE]    ${element}[KEYWORD_SEARCH]    ${element}[APARTMENT_CITY]    ${element}[APARTMENT_TYPE]    
            END
            IF    '${element}[TRANSFER_INSTITUTE_DATE]' != 'None'
                ${tmpday}    Get Taiwain Date String    ${element}[TRANSFER_INSTITUTE_DATE]
                Input Text    //*[@id="casePatient_ReferHospDate"]   ${tmpday}                
            END           
        END  
        IF    '${element}[CASEPATIENT]' == '8'
            Click Element    //label[@for="casePatient_StatusWhenReport_H"]      
        END    
        
    END


#醫院搜尋視窗 搜尋方式 1關鍵字  2 縣市+類別
Search Type
    [Arguments]    ${search_type}    ${keyword_search}    ${apartment_city}    ${apartment_type}
    IF    '${search_type}' == '1'
                Sleep    2s
                Click Element    //*[@id="hospSelectorData"]/div/div                 
                Input Text    id=hospSelector_SearchText    ${keyword_search}                
                Click Button    //*[@id="hospSelectorData"]/div[1]/div/button
                Sleep    1s
                #暫抓搜尋到的第一筆資料                
                Click Element    //*[@id="hospSelector_SearchResult"]/div/div[1]/a                
                
            END

            IF    '${search_type}' == '2'
                Sleep    2s
                Click Element    //*[@id="hospSelector_County"]
                Wait Until Element Contains    id=hospSelector_County    ${apartment_city}
                Select From List By Label    id=hospSelector_County    ${apartment_city}
                Sleep    1s
                Click Element    //*[@id="hospSelector_Type"]
                Wait Until Element Contains    id=hospSelector_Type    ${apartment_type}
                Select From List By Label    id=hospSelector_Type    ${apartment_type}
                Sleep    2s
                #暫抓搜尋到的第一筆資料
                Click Element    //*[@id="hospSelector_SearchResult"]/div/div[1]/a                
            END            
            Sleep    2s


# 必填: 個案是否死亡
Death
    [Arguments]    ${element}
    IF    '${element}[DEATH]' != 'None'
        Click Element    //*[@id="casePatient_isDead"]
        IF    ${element}[DEATH] == $True
            Click Element    //label[@for="casePatient_isDead_True"]
            ${tmpday}    Get Taiwain Date String    ${element}[DEATH_DAY]
            Input Text    //*[@id="casePatient_DateOfDead"]   ${tmpday}
            
            #目前只設定一個死亡原因
            IF    '${element}[DEATH_REASON]' != 'None'
                Input Text    id=casePatient_DeadReason_A    ${element}[DEATH_REASON]            
            END
        ELSE
            Click Element    //label[@for="casePatient_isDead_False"]
        END        
    END
    

# 必填: 旅遊史
Travel_History
    [Arguments]    ${element}
    IF    '${element}[HAS_TRAVEL_HISTORY]' != 'None'
        IF    ${element}[HAS_TRAVEL_HISTORY] == $True
        Click Element    //*[@id="ReportDisease_mainTrav"]/div[1]/label
        Sleep    2s
        
        IF    '${element}[MAIN_TRAVAL]' == '1'
            #國內
            Click Element    //*[@id="ReportDisease_mainTrav_area"]/div[1]/div/label
            Click Element    id=ReportDisease_inCountry_0_county
            Select From List By Label    id=ReportDisease_inCountry_0_county    ${element}[IN_COUNTRY_CITY]
            ${tmpday}    Get Taiwain Date String    ${element}[IN_COUNTRY_START]
            Input Text    //*[@id="ReportDisease_inCountry_0_start"]    ${tmpday}
            ${tmpday}    Get Taiwain Date String    ${element}[IN_COUNTRY_END]
            Input Text    //*[@id="ReportDisease_inCountry_0_end"]    ${tmpday}
        END
        IF    '${element}[MAIN_TRAVAL]' == '2'
            #國外旅遊
            Click Element    //*[@id="ReportDisease_mainTrav_area"]/div[3]/div/label                
            Sleep    2s
            Click Element    //*[@id="_easyui_textbox_input6"]                            
            Input Text    id=_easyui_textbox_input6    ${element}[OUT_COUNTRY]            
            Sleep    2s
            ${tmpday}    Get Taiwain Date String    ${element}[OUT_COUNTRY_START]
            Input Text    //*[@id="ReportDisease_outCountry_0_start"]    ${tmpday}
            ${tmpday}    Get Taiwain Date String    ${element}[OUT_COUNTRY_END]
            Input Text    //*[@id="ReportDisease_outCountry_0_end"]    ${tmpday}
        END
        IF    '${element}[MAIN_TRAVAL]' == '3'
            #國外居住
            Click Element    //*[@id="ReportDisease_mainTrav_area"]/div[5]/div/label
            Sleep    2s
            Click Element    //*[@id="_easyui_textbox_input6"]
            Input Text    id=_easyui_textbox_input6    ${element}[OUT_COUNTRY_LIVE]
            Sleep    2s
            ${tmpday}    Get Taiwain Date String    ${element}[DEPARTURE_DATE]
            Input Text    //*[@id="ReportDisease_outCountryLive_0_county_out"]    ${tmpday}
            ${tmpday}    Get Taiwain Date String    ${element}[ENTRY_DATE]
            Input Text    //*[@id="ReportDisease_outCountryLive_0_county_in"]    ${tmpday}
        END     
        
    ELSE
        Click Element    //*[@id="ReportDisease_mainTrav"]/div[2]/label
    END
        
    END
    

Logout
    Click Button    //*[@id="header"]/ul/li[4]/button
    Wait Until Page Contains    您確定要登出本系統？
    Sleep    200ms
    # xpath無效, 改full xpath
    Click Button    xpath=/html/body/div[5]/div/div/div[3]/div/button[1]

Clear Error
    Sleep    200ms
    # 如果有錯誤 關掉dialog
    ${checkdata}    Does Page Contain Element    //div[@id="alertDialog"]
    Run Keyword If    ${checkdata} == ${True}    
    ...    Click Element    //*[@id="alertDialog"]/div/div/div[3]/div/a
    
    # 滾回頂端
    Scroll Element Into View    //*[@id="child-item"]/li[1]/a
        