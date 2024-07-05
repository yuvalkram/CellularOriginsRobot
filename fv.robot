*** Settings ***
Library    Process    

*** Test Cases ***
Test invalid placements
    ${output}=    Place Robot in Disallowed Place 1
    Should Match    ${output.stdout}    Invalid position. Position should be within 5x5 grid.
    ${output}=    Place Robot in Disallowed Place 2
    Should Match    ${output.stdout}    Invalid position. Position should be within 5x5 grid.
    ${output}=    Place Robot in Disallowed Place 3
    Should Match    ${output.stdout}    Invalid position. Position should be within 5x5 grid.

Test valid placement and movement (one and two reports)
    ${output}=    Send to Robot    PLACE 2,4,SOUTH MOVE REPORT EXIT
    Should Match    ${output.stdout}    2 3 SOUTH
    ${output}=    Send to Robot    PLACE 0,1,NORTH REPORT MOVE REPORT EXIT
     Should Match    ${output.stdout}    0 1 NORTH\n0 2 NORTH

Test turning and moving
    ${output}=    Send to Robot    PLACE 1,1,NORTH LEFT MOVE REPORT EXIT
    Should Match    ${output.stdout}    0 1 WEST
    ${output}=    Send to Robot    PLACE 3,3,EAST RIGHT MOVE REPORT EXIT
    Should Match    ${output.stdout}    3 2 SOUTH
    ${output}=    Send to Robot    PLACE 2,2,SOUTH RIGHT MOVE LEFT MOVE RIGHT REPORT EXIT
    Should Match    ${output.stdout}    1 1 WEST

Test Trying to fall off
    ${output}=    Send to Robot    PLACE 0,0,WEST MOVE REPORT EXIT
    Should Match    ${output.stdout}    0 0 WEST
    ${output}=    Send to Robot    PLACE 0,0,NORTH MOVE MOVE MOVE MOVE MOVE MOVE REPORT EXIT
    Should Match    ${output.stdout}    0 4 NORTH

Test reporting before and after placement
    ${output}=    Send to Robot    REPORT PLACE 1,1,NORTH REPORT EXIT
    Should Match    ${output.stdout}    1 1 NORTH

Test movement before and after placement
    ${output}=    Send to Robot    MOVE PLACE 1,1,NORTH REPORT EXIT
    Should Match    ${output.stdout}    1 1 NORTH
    ${output}=    Send to Robot    MOVE PLACE 1,1,NORTH MOVE REPORT EXIT
    Should Match    ${output.stdout}    1 2 NORTH

Test multiple placements
    ${output}=    Send to Robot    PLACE 1,1,NORTH PLACE 2,2,SOUTH REPORT EXIT
    Should Match    ${output.stdout}    1 1 NORTH

Test full circles (clockwise/anti-clockwise)
    ${output}=    Send to Robot    PLACE 1,1,NORTH RIGHT RIGHT RIGHT RIGHT REPORT EXIT
    Should Match    ${output.stdout}    1 1 NORTH
    ${output}=    Send to Robot    PLACE 1,1,NORTH LEFT LEFT LEFT LEFT REPORT EXIT
    Should Match    ${output.stdout}    1 1 NORTH

Test all valid commands are ignored before a PLACE command
    ${output}=    Send to Robot    MOVE LEFT RIGHT REPORT EXIT
    Should Be Empty    ${output.stdout}
    ${output}=    Send to Robot    MOVE LEFT RIGHT REPORT PLACE 1,3,EAST REPORT EXIT
    Should Be Equal    ${output.stdout}    1 3 EAST

Test that invalid keywords are ignored (and do not cause errors)
    ${output}=    Send to Robot    PLACE 1,1,NORTH INVALID MOVE REPORT EXIT
    Should Match    ${output.stdout}    Invalid command. Use one of REPORT, MOVE, LEFT, RIGHT, PLACE x,y,direction.\n1 2 NORTH
    ${output}=    Send to Robot    PLACE 1,1,NORTH WESTSOUTH PLACE 2,2,SOUTH REPORT EXIT
    Should Match    ${output.stdout}    Invalid command. Use one of REPORT, MOVE, LEFT, RIGHT, PLACE x,y,direction.\n1 1 NORTH
    ${output}=    Send to Robot    PLACE NORTH,1,1 PLACE 2,2,SOUTH REPORT EXIT
    Should Match    ${output.stdout}    invalid literal for int() with base 10: 'NORTH'\n2 2 SOUTH
    ${output}=    Send to Robot    PLACE 2,1,1 EXIT
    Should Match    ${output.stdout}    Invalid direction. Use one of NORTH, SOUTH, EAST, WEST.

*** Keywords ***
Send to Robot 
    [Arguments]    ${command}
    ${output} =   Run Process     python ${CURDIR}/toyRobot.Py ${command}      shell=True
    RETURN    ${output}

Place Robot in Disallowed Place 1
    ${output}=    Send to Robot    PLACE -1,-1,WEST REPORT EXIT
    RETURN    ${output}

Place Robot in Disallowed Place 2
    ${output}=    Send to Robot    PLACE 5,0,WEST REPORT EXIT
    RETURN    ${output}

Place Robot in Disallowed Place 3
    ${output}=    Send to Robot    PLACE 3,123,SOUTH REPORT EXIT
    RETURN    ${output}

