(function() {
  var Doc, ghm;

  ghm = require('github-flavored-markdown');

  module.exports = Doc = (function() {

    function Doc(node) {
      var abstract, author, code, comment, deprecated, example, line, lines, note, option, param, returnValue, see, since, title, todo, version;
      this.node = node;
      if (this.node) {
        comment = [];
        lines = this.node.comment.split('\n');
        while ((line = lines.shift()) !== void 0) {
          if (!/^@example/.exec(line)) {
            while (/^  \w+/.test(lines[0])) {
              line += lines.shift().substring(1);
            }
          }
          if (returnValue = /^@return\s+\[(.*?)\]\s+(.*)/.exec(line)) {
            this.returnValue = {
              type: returnValue[1],
              desc: returnValue[2]
            };
          } else if (param = /^@param\s+\[(.*?)\]\s+([^ ]*)\s+(.*)/.exec(line)) {
            this.params || (this.params = []);
            this.params.push({
              type: param[1],
              name: param[2],
              desc: param[3]
            });
          } else if (option = /^@option\s+([^ ]*)\s+\[(.*?)\]\s+([^ ]*)\s+(.*)/.exec(line)) {
            this.options || (this.options = []);
            this.options.push({
              param: option[1],
              type: option[2],
              name: option[3],
              desc: option[4]
            });
          } else if (see = /^@see\s+(.*)/.exec(line)) {
            this.see || (this.see = []);
            this.see.push(see[1]);
          } else if (author = /^@author\s+(.*)/.exec(line)) {
            this.authors || (this.authors = []);
            this.authors.push(author[1]);
          } else if (note = /^@note\s+(.*)/.exec(line)) {
            this.notes || (this.notes = []);
            this.notes.push(note[1]);
          } else if (todo = /^@todo\s+(.*)/.exec(line)) {
            this.todos || (this.todos = []);
            this.todos.push(todo[1]);
          } else if (example = /^@example\s+(.*)/.exec(line)) {
            title = example[1];
            code = [];
            while (/^  \w+/.test(lines[0])) {
              code.push(lines.shift().substring(2));
            }
            if (code.length !== 0) {
              this.examples || (this.examples = []);
              this.examples.push({
                title: title,
                code: code.join('\n')
              });
            }
          } else if (abstract = /^@abstract\s+(.*)/.exec(line)) {
            this.abstract = abstract[1];
          } else if (/^@private/.exec(line)) {
            this.private = true;
          } else if (since = /^@since\s+(.*)/.exec(line)) {
            this.since = since[1];
          } else if (version = /^@version\s+(.*)/.exec(line)) {
            this.version = version[1];
          } else if (deprecated = /^@deprecated\s+(.*)/.exec(line)) {
            this.deprecated = deprecated[1];
          } else {
            comment.push(line);
          }
        }
        this.comment = ghm.parse(comment.join('\n'), 'netzpirat/codo');
      }
    }

    Doc.prototype.toJSON = function() {
      var json;
      if (this.node) {
        json = {
          abstract: this.abstract,
          private: this.private,
          deprecated: this.deprecated,
          version: this.version,
          since: this.since,
          examples: this.examples,
          todos: this.todos,
          notes: this.notes,
          authors: this.authors,
          comment: this.comment,
          params: this.params,
          options: this.options,
          see: this.see,
          returnValue: this.returnValue
        };
        return json;
      }
    };

    return Doc;

  })();

}).call(this);
