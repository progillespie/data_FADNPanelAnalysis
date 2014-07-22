/* REMINDER for myself.

   If using VIM and ^M characters appear at the end of a line you can do 

	:1,$s/^V^M//

   where ^V is the key combination CTRL-V and ^M is CTRL-M
   it will type out as ^M before you hit enter. This is a regex that just 
   replaces all instances of ^M with nothing.

   If those characters appeared, that means that the text file was 
   formatted as a UNIX text file in VIM. You can set it back to DOS with 

	:set ff=dos


   There's no actual stata code here, this is just a reminder, but making
   it a do file means I probably won't delete it. Furthermore, I'm keeping
   it in sub_do/ and I will ALWAYS know where that is located on my computer. 

*/ 
