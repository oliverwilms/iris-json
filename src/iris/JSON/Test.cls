/// https://community.intersystems.com/post/iterate-over-dynamic-object
Class JSON.Test
{

/// do ##class(JSON.Test).Test()
ClassMethod Test()
{
    set json = "{""a"":1,""b"":2,""c"":{""c1"":3,""c2"":4}, ""d"": [5, {""e_e"":6}, 7]}"
    
    set obj = {}.%FromJSON(json)
    
    do ..Iterate(obj)
}

ClassMethod Iterate(obj As %DynamicAbstractObject, level = 0, path = "obj")
{
    set indent = $j("", level * 4)
    #dim iterator As %Iterator.Array
    set iterator = obj.%GetIterator()
    
    while iterator.%GetNext(.key, .value) {
        set type = obj.%GetTypeOf(key)
        write indent, "Key: ", key, !
        write indent, "Type: ", type, !
        
        if $classname(obj) = "%Library.DynamicArray" {
            set newPath = path _ ".%GetAt(" _ key _ ")"
        } else {
            if $zname(key, 6) = 1 {
                set newPath = path _  "." _ key
            } else {
                set newPath = path _  ".""" _ key _ """"
            }
        }
        
        write indent, "Path: ", newPath, !
        if $isObject(value) {
            write indent, "Value: ", !
            do ..Iterate(value, level + 1, newPath)
        } else {
            write indent, "Value: ", value, !
        }
        write !
    }
}

/*
Output from running Test method:

Key: a
Type: number
Path: obj.a
Value: 1
 
Key: b
Type: number
Path: obj.b
Value: 2
 
Key: c
Type: object
Path: obj.c
Value:
    Key: c1
    Type: number
    Path: obj.c.c1
    Value: 3
 
    Key: c2
    Type: number
    Path: obj.c.c2
    Value: 4
 
 
Key: d
Type: array
Path: obj.d
Value:
    Key: 0
    Type: number
    Path: obj.d.%GetAt(0)
    Value: 5
 
    Key: 1
    Type: object
    Path: obj.d.%GetAt(1)
    Value:
        Key: e_e
        Type: number
        Path: obj.d.%GetAt(1)."e_e"
        Value: 6
 
 
    Key: 2
    Type: number
    Path: obj.d.%GetAt(2)
    Value: 7
*/
/// https://community.intersystems.com/post/single-operation-concatenate-2-dynamicarrays
ClassMethod ConcatArrays(pArgs...) As %DynamicArray
{
    //set outArray = ##class(%DynamicArray).%New()
    Set outArray = []
    for i=1:1:pArgs {
        set arg = pArgs(i)
        if ($IsObject(arg) && arg.%IsA("%DynamicArray")) {
            set iter = arg.%GetIterator()
            while iter.%GetNext(.key, .value) {
                do outArray.%Push(value)
            }
        } else {
            do outArray.%Push(arg)
        }
    }
    return outArray
}

}
