fs = require 'fs'
path = require 'path'

trailingWhitespace = /\s$/
attributePattern = /\s+([a-zA-Z][-a-zA-Z]*)\s*=\s*$/
tagPattern = /<([a-zA-Z][-a-zA-Z]*)(?:\s|$)/

module.exports =
  selector: '.source.pml'
  disableForSelector: '.source.pml .comment'
  excludeLowerPriority: false

  getSuggestions: (request) ->
    if @notShowAutocomplete(request)
      []
    else @getCompletions(request)

  onDidInsertSuggestion: ({editor, suggestion}) ->
    setTimeout(@triggerAutocomplete.bind(this, editor), 1) if suggestion.type is 'attribute'

  triggerAutocomplete: (editor) ->
    atom.commands.dispatch(atom.views.getView(editor), 'autocomplete-plus:activate', activatedManually: false)

  # Load Completions from json
  loadCompletions: ->
    @completions = {}
    fs.readFile path.resolve(__dirname, '..', 'completions.json'), (error, content) =>
      @completions = JSON.parse(content) unless error?
      return
    @functions = {}
    fs.readFile path.resolve(__dirname, '..', 'functions.json'), (error, content) =>
      @functions = JSON.parse(content) unless error?
      return

  # (optional): called _after_ the suggestion `replacementPrefix` is replaced
  # by the suggestion `text` in the buffer
  onDidInsertSuggestion: ({editor, triggerPosition, suggestion}) ->

  # (optional): called when your provider needs to be cleaned up. Unsubscribe
  # from things, kill any processes, etc.
  dispose: ->

  notShowAutocomplete: (request) ->
    return true if request.prefix is ''
    scopes = request.scopeDescriptor.getScopesArray()
    return true if scopes.indexOf('keyword.operator.assignment.pml') isnt -1 or
      scopes.indexOf('variable.other.property.pml') isnt -1 or
      scopes.indexOf('constant.numeric.integer.long.decimal.pml') isnt -1 or
      scopes.indexOf('constant.numeric.integer.decimal.pml') isnt -1 or
      scopes.indexOf('punctuation.parens.pml') isnt -1

  getCompletions: ({editor, prefix}) ->
    completions = []
    lowerCasePrefix = prefix.toLowerCase()
    for key in @completions.keywords when key.text.toLowerCase().indexOf(lowerCasePrefix) is 0
      completions.push(@buildCompletion(key))
    for func in @functions.functions when func.text.toLowerCase().indexOf(lowerCasePrefix) is 0
      completions.push(@buildCompletion(func))
    completions

  buildCompletion: (suggestion) ->
    text: suggestion.text
    snippet: suggestion.snippet ?= null
    displayText: suggestion.displayText ?= null
    type: suggestion.type
    leftLabel: suggestion.leftLabel ?= null
    rightLabel: suggestion.rightLabel ?= null
    description: suggestion.description ?= "PML <#{suggestion.text}> #{suggestion.type}"
    descriptionMoreURL: suggestion.descriptionMoreURL ?= null
