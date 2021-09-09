def format(target):
    returns = {
        str(target.label): {
            "target_info": target,
            "build_info": build_options(target),
        },
    }

    return struct_to_dict(returns)


def struct_to_dict(x, depth=100):
    root = {}
    queue = [(root, x)]
    for i in range(depth):
        nextlevel = [] if i < depth - 1 else None
        for dest, obj in queue:
            if _is_depset(obj):
                obj = obj.to_list()
            if _is_list(obj):
                for item in list(obj):
                    converted = _convert_one(item, nextlevel)
                    dest.append(converted)
            elif type(obj) == type({}):
                for key, value in obj.items():
                    converted = _convert_one(value, nextlevel)
                    dest[key] = converted
            else:  # struct or object
                dest["_type"] = type(obj)
                for propname in dir(obj):
                    _token = "nope"
                    value = getattr(obj, propname, _token)
                    if value == _token:
                        continue  # Native methods are not inspectable. Ignore.
                    converted = _convert_one(value, nextlevel)
                    dest[propname] = converted
                if type(obj) == "Target":
                    _providers = providers(obj)
                    for k, v in _providers.items():
                        dest[k] = _convert_one(v, nextlevel)

        queue = nextlevel
    return root


def _convert_one(val, nextlevel):
    nest = nextlevel != None
    if _is_sequence(val) and nest:
        out = []
        nextlevel.append((out, val))
        return out
    elif _is_atom(val) or not nest:
        if type(val) == type(False) or type(val) == type(None):
            return str(val)
        return val
    elif type(val) == "File":
        return val.path
    elif type(val) == "Label":
        return str(val)
    else:  # by default try to convert object to dict
        out = {}
        nextlevel.append((out, val))
        return out


def _is_sequence(val):
    return _is_list(val) or _is_depset(val)


def _is_list(val):
    return type(val) == type([])


def _is_depset(val):
    return type(val) == "depset"


def _is_atom(val):
    return (
        type(val) == type("")
        or type(val) == type(0)
        or type(val) == type(False)
        or type(val) == type(None)
    )

