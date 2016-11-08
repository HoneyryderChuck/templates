# Pipe to Enumerator

## Why?

Running system commands and parse them in ruby is fairly easy, but memory-wise also easy to shoot yourself in teh foot. 

Don't eager load outputs. 

## How?

```ruby
lines = Enumerator.new do |y|
  IO.popen(COMMAND) do |io|
    io.each_line do |line|
      line.chomp!
      y << line
    end
  end
end.lazy

# why lazy? because you will apply other filters, and you better filter stuff out asap
```
