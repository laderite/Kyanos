local TableUtil = {}

function TableUtil.Filter(tbl, predicate)
    local result = {}
    for _, v in ipairs(tbl) do
        if predicate(v) then
            table.insert(result, v)
        end
    end
    return result
end

function TableUtil.Sort(tbl, comparator)
    local sorted = table.clone(tbl)
    table.sort(sorted, comparator)
    return sorted
end

function TableUtil.Map(tbl, mapper)
    local result = {}
    for i, v in ipairs(tbl) do
        result[i] = mapper(v)
    end
    return result
end

function TableUtil.Reduce(tbl, reducer, initial)
    local result = initial
    for _, v in ipairs(tbl) do
        result = reducer(result, v)
    end
    return result
end

return TableUtil
