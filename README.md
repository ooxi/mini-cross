# mini-cross

Provides user configured development environments.





## CLI

There two ways of invoking mini-cross

 1. The command invocation
 2. The shell invocation

While technically similar, they provide for different use cases. The first
allows to run individual commands inside the development environment while
remaining attached to the host shell. The second changes the point of view to
the inside of the development environment so that multiple commands can be
executed while attached to the same container.

Therefore the command invocation is more suitable for scripted usage while the
second is crafted toward comfort for interactive use.



### Command invocation

    mini-cross <machine> <command>+

When using mini-cross with command invocation, a *machine* has always to be
specified. The *machine* determines where to look for the mini-cross
configuration and allows for multiple configurations in the same project. The
special machine `_` is the default machine (most useful for shell invocation
though).

This command will start the referenced machine and execute the command using
the default docker entry point (most likely a [bash][1] shell).



### Shell invocation

    mini-cross [<machine>]

Invoking mini-cross without additional commands is referred to as shell
invocation because the development environment will stay attached to the current
shell. Multiple commands may now be executed inside the same container, which
can be quit using the exit command (assuming the container uses a shell like
[bash][1] as docker entry point).

Since the shell invocation does not use arguments, the machine name can be
omited and `_` (the default machine) will be assumed.





[1]: https://www.gnu.org/software/bash/

