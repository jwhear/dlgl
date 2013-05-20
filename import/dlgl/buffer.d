module dlgl.buffer;

import derelict.opengl3.gl3;
import dlgl.util;

class VertexArray
{
	GLuint vao;
	alias vao this;

	///
	this()
	{
		gl!"GenVertexArrays"(1, &vao);
	}

	///
	void bind()
	{
		gl!"BindVertexArray"(vao);
	}

	///
	void bind(GLuint loc, GLenum type, int components, int stride, int offset = 0, bool normalize = false)
	{
		bind();
		if (type == GL_INT || type == GL_UNSIGNED_INT)
			gl!"VertexAttribIPointer"(loc, components, type, stride, cast(void*)offset);
		else
			gl!"VertexAttribPointer"(loc, components, type, normalize ? GL_TRUE : GL_FALSE,
								stride, cast(void*)offset);
		gl!"EnableVertexAttribArray"(loc);
	}
}

class Buffer
{
	GLuint buffer;
	alias buffer this;
	size_t length;		/// The number of elements in the buffer
	GLenum target;		///

	///
	this(T = void)(GLenum t)
	{
		target = t;
		gl!"GenBuffers"(1, &buffer);
	}

	///
	this(T)(T[] data, GLenum t)
	{
		this();
		target = t;
		setData(data);
	}

	/**
	 * The `target` parameter specifies which buffer target to bind to,
	 *  e.g. GL_ARRAY_BUFFER or GL_ELEMENT_ARRAY_BUFFER
	 */
	void bind(GLenum t)
	{
		target = t;
		gl!"BindBuffer"(target, buffer);
	}

	///
	void bindArray()
	{
		bind(GL_ARRAY_BUFFER);
	}

	///
	void bindElementArray()
	{
		bind(GL_ELEMENT_ARRAY_BUFFER);
	}

	///
	void bind()
	{
		bind(target);
	}

	///
	void setData(T)(T[] data)
	{
		bind(target);
		gl!"BufferData"(target,
					 T.sizeof * data.length,
					 data.ptr, GL_STATIC_DRAW);
		length = data.length;
	}
}
