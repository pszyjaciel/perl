#!/bin/csh

# the function sorts descending rows in a txt-file by 3th column, 
# when values in 3th column are equal, then sorting by 2nd column is executed
	 
set col1 = 3										# sort by column #3

# read the txt-file to myNewArray[]
set myNewArray
foreach lne ("`cat c:/arknr2.txt`")
	set featTwo = ($lne:x)				# split on single word
	if ($featTwo[1] == "#T") then
		set j = 1
		while ($j <= $#featTwo)
			set myNewArray = ( $myNewArray $featTwo[$j] )
			@ j++
		end
	endif
end

# 1st. sorting of myNewArray[] from the highest to the lowest by the column #3 
# https://www.cs.cmu.edu/~adamchik/15-121/lectures/Sorting%20Algorithms/sorting.html
set lineLength = $#featTwo
set arrayLength = $#myNewArray
@ i = ( ( $arrayLength / $lineLength ) - 1 )		# number of rows 

while ( $i >= 0 )
	set j = 1
	while ( $j <= $i )
		@ index1 = ( $col1 + ( $lineLength * ( $j - 1 ) ) )
		@ index2 = ( $col1 + ( $lineLength * $j ) )
		@ var1 = $myNewArray[$index1]:s/.//			# removes a dot
		@ var2 = $myNewArray[$index2]:s/.//
		if ( $var1 < $var2 ) then
		@ indexStart = $index1 - 2					# $index1 - 2 : the first column; $index2 - 3 : the last column
			while ($indexStart <= $index2 - 3)		# replaces the whole row
				set temp = $myNewArray[$indexStart]		
				@ indexEnd = $indexStart + $lineLength
				set myNewArray[$indexStart] = $myNewArray[$indexEnd]
				set myNewArray[$indexEnd] = $temp
				@ indexStart++
			end
		endif
		@ j++
	end
	@ i--
end

# this 2nd. sorting of myNewArray[] from the highest to the lowest by the column #2
# only affects row, which #3 column is equal to the #3 column of the next row
@ i = ( ( $arrayLength / $lineLength ) - 1 )		# number of rows 
while ( $i >= 0 )
	set j = 1
	while ( $j <= $i )
		@ index1 = ( $col1 + ( $lineLength * ( $j - 1 ) ) )
		@ index2 = ( $col1 + ( $lineLength * $j ) )
		@ var1 = $myNewArray[$index1]:s/.//			# removes a dot
		@ var2 = $myNewArray[$index2]:s/.//
		if ( $var1 == $var2 ) then
			@ indexStart = $index1 - 2				# $index1 - 2 : the first column
			@ tmpIdx1 = $index1 - 1
			@ tmpIdx2 = $index2 - 1
			@ tmpVar1 = $myNewArray[$tmpIdx1]:s/.//
			@ tmpVar2 = $myNewArray[$tmpIdx2]:s/.//
			if ( $tmpVar1 > $tmpVar2 ) then
				while ($indexStart <= $index2 - 3)		# replaces the whole row ($index2 - 3 : the last column)
					set temp = $myNewArray[$indexStart]		
					@ indexEnd = $indexStart + $lineLength
					set myNewArray[$indexStart] = $myNewArray[$indexEnd]
					set myNewArray[$indexEnd] = $temp
					@ indexStart++
				end	
			endif
		endif
		@ j++
	end				# end of while
	@ i--
end

# write the array to a file
@ row = $#myNewArray / $#featTwo
@ col = $#featTwo
set j = 1
while ($j <= $row)
	set i = 1
	while ($i <= $col) 
		@ index = $i + ( $col * ( $j - 1 ) )
		echo -n "$myNewArray[$index] " >> c:/arknr2b.txt
		echo -n "$myNewArray[$index] " 
		@ i++
	end
	echo "\r" >> c:/arknr2b.txt
	echo "\r"
	@ j++
end
