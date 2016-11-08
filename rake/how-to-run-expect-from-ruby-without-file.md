# Run expect from Ruby stdin

## Why?

This is an handy feature for dynamic ssh login based on some logic. 

Expect usually waits a file, but also eats IO. Problem is, ruby achieves this by exec, and can't pass streams safely. 

The solution is not to exec, instead create a subprocess, and buffer all streams in separate threads.

## How?

```ruby
user, pass = find_user_pass
host = find_host
session = <<-TXT
spawn ssh #{host}@#{user}
expect {
"Are you sure you want to continue connecting (yes/no)?" { send "yes\n" }
}
expect {
"#{user}@#{host}'s password: " { send "#{pass}\n" }
}
expect {
"Permission denied, please try again" exit
"Name or service not known" exit
}

interact
wait
exit
TXT

# MAGIC!

$stdin.raw {
  Open3.popen3("expect -") do |i,o,e,t|
    Thread.start { IO.copy_stream(o, $stdout) }
    i << session
    Thread.start { IO.copy_stream($stdin, i) }
    t.value
  end
}

```
