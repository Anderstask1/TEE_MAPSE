%save only the first decimals
function roundedValue = roundDecimals(value, decimalNo) 
divider = 10^decimalNo;
roundedValue = round(value*divider)/divider;
