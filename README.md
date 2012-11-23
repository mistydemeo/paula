# Paula

Paula is an easy-to-use object-oriented for playing chiptunes. It gives you a single,
simple API to interact with many different chiptune playback libraries.

In its current alpha, Paula includes the following plugins:
* [mdxmini](https://github.com/BouKiCHi/mdxplayer), which supports MDX music from the
X68000 computer.
* [xmp](http://xmp.sourceforge.net/), which supports over 90 classic computer tracker
formats.

## Usage

Create a player object using a file path and an options hash:

```ruby
player = Paula('path/to/file', opts)
```

Supported options:

:frequency - The playback frequency, in Hz. Mandatory. Currently, specifying a
frequency higher than a player's maximum supported frequency raises an exception;
this is temporary, until resampling is implemented.
:loops - The number of times the song should loop before finishing. Defaults to 1.

Generate audio samples using the `#next_sample` method. This moves the song's 
position forward, so you can play back music with a simple loop like:

```ruby
begin
  speakers << player.next_sample
end while not player.complete?
```

As sugar, player is also enumerable, so you can, e.g.:
```ruby
player.each {|s| speakers << s}
```

## FAQ

Q: How do I restart a song?
A: Right now, you should restart a song by recreating the player object. A
`#restart` instance method might be added later, which would just be sugar for
recreating the object manually.

Q: Can I seek to another position?
A: Right now, no. Rewinding isn't supported, because most chiptune players aren't 
capable of rewinding the song. Seeking forward just isn't implemented, though you
can just call `#next_sample` until you reach the point you want.

Eventually I may add a buffer option to render all audio ahead of time, which would
make seeking backwards possible.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Make sure you write tests so you know your code works!
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create new Pull Request
