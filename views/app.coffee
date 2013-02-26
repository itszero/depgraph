class DepGraph
  constructor: ->
    @space = 30
    @line_shift = 5
    @line_space = 20
    @y = 260
    $('#btn_parse').click =>
      $('#btn_parse').text("Working...")
      $.getJSON '/query', {'q': $('#txt_sentence').val()}, (d) =>
          [@words_raw, @deps_raw] = d
          @draw()
          $('#btn_parse').text("Parse")
      return false
    $('#btn_draw').click =>
      [@words_raw, @deps_raw] = [$('#txt_tags').val(), $('#txt_deps').val()]
      return false
      @draw()

  draw: ->
    @_readWords()
    @_readDependencies()
    cv = $('#graph')[0]
    ctx = cv.getContext('2d')
    @_measureWidth(ctx)
    cv.width = @word_pos[@word_pos.length - 1] + @space
    ctx = cv.getContext('2d')
    ctx.fillStyle = 'white'
    ctx.fillRect(0, 0, cv.width, cv.height)
    @_drawWords(ctx)
    @_drawTags(ctx)
    @_drawDependencies(ctx)
    $('#img_holder img')[0].src = cv.toDataURL("image/png")

  _measureWidth: (ctx) ->
    @word_pos = []
    x = @space
    ctx.font = "16pt Helvetica"
    ctx.fillStyle = "black"
    for word in @words
      @word_pos.push(x)
      m = ctx.measureText(word[0])
      x += m.width + @space

  _drawWords: (ctx) ->
    y = @y
    i = 0
    ctx.font = "16pt Helvetica"
    ctx.fillStyle = "black"
    for word in @words
      x = @word_pos[i]
      i++
      ctx.fillText(word[0], x, y)

  _drawTags: (ctx) ->
    y = @y
    i = 0
    ctx.font = "10pt Helvetica"
    ctx.fillStyle = "#777"
    for word in @words
      x = @word_pos[i]
      i++
      ctx.fillText(word[1], x, y + 20)

  _drawDependencies: (ctx) ->
    @word_count = []
    for @word in @words
      @word_count.push(0)
    @word_used_height = []
    for @word in @words
      @word_used_height.push([])

    ctx.font = "12pt Helvetica"
    ctx.fillStyle = "blue"

    y = @y - 20
    ctx.lineWidth = "1"
    for [dep, from, to] in @deps
      continue if dep == 'root'
      wfx = @word_pos[from[1]] + @line_shift
      wfc = @word_count[from[1]]
      wtx = @word_pos[to[1]] + @line_shift
      wtc = @word_count[to[1]]
      @word_count[from[1]]++
      @word_count[to[1]]++
      wc = @_getUnusedHeight(Math.max(wfc, wtc), from[1], to[1])

      ctx.beginPath()
      ctx.moveTo(wfx + (wfc * @line_shift), y)
      ctx.lineTo(wfx + (wfc * @line_shift), y - (wc + 1) * @line_space)
      ctx.lineTo(wtx + (wtc * @line_shift), y - (wc + 1) * @line_space)
      ctx.lineTo(wtx + (wtc * @line_shift), y)
      ctx.lineTo(wtx + (wtc * @line_shift) - 2, y - 4)
      ctx.lineTo(wtx + (wtc * @line_shift) + 2, y - 4)
      ctx.lineTo(wtx + (wtc * @line_shift), y)
      ctx.stroke()

      if (to[1] > from[1])
        ctx.fillText(dep, wfx + (wfc * @line_shift), y - (wc + 1) * @line_space - 5)
      else
        m = ctx.measureText(dep)
        ctx.fillText(dep, wfx + (wfc * @line_shift) - m.width, y - (wc + 1) * @line_space - 5)

  _getUnusedHeight: (h, f, t) ->
    while true
      for i in [f..t]
        if h in @word_used_height[i]
          h++
          continue
      break

    for i in [f..t]
      @word_used_height[i].push(h)
    return h


  _readWords: ->
    @words = []
    tags = @words_raw.split(" ")
    for tag_set in tags
      [word, tag] = tag_set.split("/")
      @words.push([word, tag])

  _readDependencies: ->
    @deps = []
    deps = @deps_raw.split("\n")
    re = /(\w+)\((.+)-(\d+), (.+)-(\d+)\)/
    for dep_set in deps
      [_, type, from_word, from_pos, to_word, to_pos] = dep_set.match(re)
      @deps.push([type, [from_word, parseInt(from_pos) - 1], [to_word, parseInt(to_pos) - 1]])

jQuery ->
  window.depGraph = new DepGraph
