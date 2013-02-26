require './stanford-parser.jar'
java_import 'java.io.StringReader'
java_import 'edu.stanford.nlp.parser.lexparser.LexicalizedParser'
java_import 'edu.stanford.nlp.trees.PennTreebankLanguagePack'
java_import 'edu.stanford.nlp.trees.Tree'

require 'sinatra'
require 'json'
require 'sass'
require 'haml'
require 'coffee-script'

class NLP
  def initialize
    @parser = LexicalizedParser.loadModel()
    @ptlp = PennTreebankLanguagePack.new
    @gsf = @ptlp.grammaticalStructureFactory();
  end

  def parse(sentence)
    tokens = @ptlp.getTokenizerFactory().getTokenizer(StringReader.new(sentence))
    wordlist = tokens.tokenize()
    parseTree = @parser.apply(wordlist)
    tags = parseTree.taggedYield()

    gs = @gsf.newGrammaticalStructure(parseTree)
    tdl = gs.typedDependencies()

    [tags.join(" "), tdl.join("\n")]
  end
end

class DepGraphServer < Sinatra::Base
  def initialize
    super
    @nlp = NLP.new
  end

  get '/' do
    haml :index
  end

  get '/css/style.css' do
    scss :style
  end

  get '/js/app.js' do
    coffee :app
  end

  get '/query' do
    @nlp.parse(params[:q]).to_json
  end

  run! if __FILE__ == $0
end
