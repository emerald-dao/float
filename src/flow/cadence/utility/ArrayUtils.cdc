// Copied from https://github.com/bluesign/flow-utils/blob/dnz/cadence/contracts/ArrayUtils.cdc with minor adjustments

access(all) contract ArrayUtils {

    access(all) fun rangeFunc(_ start: Int, _ end: Int, _ f : ((Int):Void) ) {
        var current = start
        while current < end{
            f(current)
            current = current + 1
        }
    }

    access(all) fun range(_ start: Int, _ end: Int): [Int]{
        var res:[Int] = []
        self.rangeFunc(start, end, fun (i:Int){
            res.append(i)
        })
        return res
    }

    access(all) fun transform(_ array: &[AnyStruct], _ f : ((AnyStruct): AnyStruct)){
        for i in self.range(0, array.length){
            array[i] = f(array[i])
        }
    }

    access(all) fun iterate(_ array: [AnyStruct], _ f : ((AnyStruct): Bool)){
        for item in array{
            if !f(item){
                break
            }
        }
    }

    access(all) fun map(_ array: [AnyStruct], _ f : ((AnyStruct): AnyStruct)) : [AnyStruct] {
        var res : [AnyStruct] = []
        for item in array{
            res.append(f(item))
        }
        return res
    }

    access(all) fun mapStrings(_ array: [String], _ f: ((String) : String) ) : [String] {
        var res : [String] = []
        for item in array{
            res.append(f(item))
        }
        return res
    }

    access(all) fun reduce(_ array: [AnyStruct], _ initial: AnyStruct, _ f : ((AnyStruct, AnyStruct): AnyStruct)) : AnyStruct{
        var res: AnyStruct = f(initial, array[0])
        for i in self.range(1, array.length){
            res =  f(res, array[i])
        }
        return res
    }

}