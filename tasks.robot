*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images.

Library             RPA.Browser.Selenium    auto_close=${FALSE}
Library             RPA.HTTP
Library             RPA.Tables
Library             RPA.PDF
Library             RPA.Archive


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    ${orders} =    Get orders
    FOR    ${order}    IN    @{orders}
        Log    ${order}
        Close the annoying modal
        Fill the form    ${order}
        Preview robot
        ${screenshot} =    Take a screenshot of the robot    ${order}[Order number]
        Wait Until Keyword Succeeds    5x    0.5 sec    Submit order
        ${pdf} =    Store the receipt as a PDF file    ${order}[Order number]
        Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}
        Order another robot
    END
    Create a ZIP file


*** Keywords ***
Open the robot order website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order

Get orders
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True
    ${orders} =    Read table from CSV    orders.csv
    RETURN    ${orders}

Close the annoying modal
    Click Button    css: .btn-dark

Fill the form
    [Arguments]    ${order}
    Select From List By Value    head    ${order}[Head]
    Select Radio Button    body    ${order}[Body]
    Input Text    css: .form-control    ${order}[Legs]
    Input Text    address    ${order}[Address]

Preview robot
    Click Button    id: preview
    Wait Until Element Is Visible    id:robot-preview-image

Submit order
    Click Button    id:order
    Wait Until Element Is Visible    id:receipt

Store the receipt as a PDF file
    [Arguments]    ${order_number}
    Wait Until Element Is Visible    id:receipt
    ${receipt_html} =    Get Element Attribute    id:receipt    outerHTML
    Set Local Variable    ${file_path}    ${OUTPUT_DIR}${/}${order_number}.pdf
    Html To Pdf    ${receipt_html}    ${file_path}
    RETURN    ${file_path}

Take a screenshot of the robot
    [Arguments]    ${order_number}
    Set Local Variable    ${file_path}    ${OUTPUT_DIR}${/}${order_number}.png
    Screenshot    id:robot-preview-image    ${file_path}
    RETURN    ${file_path}

Embed the robot screenshot to the receipt PDF file
    [Arguments]    ${screenshot}    ${pdf}
    Open Pdf    ${pdf}
    ${image_files} =    Create List    ${screenshot}:align=center
    Add Files To PDF    ${image_files}    ${pdf}    append=True
    Close Pdf    ${pdf}

Order another robot
    Click Button    id:order-another
    Wait Until Element Is Visible    css:.modal

Create a ZIP file
    ${zip_file_name} =    Set Variable    ${OUTPUT_DIR}${/}receipts.zip
    Archive Folder With Zip    ${OUTPUT_DIR}    ${zip_file_name}
