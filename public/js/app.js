const START_X = 30
const SPACE = 30
const LINE_SHIFT = 10
const LINE_SPACE = 20

class DepGraph {
  constructor() {
    $('#btn_parse').click((e) => {
      $('#img_holder').empty()
      $('#btn_parse').text('Working...')
      $('#btn_parse').attr('disabled', true)
      $.post('/query', {
        lang: $('#sel_lang').val(),
        q: $('#txt_sentence').val()
      }, ({
        result
      }) => {
        const imgsrcs = this.draw(result)
        imgsrcs.forEach(src => {
          $('<img/>').attr('src', src).appendTo('#img_holder')
        })
        $('#btn_parse').text('Parse')
        $('#btn_parse').attr('disabled', false)
      })

      e.preventDefault()
    })
  }

  draw(sentences) {
    const canvas = $('#graph')[0]
    const ctx = canvas.getContext('2d')
    this._measureWidth(ctx, sentences)
    this._measureDependencyLines(ctx, sentences)

    return sentences.map(sentence => this._drawSentence(canvas, ctx, sentence))
  }

  _measureWidth(ctx, sentences) {
    for (let sentence of sentences) {
      for (let word of sentence) {
        ctx.font = "16pt Helvetica"
        const widthText = ctx.measureText(word.text).width
        ctx.font = "10pt Helvetica"
        const widthUpos = ctx.measureText(word.upos).width
        word.draw_width = Math.max(widthText, widthUpos)
      }
    }
  }

  _measureDependencyLines(ctx, sentences) {
    for (let sentence of sentences) {
      const word_count = []
      sentence.forEach(() => {
        word_count.push(0)
      })
      const word_used_height = []
      sentence.forEach(() => {
        word_used_height.push({})
      })

      for (let word of sentence) {
        if (word.deprel === 'root') {
          continue
        }

        const wfc = word.draw_arrow_count || 0
        const wtc = sentence[word.to].draw_arrow_count || 0
        word.draw_arrow_count = (word.draw_arrow_count || 0) + 1
        sentence[word.to].draw_arrow_count = (sentence[word.to].draw_arrow_count || 0) + 1
        word.draw_line_from_x = wfc * LINE_SHIFT
        word.draw_line_to_x = wtc * LINE_SHIFT

        if (wfc * LINE_SHIFT > word.draw_width) {
          word.draw_width = wfc * LINE_SHIFT
        }
        if (wtc * LINE_SHIFT > sentence[word.to].draw_width) {
          sentence[word.to].draw_width = wtc * LINE_SHIFT
        }

        word.draw_line_height_unit = this._getUnusedHeight(word.id, word.to, word_used_height)
      }
    }
  }

  _drawSentence(canvas, ctx, sentence) {
    this._calcDrawX(sentence)

    const lastWord = sentence[sentence.length - 1]
    const maxHeightUnit = sentence.reduce((h, word) => Math.max(h, word.draw_line_height_unit || 0), 0)
    canvas.width = lastWord.draw_x + lastWord.draw_width + SPACE
    canvas.height = SPACE + (maxHeightUnit + 1) * LINE_SPACE + 5 + 16 + 30 + 10 + SPACE
    ctx.fillStyle = 'white'
    ctx.fillRect(0, 0, canvas.width, canvas.height)

    this._drawWords(ctx, sentence)
    this._drawTags(ctx, sentence)
    this._drawDependencies(ctx, sentence)

    return canvas.toDataURL('image/png')
  }

  _calcDrawX(sentence) {
    let x = START_X
    sentence.forEach(word => {
      word.draw_x = x
      x += word.draw_width + SPACE
    })
  }

  _drawWords(ctx, sentence) {
    ctx.font = '16pt Helvetica'
    ctx.fillStyle = 'black'

    sentence.forEach(word => {
      ctx.fillText(word.text, word.draw_x, ctx.canvas.height - SPACE - 10 - 20)
    })
  }

  _drawTags(ctx, sentence) {
    ctx.font = '10pt Helvetica'
    ctx.fillStyle = '#777'

    sentence.forEach(word => {
      ctx.fillText(word.upos, word.draw_x, ctx.canvas.height - SPACE)
    })
  }

  _drawDependencies(ctx, sentence) {
    ctx.font = "12pt Helvetica"
    ctx.fillStyle = "blue"

    const y = ctx.canvas.height - SPACE - 10 - 20 - 20
    ctx.lineWidth = 1
    for (let word of sentence) {
      if (word.deprel === 'root') {
        continue
      }

      const from_x = word.draw_line_from_x + word.draw_x + LINE_SHIFT
      const to_x = word.draw_line_to_x + sentence[word.to].draw_x + LINE_SHIFT

      ctx.beginPath()
      ctx.moveTo(from_x, y)
      ctx.lineTo(from_x, y - (word.draw_line_height_unit + 1) * LINE_SPACE)
      ctx.lineTo(to_x, y - (word.draw_line_height_unit + 1) * LINE_SPACE)
      ctx.lineTo(to_x, y)
      ctx.stroke()
      ctx.beginPath()
      ctx.lineTo(to_x - 4, y - 8)
      ctx.lineTo(to_x + 4, y - 8)
      ctx.lineTo(to_x, y)
      ctx.fillStyle = "black"
      ctx.fill()
      ctx.fillStyle = "blue"

      if (word.to > word.id) {
        ctx.fillText(word.deprel, from_x, y - (word.draw_line_height_unit + 1) * LINE_SPACE - 5)
      } else {
        const m = ctx.measureText(word.deprel)
        ctx.fillText(word.deprel, from_x - m.width, y - (word.draw_line_height_unit + 1) * LINE_SPACE - 5)
      }
    }
  }

  _getUnusedHeight(from, to, word_used_height) {
    const i_from = Math.min(from, to)
    const i_to = Math.max(from, to)

    let h = 0
    for (let i = i_from; i <= i_to; i++) {
      if (word_used_height[i][h]) {
        h++
        i = i_from
      }
    }

    for (let i = i_from; i <= i_to; i++) {
      word_used_height[i][h] = true
    }

    return h
  }
}

$(() => {
  new DepGraph()
})