
import Foundation

class DispatchHandle
{
	func perform()
	{
		block?()
	}
	
	func cancel()
	{
		block = nil
	}
	
	var block : dispatch_block_t? = nil
}

func dispatch_after_delay(interval : NSTimeInterval, queue: dispatch_queue_t, block: dispatch_block_t) -> DispatchHandle
{
	var result = DispatchHandle()
	result.block = block
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC * UInt64(interval))), queue)
	{
		result.perform()
	}
	return result
}
