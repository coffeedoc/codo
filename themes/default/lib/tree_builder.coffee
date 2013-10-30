module.exports = class TreeBuilder

  @build: (collection, resolver) ->
    (new @ collection, resolver).tree

  constructor: (@collection, @resolver) ->
    @tree = []

    for entry in @collection
      do (entry) =>
        storage      = @tree
        [name, path] = @resolver(entry)

        for segment in path
          storage = @situate(storage, segment)

        @situate(storage, name, entry)


  situate: (storage, name, entity) ->
    for entry in storage
      if entry.name == name
        entry.entity = entry.entity || entity
        return entry.children

    storage.push entry = 
      name:     name
      children: []
      entity:   entity

    entry.children