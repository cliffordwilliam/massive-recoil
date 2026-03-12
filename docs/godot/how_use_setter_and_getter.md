## Recommendation

Use GDScript **property syntax with `set`/`get` blocks** or an explicit getter/setter function pair, and avoid mixing styles on the same variable:

- **Inline property with code blocks** for simple logic and encapsulation:
  ```gdscript
  var milliseconds: int = 0
  var seconds: int:
	  get:
		  return milliseconds / 1000
	  set(value):
		  milliseconds = value * 1000
  ```
- **Alternative syntax using existing functions** when you want to reuse logic:
  ```gdscript
  var my_prop:
	  get = get_my_prop, set = set_my_prop
  ```
  or on one line:
  ```gdscript
  var my_prop: get = get_my_prop, set = set_my_prop
  ```
- **Do not mix notations** for the same variable; choose either inline `get`/`set` blocks or the `get = func, set = func` style.
- **Access the variable name directly inside its own setter/getter** to touch the underlying storage without recursion, and avoid calling a separate function that then sets the property again (that can cause infinite recursion).

## Why

The documentation states that properties use `set` and `get` after a variable declaration to run code whenever the property is accessed or assigned, giving you validation and encapsulation. It notes that `set`/`get` methods are **always called** (unlike old `setget`), and recommends using another backing variable if you need direct access. The alternative syntax exists specifically to **reuse existing functions** for multiple properties, but the docs emphasize that the same notation must be used consistently per variable and explain how direct use of the variable name within its own setter/getter safely updates the underlying value without recursion, while delegating to another function that sets the property again will recurse infinitely.

## Citation

`tutorials/scripting/gdscript/gdscript_basics.rst`

> “For this, GDScript provides a special syntax to define properties using the `set` and `get` keywords after a variable declaration. Then you can define a code block that will be executed when the variable is accessed or assigned.  
> :::  
> ```  
> var milliseconds: int = 0  
> var seconds: int:  
>     get:  
>         return milliseconds / 1000  
>     set(value):  
>         milliseconds = value * 1000  
> ```”  

> “Unlike `setget` in previous Godot versions, `set` and `get` methods are **always** called … If you need direct access to the value, use another variable for direct access and make the property code use that name.”  

> “Also there is another notation to use existing class functions if you want to split the code from the variable declaration or you need to reuse the code across multiple properties …  
> :::  
> ```  
> var my_prop:  
>     get = get_my_prop, set = set_my_prop  
> ```  
> … The setter and getter must use the same notation, mixing styles for the same variable is not allowed.”  

> “Using the variable's name to set it inside its own setter or to get it inside its own getter will directly access the underlying member, so it won't generate infinite recursion…  
> :::  
> ```  
> var warns_when_changed = "some value":  
>     get:  
>         return warns_when_changed  
>     set(value):  
>         changed.emit(value)  
>         warns_when_changed = value  
> ``` …  
> The exception does **not** propagate to other functions called in the setter/getter. For example, the following code **will** cause an infinite recursion:  
> :::  
> ```  
> var my_prop:  
>     set(value):  
>         set_my_prop(value)  
>  
> func set_my_prop(value):  
>     my_prop = value # Infinite recursion…  
> ```”
