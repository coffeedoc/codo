(function() {
  var Doc, Node, marked, _,
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  Node = require('./node');

  marked = require('marked');

  _ = require('underscore');

  _.str = require('underscore.string');

  module.exports = Doc = (function(_super) {

    __extends(Doc, _super);

    function Doc(node, options) {
      var abstract, author, code, comment, concern, copyright, deprecated, example, extend, include, line, lines, mixin, note, option, param, returnValue, see, since, text, title, todo, version, _base, _name, _ref;
      this.node = node;
      this.options = options;
      try {
        if (this.node) {
          comment = [];
          lines = this.node.comment.split('\n');
          while ((line = lines.shift()) !== void 0) {
            if (!/^@example/.exec(line)) {
              while (/^\s{2}\w+/.test(lines[0])) {
                line += lines.shift().substring(1);
              }
            }
            if (returnValue = /^@return\s+\[(.+?)\](?:\s+(.+))?/i.exec(line)) {
              this.returnValue = {
                type: returnValue[1],
                desc: returnValue[2]
              };
            } else if (param = /^@param\s+\(see ((?:[$A-Za-z_\x7f-\uffff][$.\w\x7f-\uffff]*)?[#.][$A-Za-z_\x7f-\uffff][$\w\x7f-\uffff]*)\)/i.exec(line)) {
              this.params || (this.params = []);
              this.params.push({
                reference: param[1]
              });
            } else if (param = /^@param\s+([$A-Za-z_\x7f-\uffff][$.\w\x7f-\uffff]*)\s+\(see ((?:[$A-Za-z_\x7f-\uffff][$.\w\x7f-\uffff]*)?[#.][$A-Za-z_\x7f-\uffff][$\w\x7f-\uffff]*)\)/i.exec(line)) {
              this.params || (this.params = []);
              this.params.push({
                name: param[1],
                reference: param[2]
              });
            } else if (param = /^@param\s+([^ ]+)\s+\[(.+?)\](?:\s+(.+))?/i.exec(line)) {
              this.params || (this.params = []);
              this.params.push({
                type: param[2],
                name: param[1],
                desc: param[3] || ''
              });
            } else if (param = /^@param\s+\[(.+?)\]\s+([^ ]+)(?:\s+(.+))?/i.exec(line)) {
              this.params || (this.params = []);
              this.params.push({
                type: param[1],
                name: param[2],
                desc: param[3] || ''
              });
            } else if (option = /^@option\s+([^ ]+)\s+\[(.+?)\]\s+([^ ]+)(?:\s+(.+))?/i.exec(line)) {
              this.paramsOptions || (this.paramsOptions = {});
              (_base = this.paramsOptions)[_name = option[1]] || (_base[_name] = []);
              this.paramsOptions[option[1]].push({
                type: option[2],
                name: option[3],
                desc: option[4] || ''
              });
            } else if (see = /^@see\s+([^\s]+)(?:\s+(.+))?/i.exec(line)) {
              this.see || (this.see = []);
              this.see.push({
                reference: see[1],
                label: see[2]
              });
            } else if (author = /^@author\s+(.+)/i.exec(line)) {
              this.authors || (this.authors = []);
              this.authors.push(author[1]);
            } else if (copyright = /^@copyright\s+(.+)/i.exec(line)) {
              this.copyright = copyright[1];
            } else if (note = /^@note\s+(.+)/i.exec(line)) {
              this.notes || (this.notes = []);
              this.notes.push(note[1]);
            } else if (todo = /^@todo\s+(.+)/i.exec(line)) {
              this.todos || (this.todos = []);
              this.todos.push(todo[1]);
            } else if (example = /^@example(?:\s+(.+))?/i.exec(line)) {
              title = example[1] || '';
              code = [];
              while (/^\s{2}.*/.test(lines[0])) {
                code.push(lines.shift().substring(2));
              }
              if (code.length !== 0) {
                this.examples || (this.examples = []);
                this.examples.push({
                  title: title,
                  code: code.join('\n')
                });
              }
            } else if (abstract = /^@abstract(?:\s+(.+))?/i.exec(line)) {
              this.abstract = abstract[1] || '';
            } else if (/^@private/.exec(line)) {
              this.private = true;
            } else if (since = /^@since\s+(.+)/i.exec(line)) {
              this.since = since[1];
            } else if (version = /^@version\s+(.+)/i.exec(line)) {
              this.version = version[1];
            } else if (deprecated = /^@deprecated\s+(.*)/i.exec(line)) {
              this.deprecated = deprecated[1];
            } else if (mixin = /^@mixin/i.exec(line)) {
              this.mixin = true;
            } else if (concern = /^@concern\s+(.+)/i.exec(line)) {
              this.concerns || (this.concerns = []);
              this.concerns.push(concern[1]);
            } else if (include = /^@include\s+(.+)/i.exec(line)) {
              this.includeMixins || (this.includeMixins = []);
              this.includeMixins.push(include[1]);
            } else if (extend = /^@extend\s+(.+)/i.exec(line)) {
              this.extendMixins || (this.extendMixins = []);
              this.extendMixins.push(extend[1]);
            } else {
              comment.push(line);
            }
          }
          text = comment.join('\n').replace(/\n+/g, "\n");
          this.summary = _.str.clean(((_ref = /((?:.|\n)*?\.[\s$])/.exec(text)) != null ? _ref[1] : void 0) || text);
          this.comment = marked(text).replace(/\n/g, '');
        }
      } catch (error) {
        if (this.options.verbose) {
          console.warn('Create doc error:', this.node, error);
        }
      }
    }

    Doc.prototype.toJSON = function() {
      var json;
      if (this.node) {
        json = {
          includes: this.includeMixins,
          "extends": this.extendMixins,
          concerns: this.concerns,
          abstract: this.abstract,
          private: this.private,
          deprecated: this.deprecated,
          version: this.version,
          since: this.since,
          examples: this.examples,
          todos: this.todos,
          notes: this.notes,
          authors: this.authors,
          copyright: this.copyright,
          comment: this.comment,
          summary: this.summary,
          params: this.params,
          options: this.paramsOptions,
          see: this.see,
          returnValue: this.returnValue
        };
        return json;
      }
    };

    return Doc;

  })(Node);

}).call(this);
