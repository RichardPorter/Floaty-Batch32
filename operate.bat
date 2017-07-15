@echo off
IF /I %1==mpy goto mpy
IF /I %1==div goto div
IF /I %1==add goto add
IF /I %1==sub goto sub
echo hi
:mpy
set /a mantissa_mask=8388607 
REM 2^23-1
set /a implicit_bit=8388608
REM 2^23
set /a sign_mask=-2147483647
set /a sign_mask-=1
set /a exponent_mask=2139095040
set /a mpy_a=%2
set /a mpy_b=%3
set /a "mpy_exponent=((%mpy_a%&%exponent_mask%)>>23) + ((%mpy_b%&%exponent_mask%)>>23)-126"
set /a "new_sign=((%mpy_a% ^ %mpy_b%)>>31)&1"
set /a "new_mantissa=(((%mpy_a%&%mantissa_mask%)|%implicit_bit%)>>9)*(((%mpy_b%&%mantissa_mask%)|%implicit_bit%)>>9)"
REM This is where some precision is lost
REM 2^29=536870912
IF %new_mantissa% LSS 536870912 (
set /a "mpy_exponent=%mpy_exponent%-1"
set /a "new_mantissa=%new_mantissa%<<1"
)
set /a "new_mantissa=(new_mantissa>>6)&%mantissa_mask%"
set /a "new_exponent=%mpy_exponent%<<23"
set /a "result=(%new_sign%<<31)|%new_exponent%|%new_mantissa%"
echo %mpy_exponent%
echo %new_sign%
endlocal & set /a "%4=%result%"
goto :eof
:div
setlocal EnableDelayedExpansion
set /a mantissa_mask=8388607 
REM 2^23-1
set /a implicit_bit=8388608
REM 2^23
set /a exponent_mask=2139095040
set /a div_a=%2
set /a div_b=%3
set /a "new_sign=((%div_a% ^ %div_b%)>>31) & 1"
set /a "div_exponent=((%div_a%&%exponent_mask%)>>23) -((%div_b%&%exponent_mask%)>>23)+127"
set /a first_binary_digit=-1
REM echo %dec_temp%
set /a dec_binary=0
set /a msb_one=1073741824 
set /a "div_a_mantissa=(%div_a%&%mantissa_mask%) | %implicit_bit%"
set /a "div_b_mantissa=(%div_b%&%mantissa_mask%) | %implicit_bit%"
for /L %%A IN (0,1,30) DO (
set /a "test_binary=(!div_a_mantissa!)/%div_b_mantissa%"
IF !test_binary! GTR 0 (
set /a div_a_mantissa=!div_a_mantissa!-%div_b_mantissa%
set /a "dec_binary=!dec_binary! | (%msb_one%>>%%A)"
IF !first_binary_digit! EQU -1 (set /a first_binary_digit=%%A)
)
set /a div_a_mantissa=!div_a_mantissa!*2
)
set /a "new_exponent=(%div_exponent%-%first_binary_digit%)<<23"
set /a "result=( (%new_sign%<<31) | %new_exponent% | ((%dec_binary%>>(7-%first_binary_digit%))&%mantissa_mask%))"
endlocal & set /a "%4=%result%"
goto :eof
:add
setlocal EnableDelayedExpansion
set /a mantissa_mask=8388607 
REM 2^23-1
set /a implicit_bit=8388608
REM 2^23
set /a exponent_mask=2139095040
set /a add_a=%2
set /a add_b=%3
set /a "sign=(((%add_b%)>>31))&1"

echo %sign%
pause
set "operator=+"
IF %sign% EQU 1 (
set "operator=-"
)
set /a "add_a_mantissa=(%add_a% & %mantissa_mask%) | %implicit_bit%"
set /a "add_b_mantissa=(%add_b% & %mantissa_mask%) | %implicit_bit%"
set /a "add_a_exponent=(%add_a% & %exponent_mask%)>>23"
set /a "add_b_exponent=(%add_b% & %exponent_mask%)>>23"
IF %add_a_exponent% GTR %add_b_exponent% (
set /a exponent=%add_a_exponent%
set /a exponent_diff=%add_a_exponent%-%add_b_exponent%
set /a "add_b_mantissa=%add_b_mantissa% >> (%add_a_exponent%-%add_b_exponent%)"
) ELSE (
set /a exponent=%add_b_exponent%
set /a exponent_diff=%add_b_exponent%-%add_a_exponent%
set /a "add_a_mantissa=%add_a_mantissa% >> (%add_b_exponent%-%add_a_exponent%)"
)
IF %add_a_mantissa% GTR %add_b_mantissa% (
set /a "new_mantissa= %add_a_mantissa% %operator% %add_b_mantissa%"
) ELSE (
set /a "new_mantissa= %add_b_mantissa% %operator% %add_a_mantissa%"
IF "%operator%"=="-" (
set /a "sign=(sign+1) % 2"
)
)
echo %new_mantissa%
pause
set /a binary_digits=0
set /a "temp_mantissa=%new_mantissa%"
FOR /L %%A IN (0,1,30) DO (
IF !temp_mantissa! EQU 0 (
set /a "binary_digits=%%A"
goto :escape_add_count_loop
)
set /a "temp_mantissa=!temp_mantissa!>>1"
)
:escape_add_count_loop
echo %sign%
echo %new_mantissa%
echo %binary_digits%
set /a "new_mantissa=(%new_mantissa%<<(24-%binary_digits%)) & %mantissa_mask%"
echo %new_mantissa%
pause
IF %binary_digits% GTR 24 (
set /a "new_mantissa=(%new_mantissa%>>(%binary_digits%-24)) & %mantissa_mask%"
) ELSE (
set /a "new_mantissa=(%new_mantissa%<<(24-%binary_digits%)) & %mantissa_mask%"
)
set /a "exponent=%exponent%+(%binary_digits%-24)"
set /a "result=(%sign%<<31) | (%exponent% << 23) | %new_mantissa%"
IF %new_mantissa% EQU 0 (
set /a "result=0|(%sign%<<31)"
)
echo %exponent%
echo %exponent_diff%
echo %binary_digits%
endlocal & set /a "%4=%result%"
goto :eof

:sub
set /a sub_a=%2
set /a "sub_b=(1<<31) ^ %3"
call operate add %sub_a% %sub_b% sub_result
endlocal & set /a "%4=%sub_result%"
goto :eof