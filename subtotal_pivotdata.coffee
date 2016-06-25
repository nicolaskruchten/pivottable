callWithJQuery = (pivotModule) ->
    if typeof exports is "object" and typeof module is "object" # CommonJS
        pivotModule require("jquery")
    else if typeof define is "function" and define.amd # AMD
        define ["jquery"], pivotModule
    # Plain browser env
    else
        pivotModule jQuery
        
callWithJQuery ($) ->

    class SubtotalPivotData extends $.pivotUtilities.PivotData
        constructor: (input, opts) ->
            super(input, opts)

        processKey = (record, totals, keys, attrs, f) ->
            key = []
            addKey = false
            for attr in attrs
                key.push record[attr] ? "null" 
                flatKey = key.join(String.fromCharCode(0))
                if not totals[flatKey]
                    totals[flatKey] = f(key.slice())
                    addKey = true
                totals[flatKey].push record
            if addKey
                keys.push key
            return key

        processRecord: (record) -> #this code is called in a tight loop
            rowKey = []
            colKey = []
            
            @allTotal.push record
            rowKey = processKey record, @rowTotals, @rowKeys, @rowAttrs, (key) =>
                    return @aggregator(this, key, [])
            colKey = processKey record, @colTotals, @colKeys, @colAttrs, (key) =>
                    return @aggregator(this, [], key)
            m = rowKey.length-1
            n = colKey.length-1            
            if m < 0 or n < 0
                return
            for i in [0..m]
                fRowKey = rowKey.slice(0, i+1)
                flatRowKey = fRowKey.join(String.fromCharCode(0))
                if not @tree[flatRowKey]
                    @tree[flatRowKey] = {}
                for j in [0..n]
                    fColKey = colKey.slice(0, j+1)
                    flatColKey = fColKey.join(String.fromCharCode(0))
                    if not @tree[flatRowKey][flatColKey]
                        @tree[flatRowKey][flatColKey] = @aggregator(this, fRowKey, fColKey)
                    @tree[flatRowKey][flatColKey].push record

    $.pivotUtilities.SubtotalPivotData = SubtotalPivotData
