@echo off
setlocal EnableDelayedExpansion
IF /I %1==load_fp goto load_fp
IF /I %1==unload_fp goto unload_fp
echo Not a valid command
goto :eof
:unload_fp
REM echo unload
set /a "to_unload=%2"
set /a "dec_points=%3"
set /a mantissa_mask=8388607 
REM 2^23-1
set /a implicit_bit=8388608
REM 2^23
set /a exponent_mask=2139095040
set /a "new_sign=((%to_unload%)>>31) & 1"
set /a "exponent=(%to_unload%&%exponent_mask%)>>23"
set /a "mantissa=(%to_unload%&%mantissa_mask%) | %implicit_bit%"
IF %exponent% LSS 127 (
set /a int_part=0
goto :skip_unload_int
)
IF %exponent% LSS 150 (
set /a "int_part=%mantissa%>>(23-(%exponent%-127))"
goto :skip_unload_int
)
set /a "int_part=%mantissa%<<((%exponent%-127-23))"
:skip_unload_int
IF %exponent% GTR 118 (
set /a "dec_part=(%mantissa%<<(8+%exponent%-127))&(%mantissa_mask% | %exponent_mask%)"
goto :skip_unload_dec
)
set /a "dec_part=%mantissa%>>(119-%exponent%)"
:skip_unload_dec
set /a "dec_part_decimal=0"
set /a "decimal_multiplier=1000000000"
FOR /L %%A IN (30,-1,0) DO (
set /a "dec_part_decimal=!dec_part_decimal!+ ((dec_part & (1<<%%A))>>%%A)*!decimal_multiplier!"
set /a "decimal_multiplier=!decimal_multiplier!>>1"
)
set /a "dec_part_decimal=%dec_part_decimal%/2"
set "dec_string=%dec_part_decimal%"
call :strLen dec_string unpadded_length
REM echo %unpadded_length%
IF %unpadded_length% LSS 9 (
FOR /L %%A IN (8,-1,%unpadded_length%) DO (
set "dec_string=0!dec_string!"
)
)
REM set /a "dec_part_decimal=500000000 * (%dec_part% & 128) + 250000000 * (%dec_part% & 64) + 125000000 * (%dec_part% & 32) +  62500000 * (%dec_part% & 16) + 31250000 * (%dec_part% & 8) +  * (%dec_part% & 4) + 15625000 * (%dec_part% & 2) + 7812500 * (%dec_part% & 1
REM IF %dec_points% LSS 9 (
REM setlocal enabledelayedexpansion
REM echo rounding
REM set /a "dec_points_p_one=%dec_points%+1"
REM set /a roundingconstant=500000000
REM FOR /L %%A IN (%dec_points%,-1,1) DO (
REM echo !roundingconstant! 
REM set /a "roundingconstant=!roundingconstant! / 10"
REM 
REM echo %dec_string%
REM set /a dec_part_decimal=%dec_string%+!roundingconstant!
REM echo dec!dec_part_decimal!
REM IF !dec_part_decimal! GTR 1000000000 (
REM echo hi!
REM set /a int_part=%int_part%+1
REM set /a dec_part_decimal=!dec_part_decimal!-1000000000
REM )
REM echo !int_part!
REM echo !dec_part_decimal!
REM endlocal & set dec_part_decimal=!dec_part_decimal! & set int_part=!int_part!
REM )
REM set "dec_string=%dec_part_decimal%"
REM call :strLen dec_string unpadded_length
REM echo %unpadded_length%
REM IF %unpadded_length% LSS 9 (
REM FOR /L %%A IN (8,-1,%unpadded_length%) DO (
REM set "dec_string=0!dec_string!"
REM )
REM )
REM FOR /L %%A IN (%dec_points%,1,%dec_points%) DO (
REM set "dec_string=!dec_string:~0,%%A!"
REM )
REM echo %dec_points%
REM echo %dec_part%
REM echo dcpd%dec_part_decimal%
REM echo %dec_string%
REM echo %int_part%
REM echo %int_part%
REM endlocal & set "%4=%int_part%.%dec_string%"
REM echo %int_part%
set sign=
if %new_sign%==1 (
set "sign=-"
)
endlocal & set "%4=%sign%%int_part%.%dec_string%"
goto :eof

:load_fp
REM echo load
for /F "tokens=1,2 delims=." %%A IN ('echo %2') DO (
set int_temp_string=%%A
set dec_temp_string=%%B

)
set /a load_sign=0
set temp_load_string=%2
IF "%temp_load_string:~0,1%"=="-" (
set /a load_sign=1
set int_temp_string=%int_temp_string:~1%
)
REM echo %dec_temp_string%
REM echo %int_temp_string%
REM IF NOT DEFINED dec_temp_string (set /a dec_points=0 goto :skipdecimal)
call :strLen dec_temp_string dec_points
REM :skipstrlen
REM echo %dec_points%
set /a decimal_dividor=1
REM echo %dec_points%
REM pause
for /L %%A IN (1,1,%dec_points%) DO (
set /a decimal_dividor=!decimal_dividor!*10
)
REM  is 01000000 00000000 00000000 00000000  1073741824 as a 32 bit signed integer
set /a msb_one=1073741824 
REM because of right shift behaviour with negative numbers
REM echo %msb_one%
REM echo %decimal_dividor%
REM echo %dec_temp_string%
REM pause
set /a dec_binary=0
IF %dec_points%==0 goto :skipdecimal
set /a dec_temp=%dec_temp_string%
set /a first_binary_digit=-1
REM echo %dec_temp%
for /L %%A IN (0,1,30) DO (
set /a dec_temp=!dec_temp!*2
set /a "test_binary=(!dec_temp!)/%decimal_dividor%"
IF !test_binary! GTR 0 (
set /a dec_temp=!dec_temp!-%decimal_dividor%
set /a "dec_binary=!dec_binary! | (%msb_one%>>%%A)"
IF !first_binary_digit! EQU -1 (set /a first_binary_digit=1+%%A)
)
)
:skipdecimal
REM echo binary%dec_binary%
REM echo %decimal_dividor%
set /a exponent=0
set /a int_temp=%int_temp_string%+0
set /a int_binary_digits=-1
FOR /L %%A IN (0,1,31) DO (
IF !int_temp! EQU 0  (IF !int_binary_digits! EQU -1 set /a "int_binary_digits=%%A")
set /a "int_temp=!int_temp!/2"
)
set /a mantissa_mask=8388607 
REM 2^23-1
IF %int_binary_digits% GEQ 24 (
set /a "int_temp=%int_temp_string%>>(%int_binary_digits%-24)"
set /a "int_temp=!int_temp! & %mantissa_mask%"
set /a exponent=%int_binary_digits%-1

goto :skipaddingdecimal
)
set /a "int_temp=(%int_temp_string%<<(24-%int_binary_digits%))& %mantissa_mask%"
REM echo %int_binary_digits%
IF %int_binary_digits% GTR 0 (
set /a "dec_temp=((%dec_binary%)>>(7+%int_binary_digits%))&%mantissa_mask%"
set /a exponent=%int_binary_digits%-1
goto :skippaddingdecimal
)
REM echo bd%first_binary_digit%
IF %first_binary_digit% GTR 7 (
set /a "dec_temp=(%dec_binary%<<(%first_binary_digit%-1-7))&%mantissa_mask%"
)
IF %first_binary_digit% LEQ 7 (
set /a "dec_temp=(%dec_binary%>>(8-%first_binary_digit%))&%mantissa_mask%"
)
REM set /a "dec_binary=(%dec_binary%>>7)"
REM set /a "dec_temp=(%dec_binary%<<(%first_binary_digit%-1))&%mantissa_mask%"
set /a "exponent=-%first_binary_digit%"
IF %first_binary_digit% LSS 0 (
set /a "exponent=-127"
)
:skipaddingdecimal
set /a "exponent=(%exponent%+127)<<23"
set /a "float_load=%exponent%|%int_temp%|%dec_temp%"
REM echo %mantissa_mask%
REM echo %float_load%
REM echo %load_sign%
set /a "float_load=%float_load% ^ (%load_sign%<<31)"
endlocal & set /a %3=%float_load%
goto :eof


:strLen
setlocal enabledelayedexpansion
:strLen_Loop
  if not "!%1:~%len%!"=="" set /A len+=1 & goto :strLen_Loop
(endlocal & set %2=%len%)
goto :eof
