python
 
import os
import itertools
import subprocess
 
class VsCodeCommand(gdb.Command):
  """Open VSCode for the current line."""
 
  def __init__ (self):
    super (VsCodeCommand, self).__init__ ("code", gdb.COMMAND_USER)
 
  def invoke (self, arg, from_tty):
    self.dont_repeat()
 
    frame = gdb.selected_frame()
    sal = frame.find_sal()
    if sal.is_valid() and sal.symtab is not None and sal.symtab.is_valid():
      subprocess.call(["code", "--goto", "%s:%d" % (sal.symtab.fullname(), sal.line)])
 
VsCodeCommand()
 
end 
