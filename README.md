# nvim-tablecalc

## Description
- My first experiments with Lua
- Goal: Implement basic table calculations within Vim

## Status
- Work in progress

## TODOs
- ~~FixBug: Formulas in same row bug: see asoc_table2.org~~
- ~~Test reserved words as table/ column name (sum)~~ works!
- ~~Improve tests~~
- ~~Improve write_to_buffer; it's to slow; load and map buffer? map line number of matches? parallel tasks?~~
- ~~Fix that highlight autocmd is globaly active~~
- ~~only eval math expressions~~
- Add functioniliy:
    - ~~Analoge to sum, multiply~~
    - ~~Calculate correclty with the results of formulas~~
    - Styling: ~~Formulas should have a different color~~, results maybe in a new line
    - Tablename and maybe row numbers should be optional
    - ~~Set table_name_marker by filetype~~
    - ~~avoid recursiv self calls~~
    - ~~Table creator~~
- ~~Robust error handling~~
- ~~Fix: Using empty fields in formulas: Can't evaluate + 3 + 3~~
- ~~Hotfix: sum~~
- Header row should be parsed correctly if it is not the direct follower of table_name
- ~~After reformating the buffer the cursor should stay at its current position (and not jump to the top)~~
- refactor

Today is Pungenday, the 26th day of The Aftermath in the YOLD 3190
