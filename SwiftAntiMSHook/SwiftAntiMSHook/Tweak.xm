#import <mach-o/dyld.h>
#import<substrate.h>
#import <UIKit/UIkit.h>

static int (*denyDebugger)=NULL;

bool newDenyDebugger(int64_t value)
{
  NSLog(@"Hook Success ~~");
  return 1;
}

%ctor {
   void* denyDebugger_address = look for it at IDA;
   void* addr = (void*)(_dyld_get_image_vmaddr_slide(0) + denyDebugger_address);
   MSHookFunction(addr, (void*)newDenyDebugger, (void**)&denyDebugger);
   NSLog(@"----MSHookFunction End---, and vm_region_addr_new is %p", denyDebugger);
}
