require 'person'

describe Person do

    before(:each) do
        Person.clear
    end

    describe '#initialize' do
        it 'requires a name' do
            expect { Person.new() }.to raise_error ArgumentError
        end

        it 'creates a new person with a name' do
            name = 'Hannah'

            person = Person.new(name: name)

            expect(person.name).to eq name
        end

        it 'creates a new person with a name and spouse' do
            name = 'Garth'
            spouse = 'Jessica'

            person = Person.new(name: name, spouse: spouse)

            expect(person.name).to eq name
            expect(person.spouse.name).to eq spouse
            expect(person.spouse.spouse).to eq person
        end
    end

    describe '#save' do
        it 'saves a person to the @@all array' do
            person = Person.new(name: 'Dan')

            person.save
            result = Person.all.first

            expect(result).to eq person
        end
    end

    describe '#spouse=' do
        describe 'when given a name' do
            it 'creates a new person with that name' do
                person = Person.new(name: 'Garth')
                spouse = 'Jessica'

                person.spouse = spouse
                result = person.spouse

                expect(result).to be_a Person
                expect(result.name).to eq spouse
            end

            it 'sets the other person\'s spouse to itself' do
                person = Person.new(name: 'Garth')
                spouse = 'Jessica'

                person.spouse = spouse
                result = person.spouse

                expect(result.spouse).to be person
            end
        end
    end

    describe '.clear' do
        describe 'when a person is created' do
            it 'clears the @@all array' do
                Person.new(name: 'Hannah')

                Person.clear
                result = Person.all

                expect(result).to eq []
            end
        end

        describe 'when multiple people are created' do
            it 'clears the @@all array' do
                Person.new(name: 'Hannah')
                Person.new(name: 'Garth')
                Person.new(name: 'Dan')

                Person.clear
                result = Person.all

                expect(result).to eq []
            end
        end
    end

    describe '.all' do
        describe 'when a person is created' do
            it 'returns an array with only that person' do
                person = Person.create(name: 'Hannah')

                result = Person.all

                expect(result).to eq [person]
            end
        end

        describe 'when multiple people are created' do
            it 'returns an array with all of those people' do
                person_1 = Person.create(name: 'Hannah')
                person_2 = Person.create(name: 'Garth')
                person_3 = Person.create(name: 'Dan')

                result = Person.all

                expect(result).to eq [person_1, person_2, person_3]
            end
        end
    end

    describe '.find_by_name' do
        describe 'when given the name of a person that exists' do
            it 'returns that person' do
                person_1 = Person.create(name: 'Garth')
                person_2 = Person.create(name: 'Hannah')

                result = Person.find_by_name(name: 'Hannah')

                expect(result).to eq person_2
            end
        end
    end

    describe '.create' do
        describe 'when given the name of a person' do
            it 'creates the person and saves them' do
                person = Person.create(name: 'Garth')

                result = Person.all.first

                expect(result).to eq person
                expect(Person.all.length).to eq 1
            end
        end

        describe 'when multiple people are created' do
            it 'creates and saves all of them' do
                person_1 = Person.create(name: 'Garth')
                person_2 = Person.create(name: 'Dan')
                person_3 = Person.create(name: 'Hannah')

                result = Person.all

                expect(result).to eq [person_1, person_2, person_3]
                expect(Person.all.length).to eq 3
            end
        end
    end

    describe '.find_or_create' do
        describe 'when given the name of a person that doesnt exist' do
            it 'creates that person' do
                name = 'Garth'

                result = Person.find_or_create(name: name)

                expect(result.name).to eq name
            end
        end

        describe 'when given the name of a person that exists' do
            it 'returns that person' do
                name = 'Garth'
                person = Person.create(name: name)

                result = Person.find_or_create(name: name)

                expect(result).to eq person
            end

            it 'doesnt duplicate that person' do
                name = 'Garth'
                person = Person.create(name: name)

                result = Person.find_or_create(name: name)

                expect(Person.all.length).to eq 1
            end
        end
    end
end