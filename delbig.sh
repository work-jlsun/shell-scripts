#!/bin/bash



filename="out"
function del_bigger_file
{
  find ~ -size +10  > $filename

  cat $filename | while read line
  do 
		printf "file: %s\n" $line
		#rm $line
		
  done   
}


del_bigger_file

