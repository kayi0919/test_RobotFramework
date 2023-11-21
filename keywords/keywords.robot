*** Settings ***
Documentation       Template keyword resource.
Library        DateTime
Library        RPA.Browser.Selenium
Library        RPA.Excel.Files


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


Read Report Excel
    [Arguments]    ${file}
    Open Workbook    testdata\\${file}
    
    ${sheet1}    Read Worksheet    name=login    header=True
    ${sheet2}=    Read Worksheet    name=report   header=True    start=3    #第一二行是說明, 第三行是標頭
    Log To Console    \r\n${sheet1}\r\n${sheet2}
    Close Workbook
    Set Global Variable    ${test_users}    ${sheet1}
    Set Global Variable    ${test_reports}    ${sheet2}

Clean Excel
    [Arguments]    ${file}
    Open Workbook    testdata\\${file}
    Delete Rows    start=4    end=100
    Save Workbook
    Close Workbook


Read ID Excel
    [Arguments]    ${file}
    Open Workbook    testdata\\${file}
    ${sheet3}=    Read Worksheet    name=ID   header=True    start=3
    Log To Console    \r\n${sheet3}
    Close Workbook
    Set Global Variable    ${test_id}    ${sheet3}
    
Read Update Excel
    [Arguments]    ${file}
    Open Workbook    testdata\\${file}
    ${sheet4}=    Read Worksheet    name=update   header=True    start=3
    Log To Console    \r\n${sheet4}
    Close Workbook
    Set Global Variable    ${test_update}    ${sheet4}
    

Write ID Excel
    [Arguments]    ${data_id}    ${data_num}    ${file}
    Open Workbook    testdata\\${file}
    ${table}    Create Dictionary    報表編號=${data_id}    序號=${data_num}
    Append Rows To Worksheet    ${table}    start=4
    Save Workbook
    Close Workbook

Write Result Excel
    [Arguments]    ${data_function}    ${data_num}    ${data_expected}    ${data_result}    ${file}
    Open Workbook    testdata\\${file}
    ${table}    Create Dictionary    功能=${data_function}    序號=${data_num}    預期=${data_expected}    結果=${data_result}
    Append Rows To Worksheet    ${table}    start=4
    Save Workbook
    Close Workbook

Transfer Taiwan Date
    [Arguments]    ${element_data}    ${locator}
    ${tmpday}    Get Taiwain Date String    ${element_data}
    Input Text    ${locator}    ${tmpday}
    Wait Until Page Contains Element    //div[@id="ui-datepicker-div"]/div[2]/button[2]
    Click Button    //div[@id="ui-datepicker-div"]/div[2]/button[2]

Diagnostician
    [Arguments]    ${element}
    IF    '${element}[IDNO]' != 'None'
        Input Text    id=casePatient_Idno    ${element}[IDNO]       
    END
IDNO
    [Arguments]    ${element}
    IF    '${element}[DIAGNOSTICIAN]' != 'None'
        Input Text    id=reporter_DiagDoctor    ${element}[DIAGNOSTICIAN]        
    END

Name
    [Arguments]    ${element}
    IF    '${element}[NAME]' != 'None'
        Input Text    id=casePatient_Name    ${element}[NAME]        
    END

Romanization
    [Arguments]    ${element}
    IF    '${element}[ROMANIZATION_NAME]' != 'None'    
        Input Text    id=casePatient_Spell    ${element}[ROMANIZATION_NAME]
    END

Gender
    [Arguments]    ${element}
    IF    '${element}[GENDER]' != 'None'
        Scroll Element Into View    //*[@id="casePatient_Gender_area"]
        #Click Element    //*[@id="casePatient_Gender_area"]
        IF    '${element}[GENDER]' == '1'
            Click Element    //label[@for="casePatient_Gender_M"]
        ELSE 
            IF    '${element}[GENDER]' == '3'
                Click Element    //label[@for="casePatient_Gender_X"]
            ELSE
                Click Element    //label[@for="casePatient_Gender_F"]
            END
        END
    END

Birthday
    [Arguments]    ${element}
    IF    '${element}[BIRTHDAY]' != 'None'
        Log To Console    ${element}[BIRTHDAY]
        Input Text    id=casePatient_Birthdate    ${element}[BIRTHDAY]
        Wait Until Page Contains Element    //div[@id="ui-datepicker-div"]/div[2]/button[2]
        Click Button    //div[@id="ui-datepicker-div"]/div[2]/button[2]
    END


Nationality
    [Arguments]    ${element}
    IF    '${element}[NATIONALITY]' != 'None'
        IF    ${element}[NATIONALITY] == $True    #預設非本國籍
            Click Element    //label[@for="casePatient_Nation_Local"]        
        ELSE
            Click Element    //label[@for="casePatient_Nation_Foreigner"]
            Click Element    id=_easyui_textbox_input3
            Sleep    200ms
            Input Text    id=_easyui_textbox_input3    ${element}[COUNTRY]
            Sleep    500ms
            #選項有OTH 其他時須填寫            
            IF    '${element}[COUNTRY]' == 'OTH 其他'
                Click Element    id=casePatient_other_Country
                Sleep    200ms
                Input Text    id=casePatient_other_Country    ${element}[OTHER_COUNTRY]
            END
            Identity    ${element}
        END
    END

Identity
    [Arguments]    ${element}
    IF    '${element}[IDENTITY]' != 'None'
        Select From List By Label    id=casePatient_Foreigner_Type    ${element}[IDENTITY] 
        IF    '${element}[IDENTITY]' == '其他'
            Click Element    id=casePatient_Foreigner_Description
            Sleep    200ms
            Input Text    id=casePatient_Foreigner_Description    ${element}[IDENTITY_DESCRIPTION]
        END
    END

CellPhone
    [Arguments]    ${element}
    IF    '${element}[CELLPHONE]' != 'None'
        Input Text    //input[@id="casePatient_MobilePhone_0"]    ${element}[CELLPHONE]
    END

ContactPhone
    [Arguments]    ${element}
    IF    '${element}[CONTACTPHONE]' != 'None'
        Input Text    //input[@id="casePatient_ContactPhone_0"]    ${element}[CONTACTPHONE]
    END

County
    [Arguments]    ${element}
    IF    '${element}[COUNTY]' != 'None'
        Click Element    id=casePatient_Living_County
        Wait Until Element Contains    id=casePatient_Living_County    ${element}[COUNTY]
        Select From List By Label    id=casePatient_Living_County    ${element}[COUNTY]
    END

Town
    [Arguments]    ${element}
    IF    '${element}[TOWN]' != 'None'
        Click Element    id=casePatient_Living_Town
        Wait Until Element Contains    id=casePatient_Living_Town    ${element}[TOWN]
        Select From List By Label    id=casePatient_Living_Town    ${element}[TOWN]
    END

Village
    [Arguments]    ${element}
    IF    '${element}[VILLAGE]' != 'None'
        Click Element    id=casePatient_Living_Village
        Wait Until Element Contains    id=casePatient_Living_Village    ${element}[VILLAGE]
        Select From List By Label    id=casePatient_Living_Village    ${element}[VILLAGE]
    END

Address
    [Arguments]    ${element}
    IF    '${element}[ADDRESS]' != 'None'
        Input Text    id=casePatient_Living_Address    ${element}[ADDRESS]
    END

Institutions
    [Arguments]    ${element}
    Click Element    //*[@id="casePatient_Form"]/div[4]/div[1]/div
    IF    '${element}[INSTITUTIONS]' != 'None'        
        IF    ${element}[INSTITUTIONS] == $True    
            Click Element    //label[@for="casePatient_DenseFacility_True"]        
        ELSE        
            Click Element    //label[@for="casePatient_DenseFacility_False"]
        END
    END

Ins_Catrgory
    [Arguments]    ${element}
    IF    '${element}[INSTITUTIONS_CATEGORY]' != 'None'
        Click Element    id=casePatient_FacilityType
        Wait Until Element Contains    id=casePatient_FacilityType    ${element}[INSTITUTIONS_CATEGORY]
        Select From List By Label    id=casePatient_FacilityType    ${element}[INSTITUTIONS_CATEGORY]
    END

Marriage
    [Arguments]    ${element}
    IF    '${element}[MARRIAGE]' != 'None'
        Click Element    id=casePatient_Marriage
        Wait Until Element Contains    id=casePatient_Marriage    ${element}[MARRIAGE]
        Select From List By Label    id=casePatient_Marriage    ${element}[MARRIAGE]
    END


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
            Transfer Taiwan Date    ${element}[FIRST_GENERAL_WARD]    //*[@id="casePatient_AdmissionDate"]
        END
        IF    '${element}[CASEPATIENT]' == '4'
            Click Element    //label[@for="casePatient_StatusWhenReport_D"]
            Transfer Taiwan Date    ${element}[FIRST_ICU]    //*[@id="casePatient_FirstICUWardDate"]           
        END
        IF    '${element}[CASEPATIENT]' == '5'
            Click Element    //label[@for="casePatient_StatusWhenReport_E"]
            Transfer Taiwan Date    ${element}[FIRST_ISOLATION_WARD]    //*[@id="casePatient_FirstIsolateWardDate"]           
        END
        IF    '${element}[CASEPATIENT]' == '6'
            Click Element    //label[@for="casePatient_StatusWhenReport_F"]
            Transfer Taiwan Date    ${element}[DISCHARGE_DATE]    //*[@id="casePatient_DischargedDate"]          
        END
        IF    '${element}[CASEPATIENT]' == '7'
            Click Element    //label[@for="casePatient_StatusWhenReport_G"]
            Click Element    id=casePatient_ReferHospName_SearchModal

            #醫院搜尋視窗            
            IF    '${element}[SEARCH_TYPE]' != 'None'
                Search Type    ${element}[SEARCH_TYPE]    ${element}[KEYWORD_SEARCH]    ${element}[APARTMENT_CITY]    ${element}[APARTMENT_TYPE]    
            END
            IF    '${element}[TRANSFER_INSTITUTE_DATE]' != 'None'
                Wait Until Page Contains Element    //*[@id="casePatient_ReferHospDate"]
                Click Element    //*[@id="casePatient_ReferHospDate"]
                Transfer Taiwan Date    ${element}[TRANSFER_INSTITUTE_DATE]    //*[@id="casePatient_ReferHospDate"]               
            END           
        END  
        IF    '${element}[CASEPATIENT]' == '8'
            Click Element    //label[@for="casePatient_StatusWhenReport_H"]      
        END    
        
    END


#醫院搜尋視窗 搜尋方式 1關鍵字  2 縣市+類別
Search Type
    [Arguments]    ${search_type}    ${keyword_search}    ${apartment_city}    ${apartment_type}
    Wait Until Page Contains    關鍵字查詢
    IF    '${search_type}' == '1'
        Sleep    200ms
        Click Element    //*[@id="hospSelectorData"]/div/div                 
        Input Text    id=hospSelector_SearchText    ${keyword_search}                
        Click Button    //*[@id="hospSelectorData"]/div[1]/div/button
        Wait Until Page Contains Element    //div[@id="hospSelector_SearchResult"]/div/div[1]/a
        #暫抓搜尋到的第一筆資料            
        Click Element    //div[@id="hospSelector_SearchResult"]/div/div[1]/a            
    END

    IF    '${search_type}' == '2'
        Sleep    200ms
        Click Element    //*[@id="hospSelector_County"]
        Wait Until Element Contains    id=hospSelector_County    ${apartment_city}
        Select From List By Label    id=hospSelector_County    ${apartment_city}
        Sleep    200ms
        Click Element    //*[@id="hospSelector_Type"]
        Wait Until Element Contains    id=hospSelector_Type    ${apartment_type}
        Select From List By Label    id=hospSelector_Type    ${apartment_type}
        Wait Until Page Contains Element     //div[@id="hospSelector_SearchResult"]/div/div[1]/a
        #暫抓搜尋到的第一筆資料   
        Click Element    //div[@id="hospSelector_SearchResult"]/div/div[1]/a                
    END

Death
    [Arguments]    ${element}
    IF    '${element}[DEATH]' != 'None'
        Scroll Element Into View    //*[@id="casePatient_isDead"]
        #Click Element    //*[@id="casePatient_isDead"]
        Wait Until Page Contains    個案是否死亡
        IF    ${element}[DEATH] == $True
            Click Element    //label[@for="casePatient_isDead_True"]
            Transfer Taiwan Date    ${element}[DEATH_DAY]    //*[@id="casePatient_DateOfDead"]
            #只設定一個死亡原因
            IF    '${element}[DEATH_REASON]' != 'None'
                Input Text    id=casePatient_DeadReason_A    ${element}[DEATH_REASON]            
            END
        ELSE
            Click Element    //label[@for="casePatient_isDead_False"]
        END        
    END

Disease Category
    [Arguments]    ${element}
    IF    '${element}[DISEASE_CATEGORY]' != 'None'
        Click Button    //*[@id="choose_diseases"]
        Wait Until Page Contains    依法定傳染病
        Sleep    1s
        Click Element    //*[@id="nav-category-${element}[DISEASE_CATEGORY]"]
        Wait Until Page Contains    ${element}[DISEASE_NAME]
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
Sick Date
    [Arguments]    ${element}
    IF    '${element}[NO_SICKDAY]' != 'None'
        IF    ${element}[NO_SICKDAY] == $True
            Click Element    //*[@id="ReportRelateDate"]/div[2]/div[2]/div/label
        ELSE
            Transfer Taiwan Date    ${element}[SICK_DAY]    //*[@id="ReportDisease_onsetDate"]   
        END        
    END

# 診斷日期
Diagnose Day
    [Arguments]    ${element}
    IF    '${element}[DIAGNOSE_DAY]' != 'None'
        Transfer Taiwan Date    ${element}[DIAGNOSE_DAY]    //*[@id="ReportDisease_diagDate"]           
    END

Report Day
    [Arguments]    ${element}
    IF    '${element}[REPORTED_DAY]' != 'None'
        Transfer Taiwan Date    ${element}[REPORTED_DAY]    //*[@id="ReportDisease_reportDate"]        
    END

Travel_History
    [Arguments]    ${element}
    IF    '${element}[HAS_TRAVEL_HISTORY]' != 'None'
        IF    ${element}[HAS_TRAVEL_HISTORY] == $True
        Click Element    //*[@id="ReportDisease_mainTrav"]/div[1]/label
        Wait Until Page Contains    國內旅遊史
            IF    '${element}[MAIN_TRAVAL]' == '1'
                #國內
                Click Element    //*[@id="ReportDisease_mainTrav_area"]/div[1]/div/label
                Wait Until Page Contains Element    id=ReportDisease_inCountry_0_county
                Click Element    id=ReportDisease_inCountry_0_county
                Select From List By Label    id=ReportDisease_inCountry_0_county    ${element}[IN_COUNTRY_CITY]
                Transfer Taiwan Date    ${element}[IN_COUNTRY_START]    //*[@id="ReportDisease_inCountry_0_start"] 
                Transfer Taiwan Date    ${element}[IN_COUNTRY_END]    //*[@id="ReportDisease_inCountry_0_end"]
            END
            IF    '${element}[MAIN_TRAVAL]' == '2'
                #國外旅遊
                Click Element    //*[@id="ReportDisease_mainTrav_area"]/div[3]/div/label                
                Wait Until Page Contains Element    //*[@id="_easyui_textbox_input6"]
                Click Element    //*[@id="_easyui_textbox_input6"]
                Sleep    200ms
                Input Text    id=_easyui_textbox_input6    ${element}[OUT_COUNTRY]
                Sleep    500ms            
                Transfer Taiwan Date    ${element}[OUT_COUNTRY_START]    //*[@id="ReportDisease_outCountry_0_start"] 
                Transfer Taiwan Date    ${element}[OUT_COUNTRY_END]    //*[@id="ReportDisease_outCountry_0_end"]
            END
            IF    '${element}[MAIN_TRAVAL]' == '3'
                #國外居住
                Click Element    //*[@id="ReportDisease_mainTrav_area"]/div[5]/div/label
                Wait Until Page Contains Element    //*[@id="_easyui_textbox_input6"]
                Click Element    //*[@id="_easyui_textbox_input6"]
                Sleep    200ms
                Input Text    id=_easyui_textbox_input6    ${element}[OUT_COUNTRY_LIVE]
                Sleep    500ms
                Transfer Taiwan Date    ${element}[DEPARTURE_DATE]    //*[@id="ReportDisease_outCountryLive_0_county_out"]
                Transfer Taiwan Date    ${element}[ENTRY_DATE]    //*[@id="ReportDisease_outCountryLive_0_county_in"]  
            END        
        ELSE
            Click Element    //*[@id="ReportDisease_mainTrav"]/div[2]/label
        END
    END

Create Data
    Click Button    //*[@id="buttonReportSend"]
    Wait Until Page Contains    確認是否送出通報單
    Sleep    1s
    Click Button    //*[@id="_dialog"]/div/div/div[3]/div[1]/button
    Sleep    1s

    # 通報完成頁
    Wait Until Page Contains    法定傳染病個案通報完成
    

Update Data
    Click Element    id=editFunctionButtons
    #與commom report送出按鈕撞名 使用xpath
    Click Button    //div[@id="editFunctionButtons"]/button[1]

    Wait Until Page Contains    確認是否送出通報單
    Sleep    1s
    Click Button    //*[@id="_dialog"]/div/div/div[3]/div[1]/button
    Sleep    1s

    Wait Until Page Contains    確定增修以下內容
    Sleep    1s
    Click Button    //div[@id="editFieldConfirmModal"]/div/div/div/button[1]
    Sleep    1s

    Wait Until Page Contains    關閉
    Sleep    1s
    Click Element    //div[@id="alertDialog"]/div/div/div[3]/div/a


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
    ...    Click Element    //div[@id="alertDialog"]/div/div/div[3]/div/a
    
    # 滾回頂端
    Scroll Element Into View    //*[@id="child-item"]/li[1]/a
        