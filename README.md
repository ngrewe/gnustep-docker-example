Containerized Objective-C Web Server Example
============================================

This is a small piece of example code showing how to create a Docker container
running a headless Objective-C application (in this case: a small web server).
This is more an exercise in demonstrating the general concept: Having
deterministically built images with development tools and runtime dependencies
and coordinating them to deploy the compiled artifact with minimal cruft. The
build scripts for the base images are available in the
[gnustep-boxes](https://www.github.com/ngrewe/gnustep-boxes) project.

How it works
------------

1. Invoke the `build_outer.sh` script with any parameters you'd like to pass to
   the final `docker build` command. For example, you may want to pass the
   repository/tag that you want to save the image under (`-t my/useless-thing`).
2. The scripts spins up a `gnustep-headless-dev` container (which has all the
   build tools), shares the repository directory and the host's docker socket
   with it. In this container, the `build_inner.sh` script is then run.
3. `build_inner.sh` installs the dependencies not bundled with the base image,
   as well as the app itself into a staging directory.
4. `docker build` is invoked to build a new image based on the
   `gnustep-headless-rt` runtime image, by just copying the staged dependencies
   into the correct location in the filesystem.
5. Run a container based on that image as usual:
   ```
   docker run --rm -p 8080:8080 my/useless-thing
   ```
6. Point your browser at the docker host's IP at port 8080 and be greeted by ‘Hello World’.


What it does
------------

Honestly? Not much. It just responds to a GET request with a static string. It
demonstrates, however, how to handle requests asynchronously using
libdispatch.



License
--------
Copyright (c) 2016 Niels Grewe

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
