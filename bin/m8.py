#!/usr/bin/env python  
 # Magic 8 ball program  
import random  
answers = ["As I see it, yes","It is certain","It is decidedly so","Most likely","Outlook good","Signs point to yes","Without a doubt","Yes","Yes definitely","You may rely on it","Better not tell you now","Cannot predict now","Concentrate and ask again","Don't count on it","My reply is no","My sources say no","Outlook not so good","Very doubtful"]  
raw_input("Hello candy-ass, what you need to know?\n")  
response = random.choice(answers)  
print response +'\n'  
while (True):  
  raw_input("Any other question?\n")  
  print random.choice(answers) + '\n'  

