## Recommendation

Use **`RefCounted`-derived types normally and let Godot manage their lifetime automatically**:

- **Instantiate and use `RefCounted` classes without calling `free()`**; they are freed when nothing references them anymore.
- **Do not manually manipulate the reference count** (`init_ref()`, `reference()`, `unreference()`) in regular game code; these methods are for advanced/engine-level use only.
- **Avoid reference cycles** between `RefCounted` instances (or between a Node and a `RefCounted` it holds) so they can be released; where a cycle is required, make at least one link weak using `@GlobalScope.weakref()` so it doesn’t contribute to the reference count.
- In C#, be aware that **collection is delayed**: rely on the garbage collector to eventually release unused `RefCounted` objects instead of expecting immediate freeing.

## Why

The documentation explains that `RefCounted` keeps an **internal reference counter** and is **automatically released when no longer in use**, so manual freeing is unnecessary and can be harmful. It warns that **cycles prevent the count from reaching zero**, causing leaks, and specifically recommends breaking cycles with `weakref()` when needed. It also notes that the class’s low-level methods are “only for advanced users” and can cause issues if misused, reinforcing that the best practice is to simply use `RefCounted`-derived types as ordinary objects and let the engine manage their memory (with C#’s GC adding an additional layer of delayed cleanup).

## Citation

`classes/class_refcounted.rst`

> “Base class for any object that keeps a reference count. :ref:`Resource<class_Resource>` and many other helper objects inherit this class.  
> Unlike other :ref:`Object<class_Object>` types, **RefCounted**\ s keep an internal reference counter so that they are automatically released when no longer in use, and only then. **RefCounted**\ s therefore do not need to be freed manually with :ref:`Object.free()<class_Object_method_free>`.”  

> “**RefCounted** instances caught in a cyclic reference will **not** be freed automatically. For example, if a node holds a reference to instance `A`, which directly or indirectly holds a reference back to `A`, `A`'s reference count will be 2. Destruction of the node will leave `A` dangling with a reference count of 1, and there will be a memory leak. To prevent this, one of the references in the cycle can be made weak with :ref:`@GlobalScope.weakref()<class_@GlobalScope_method_weakref>`.”  

> “In the vast majority of use cases, instantiating and using **RefCounted**-derived types is all you need to do. The methods provided in this class are only for advanced users, and can cause issues if misused.”  

> “**Note:** In C#, reference-counted objects will not be freed instantly after they are no longer in use. Instead, garbage collection will run periodically and will free reference-counted objects that are no longer in use. This means that unused ones will remain in memory for a while before being removed.”
