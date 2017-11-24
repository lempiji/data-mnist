import std.file;
import std.getopt;
import std.net.curl;
import std.stdio;

void main(string[] args)
{
	string sourceUrl = "http://yann.lecun.com/exdb/mnist/";
	string dataPath = "mnist_data";
	bool force = false;

	auto getoptInfo = getopt(args, std.getopt.config.passThrough, "force",
			&force, "data", &dataPath, "source", &sourceUrl);

	if (getoptInfo.helpWanted)
	{
		defaultGetoptPrinter(`MNIST data downloader`, getoptInfo.options);
		return;
	}

	if (!exists(dataPath))
		mkdir(dataPath);

	downloadAndGunzip(sourceUrl, dataPath, "train-images-idx3-ubyte.gz", force);
	downloadAndGunzip(sourceUrl, dataPath, "train-labels-idx1-ubyte.gz", force);
	downloadAndGunzip(sourceUrl, dataPath, "t10k-images-idx3-ubyte.gz", force);
	downloadAndGunzip(sourceUrl, dataPath, "t10k-labels-idx1-ubyte.gz", force);
}

void downloadAndGunzip(string rootUrl, string dataPath, string fileName, bool force)
{
	downloadFile(rootUrl, dataPath, fileName, force);
	gunzip(dataPath, fileName, force);
}

void downloadFile(string rootUrl, string dataPath, string fileName, bool force)
{
	import std.file : exists;
	import std.path : buildNormalizedPath;

	auto filePath = buildNormalizedPath(dataPath, fileName);

	if (!force && exists(filePath))
	{
		writeln("skip downloading. ", fileName);
		return;
	}

	auto dataUrl = rootUrl ~ "/" ~ fileName;

	writeln("downloading ", dataUrl);

	try
	{
		download(dataUrl, filePath);
		writeln("downloading success ", fileName);
	}
	catch (Exception e)
	{
		writeln("downloading failure ", fileName);
		writeln(e);
	}
}

void gunzip(string dataPath, string fileName, bool force)
{
	import std.path : buildNormalizedPath, stripExtension;

	auto filePath = buildNormalizedPath(dataPath, fileName);
	auto outputPath = stripExtension(filePath);

	if (!force && exists(outputPath))
	{
		writeln("skip gunzip. ", fileName);
		return;
	}

	import std.algorithm : min;
	import std.array : appender;
	import std.range : put;
	import std.zlib : UnCompress;

	writeln("gunzip ", filePath);
	try
	{
		auto data = std.file.read(filePath);
		auto result = appender!(ubyte[])();
		auto uncompressor = new UnCompress();

		for (uint i = 0; i < data.length; i += 1024)
		{
			put(result, cast(ubyte[]) uncompressor.uncompress(data[i .. min(i + 1024, data.length)]));
		}
		put(result, cast(ubyte[]) uncompressor.flush());

		std.file.write(outputPath, result.data);

		writeln("gunzip success ", filePath);
	}
	catch (Exception e)
	{
		writeln("gunzip failure ", filePath);
		writeln(e);
	}
}
