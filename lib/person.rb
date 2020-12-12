class Person
    attr_accessor :name
    attr_reader :spouse

    @@all = []

    def initialize(name:, spouse: nil)
        @name = name
        self.spouse = spouse
    end

    def save
        @@all << self
    end

    def spouse=(spouse)
        if spouse.is_a?(String)
            @spouse = Person.find_or_create(name: spouse)
            @spouse.spouse = self
        else
            @spouse = spouse
        end
    end

    def self.all
        @@all
    end

    def self.clear
        @@all = []
    end

    def self.find_by_name(name:)
        @@all.find { |person| person.name == name }
    end

    def self.create(name:)
        person = self.new(name: name)
        person.save
        person
    end

    def self.find_or_create(name:)
        self.find_by_name(name: name) || self.create(name: name)
    end
end