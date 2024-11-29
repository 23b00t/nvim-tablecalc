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
    - ~~Formulas should have a different color~~
    - ~~Tablename should be optional~~
    - ~~Set table_name_marker by filetype~~
    - ~~avoid recursiv self calls~~
    - ~~Table creator~~
- ~~Robust error handling~~
- ~~Fix: Using empty fields in formulas: Can't evaluate + 3 + 3~~
- ~~Hotfix: sum~~
- ~~Header row should be parsed correctly if it is not the direct follower of table_name~~
- ~~After reformating the buffer the cursor should stay at its current position (and not jump to the top)~~
- ~~Tests: Add setUp and tearDown for mocking and cleaning up~~
- ~~Handle referencing strings in formulas~~
- Implement TableInsertRows
- refactor
- Documentation

## Known Issues
- Row indexes have to be succeeding numbers

## Epected Behaviour
- If a column is tag with a number (e.g. num1 as 1) it can be reffered to in a formula (e.g. 1.1 which means column one row one)
  and using floats starting with that column name number (in this example 1) won't treated as folats.  So it is generally not reccomended
  to use numbers to name columns.
- Cells containing only strings are evaluated to 0. Cells containing strings and numbers are evaluated as the numbers they contain. 
  That means 23b00t will be evaluated as 2300 and l3e7 to 37. 

## Open Questions
- Should TableCreate be a seperate plugin? Re-think structure...


Today is Pungenday, the 26th day of The Aftermath in the YOLD 3190
