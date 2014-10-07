$ = jQuery


###
Pivot Table UI: calls Pivot Table core above with options set by user
###

$.fn.pivotUI = (input, inputOpts, overwrite = false, locale="en") ->
  defaults =
    derivedAttributes: {}
    aggregators: $.pivotUtilities.locales[locale].aggregators
    renderers: $.pivotUtilities.locales[locale].renderers
    attributes: []
    values: []
    hiddenAttributes: []
    menuLimit: 200
    cols: [], rows: [], vals: []
    exclusions: {}
    unusedAttrsVertical: "auto"
    autoSortUnusedAttrs: false
    rendererOptions: localeStrings: $.pivotUtilities.locales[locale].localeStrings
    onRefresh: null
    filter: -> true
    localeStrings: $.pivotUtilities.locales[locale].localeStrings

  existingOpts = @data "pivotUIOptions"
  if not existingOpts? or overwrite
    opts = $.extend defaults, inputOpts
  else
    opts = existingOpts

  try
    #cache the input in some useful form
    input = PivotData.convertToArray(input)
    tblCols = (k for own k of input[0])
    tblCols.push c for own c of opts.derivedAttributes when (c not in tblCols)

    #figure out the cardinality and some stats
    axisValues = {}
    axisValues[x] = {} for x in tblCols

    PivotData.forEachRecord input, opts.derivedAttributes, (record) ->
      for own k, v of record when opts.filter(record)
        v ?= "null"
        axisValues[k][v] ?= 0
        axisValues[k][v]++

    #start building the output
    uiTable = $("<table cellpadding='5'>")

    #renderer control
    rendererControl = $("<td>")

    renderer = $("<select class='pvtRenderer'>")
      .appendTo(rendererControl)
      .bind "change", -> refresh() #capture reference
    for own x of opts.renderers
      $("<option>").val(x).html(x).appendTo(renderer)


    #axis list, including the double-click menu
    colList = $("<td class='pvtAxisContainer pvtUnused'>")
    if opts.attributes.length > 0
      shownAttributes = (c for c in tblCols when c in opts.attributes)
    else
      shownAttributes = (c for c in tblCols when c not in opts.hiddenAttributes and c not in opts.values)

    shownValues = if opts.values.length > 0 then (d for d in tblCols when d in opts.values) else shownAttributes

    unusedAttrsVerticalAutoOverride = false
    if opts.unusedAttrsVertical == "auto"
      attrLength = 0
      attrLength += a.length for a in shownAttributes
      unusedAttrsVerticalAutoOverride = attrLength > 120

    if opts.unusedAttrsVertical == true or unusedAttrsVerticalAutoOverride
      colList.addClass('pvtVertList')
    else
      colList.addClass('pvtHorizList')

    for i, c of shownAttributes
      do (c) ->
        keys = (k for k of axisValues[c])
        hasExcludedItem = false
        valueList = $("<div>").addClass('pvtFilterBox').hide()

        valueList.append $("<h4>").text("#{c} (#{keys.length})")
        if keys.length > opts.menuLimit
          valueList.append $("<p>").html(opts.localeStrings.tooMany)
        else
          btns = $("<p>").appendTo(valueList)
          btns.append $("<button>").html(opts.localeStrings.selectAll).bind "click", ->
            valueList.find("input").prop "checked", true
          btns.append $("<button>").html(opts.localeStrings.selectNone).bind "click", ->
            valueList.find("input").prop "checked", false
          btns.append $("<input>").addClass("pvtSearch").attr("placeholder", opts.localeStrings.filterResults).bind "keyup", ->
            filter = $(this).val().toLowerCase()
            $(this).parents(".pvtFilterBox").find('label span').each ->
              testString = this.innerText.toLowerCase().indexOf(filter)
              if testString isnt -1
                $(this).parent().show()
              else
                $(this).parent().hide()

          checkContainer = $("<div>").addClass("pvtCheckContainer").appendTo(valueList)

          for k in keys.sort(naturalSort)
             v = axisValues[c][k]
             filterItem = $("<label>")
             filterItemExcluded = if opts.exclusions[c] then (k in opts.exclusions[c]) else false
             hasExcludedItem ||= filterItemExcluded
             $("<input type='checkbox' class='pvtFilter'>")
              .attr("checked", !filterItemExcluded).data("filter", [c,k])
              .appendTo filterItem
             filterItem.append $("<span>").text "#{k} (#{v})"
             checkContainer.append $("<p>").append(filterItem)

        updateFilter = ->
          unselectedCount = $(valueList).find("[type='checkbox']").length -
                    $(valueList).find("[type='checkbox']:checked").length
          if unselectedCount > 0
            attrElem.addClass "pvtFilteredAttribute"
          else
            attrElem.removeClass "pvtFilteredAttribute"
          if keys.length > opts.menuLimit
            valueList.toggle()
          else
            valueList.toggle(0, refresh)

        $("<p>").appendTo(valueList)
          .append $("<button>").text("OK").bind "click", updateFilter

        showFilterList = (e) ->
          valueList.css(left: e.pageX, top: e.pageY).toggle()
          $('.pvtSearch').val('')
          $('label').show()

        triangleLink = $("<span class='pvtTriangle'>").html(" &#x25BE;")
          .bind "click", showFilterList

        attrElem = $("<li class='axis_#{i}'>")
          .append $("<span class='pvtAttr'>").text(c).data("attrName", c).append(triangleLink)
        attrElem.addClass('pvtFilteredAttribute') if hasExcludedItem
        colList.append(attrElem).append(valueList)

        attrElem.bind "dblclick", showFilterList

    tr1 = $("<tr>").appendTo(uiTable)

    #aggregator menu and value area

    aggregator = $("<select class='pvtAggregator'>")
      .bind "change", -> refresh() #capture reference
    for own x of opts.aggregators
      aggregator.append $("<option>").val(x).html(x)

    $("<td class='pvtVals'>")
      .appendTo(tr1)
      .append(aggregator)
      .append($("<br>"))

    #column axes
    $("<td class='pvtAxisContainer pvtHorizList pvtCols'>").appendTo(tr1)

    tr2 = $("<tr>").appendTo(uiTable)

    #row axes
    tr2.append $("<td valign='top' class='pvtAxisContainer pvtRows'>")

    #the actual pivot table container
    pivotTable = $("<td valign='top' class='pvtRendererArea'>").appendTo(tr2)

    #finally the renderer dropdown and unused attribs are inserted at the requested location
    if opts.unusedAttrsVertical == true or unusedAttrsVerticalAutoOverride
      uiTable.find('tr:nth-child(1)').prepend rendererControl
      uiTable.find('tr:nth-child(2)').prepend colList
    else
      uiTable.prepend $("<tr>").append(rendererControl).append(colList)

    #render the UI in its default state
    @html uiTable

    #set up the UI initial state as requested by moving elements around

    for x in opts.cols
      @find(".pvtCols").append @find(".axis_#{shownAttributes.indexOf(x)}")
    for x in opts.rows
      @find(".pvtRows").append @find(".axis_#{shownAttributes.indexOf(x)}")
    if opts.aggregatorName?
      @find(".pvtAggregator").val opts.aggregatorName
    if opts.rendererName?
      @find(".pvtRenderer").val opts.rendererName

    initialRender = true

    #set up for refreshing
    refreshDelayed = =>
      subopts =
        derivedAttributes: opts.derivedAttributes
        localeStrings: opts.localeStrings
        rendererOptions: opts.rendererOptions
        cols: [], rows: []

      numInputsToProcess = opts.aggregators[aggregator.val()]([])().numInputs ? 0
      vals = []
      @find(".pvtRows li span.pvtAttr").each -> subopts.rows.push $(this).data("attrName")
      @find(".pvtCols li span.pvtAttr").each -> subopts.cols.push $(this).data("attrName")
      @find(".pvtVals select.pvtAttrDropdown").each ->
        if numInputsToProcess == 0
          $(this).remove()
        else
          numInputsToProcess--
          vals.push $(this).val() if $(this).val() != ""

      if numInputsToProcess != 0
        pvtVals = @find(".pvtVals")
        for x in [0...numInputsToProcess]
          newDropdown = $("<select class='pvtAttrDropdown'>")
            .append($("<option>"))
            .bind "change", -> refresh()
          for attr in shownValues
            newDropdown.append($("<option>").val(attr).text(attr))
          pvtVals.append(newDropdown)

      if initialRender
        vals = opts.vals
        i = 0
        @find(".pvtVals select.pvtAttrDropdown").each ->
          $(this).val vals[i]
          i++
        initialRender = false

      subopts.aggregatorName = aggregator.val()
      subopts.vals = vals
      subopts.aggregator = opts.aggregators[aggregator.val()](vals)
      subopts.renderer = opts.renderers[renderer.val()]

      #construct filter here
      exclusions = {}
      @find('input.pvtFilter').not(':checked').each ->
        filter = $(this).data("filter")
        if exclusions[filter[0]]?
          exclusions[filter[0]].push( filter[1] )
        else
          exclusions[filter[0]] = [ filter[1] ]

      subopts.filter = (record) ->
        return false if not opts.filter(record)
        for k,excludedItems of exclusions
          return false if ""+record[k] in excludedItems
        return true

      pivotTable.pivot(input,subopts)
      pivotUIOptions = $.extend opts,
        cols: subopts.cols
        rows: subopts.rows
        vals: vals
        exclusions: exclusions
        aggregatorName: aggregator.val()
        rendererName: renderer.val()

      @data "pivotUIOptions", pivotUIOptions

      # if requested make sure unused columns are in alphabetical order
      if opts.autoSortUnusedAttrs
        natSort = $.pivotUtilities.naturalSort
        unusedAttrsContainer = @find("td.pvtUnused.pvtAxisContainer")
        $(unusedAttrsContainer).children("li")
          .sort((a, b) => natSort($(a).text(), $(b).text()))
          .appendTo unusedAttrsContainer

      pivotTable.css("opacity", 1)
      opts.onRefresh(pivotUIOptions) if opts.onRefresh?

    refresh = =>
      pivotTable.css("opacity", 0.5)
      setTimeout refreshDelayed, 10

    #the very first refresh will actually display the table
    refresh()

    # expose the refresh method for externally tiggered re-renders
    @data "refresh", refresh

    @find(".pvtAxisContainer").sortable
        update: (e, ui) -> refresh() if not ui.sender?
        connectWith: @find(".pvtAxisContainer")
        items: 'li'
        placeholder: 'pvtPlaceholder'
  catch e
    console.error(e.stack) if console?
    @html opts.localeStrings.uiRenderError
  return this
