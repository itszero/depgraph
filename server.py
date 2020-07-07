#!/usr/bin/env python
import os
from bottle import route, request, static_file, run
import stanza

@route('/')
def serve_root():
  return static_file('index.html', root='./public')

def map_sentence(sentence):
  words = [
    {
      'text': word.text,
      'upos': word.upos,
      'deprel': word.deprel,
      'id': int(word.id) - 1,
      'to': word.head - 1,
    } for word in sentence.words
  ]

  return words

@route('/query', method="POST")
def query():
  lang = request.forms.getunicode('lang')
  q = request.forms.getunicode('q')[0:500]
  nlp = stanza.Pipeline(lang=lang, dir='./stanza_resources', processors='tokenize,mwt,pos,lemma,depparse', use_gpu=False)
  doc = nlp(q)

  return {'result': [map_sentence(sentence) for sentence in doc.sentences]}

@route('/<filename:path>')
def serve_static(filename):
    return static_file(filename, root='./public')

run(host='0', port=os.getenv('PORT') or 8080)
