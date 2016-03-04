provider = require './provider'

module.exports =
  config:
    caseSensitiveCompletion:
      type: 'boolean'
      default: false
      title: 'Case Sensitive Completion (not yet implemented)'
      description: 'The completion is by default case insensitive.'
    useSnippets:
      type: 'string'
      default: 'none'
      enum: ['none', 'all', 'required']
      title: 'Autocomplete Function Parameters (not yet implemented)'
      description: 'Allows to complete functions with their arguments. Use completion key to jump between arguments. Will ignore some settings if used.'

  activate: -> provider.loadCompletions()

  deactivate: -> provider.dispose()

  getProvider: -> provider
