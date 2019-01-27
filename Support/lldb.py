import lldb 

def printworld(debugger, command, result, internal_dict):
  print "world!"
  
def rob_list_breakpoints(debugger, command, result, internal_dict):
  global idob

  print("rlb!")
  ci = lldb.debugger.GetCommandInterpreter()
  output = lldb.SBCommandReturnObject()
  ci.HandleCommand('breakpoint list')
  print(something_or_other)

  idob.send("done")
  ci.HandleCommand("script print \"DATA SENT\"", output)
  ci.HandleCommand("continue", output) 

  print("!blr")
  