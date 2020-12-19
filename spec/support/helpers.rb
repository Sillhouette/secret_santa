module Helpers
    def generate_cli(*inputs)
        input = StringIO.new(inputs.join("\n") + "\n")
        output = StringIO.new

        Cli.new(input: input, output: output)
    end
end
