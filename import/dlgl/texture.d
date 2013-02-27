module dlgl.texture;

import derelict.opengl3.gl3;
import dlgl.image;

class Texture
{
	GLuint id;
	GLenum format;  ///
	GLenum type;    ///

	GLsizei width,  ///
			height; ///

	///
	this(Image img)
	{
		glGenTextures(1, &id);
		bind();

		width = img.width; height = img.height;

		//TODO make these parameters more adaptive to the source image
		glTexImage2D(type, 0, format, width, height, 0, GL_RGBA, 
					GL_UNSIGNED_BYTE, img.dataPtr);

		// Depending on how it's to be used, might want GL_LINEAR and some mipmaps
		glTexParameteri(type, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
		glTexParameteri(type, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	}

	void release()
	{
		assert(id != 0);
		glDeleteTextures(1, &id);
		id = 0;
	}

	void bind()
	{
		assert(id != 0);
		glBindTexture(type, id);
	}
}
