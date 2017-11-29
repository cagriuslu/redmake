# redmake

make based build system for small projects with cross-dependencies

## Detail

redmake follows convention-over-configuration principle. It assumes that every redmake project is a library. Optionally, there may be executables that are using the library. redmake projects should have the following directory structure:

```
inc/
src/
tst/
Makefile
```

`inc/` directory should contain C or C++ headers. `src/` and `tst/` may contain C and C++ sources directly underneaht. (Sources in child directories are ignored) C sources should have `c` extension. C++ sources should have `cc` extension. Every source file under `tst/` should have a main function because a separate binary executable is generated using each. Source files under `src/` are linked together while building the library.

While creating a new redmake project, [ProjectMakefile](redmake/ProjectMakefile) should be copied to the newly created project and renamed as Makefile. redmake repository (this repository) should reside at the same level as the other redmake project. For example, if you have a redmake project named 'MyLibrary', your workspace should look like this:

```
MyLibrary/
    inc/
    src/
    tst/
    Makefile/
redmake/
    Makefile
    ProjectMakefile
    ...
```

redmake projects under the same workspace can depend on each other. For example, if you have a project called 'MySolution' which depends on 'MyLibrary', modify the Makefile of 'MySolution' project as such:

```
...
REDMAKE_DEPENDENCIES = MyLibrary
...
```
