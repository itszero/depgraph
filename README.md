# DepGraph

This is a simple dependencies parsing visualizer using JavaScript canvas. It
depends on Stanford Parser for parsing, and visualize the sentence using
part-of-speech tags and parsing result. You could try it on
[http://depgraph.herokuapp.com/](http://depgraph.herokuapp.com/).

## Usage

You could input a sentence and let the program parse and visualize it for you.
Then you could find the parsing result in **manual** tab. You could modify it
as you see fit and hit the **Draw** button to update the graph. You may also
starts directly from **manual **tab by putting tags and dependencies parsing
result into respective textbox.

## License

Since Stanford Parser is released under GPL, I'm releasing this software using
GPL too.

## Credits

- [Stanford Parser](http://nlp.stanford.edu/software/lex-parser.shtml)
- Idea from [DependenSee](http://chaoticity.com/dependensee-a-dependency-parse-visualisation-tool/)
