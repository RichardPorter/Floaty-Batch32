@echo off
call convert load_fp 3.14 pi
set /p "radius=Please enter the circle's radius"
echo %radius%
call convert load_fp %radius% fradius
echo %fradius%
call operate mpy %fradius% %fradius% fradius2
echo fradius2%fradius2%
call operate mpy %fradius2% %pi% area
echo area %area%
call convert unload_fp %area% 2 area_string
echo Area of circle is approximately %area_string%