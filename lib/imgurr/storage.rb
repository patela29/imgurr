#
# Storage is the interface between multiple Backends. You can use Storage
# directly without having to worry about which Backend is in use.
#
module Imgurr
  class Storage
    JSON_FILE = "#{ENV['HOME']}/.imgurr"

    # Public: the path to the Json file used by imgurr.
    #
    # ENV['IMGURRFILE'] is mostly used for tests
    #
    # Returns the String path of imgurr's Json representation.
    def json_file
      ENV['IMGURRFILE'] || JSON_FILE
    end

    # Public: initializes a Storage instance by loading in your persisted data from adapter.
    #
    # Returns the Storage instance.
    def initialize
      @hashes = []
      bootstrap
      populate
    end

    # Public: the in-memory collection of all Lists attached to this Storage
    # instance.
    #
    # lists - an Array of individual List items
    #
    # Returns nothing.
    attr_writer :hashes

    # Public: tests whether a named List exists.
    #
    # name - the String name of a List
    #
    # Returns true if found, false if not.
    def hash_exists?(delete_hash)
      @hashes.detect { |hash| hash == delete_hash }
    end

    # Public: all Items in storage.
    #
    # Returns an Array of all Items.
    def items
      @hashes.collect(&:items).flatten
    end

    # Public: creates a Hash of the representation of the in-memory data
    # structure. This percolates down to Items by calling to_hash on the List,
    # which in tern calls to_hash on individual Items.
    #
    # Returns a Hash of the entire data set.
    def to_hash
      { :hashes => @hashes.collect(&:to_hash) }
    end

    # Takes care of bootstrapping the Json file, both in terms of creating the
    # file and in terms of creating a skeleton Json schema.
    #
    # Return true if successfully saved.
    def bootstrap
      return if File.exist?(json_file)
      FileUtils.touch json_file
      File.open(json_file, 'w') {|f| f.write(to_json) }
      save
    end

    # Take a JSON representation of data and explode it out into the constituent
    # Lists and Items for the given Storage instance.
    #
    # Returns nothing.
    def populate
      file = File.new(json_file, 'r')
      storage = JSON.parse(file)

      storage['hashes'].each do |hashes|
        hashes.each do |id, key|
          @hashes[id] = key
        end
      end
    end

    # Public: persists your in-memory objects to disk in Json format.
    #
    # lists_Json - list in Json format
    #
    # Returns true if successful, false if unsuccessful.
    def save
      File.open(json_file, 'w') {|f| f.write(to_json) }
    end

    # Public: the Json representation of the current List and Item assortment
    # attached to the Storage instance.
    #
    # Returns a String Json representation of its Lists and their Items.
    def to_json
      JSON.generate(to_hash)
    end
  end
end