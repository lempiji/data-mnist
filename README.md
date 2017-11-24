Download MNIST dataset from [http://yann.lecun.com/exdb/mnist/](http://yann.lecun.com/exdb/mnist/)

# Usage

## Add Setting
Add `postGenerateCommands` in your dub.json.

```json
{
    "postGenerateCommands": [
        "dub fetch data-mnist",
        "dub run data-mnist"
    ]
}
```

After that, if you build, files will be created in `mnist_data`.

## An example of load data

```d
import std.file;
import std.path;

auto trainImages = std.file.read(buildNormalizedPath("mnist_data", "train-images-idx3-ubyte"));
auto trainLabels = std.file.read(buildNormalizedPath("mnist_data", "train-labels-idx3-ubyte"));
auto testImages = std.file.read(buildNormalizedPath("mnist_data", "t10k-images-idx1-ubyte"));
auto testLabels = std.file.read(buildNormalizedPath("mnist_data", "t10k-labels-idx1-ubyte"));
```
