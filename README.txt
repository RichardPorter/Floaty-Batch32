To load a number into var_name:
call convert load_fp x.y var_name

mpy, add, and div are all called as:

call operate operator arg_a_val arg_b_val var_name

To unload a floating point number into a string

call convert unload_fp arg_val decimal_points var_name

Specifying a number of decimal points is not currently supported

circle.bat provides an example

TODO:

Proper handling of 0 (especially -0)
Handling NaN
Handling Inf and -Inf
Subtraction
Supporting specifying a number of decimal points for unload_fp