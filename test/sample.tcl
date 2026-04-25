# sample.tcl — smoke test fixture
proc greet {name} {
    return "hello, $name"
}

puts [greet "world"]
