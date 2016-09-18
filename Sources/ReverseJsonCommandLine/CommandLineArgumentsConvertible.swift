import ReverseJsonCore
import ReverseJsonSwift
import ReverseJsonObjc

public protocol CommandLineArgumentsConvertible {
    init(args: [String]) throws
}

extension SwiftTranslator: CommandLineArgumentsConvertible {
    public init(args: [String]) {
        self.init()
        objectType = args.contains("-c") || args.contains("--class") ? .classType : .structType
        listType = args.contains("-ca") || args.contains("--contiguousarray") ? .contiguousArray : .array
        mutableFields = args.contains("-m") || args.contains("--mutable")
        fieldVisibility = args.contains("-pf") || args.contains("--publicfields") ? .publicVisibility : .internalVisibility
        typeVisibility = args.contains("-pt") || args.contains("--publictypes") ? .publicVisibility : .internalVisibility
    }
}

extension ObjcModelCreator: CommandLineArgumentsConvertible {
    public init(args: [String]) {
        self.init()
        atomic = args.contains("-a") || args.contains("--atomic")
        readonly = !(args.contains("-m") || args.contains("--mutable"))
        if let index = args.index(where: { $0 == "-p" || $0 == "--prefix" }) , args.count > index + 1 {
            typePrefix = args[index + 1]
        }
    }
}

extension ModelGenerator: CommandLineArgumentsConvertible {
    public init(args: [String]) {
        self.init()
        allFieldsOptional = args.contains("-n") || args.contains("--nullable")
    }
}
