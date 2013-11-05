
#!/usr/bin/perl
# A test function

my $inputStr = "\"Test\"";

#print "$inputStr\n";
print &noQuotes($inputStr);

sub noQuotes(){ 

   #-------------------------------------------------------------------#
   #  two possible input arguments - $promptString, and $defaultValue  #
   #  make the input arguments local variables.                        #
   #-------------------------------------------------------------------#

	my $inputStr;
	my $newString;

	$inputStr=@_[0];

        #print "$inputStr\n" ;

	$newString = substr $inputStr, 0 , -1;
	$newString = substr $newString, 1;
		
	return $newString;	
}
