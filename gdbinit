set pagination off

# skip mostly uninteresting files in v8
skip file slots.h
skip file roots-inl.h
skip file ptr-compr-inl.h
skip file vm-state-inl.h
skip file v8-intrenal.h
skip file *base/optional.h
skip file *include/c++/v1/*
skip -rfunction ^v8::Local.*
skip -rfunction ^v8::Maybe.*
skip -rfunction ^v8::Just.*
skip -rfunction ^v8::Nothing.*
skip -rfunction ^v8::MaybeLocal.*
skip -rfunction ^v8::internal::Handle.*
skip -rfunction ^v8::internal::MaybeHandle.*
skip -rfunction ^v8::internal::TaggedImpl.*
skip -rfunction ^v8::internal::TaggedField.*
skip v8::internal::HeapObject::GetReadOnlyRoots
skip -rfunction ^v8::Utils::Convert.*
skip -rfunction ^v8::Utils::ToLocal.*
skip v8::Utils::OpenHandle
skip v8::internal::HeapObject::cast
skip v8::internal::Isolate::FromRoot
skip v8::internal::HeapObject::map_word
skip v8::internal::HeapObject::map
skip v8::internal::GetIsolateForPtrCompr
skip v8::internal::JSReceiver::GetIsolate
skip -rfunction ^v8::internal::Object::ReadField.*
skip -rfunction ^v8::base::IsInRange.*
skip -rfunction ^v8::internal::InstanceTypeChecker.*
skip -rfunction ^v8::internal::Smi::.*
skip -rfunction ^v8::base::BitField.*

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
