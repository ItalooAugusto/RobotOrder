*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images.

Library             RPA.Browser.Selenium    auto_close=${FALSE}
Library             RPA.PDF
Library             RPA.Excel.Files
Library             RPA.HTTP
Library             RPA.Tables
Library             RPA.Robocorp.Vault
Library             RPA.Desktop
Library             RPA.Email.Exchange
Library             RPA.Archive

*** Variables ***
${folderpath}=    ${OUTPUT_DIR}${/}orders.zip


*** Tasks ***
Orders robots into the website and export it as a PDF
    Open the order Browser
    Download CSV file
    Get Orders

*** Keywords ***
Open the order Browser
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order

Download CSV file
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=TRUE

Get Orders
    ${orders}=    Read table from CSV    orders.csv
    FOR    ${row}    IN    @{orders}
        Click Button    css:button.btn-dark
        Select From List By Value    head    ${row}[Head]
        Select Radio Button    body    ${row}[Body]
        Input Text    //*[@type="number"]    ${row}[Legs]
        Input Text    id:address    ${row}[Address]
        Click Button    id:preview
        Wait Until Keyword Succeeds    3x    5s    Click Button    id:order
        Wait Until Element Is Visible    id:receipt
        ${results_order}=    Get Element Attribute    id:receipt    outerHTML
        Html To Pdf    ${results_order}    ${OUTPUT_DIR}${/}${row}[Order number]-robot.pdf
        Screenshot    id:robot-preview-image    ${OUTPUT_DIR}${/}${row}[Order number]-image-robot.png
        ${files}=    Create List
        ...    ${OUTPUT_DIR}${/}${row}[Order number]-image-robot.png:x=0, y=0
        Add Files To Pdf    ${files}    ${OUTPUT_DIR}${/}${row}[Order number]-robot.pdf    append=TRUE
        Add To Archive    ${OUTPUT_DIR}${/}${row}[Order number]-robot.pdf    ${folderpath}
        Click Button    id:order-another
    END
