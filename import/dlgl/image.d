module dlgl.image;

import std.string : toStringz;
import derelict.freeimage.freeimage;

class Image
{
	private FREE_IMAGE_FORMAT format;
	private FIBITMAP* bitmap;

	///
	uint bpp() @property { return FreeImage_GetBPP(bitmap); }
	///
	uint width() @property { return FreeImage_GetWidth(bitmap); }
	///
	uint height() @property { return FreeImage_GetHeight(bitmap); }
	///
	uint widthInBytes() @property { return FreeImage_GetLine(bitmap); }

	// width in bytes aligned on 32bit boundaries (as the pixel data is).
	uint pitch() @property { return FreeImage_GetPitch(bitmap); }

	///
	ubyte* dataPtr() @property
	{
		return FreeImage_GetBits(bitmap);
	}

	///
	this(string filename)
	{
		auto cStr = toStringz(filename);
		format = FreeImage_GetFileType(cStr, 0);
		bitmap = FreeImage_Load(format, cStr, 0);
	}

	//TODO memory loading

	~this()
	{
		FreeImage_Unload(bitmap);
	}
}
